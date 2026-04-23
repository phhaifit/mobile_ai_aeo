import { ApiProperty } from '@nestjs/swagger';
import { Transform, Type } from 'class-transformer';
import {
  IsArray,
  IsBoolean,
  IsIn,
  IsInt,
  IsOptional,
  IsString,
  Min,
} from 'class-validator';
import { Database } from '../../supabase/supabase.types';

export class GetPromptsByTopicQueryDto {
  @ApiProperty({
    description: 'The topic ID',
    type: String,
  })
  @IsString()
  topicId: string;

  @ApiProperty({
    description: 'Filter by status: active, suggested, or inactive',
    required: false,
    enum: ['active', 'suggested', 'inactive'],
  })
  @IsOptional()
  @IsIn(['active', 'suggested', 'inactive'])
  status?: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  page?: number;

  @ApiProperty({ required: false })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  pageSize?: number;

  @ApiProperty({
    description: 'Search prompts by content (case-insensitive, partial match)',
    required: false,
    type: String,
  })
  @IsOptional()
  @IsString()
  search?: string;

  @ApiProperty({
    description: 'Filter by prompt type',
    required: false,
    isArray: true,
    enum: ['Informational', 'Commercial', 'Transactional', 'Navigational'],
  })
  @IsOptional()
  @Transform(({ value }) => {
    if (value === undefined || value === null || value === '') return undefined;
    if (Array.isArray(value)) return value;
    if (typeof value === 'string') {
      return value
        .split(',')
        .map((v) => v.trim())
        .filter((v) => v.length > 0);
    }
    return value;
  })
  @IsArray()
  @IsIn(['Informational', 'Commercial', 'Transactional', 'Navigational'], {
    each: true,
  })
  type?: Database['public']['Enums']['PromptType'][];

  @ApiProperty({
    description: 'Filter by isMonitored',
    required: false,
    type: Boolean,
    example: true,
  })
  @IsOptional()
  @Transform(({ value }) => {
    if (value === undefined || value === null || value === '') return undefined;
    if (typeof value === 'boolean') return value;
    if (typeof value === 'string') {
      const normalized = value.trim().toLowerCase();
      if (normalized === 'true' || normalized === '1') return true;
      if (normalized === 'false' || normalized === '0') return false;
    }
    return value;
  })
  @IsBoolean()
  isMonitored?: boolean;
}
