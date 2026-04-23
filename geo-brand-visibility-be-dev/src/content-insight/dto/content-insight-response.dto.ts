import { ApiProperty } from '@nestjs/swagger';
import { IsEnum, IsUUID } from 'class-validator';
import {
  INSIGHT_GROUP_VALUES,
  INSIGHT_TYPE_VALUES,
  type InsightGroup,
  type InsightType,
} from '../types/content-insight.types';

export class ContentInsightDto {
  @ApiProperty({
    description: 'Insight group category',
    example: 'INTENT',
    enum: INSIGHT_GROUP_VALUES,
  })
  @IsEnum(INSIGHT_GROUP_VALUES)
  insightGroup: InsightGroup;

  @ApiProperty({
    description: 'Type of insight',
    example: 'OBJECTIVE',
    enum: INSIGHT_TYPE_VALUES,
  })
  @IsEnum(INSIGHT_TYPE_VALUES)
  type: InsightType;

  @ApiProperty({
    description: 'Insight content - can be string or array of strings',
    example: 'Help users understand AI concepts',
  })
  content: string | string[];
}

export class ContentInsightResponseDto extends ContentInsightDto {
  @ApiProperty({
    description: 'Insight ID',
    example: 'uuid-123',
  })
  @IsUUID()
  id: string;

  @ApiProperty({
    description: 'Content ID',
    example: 'content-uuid-123',
  })
  @IsUUID()
  contentId: string;

  @ApiProperty({
    description: 'Created at timestamp',
    example: '2023-01-01T00:00:00Z',
  })
  createdAt: string;
}
