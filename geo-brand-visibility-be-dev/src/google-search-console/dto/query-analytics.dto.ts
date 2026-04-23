import {
  IsDateString,
  IsNotEmpty,
  IsOptional,
  IsInt,
  Min,
  Max,
} from 'class-validator';
import { Type } from 'class-transformer';
import { ApiProperty } from '@nestjs/swagger';

export class QueryAnalyticsDto {
  @ApiProperty({
    description: 'Start date of the analytics range in YYYY-MM-DD format',
    example: '2024-03-01',
  })
  @IsNotEmpty()
  @IsDateString()
  startDate: string;

  @ApiProperty({
    description: 'End date of the analytics range in YYYY-MM-DD format',
    example: '2024-03-31',
  })
  @IsNotEmpty()
  @IsDateString()
  endDate: string;

  @ApiProperty({
    description: 'Maximum number of rows to return (1–25000). Defaults to 20.',
    example: 20,
    minimum: 1,
    maximum: 25000,
    required: false,
  })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(25000)
  rowLimit?: number;
}
