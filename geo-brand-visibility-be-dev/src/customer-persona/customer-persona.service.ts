import {
  Injectable,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common';
import { v4 as uuidv4 } from 'uuid';
import { CustomerPersonaRepository } from './customer-persona.repository';
import { BrandRepository } from '../brand/brand.repository';
import { AgentService } from '../agent/agent.service';
import { CreateCustomerPersonaDto } from './dto/create-customer-persona.dto';
import { UpdateCustomerPersonaDto } from './dto/update-customer-persona.dto';
import { CustomerPersonaResponseDto } from './dto/customer-persona-response.dto';

@Injectable()
export class CustomerPersonaService {
  constructor(
    private readonly personaRepository: CustomerPersonaRepository,
    private readonly brandRepository: BrandRepository,
    private readonly agentService: AgentService,
  ) {}

  async findByBrandId(
    brandId: string,
    userId: string,
  ): Promise<CustomerPersonaResponseDto[]> {
    const brand = await this.brandRepository.findById(brandId, userId);
    if (!brand) throw new NotFoundException('Brand not found');

    return this.personaRepository.findByBrandId(
      brandId,
      userId,
    ) as unknown as Promise<CustomerPersonaResponseDto[]>;
  }

  async findById(
    id: string,
    userId: string,
  ): Promise<CustomerPersonaResponseDto> {
    const persona = await this.personaRepository.findById(id);
    if (!persona) throw new NotFoundException('Customer persona not found');
    return persona as unknown as CustomerPersonaResponseDto;
  }

  async findPrimaryByBrandId(brandId: string, userId: string) {
    return this.personaRepository.findPrimaryByBrandId(brandId);
  }

  async create(
    brandId: string,
    dto: CreateCustomerPersonaDto,
    userId: string,
  ): Promise<CustomerPersonaResponseDto> {
    const brand = await this.brandRepository.findById(brandId, userId);
    if (!brand) throw new NotFoundException('Brand not found');

    if (dto.isPrimary) {
      await this.personaRepository.clearPrimaryForBrand(brandId);
    }

    return this.personaRepository.create({
      brandId,
      ...dto,
    } as any) as unknown as CustomerPersonaResponseDto;
  }

  async update(
    id: string,
    dto: UpdateCustomerPersonaDto,
    userId: string,
  ): Promise<CustomerPersonaResponseDto> {
    if (Object.keys(dto).length === 0) {
      throw new BadRequestException('No fields to update');
    }

    const existing = await this.personaRepository.findById(id);
    if (!existing) throw new NotFoundException('Customer persona not found');

    if (dto.isPrimary) {
      await this.personaRepository.clearPrimaryForBrand(existing.brandId);
    }

    const updated = await this.personaRepository.update(id, dto as any);
    if (!updated) throw new NotFoundException('Customer persona not found');
    return updated as unknown as CustomerPersonaResponseDto;
  }

  async generatePersonas(
    brandId: string,
    userId: string,
    additionalContext?: string,
  ): Promise<CreateCustomerPersonaDto[]> {
    const brand = await this.brandRepository.findById(brandId, userId);
    if (!brand) throw new NotFoundException('Brand not found');

    const existingPersonas = await this.personaRepository.findByBrandId(
      brandId,
      userId,
    );
    const existingNames = new Set(
      existingPersonas
        .map((persona) => persona.name?.trim().toLowerCase())
        .filter((name): name is string => Boolean(name)),
    );
    const existingSummary =
      existingPersonas.length > 0
        ? existingPersonas
            .map((persona, index) => {
              const professional =
                (persona.professional as Record<string, unknown>) || {};
              const jobTitle =
                (professional.jobTitle as string | undefined) || 'N/A';
              const industry =
                (professional.industry as string | undefined) || 'N/A';
              return `${index + 1}. ${persona.name} — ${jobTitle} (${industry})`;
            })
            .join('\n')
        : 'None';

    const brandInfo = `
    - Brand Name: ${brand.name}
    - Industry: ${brand.industry}
    - Revenue Models: ${(brand as any).revenueModel || 'N/A'}
    - Customer Types: ${(brand as any).customerType || 'N/A'}
    - Products/Services: ${brand.services?.map((s) => `${s.name}: ${s.description}`).join(', ') || 'N/A'}
    - Mission: ${brand.mission}
    - Target Market: ${brand.targetMarket}
    - Description: ${brand.description || 'N/A'}
    - Location: ${(brand as any).location || 'N/A'}
    - Language: ${(brand as any).language || 'N/A'}
    `;

    const buildPrompt = (generationId: string, extra?: string) =>
      `Generate buyer personas using the following brand information:` +
      `\n${brandInfo}` +
      (additionalContext
        ? `\n\nAdditional context from the user:\n${additionalContext}`
        : '') +
      `\n\nExisting personas already saved for this brand (do NOT repeat or closely mimic these):\n${existingSummary}` +
      `\n\nGeneration request id (use as a randomness seed to vary outputs): ${generationId}` +
      (extra ? `\n\n${extra}` : '');

    const attempt1 = await this.agentService.execute<
      CreateCustomerPersonaDto[]
    >(userId, 'persona_generation', buildPrompt(uuidv4()));
    const filtered1 = attempt1.filter((persona) => {
      const name = persona.name?.trim().toLowerCase();
      return !name || !existingNames.has(name);
    });

    if (existingNames.size > 0 && filtered1.length === 0) {
      const attempt2 = await this.agentService.execute<
        CreateCustomerPersonaDto[]
      >(
        userId,
        'persona_generation',
        buildPrompt(
          uuidv4(),
          'IMPORTANT: Create NEW personas that are clearly different from the existing list in name, role, and context.',
        ),
      );
      const filtered2 = attempt2.filter((persona) => {
        const name = persona.name?.trim().toLowerCase();
        return !name || !existingNames.has(name);
      });
      return filtered2.length > 0 ? filtered2 : attempt2;
    }

    return filtered1.length > 0 ? filtered1 : attempt1;
  }

  async delete(id: string, userId: string) {
    const existing = await this.personaRepository.findById(id);
    if (!existing) throw new NotFoundException('Customer persona not found');

    await this.personaRepository.delete(id);
  }
}
