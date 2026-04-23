import {
  BadRequestException,
  Injectable,
  Logger,
  NotFoundException,
  UnauthorizedException,
} from '@nestjs/common';
import {
  searchconsole,
  searchconsole_v1,
  auth,
} from '@googleapis/searchconsole';
import { GoogleService } from '../google/google.service';
import {
  GscRepository,
  GoogleOAuthCredential,
  GscProperty,
} from './google-search-console.repository';
import { ConnectGscDto } from './dto/connect-gsc.dto';
import { LinkSiteDto } from './dto/link-site.dto';

const GSC_SCOPE = 'https://www.googleapis.com/auth/webmasters.readonly';

export interface GscSite {
  siteUrl: string;
  permissionLevel: string;
}

export interface GscAnalyticsSummary {
  clicks: number;
  impressions: number;
  ctr: number;
  position: number;
}

export interface GscQueryRow {
  query: string;
  clicks: number;
  impressions: number;
  ctr: number;
  position: number;
}

export interface GscPageRow {
  page: string;
  clicks: number;
  impressions: number;
  ctr: number;
  position: number;
}

export interface GscTrendPoint {
  date: string;
  clicks: number;
  impressions: number;
  ctr: number;
  position: number;
}

@Injectable()
export class GscService {
  private readonly logger = new Logger(GscService.name);

  constructor(
    private readonly googleService: GoogleService,
    private readonly gscRepository: GscRepository,
  ) {}

  // ── OAuth Connection ──

  async handleOAuthCallback(
    userId: string,
    projectId: string,
    dto: ConnectGscDto,
  ): Promise<void> {
    const tokens = await this.googleService.exchangeCodeForTokens(
      dto.code,
      dto.codeVerifier,
      dto.redirectUri,
    );

    this.logger.log(
      `GSC OAuth callback for project ${projectId}, scopes from Google: ${tokens.scopes.join(', ')}`,
    );

    const encryptedRefreshToken = this.googleService.encryptRefreshToken(
      tokens.refreshToken,
    );

    await this.gscRepository.upsertCredential(
      userId,
      projectId,
      encryptedRefreshToken,
      tokens.scopes,
    );
  }

  async getConnectionStatus(projectId: string): Promise<{
    connected: boolean;
    hasGscScope: boolean;
    scopes: string[];
    isValid: boolean;
  }> {
    const credential =
      await this.gscRepository.findCredentialByProjectId(projectId);

    if (!credential) {
      return {
        connected: false,
        hasGscScope: false,
        scopes: [],
        isValid: false,
      };
    }

    const hasGscScope = credential.scopes.includes(GSC_SCOPE);

    return {
      connected: hasGscScope,
      hasGscScope,
      scopes: credential.scopes,
      isValid: credential.isValid,
    };
  }

  async disconnect(projectId: string): Promise<void> {
    await this.gscRepository.deleteProperty(projectId);
    // Only remove GSC scope, preserve GA and other scopes
    await this.gscRepository.removeScopesFromCredential(projectId, [GSC_SCOPE]);
  }

  // ── Site Management ──

  async listSites(projectId: string): Promise<GscSite[]> {
    const client = await this.createSearchConsoleClient(projectId);

    const response = await this.callGoogleApi(projectId, () =>
      client.sites.list(),
    );

    const sites = response.data.siteEntry || [];
    return sites.map((site) => ({
      siteUrl: site.siteUrl || '',
      permissionLevel: site.permissionLevel || '',
    }));
  }

  async linkSite(userId: string, dto: LinkSiteDto): Promise<GscProperty> {
    const existing = await this.gscRepository.findPropertyByProjectId(
      dto.projectId,
    );
    if (existing) {
      throw new BadRequestException(
        'This project already has a linked GSC property. Unlink it first.',
      );
    }

    const sites = await this.listSites(dto.projectId);
    const site = sites.find((s) => s.siteUrl === dto.siteUrl);
    if (!site) {
      throw new NotFoundException(
        'Site not found in your Google Search Console account.',
      );
    }

    return this.gscRepository.createProperty(
      dto.projectId,
      userId,
      dto.siteUrl,
      site.permissionLevel,
    );
  }

  async getLinkedProperty(projectId: string): Promise<GscProperty | null> {
    return this.gscRepository.findPropertyByProjectId(projectId);
  }

  async unlinkSite(userId: string, projectId: string): Promise<void> {
    const property =
      await this.gscRepository.findPropertyByProjectId(projectId);
    if (!property) {
      throw new NotFoundException('No GSC property linked to this project.');
    }
    if (property.userId !== userId) {
      throw new BadRequestException(
        'Only the user who connected GSC can unlink it.',
      );
    }

    await this.gscRepository.deleteProperty(projectId);
  }

  // ── Analytics (Live API Calls) ──

  async getAnalyticsSummary(
    userId: string,
    projectId: string,
    startDate: string,
    endDate: string,
  ): Promise<GscAnalyticsSummary> {
    const { client, property } = await this.getClientForProject(projectId);

    const response = await this.callGoogleApi(projectId, () =>
      client.searchanalytics.query({
        siteUrl: property.siteUrl,
        requestBody: { startDate, endDate },
      }),
    );

    // Without dimensions, GSC returns a single aggregated row
    const row = response.data.rows?.[0];
    if (!row) {
      return { clicks: 0, impressions: 0, ctr: 0, position: 0 };
    }

    return {
      clicks: row.clicks ?? 0,
      impressions: row.impressions ?? 0,
      ctr: row.ctr ?? 0,
      position: row.position ?? 0,
    };
  }

  async getTopQueries(
    userId: string,
    projectId: string,
    startDate: string,
    endDate: string,
    rowLimit: number = 20,
  ): Promise<GscQueryRow[]> {
    const { client, property } = await this.getClientForProject(projectId);

    const response = await this.callGoogleApi(projectId, () =>
      client.searchanalytics.query({
        siteUrl: property.siteUrl,
        requestBody: {
          startDate,
          endDate,
          dimensions: ['query'],
          rowLimit,
        },
      }),
    );

    return (response.data.rows || []).map((row) => ({
      query: row.keys?.[0] || '',
      clicks: row.clicks ?? 0,
      impressions: row.impressions ?? 0,
      ctr: row.ctr ?? 0,
      position: row.position ?? 0,
    }));
  }

  async getTopPages(
    userId: string,
    projectId: string,
    startDate: string,
    endDate: string,
    rowLimit: number = 20,
  ): Promise<GscPageRow[]> {
    const { client, property } = await this.getClientForProject(projectId);

    const response = await this.callGoogleApi(projectId, () =>
      client.searchanalytics.query({
        siteUrl: property.siteUrl,
        requestBody: {
          startDate,
          endDate,
          dimensions: ['page'],
          rowLimit,
        },
      }),
    );

    return (response.data.rows || []).map((row) => ({
      page: row.keys?.[0] || '',
      clicks: row.clicks ?? 0,
      impressions: row.impressions ?? 0,
      ctr: row.ctr ?? 0,
      position: row.position ?? 0,
    }));
  }

  async getDateTrend(
    userId: string,
    projectId: string,
    startDate: string,
    endDate: string,
  ): Promise<GscTrendPoint[]> {
    const { client, property } = await this.getClientForProject(projectId);

    const response = await this.callGoogleApi(projectId, () =>
      client.searchanalytics.query({
        siteUrl: property.siteUrl,
        requestBody: {
          startDate,
          endDate,
          dimensions: ['date'],
          rowLimit: 25000,
        },
      }),
    );

    return (response.data.rows || []).map((row) => ({
      date: row.keys?.[0] || '',
      clicks: row.clicks ?? 0,
      impressions: row.impressions ?? 0,
      ctr: row.ctr ?? 0,
      position: row.position ?? 0,
    }));
  }

  // ── Private Helpers ──

  /**
   * Wraps a Google API call with error handling.
   * On 401/403, marks the credential as invalid so the user is prompted to reconnect.
   */
  private async callGoogleApi<T>(
    credentialProjectId: string,
    apiCall: () => Promise<T>,
  ): Promise<T> {
    try {
      return await apiCall();
    } catch (error: unknown) {
      const status = (error as { response?: { status?: number } })?.response
        ?.status;

      if (status === 401 || status === 403) {
        this.logger.warn(
          `Google API returned ${status} for project ${credentialProjectId}, marking credential as invalid`,
        );
        await this.gscRepository.setCredentialInvalid(credentialProjectId);
        throw new UnauthorizedException(
          'Your Google Search Console access has been revoked. Please reconnect.',
        );
      }

      this.logger.error(
        `Google API error for project ${credentialProjectId}: ${error instanceof Error ? error.message : String(error)}`,
      );
      throw error;
    }
  }

  private async createSearchConsoleClient(
    projectId: string,
  ): Promise<searchconsole_v1.Searchconsole> {
    const credential = await this.getValidCredential(projectId);
    const accessToken = await this.googleService.getAccessTokenFromRefresh(
      credential.encryptedRefreshToken,
    );

    const oauth2Client = new auth.OAuth2();
    oauth2Client.setCredentials({ access_token: accessToken });

    return searchconsole({ version: 'v1', auth: oauth2Client });
  }

  private async getClientForProject(projectId: string): Promise<{
    client: searchconsole_v1.Searchconsole;
    property: GscProperty;
  }> {
    const property =
      await this.gscRepository.findPropertyByProjectId(projectId);
    if (!property) {
      throw new NotFoundException('No GSC property linked to this project.');
    }

    const client = await this.createSearchConsoleClient(projectId);
    return { client, property };
  }

  private async getValidCredential(
    projectId: string,
  ): Promise<GoogleOAuthCredential> {
    const credential =
      await this.gscRepository.findCredentialByProjectId(projectId);

    if (!credential) {
      throw new UnauthorizedException(
        'Google Search Console is not connected. Please connect your account first.',
      );
    }

    if (!credential.isValid) {
      throw new UnauthorizedException(
        'Your Google Search Console connection has expired. Please reconnect.',
      );
    }

    if (!credential.scopes.includes(GSC_SCOPE)) {
      throw new UnauthorizedException(
        'Google Search Console scope not granted. Please connect Google Search Console.',
      );
    }

    return credential;
  }
}
