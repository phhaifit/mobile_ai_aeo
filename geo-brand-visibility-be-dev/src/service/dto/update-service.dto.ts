import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsOptional, IsString, IsUUID } from 'class-validator';

export class UpdateServiceDto {
  @ApiPropertyOptional({ description: 'Name of the service or product' })
  @IsOptional()
  @IsString()
  name?: string;

  @ApiPropertyOptional({ description: 'Description of the service or product' })
  @IsOptional()
  @IsString()
  description?: string;

  @ApiPropertyOptional({
    description: 'Pricing info (free-form text)',
    example: 'Starting from $500/month',
  })
  @IsOptional()
  @IsString()
  price?: string;

  @ApiPropertyOptional({ description: 'Service category ID' })
  @IsOptional()
  @IsUUID()
  categoryId?: string | null;
}
