import { ApiProperty } from '@nestjs/swagger';
import {
  IsString,
  IsOptional,
  IsArray,
  IsDateString,
  IsUUID,
  IsBoolean,
  IsIn,
  MaxLength,
  ValidateNested,
  Equals,
} from 'class-validator';
import { Type } from 'class-transformer';
import { SocialPostSource } from '../enums';

export class CadenceOverrideAccountDto {
  @ApiProperty()
  @IsString()
  accountId: string;

  @ApiProperty()
  @IsString()
  platform: string;

  @ApiProperty()
  @IsString()
  @MaxLength(500)
  reason: string;
}

export class CadenceOverrideDto {
  @ApiProperty({ description: 'Must be true — user acknowledged risk' })
  @IsBoolean()
  @Equals(true)
  acknowledged: true;

  @ApiProperty({ description: 'ISO 8601 timestamp when user clicked confirm' })
  @IsDateString()
  acknowledgedAt: string;

  @ApiProperty({ enum: ['soft'], description: 'Override severity level' })
  @IsIn(['soft'])
  severity: 'soft';

  @ApiProperty({ type: [CadenceOverrideAccountDto] })
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => CadenceOverrideAccountDto)
  accounts: CadenceOverrideAccountDto[];
}

export class CreateSocialPostDto {
  @ApiProperty({ description: 'Post title', required: false })
  @IsString()
  @IsOptional()
  title?: string;

  @ApiProperty({ description: 'Post message/content' })
  @IsString()
  message: string;

  @ApiProperty({
    description: 'Media URLs (images/videos)',
    type: [String],
    required: false,
  })
  @IsArray()
  @IsString({ each: true })
  @IsOptional()
  mediaUrls?: string[];

  @ApiProperty({ description: 'Link URL to share', required: false })
  @IsString()
  @IsOptional()
  linkUrl?: string;

  @ApiProperty({
    description: 'IDs of social accounts to post to',
    type: [String],
  })
  @IsArray()
  @IsUUID('4', { each: true })
  socialAccountIds: string[];

  @ApiProperty({
    description:
      'Scheduled publish time (ISO 8601). Null = publish immediately',
    required: false,
  })
  @IsDateString()
  @IsOptional()
  scheduledAt?: string;

  @ApiProperty({
    description: 'Optional linked content ID',
    required: false,
  })
  @IsUUID()
  @IsOptional()
  contentId?: string;

  @ApiProperty({ description: 'Additional metadata', required: false })
  @IsOptional()
  metadata?: Record<string, any>;

  @ApiProperty({
    description: 'Cadence override consent when publishing against soft limits',
    required: false,
  })
  @IsOptional()
  @ValidateNested()
  @Type(() => CadenceOverrideDto)
  cadenceOverride?: CadenceOverrideDto;
}

export class SocialPostResponseDto {
  @ApiProperty()
  id: string;

  @ApiProperty({ required: false })
  title?: string;

  @ApiProperty()
  message: string;

  @ApiProperty({ type: [String] })
  mediaUrls: string[];

  @ApiProperty({ required: false })
  linkUrl?: string;

  @ApiProperty({ required: false })
  scheduledAt?: string;

  @ApiProperty({
    required: false,
    enum: SocialPostSource,
    description: 'Post source: manual or auto_publish',
  })
  source?: SocialPostSource;

  @ApiProperty({ required: false })
  contentId?: string;

  @ApiProperty()
  targets: SocialPostTargetResponseDto[];

  @ApiProperty()
  createdAt: string;
}

export class SocialPostTargetResponseDto {
  @ApiProperty()
  id: string;

  @ApiProperty()
  status: string;

  @ApiProperty({ required: false })
  platformPostId?: string;

  @ApiProperty({ required: false })
  platformPostUrl?: string;

  @ApiProperty({ required: false })
  errorMessage?: string;

  @ApiProperty({ required: false })
  publishedAt?: string;

  @ApiProperty()
  account: {
    id: string;
    platform: string;
    accountName: string;
    accountAvatar?: string;
  };
}

// ============================================================
// Rate limit error response DTOs
// ============================================================

export class RateLimitErrorDetailsDto {
  @ApiProperty({ required: false })
  limit?: number;

  @ApiProperty({ required: false })
  current?: number;

  @ApiProperty({ required: false, description: 'ISO 8601 reset time' })
  resetAt?: string;

  @ApiProperty({ required: false, description: 'Seconds until retry' })
  retryAfter?: number;
}

export class RateLimitErrorDto {
  @ApiProperty({ description: 'Error code (e.g. RATE_LIMIT_DAILY_CAP)' })
  code: string;

  @ApiProperty()
  message: string;

  @ApiProperty({ type: RateLimitErrorDetailsDto })
  details: RateLimitErrorDetailsDto;
}

export class PartialFailureResultDto {
  @ApiProperty()
  accountId: string;

  @ApiProperty({ enum: ['created', 'rejected'] })
  status: 'created' | 'rejected';

  @ApiProperty({ required: false })
  postId?: string;

  @ApiProperty({ required: false, type: RateLimitErrorDto })
  error?: RateLimitErrorDto;
}

export class PartialFailureResponseDto {
  @ApiProperty({ enum: ['PARTIAL_FAILURE'] })
  code: 'PARTIAL_FAILURE';

  @ApiProperty({ required: false, type: SocialPostResponseDto })
  post?: SocialPostResponseDto;

  @ApiProperty({ type: [PartialFailureResultDto] })
  results: PartialFailureResultDto[];
}

// ============================================================
// Post stats & scheduled slots DTOs
// ============================================================

export class PostStatsResponseDto {
  @ApiProperty()
  accountId: string;

  @ApiProperty()
  platform: string;

  @ApiProperty({ default: '24h' })
  window: string;

  @ApiProperty()
  publishedCount: number;

  @ApiProperty()
  scheduledCount: number;

  @ApiProperty()
  totalCount: number;

  @ApiProperty()
  dailyLimit: number;

  @ApiProperty()
  remaining: number;

  @ApiProperty()
  minSpacingMinutes: number;

  @ApiProperty({ required: false })
  lastPublishedAt: string | null;

  @ApiProperty({ required: false })
  lastCommitAt: string | null;

  @ApiProperty({ required: false })
  nextAvailableAt: string | null;
}

export class ScheduledSlotDto {
  @ApiProperty()
  targetId: string;

  @ApiProperty()
  postId: string;

  @ApiProperty({ required: false })
  scheduledAt: string | null;

  @ApiProperty()
  status: string;

  @ApiProperty()
  createdAt: string;
}

export class ScheduledSlotsResponseDto {
  @ApiProperty()
  accountId: string;

  @ApiProperty({ type: [ScheduledSlotDto] })
  slots: ScheduledSlotDto[];
}
