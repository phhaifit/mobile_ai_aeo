import { ApiProperty } from '@nestjs/swagger';
import { IsEnum, IsNotEmpty, IsString, IsUUID } from 'class-validator';
import {
  INSIGHT_GROUP_VALUES,
  INSIGHT_TYPE_VALUES,
  type InsightGroup,
  type InsightType,
} from '../types/content-insight.types';

export class CreateContentInsightDto {
  @ApiProperty({
    description: 'Content ID that this insight belongs to',
    example: 'uuid-content-123',
  })
  @IsUUID()
  @IsNotEmpty()
  contentId: string;

  @ApiProperty({
    description: 'Insight group category',
    example: 'INTENT',
    enum: INSIGHT_GROUP_VALUES,
  })
  @IsEnum(INSIGHT_GROUP_VALUES)
  @IsNotEmpty()
  insightGroup: InsightGroup;

  @ApiProperty({
    description: 'Type of insight',
    example: 'OBJECTIVE',
    enum: INSIGHT_TYPE_VALUES,
  })
  @IsEnum(INSIGHT_TYPE_VALUES)
  @IsNotEmpty()
  type: InsightType;

  @ApiProperty({
    description: 'Insight content - can be string or array of strings',
    example: 'Help users understand AI concepts',
  })
  @IsNotEmpty()
  content: string | string[];
}
