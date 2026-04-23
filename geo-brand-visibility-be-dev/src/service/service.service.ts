import {
  BadRequestException,
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { ServiceRepository } from './service.repository';
import { BrandRepository } from '../brand/brand.repository';
import { ServiceCategoryService } from '../service-category/service-category.service';
import { CreateServiceDto } from './dto/create-service.dto';
import { UpdateServiceDto } from './dto/update-service.dto';
import {
  ImportServicesResponseDto,
  ServiceResponseDto,
} from './dto/service-response.dto';

@Injectable()
export class ServiceService {
  constructor(
    private readonly serviceRepository: ServiceRepository,
    private readonly brandRepository: BrandRepository,
    private readonly categoryService: ServiceCategoryService,
  ) {}

  async findByBrandId(
    brandId: string,
    userId: string,
  ): Promise<ServiceResponseDto[]> {
    const brand = await this.brandRepository.findById(brandId, userId);
    if (!brand) throw new NotFoundException('Brand not found');
    return this.serviceRepository.findByBrandId(
      brandId,
      userId,
    ) as unknown as Promise<ServiceResponseDto[]>;
  }

  async create(
    brandId: string,
    dto: CreateServiceDto,
    userId: string,
  ): Promise<ServiceResponseDto> {
    const brand = await this.brandRepository.findById(brandId, userId);
    if (!brand) throw new NotFoundException('Brand not found');
    return this.serviceRepository.create({
      brandId,
      ...dto,
    }) as unknown as ServiceResponseDto;
  }

  async update(
    id: string,
    dto: UpdateServiceDto,
    userId: string,
  ): Promise<ServiceResponseDto> {
    if (Object.keys(dto).length === 0)
      throw new BadRequestException('No fields to update');

    const existing = await this.serviceRepository.findById(id, userId);
    if (!existing) throw new NotFoundException('Service not found');

    const updated = await this.serviceRepository.update(id, dto);
    if (!updated) throw new NotFoundException('Service not found');
    return updated as unknown as ServiceResponseDto;
  }

  async delete(id: string, userId: string): Promise<void> {
    const existing = await this.serviceRepository.findById(id, userId);
    if (!existing) throw new NotFoundException('Service not found');
    await this.serviceRepository.delete(id);
  }

  async importFromCsv(
    brandId: string,
    file: Express.Multer.File,
    userId: string,
  ): Promise<ImportServicesResponseDto> {
    const brand = await this.brandRepository.findById(brandId, userId);
    if (!brand) throw new NotFoundException('Brand not found');

    const rows = this.parseCsv(file.buffer.toString('utf-8'));
    if (rows.length === 0) return { created: 0 };

    // Resolve category names to IDs (find or create per unique name)
    const categoryCache = new Map<string, string>();
    for (const row of rows) {
      if (row.category && !categoryCache.has(row.category)) {
        const cat = await this.categoryService.findOrCreate(
          brandId,
          row.category,
        );
        categoryCache.set(row.category, cat.id);
      }
    }

    const items = rows.map((row) => ({
      brandId,
      name: row.name,
      description: row.description || null,
      price: row.price || null,
      categoryId: row.category
        ? (categoryCache.get(row.category) ?? null)
        : null,
    }));

    try {
      const created = await this.serviceRepository.createMany(items);
      return { created: created.length };
    } catch (err) {
      if (err instanceof ConflictException) {
        throw new ConflictException(
          'Some services already exist. Remove duplicates from the file and try again.',
        );
      }
      throw err;
    }
  }

  private parseCsv(content: string): Array<{
    name: string;
    description?: string;
    price?: string;
    category?: string;
  }> {
    const lines = content
      .split(/\r?\n/)
      .map((l) => l.trim())
      .filter(Boolean);
    if (lines.length === 0) return [];

    const headerCols = this.splitCsvLine(lines[0]).map((h) =>
      h.trim().toLowerCase(),
    );
    const hasHeader = headerCols.includes('name');
    const startIndex = hasHeader ? 1 : 0;

    const colIndex = (col: string) => headerCols.indexOf(col);
    const nameIdx = hasHeader ? colIndex('name') : 0;
    const descIdx = hasHeader ? colIndex('description') : 1;
    const priceIdx = hasHeader ? colIndex('price') : -1;
    const categoryIdx = hasHeader ? colIndex('category') : -1;

    const results: Array<{
      name: string;
      description?: string;
      price?: string;
      category?: string;
    }> = [];

    for (let i = startIndex; i < lines.length; i++) {
      const cols = this.splitCsvLine(lines[i]);
      const trimmedName = cols[nameIdx]?.trim();
      if (!trimmedName) continue;
      results.push({
        name: trimmedName,
        description:
          descIdx >= 0 ? cols[descIdx]?.trim() || undefined : undefined,
        price: priceIdx >= 0 ? cols[priceIdx]?.trim() || undefined : undefined,
        category:
          categoryIdx >= 0 ? cols[categoryIdx]?.trim() || undefined : undefined,
      });
    }

    return results;
  }

  private splitCsvLine(line: string): string[] {
    const result: string[] = [];
    let current = '';
    let inQuotes = false;

    for (let i = 0; i < line.length; i++) {
      const char = line[i];
      if (char === '"') {
        if (inQuotes && line[i + 1] === '"') {
          current += '"';
          i++;
        } else inQuotes = !inQuotes;
      } else if (char === ',' && !inQuotes) {
        result.push(current);
        current = '';
      } else {
        current += char;
      }
    }

    result.push(current);
    return result;
  }
}
