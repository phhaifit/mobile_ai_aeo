import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsOptional, IsString } from 'class-validator';

export class UpdateServiceCategoryDto {
  @ApiPropertyOptional({ description: 'Category name', example: 'Consulting' })
  @IsOptional()
  @IsString()
  name?: string;
}
