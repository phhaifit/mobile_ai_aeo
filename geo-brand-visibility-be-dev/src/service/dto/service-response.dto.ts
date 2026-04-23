import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { ServiceCategoryResponseDto } from '../../service-category/dto/service-category-response.dto';

export class ServiceResponseDto {
  @ApiProperty() id: string;
  @ApiProperty() brandId: string;
  @ApiProperty() name: string;
  @ApiPropertyOptional() description?: string | null;
  @ApiPropertyOptional() price?: string | null;
  @ApiPropertyOptional() categoryId?: string | null;
  @ApiPropertyOptional({ type: () => ServiceCategoryResponseDto })
  category?: ServiceCategoryResponseDto | null;
  @ApiProperty() createdAt: string;
  @ApiProperty() updatedAt: string;
}

export class ImportServicesResponseDto {
  @ApiProperty({ description: 'Number of services created' })
  created: number;
}
