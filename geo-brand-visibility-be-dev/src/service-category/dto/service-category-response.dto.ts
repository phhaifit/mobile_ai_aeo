import { ApiProperty } from '@nestjs/swagger';

export class ServiceCategoryResponseDto {
  @ApiProperty() id: string;
  @ApiProperty() brandId: string;
  @ApiProperty() name: string;
  @ApiProperty() createdAt: string;
  @ApiProperty() updatedAt: string;
}
