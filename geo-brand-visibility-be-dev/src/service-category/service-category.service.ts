import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { ServiceCategoryRepository } from './service-category.repository';
import { BrandRepository } from '../brand/brand.repository';
import { CreateServiceCategoryDto } from './dto/create-service-category.dto';
import { UpdateServiceCategoryDto } from './dto/update-service-category.dto';
import { ServiceCategoryResponseDto } from './dto/service-category-response.dto';

@Injectable()
export class ServiceCategoryService {
  constructor(
    private readonly categoryRepository: ServiceCategoryRepository,
    private readonly brandRepository: BrandRepository,
  ) {}

  async findByBrandId(
    brandId: string,
    userId: string,
  ): Promise<ServiceCategoryResponseDto[]> {
    const brand = await this.brandRepository.findById(brandId, userId);
    if (!brand) throw new NotFoundException('Brand not found');
    return this.categoryRepository.findByBrandId(
      brandId,
      userId,
    ) as unknown as Promise<ServiceCategoryResponseDto[]>;
  }

  async create(
    brandId: string,
    dto: CreateServiceCategoryDto,
    userId: string,
  ): Promise<ServiceCategoryResponseDto> {
    const brand = await this.brandRepository.findById(brandId, userId);
    if (!brand) throw new NotFoundException('Brand not found');

    return this.categoryRepository.create({
      brandId,
      name: dto.name,
    }) as unknown as ServiceCategoryResponseDto;
  }

  async findOrCreate(
    brandId: string,
    name: string,
  ): Promise<ServiceCategoryResponseDto> {
    const existing = await this.categoryRepository.findByName(brandId, name);
    if (existing) return existing as unknown as ServiceCategoryResponseDto;
    return this.categoryRepository.create({
      brandId,
      name,
    }) as unknown as ServiceCategoryResponseDto;
  }

  async update(
    id: string,
    dto: UpdateServiceCategoryDto,
    userId: string,
  ): Promise<ServiceCategoryResponseDto> {
    if (!dto.name) throw new BadRequestException('No fields to update');

    const existing = await this.categoryRepository.findById(id, userId);
    if (!existing) throw new NotFoundException('Category not found');

    const updated = await this.categoryRepository.update(id, dto);
    if (!updated) throw new NotFoundException('Category not found');
    return updated as unknown as ServiceCategoryResponseDto;
  }

  async delete(id: string, userId: string): Promise<void> {
    const existing = await this.categoryRepository.findById(id, userId);
    if (!existing) throw new NotFoundException('Category not found');
    await this.categoryRepository.delete(id);
  }
}
