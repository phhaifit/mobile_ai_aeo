import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsString } from 'class-validator';

export class CreateServiceCategoryDto {
  @ApiProperty({ description: 'Category name', example: 'Consulting' })
  @IsString()
  @IsNotEmpty()
  name: string;
}
