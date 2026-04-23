import { ApiProperty } from '@nestjs/swagger';
import { IsEnum, IsNotEmpty, IsOptional } from 'class-validator';
import {
  INSIGHT_GROUP_VALUES,
  INSIGHT_TYPE_VALUES,
  type InsightGroup,
  type InsightType,
} from '../types/content-insight.types';

export class UpdateContentInsightDto {
  @ApiProperty({
    description: 'Insight group category',
    example: 'INTENT',
    enum: INSIGHT_GROUP_VALUES,
    required: false,
  })
  @IsEnum(INSIGHT_GROUP_VALUES)
  @IsOptional()
  insightGroup?: InsightGroup;

  @ApiProperty({
    description: 'Type of insight',
    example: 'OBJECTIVE',
    enum: INSIGHT_TYPE_VALUES,
    required: false,
  })
  @IsEnum(INSIGHT_TYPE_VALUES)
  @IsOptional()
  type?: InsightType;

  @ApiProperty({
    description: 'Insight content - can be string or array of strings',
    example: 'Help users understand AI concepts',
    required: false,
  })
  @IsNotEmpty()
  @IsOptional()
  content?: string | string[];
}
