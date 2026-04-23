import { IsOptional, IsArray, IsUUID, IsISO8601, IsIn } from 'class-validator';
import { Transform } from 'class-transformer';
import { ApiPropertyOptional } from '@nestjs/swagger';
import type { Enums } from '../../supabase/supabase.types';

export class MetricsFilterDto {
  @ApiPropertyOptional({
    description: 'Filter by start date (ISO format).',
    example: '2023-01-01T00:00:00Z',
    type: String,
  })
  @IsOptional()
  @IsISO8601()
  start: string;

  @ApiPropertyOptional({
    description: 'Filter by end date (ISO format).',
    example: '2023-12-31T23:59:59Z',
    type: String,
  })
  @IsOptional()
  @IsISO8601()
  end: string;

  @ApiPropertyOptional({
    description:
      'Filter by AI model IDs (UUIDs). Comma-separated for multiple values.',
    example:
      '123e4567-e89b-12d3-a456-426614174000,987fcdeb-51a2-43f7-b890-123456789012',
    type: String,
  })
  @IsOptional()
  @IsArray()
  @IsUUID('4', { each: true })
  @Transform(({ value }) => {
    if (typeof value === 'string') {
      return value
        .split(',')
        .map((v: string) => v.trim())
        .filter((v: string) => v);
    }
    return value as string[];
  })
  models?: string[];

  @ApiPropertyOptional({
    description:
      'Filter by prompt types. Comma-separated for multiple values (AWARENESS, INTEREST, CONSIDERATION, PURCHASE, LOYALTY).',
    example: 'AWARENESS,INTEREST',
    type: String,
  })
  @IsOptional()
  @IsArray()
  @Transform(({ value }) => {
    if (typeof value === 'string') {
      return value
        .split(',')
        .map((v: string) => v.trim())
        .filter((v: string) => v);
    }
    return value as Enums<'PromptType'>[];
  })
  promptTypes?: Enums<'PromptType'>[];

  @ApiPropertyOptional({
    description: 'Grouping granularity for time-series data.',
    example: 'month',
    enum: ['day', 'month'],
  })
  @IsOptional()
  @IsIn(['day', 'month'])
  granularity?: 'day' | 'month';
}
