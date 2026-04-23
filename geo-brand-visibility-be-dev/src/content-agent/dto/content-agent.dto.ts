import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsEnum,
  IsOptional,
  IsString,
  IsBoolean,
  IsInt,
  Min,
  Max,
} from 'class-validator';

export enum AgentType {
  SOCIAL_MEDIA_GENERATOR = 'SOCIAL_MEDIA_GENERATOR',
  BLOG_GENERATOR = 'BLOG_GENERATOR',
}

export class CreateContentAgentDto {
  @ApiProperty({ description: 'Project ID' })
  @IsString()
  projectId: string;

  @ApiProperty({ enum: AgentType, description: 'Type of the agent' })
  @IsEnum(AgentType)
  agentType: AgentType;

  @ApiPropertyOptional({ description: 'Content Profile ID for writing style' })
  @IsOptional()
  @IsString()
  contentProfileId?: string;
}

export class UpdateContentAgentDto {
  @ApiPropertyOptional({ description: 'Enable or disable the agent' })
  @IsOptional()
  @IsBoolean()
  isActive?: boolean;

  @ApiPropertyOptional({ description: 'Content Profile ID for writing style' })
  @IsOptional()
  @IsString()
  contentProfileId?: string;

  @ApiPropertyOptional({
    description: 'Number of posts to generate per day (1-100)',
    minimum: 1,
    maximum: 100,
  })
  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(100)
  postsPerDay?: number;
}

export class ContentAgentDto {
  @ApiProperty()
  id: string;

  @ApiProperty()
  projectId: string;

  @ApiProperty({ enum: AgentType })
  agentType: AgentType;

  @ApiPropertyOptional()
  contentProfileId?: string;

  @ApiProperty()
  isActive: boolean;

  @ApiPropertyOptional()
  lastRunAt?: string;

  @ApiProperty({
    description: 'Number of posts to generate per day',
    default: 1,
  })
  postsPerDay: number;

  @ApiProperty()
  createdAt: string;
}
