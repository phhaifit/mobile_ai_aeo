import {
  BadRequestException,
  Injectable,
  Logger,
  NotFoundException,
  Inject,
  ConflictException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { BrandRepository } from './brand.repository';
import { BrandProfileResponseDto } from './dto/brand-profile-response.dto';
import { UpdateBrandRequestDTO } from './dto/update-brand-request.dto';
import { AgentService } from '../agent/agent.service';
import { AGENTS, SUPABASE } from '../utils/const';
import { ProjectService } from '../project/project.service';
import {
  CloudflareService,
  CloudflareHostnameStatusResponse,
} from '../cloudflare/cloudflare.service';
import { DomainStatusResponseDto } from './dto/domain-status-response.dto';
import { SupabaseClient } from '@supabase/supabase-js';
import { Database } from '../supabase/supabase.types';
import { DEFAULT_LOCATION } from 'src/shared/constant';

@Injectable()
export class BrandService {
  private readonly logger = new Logger(BrandService.name);
  private readonly allowedLogoTypes = new Map<string, string>([
    ['image/png', 'png'],
    ['image/jpeg', 'jpg'],
    ['image/webp', 'webp'],
  ]);

  constructor(
    private readonly brandRepository: BrandRepository,
    private readonly agentService: AgentService,
    private readonly projectService: ProjectService,
    private readonly cloudflareService: CloudflareService,
    @Inject(SUPABASE) private readonly supabase: SupabaseClient<Database>,
    private readonly configService: ConfigService,
  ) {}

  async createBrand({
    projectId,
    domain,
    projectName,
    language,
    location,
    userId,
  }: {
    projectId: string;
    domain: string;
    projectName: string;
    language: string;
    location: string;
    userId: string;
  }): Promise<BrandProfileResponseDto> {
    await this.projectService.updateProject(projectId, {
      language,
      location,
      name: projectName,
    });

    const brand = await this.agentService.execute<BrandProfileResponseDto>(
      userId,
      AGENTS.BRAND_CONTEXT_INITIALIZATION,
      `Init brand context for project using given information:\n` +
        `- Project ID: "${projectId}"\n` +
        `- Domain: "${domain}"\n` +
        `- Language: "${language}"\n` +
        `- Location: "${location.length ? location : DEFAULT_LOCATION}".`,
      { domain },
    );

    // Extract header/footer HTML in the background (fire-and-forget)
    this.extractHeaderFooterInBackground(userId, brand.id, domain);

    return brand;
  }

  private extractHeaderFooterInBackground(
    userId: string,
    brandId: string,
    domain: string,
  ): void {
    this.agentService
      .execute(
        userId,
        AGENTS.BRAND_HTML_EXTRACTION,
        `Extract header and footer HTML from domain "${domain}" for brand "${brandId}".`,
        { domain, brandId },
      )
      .then(() => {
        this.logger.log(
          `Background header/footer extraction completed for brand ${brandId}`,
        );
      })
      .catch((error) => {
        this.logger.error(
          `Background header/footer extraction failed for brand ${brandId}: ${error.message}`,
          error.stack,
        );
      });
  }

  async findBrandById(
    id: string,
    userId: string,
  ): Promise<BrandProfileResponseDto> {
    const brand = await this.brandRepository.findById(id, userId);

    if (!brand) {
      throw new NotFoundException(`Brand ${id} not found`);
    }

    return brand;
  }

  async updateBrand(
    id: string,
    data: UpdateBrandRequestDTO,
    userId: string,
  ): Promise<BrandProfileResponseDto> {
    const brand = await this.findBrandById(id, userId);

    if (!brand) {
      throw new NotFoundException(`Brand ${id} not found`);
    }

    if (data.customDomain) {
      // Check if domain is already in use by another brand
      const existingBrand = await this.brandRepository.findByCustomDomain(
        data.customDomain,
      );
      if (existingBrand && existingBrand.id !== id) {
        throw new ConflictException(
          `Domain ${data.customDomain} is already in use by another brand`,
        );
      }
    }

    // Handle Cloudflare custom hostname based on domain config changes
    const cloudflareHostnameId = await this.handleCloudflareCustomHostname(
      brand,
      data,
    );

    // Include cloudflareHostnameId in the update if it changed
    const updateData = {
      ...data,
      cloudflareHostnameId,
    };

    return this.brandRepository.updateById(id, updateData);
  }

  async getDomainStatus(
    id: string,
    userId: string,
  ): Promise<DomainStatusResponseDto> {
    const brand = await this.findBrandById(id, userId);

    if (!brand.customDomain) {
      return { status: null, error: null };
    }

    // CNAME mode with Cloudflare hostname — query Cloudflare API
    if (brand.domainConfigMethod === 'cname' && brand.cloudflareHostnameId) {
      return this.checkCnameDomainStatus(brand.cloudflareHostnameId);
    }

    // Rewrite mode, or CNAME without cloudflareHostnameId — HTTP health check
    if (brand.customDomain && brand.slug) {
      return this.checkRewriteDomainStatus(brand.customDomain, brand.slug);
    }

    return { status: 'pending', error: null };
  }

  private mapCloudflareStatus(
    cfResponse: CloudflareHostnameStatusResponse,
  ): DomainStatusResponseDto {
    if (!cfResponse.success || !cfResponse.result) {
      const errorMsg =
        cfResponse.errors?.[0]?.message || 'Failed to check domain status';
      return { status: 'failed', error: errorMsg };
    }

    const { status, ssl } = cfResponse.result;

    if (status === 'active' && ssl?.status === 'active') {
      return { status: 'verified', error: null };
    }

    if (status === 'active' && ssl?.status !== 'active') {
      return {
        status: 'pending',
        error: 'SSL certificate is being provisioned. This usually takes a few minutes.',
      };
    }

    if (status === 'pending') {
      return { status: 'pending', error: null };
    }

    if (status === 'moved' || status === 'deleted') {
      return {
        status: 'misconfigured',
        error: 'Domain no longer points to the proxy. Please check your DNS settings.',
      };
    }

    return { status: 'failed', error: `Unexpected status: ${status}` };
  }

  private async checkCnameDomainStatus(
    cloudflareHostnameId: string,
  ): Promise<DomainStatusResponseDto> {
    const cfResponse =
      await this.cloudflareService.getCustomHostnameStatus(
        cloudflareHostnameId,
      );
    return this.mapCloudflareStatus(cfResponse);
  }

  private async checkRewriteDomainStatus(
    customDomain: string,
    _brandSlug: string,
  ): Promise<DomainStatusResponseDto> {
    try {
      const controller = new AbortController();
      const timeout = setTimeout(() => controller.abort(), 5000);

      const response = await fetch(`https://${customDomain}/`, {
        method: 'HEAD',
        signal: controller.signal,
        redirect: 'manual',
      });

      clearTimeout(timeout);

      // Any response (2xx, 3xx redirect) means domain is serving traffic
      if (response.status < 500) {
        return { status: 'verified', error: null };
      }

      return {
        status: 'misconfigured',
        error: `Domain returned HTTP ${response.status}. Ensure your proxy forwards to the correct origin.`,
      };
    } catch (error) {
      const message =
        error instanceof Error && error.name === 'AbortError'
          ? 'Domain did not respond within 5 seconds. Check that your proxy is running.'
          : 'Domain is not reachable. Ensure your proxy is configured and running.';
      return { status: 'misconfigured', error: message };
    }
  }

  private async handleCloudflareCustomHostname(
    existingBrand: BrandProfileResponseDto,
    updateData: UpdateBrandRequestDTO,
  ): Promise<string | null | undefined> {
    const prevDomain = existingBrand.customDomain;
    const prevMethod = existingBrand.domainConfigMethod;
    const prevHostnameId = existingBrand.cloudflareHostnameId;

    const newDomain =
      'customDomain' in updateData ? updateData.customDomain : prevDomain;
    const newMethod =
      'domainConfigMethod' in updateData
        ? updateData.domainConfigMethod
        : prevMethod;

    // Early return if no CNAME involved at all
    if (prevMethod !== 'cname' && newMethod !== 'cname') {
      return undefined;
    }

    const action = this.determineCloudflareAction(
      prevMethod,
      newMethod,
      prevDomain,
      newDomain,
      prevHostnameId,
    );

    return this.executeCloudflareAction(
      action,
      prevHostnameId,
      prevDomain,
      newDomain,
    );
  }

  private determineCloudflareAction(
    prevMethod: string | null | undefined,
    newMethod: string | null | undefined,
    prevDomain: string | null | undefined,
    newDomain: string | null | undefined,
    prevHostnameId: string | null | undefined,
  ): 'DELETE' | 'CREATE' | 'REPLACE' | 'NONE' {
    const wasCname = prevMethod === 'cname' && !!prevDomain;
    const willBeCname = newMethod === 'cname' && !!newDomain;
    const domainChanged = newDomain !== prevDomain;

    // DELETE: Had CNAME but no longer (removed or method changed)
    if (wasCname && !willBeCname && prevHostnameId) {
      return 'DELETE';
    }

    // CREATE: Will have CNAME but didn't before
    if (willBeCname && !prevHostnameId) {
      return 'CREATE';
    }

    // REPLACE: CNAME domain changed
    if (wasCname && willBeCname && domainChanged && prevHostnameId) {
      return 'REPLACE';
    }

    return 'NONE';
  }

  private async executeCloudflareAction(
    action: 'DELETE' | 'CREATE' | 'REPLACE' | 'NONE',
    prevHostnameId: string | null | undefined,
    prevDomain: string | null | undefined,
    newDomain: string | null | undefined,
  ): Promise<string | null | undefined> {
    switch (action) {
      case 'DELETE':
        this.logger.log(
          `Deleting Cloudflare custom hostname: ${prevHostnameId}`,
        );
        await this.cloudflareService.deleteCustomHostname(prevHostnameId!);
        return null;

      case 'CREATE':
        this.logger.log(`Creating Cloudflare custom hostname: ${newDomain}`);
        return this.createCloudflareHostname(newDomain!);

      case 'REPLACE':
        this.logger.log(
          `Replacing Cloudflare custom hostname: ${prevDomain} -> ${newDomain}`,
        );
        return this.replaceCloudflareHostname(prevHostnameId!, newDomain!);

      case 'NONE':
      default:
        return undefined;
    }
  }

  private async createCloudflareHostname(
    domain: string,
  ): Promise<string | undefined> {
    const result = await this.cloudflareService.createCustomHostname(domain);

    if (result.success && result.result?.id) {
      return result.result.id;
    }

    this.logger.error(
      `Failed to create Cloudflare custom hostname for ${domain}: ${JSON.stringify(result.errors)}`,
    );
    return undefined;
  }

  private async replaceCloudflareHostname(
    oldHostnameId: string,
    newDomain: string,
  ): Promise<string | null | undefined> {
    // CREATE first to avoid data loss
    const newHostnameId = await this.createCloudflareHostname(newDomain);

    if (!newHostnameId) {
      this.logger.warn(
        `Failed to create new hostname, keeping old hostname: ${oldHostnameId}`,
      );
      return undefined; // Keep old hostname on failure
    }

    // DELETE old only after successful CREATE
    try {
      await this.cloudflareService.deleteCustomHostname(oldHostnameId);
    } catch (error) {
      this.logger.error(
        `Failed to delete old hostname ${oldHostnameId}, but new hostname ${newHostnameId} created successfully`,
        error,
      );
    }

    return newHostnameId;
  }

  async findBrandByProjectId(id: string): Promise<BrandProfileResponseDto> {
    const brand = await this.brandRepository.findByProjectId(id);

    if (!brand) {
      throw new NotFoundException('Brand not found');
    }

    return brand;
  }

  async uploadLogo(
    id: string,
    file: Express.Multer.File | undefined,
    userId: string,
  ): Promise<BrandProfileResponseDto> {
    if (!file) {
      throw new BadRequestException('Logo file is required');
    }

    const extension = this.determineFileExtension(file);
    if (!extension) {
      throw new BadRequestException(
        'Invalid file type. Only PNG, JPG, and WEBP are allowed.',
      );
    }

    const existingBrand = await this.findBrandById(id, userId);

    const path = `brands/${id}/brand-image.${extension}`;
    if (existingBrand.logoUrl) {
      const oldPath = this.extractStoragePath(existingBrand.logoUrl);
      if (oldPath) {
        const { error } = await this.supabase.storage
          .from('images')
          .remove([oldPath]);
        if (error) {
          this.logger.warn(
            `Failed to remove old brand logo from storage: ${error.message}`,
          );
        }
      }
    }

    const { error: uploadError } = await this.supabase.storage
      .from('images')
      .upload(path, file.buffer, {
        contentType: file.mimetype,
        upsert: true,
        cacheControl: '3600',
      });

    if (uploadError) {
      this.logger.error(
        `Failed to upload brand logo: ${uploadError.message} (statusCode: ${String('statusCode' in uploadError ? uploadError.statusCode : 'unknown')})`,
      );
      throw new BadRequestException('Failed to upload brand logo');
    }

    const { data } = this.supabase.storage.from('images').getPublicUrl(path);
    const logoUrl = data.publicUrl;

    const updatedBrand = await this.brandRepository.updateById(id, { logoUrl });

    // Trigger cache revalidation for blog pages
    await this.revalidateBlogCache(existingBrand.slug);

    return updatedBrand;
  }

  async uploadDefaultArticleImage(
    id: string,
    file: Express.Multer.File | undefined,
    userId: string,
  ): Promise<BrandProfileResponseDto> {
    if (!file) {
      throw new BadRequestException('Article image file is required');
    }

    const extension = this.determineFileExtension(file);
    if (!extension) {
      throw new BadRequestException(
        'Invalid file type. Only PNG, JPG, and WEBP are allowed.',
      );
    }

    const existingBrand = await this.findBrandById(id, userId);

    const path = `brands/${id}/default-article-image.${extension}`;
    if (existingBrand.defaultArticleImageUrl) {
      const oldPath = this.extractStoragePath(
        existingBrand.defaultArticleImageUrl,
      );
      if (oldPath) {
        const { error } = await this.supabase.storage
          .from('images')
          .remove([oldPath]);
        if (error) {
          this.logger.warn(
            `Failed to remove old default article image from storage: ${error.message}`,
          );
        }
      }
    }

    const { error: uploadError } = await this.supabase.storage
      .from('images')
      .upload(path, file.buffer, {
        contentType: file.mimetype,
        upsert: true,
        cacheControl: '3600',
      });

    if (uploadError) {
      this.logger.error('Failed to upload default article image', uploadError);
      throw new BadRequestException('Failed to upload default article image');
    }

    const { data } = this.supabase.storage.from('images').getPublicUrl(path);
    const defaultArticleImageUrl = data.publicUrl;

    const { data: updatedBrand, error } = await this.supabase
      .from('Brand')
      .update({ defaultArticleImageUrl } as any)
      .eq('id', id)
      .select('*')
      .single();

    if (error) {
      this.logger.error(
        'Failed to update default article image in database',
        error,
      );
      throw new BadRequestException('Failed to update default article image');
    }

    // Fetch services separately
    const { data: services } = await this.supabase
      .from('Service')
      .select('id, name, description')
      .eq('brandId', id);

    // Trigger cache revalidation for blog pages
    await this.revalidateBlogCache(existingBrand.slug);

    return {
      ...updatedBrand,
      services: services || [],
    } as BrandProfileResponseDto;
  }

  async removeLogo(
    id: string,
    userId: string,
  ): Promise<BrandProfileResponseDto> {
    const brand = await this.findBrandById(id, userId);

    if (brand.logoUrl) {
      const path = this.extractStoragePath(brand.logoUrl);
      if (path) {
        const { error } = await this.supabase.storage
          .from('images')
          .remove([path]);
        if (error) {
          this.logger.warn(
            `Failed to remove brand logo from storage: ${error.message}`,
          );
        }
      }
    }

    return this.brandRepository.updateById(id, { logoUrl: null });
  }

  async removeDefaultArticleImage(
    id: string,
    userId: string,
  ): Promise<BrandProfileResponseDto> {
    const brand = await this.findBrandById(id, userId);

    if (brand.defaultArticleImageUrl) {
      const path = this.extractStoragePath(brand.defaultArticleImageUrl);
      if (path) {
        const { error } = await this.supabase.storage
          .from('images')
          .remove([path]);
        if (error) {
          this.logger.warn(
            `Failed to remove default article image from storage: ${error.message}`,
          );
        }
      }
    }

    const { data: updatedBrand, error } = await this.supabase
      .from('Brand')
      .update({ defaultArticleImageUrl: null } as any)
      .eq('id', id)
      .select('*')
      .single();

    if (error) {
      this.logger.error(
        'Failed to remove default article image from database',
        error,
      );
      throw new BadRequestException('Failed to remove default article image');
    }

    // Fetch services separately
    const { data: services } = await this.supabase
      .from('Service')
      .select('id, name, description')
      .eq('brandId', id);

    // Trigger cache revalidation for blog pages
    await this.revalidateBlogCache(brand.slug);

    return {
      ...updatedBrand,
      services: services || [],
    } as BrandProfileResponseDto;
  }

  private determineFileExtension(
    file: Express.Multer.File,
  ): string | undefined {
    // 1. Try to get extension from original filename
    if (file.originalname) {
      const parts = file.originalname.split('.');
      if (parts.length > 1) {
        const ext = parts.pop()?.toLowerCase();
        if (ext) {
          if (ext === 'jpg' || ext === 'jpeg') return 'jpg';
          if (ext === 'png') return 'png';
          if (ext === 'webp') return 'webp';
        }
      }
    }

    // 2. Fallback to mimetype
    return this.allowedLogoTypes.get(file.mimetype);
  }

  private extractStoragePath(url: string): string | null {
    try {
      const parsed = new URL(url);
      const marker = '/storage/v1/object/public/images/';
      const index = parsed.pathname.indexOf(marker);
      if (index === -1) return null;
      return parsed.pathname.slice(index + marker.length);
    } catch {
      return null;
    }
  }

  private async revalidateBlogCache(brandSlug: string | null): Promise<void> {
    if (!brandSlug) return;

    const frontendUrl = this.configService.get<string>('FRONTEND_URL');
    const revalidationSecret = this.configService.get<string>(
      'REVALIDATION_SECRET',
    );

    if (!frontendUrl || !revalidationSecret) {
      this.logger.warn(
        'FRONTEND_URL or REVALIDATION_SECRET not configured, skipping cache revalidation',
      );
      return;
    }

    try {
      const response = await fetch(`${frontendUrl}/api/revalidate`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          path: `/${brandSlug}/blog`,
          secret: revalidationSecret,
        }),
      });

      if (!response.ok) {
        this.logger.warn(`Failed to revalidate cache: ${response.statusText}`);
      } else {
        this.logger.log(
          `Successfully revalidated cache for /${brandSlug}/blog`,
        );
      }
    } catch (error) {
      this.logger.error('Error triggering cache revalidation', error);
    }
  }
}
