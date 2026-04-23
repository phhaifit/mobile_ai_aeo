import { ApiProperty } from '@nestjs/swagger';
import {
  IsString,
  IsOptional,
  IsBoolean,
  IsArray,
  IsObject,
  IsNotEmptyObject,
  IsIn,
  Matches,
  ValidateNested,
  IsEnum,
} from 'class-validator';
import { Type } from 'class-transformer';
import { ConnectionType, SocialPlatform } from '../enums';

export class SaveSocialAccountDto {
  @ApiProperty({ description: 'Platform account/page ID' })
  @IsString()
  platformAccountId: string;

  @ApiProperty({ description: 'Account/page name' })
  @IsString()
  accountName: string;

  @ApiProperty({ description: 'Account avatar URL', required: false })
  @IsString()
  @IsOptional()
  accountAvatar?: string;

  @ApiProperty({ description: 'Access token for this page/account' })
  @IsString()
  accessToken: string;

  @ApiProperty({ description: 'Additional metadata', required: false })
  @IsOptional()
  metadata?: Record<string, any>;
}

export class SaveSocialAccountsDto {
  @ApiProperty({
    description: 'Platform',
    enum: SocialPlatform,
    example: 'facebook',
  })
  @IsEnum(SocialPlatform)
  platform: SocialPlatform;

  @ApiProperty({
    description: 'List of accounts/pages to save',
    type: [SaveSocialAccountDto],
  })
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => SaveSocialAccountDto)
  accounts: SaveSocialAccountDto[];
}

export class ConnectTokenAccountDto {
  @ApiProperty({
    description: 'Platform',
    enum: SocialPlatform,
    example: 'telegram',
  })
  @IsEnum(SocialPlatform)
  platform: SocialPlatform;

  @ApiProperty({ description: 'Credentials for the platform' })
  @IsObject()
  @IsNotEmptyObject()
  credentials: Record<string, any>;
}

export class ConnectWebhookAccountDto {
  @ApiProperty({
    description: 'Platform',
    enum: SocialPlatform,
    example: 'discord',
  })
  @IsEnum(SocialPlatform)
  platform: SocialPlatform;

  @ApiProperty({ description: 'Account name' })
  @IsString()
  accountName: string;

  @ApiProperty({ description: 'Credentials (webhookUrl, etc.)' })
  @IsObject()
  @IsNotEmptyObject()
  credentials: Record<string, any>;
}

export class AutoPublishScheduleDto {
  @ApiProperty({
    description: 'Schedule type',
    enum: ['immediate', 'peak_hours', 'custom'],
  })
  @IsIn(['immediate', 'peak_hours', 'custom'])
  type: string;

  @ApiProperty({
    description: 'Custom time slots (HH:mm format)',
    required: false,
    example: ['09:00', '18:00'],
  })
  @IsOptional()
  @IsArray()
  @Matches(/^\d{2}:\d{2}$/, { each: true })
  customSlots?: string[];

  @ApiProperty({
    description: 'Custom days of the week',
    required: false,
    example: ['mon', 'wed', 'fri'],
  })
  @IsOptional()
  @IsArray()
  @IsIn(['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'], { each: true })
  customDays?: string[];
}

export class UpdateSocialAccountDto {
  @ApiProperty({
    description: 'Enable auto-publish for this account',
    required: false,
  })
  @IsOptional()
  @IsBoolean()
  autoPublish?: boolean;

  @ApiProperty({
    description: 'Auto-publish schedule configuration',
    required: false,
    type: AutoPublishScheduleDto,
  })
  @IsOptional()
  @ValidateNested()
  @Type(() => AutoPublishScheduleDto)
  autoPublishSchedule?: AutoPublishScheduleDto | null;
}

export class SocialAccountResponseDto {
  @ApiProperty()
  id: string;

  @ApiProperty()
  platform: string;

  @ApiProperty()
  connectionType: string;

  @ApiProperty()
  platformAccountId: string;

  @ApiProperty()
  accountName: string;

  @ApiProperty({ required: false })
  accountAvatar?: string;

  @ApiProperty()
  isActive: boolean;

  @ApiProperty()
  autoPublish: boolean;

  @ApiProperty({ required: false, type: AutoPublishScheduleDto })
  autoPublishSchedule?: AutoPublishScheduleDto | null;

  @ApiProperty({ required: false })
  tokenExpiresAt?: string;

  @ApiProperty({ required: false })
  metadata?: Record<string, any>;

  @ApiProperty({
    required: false,
    description: 'Posts published in the last 24 hours',
  })
  postsPublishedToday?: number;

  @ApiProperty({ required: false, description: 'Last published timestamp' })
  lastPublishedAt?: string | null;

  @ApiProperty({
    required: false,
    description: 'Account paused until this timestamp',
  })
  pausedUntil?: string | null;

  @ApiProperty({
    required: false,
    description: 'Number of consecutive publish errors',
  })
  consecutiveErrorCount?: number;

  @ApiProperty()
  createdAt: string;
}
