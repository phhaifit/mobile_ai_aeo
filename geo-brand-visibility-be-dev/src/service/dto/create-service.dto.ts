import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsNotEmpty, IsOptional, IsString, IsUUID } from 'class-validator';

export class CreateServiceDto {
  @ApiProperty({
    description: 'Name of the service or product',
    example: 'Software Development',
  })
  @IsString()
  @IsNotEmpty()
  name: string;

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
  categoryId?: string;
}
