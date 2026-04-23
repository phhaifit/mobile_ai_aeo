import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsEnum, IsOptional, IsArray } from 'class-validator';
import { SocialPlatform } from '../enums';

export enum ContentType {
  EMAIL = 'email',
  COPYWRITING = 'copywriting',
  BLOG_POST = 'blog_post',
  SOCIAL_MEDIA_POST = 'social_media_post',
}

export class GenerateContentDto {
  @ApiProperty({
    description: 'Project ID for validation',
    example: '123e4567-e89b-12d3-a456-426614174000',
  })
  @IsString()
  projectId: string;

  @ApiProperty({
    description: 'Type of content to generate',
    enum: ContentType,
    example: ContentType.BLOG_POST,
    required: false,
  })
  @IsEnum(ContentType)
  @IsOptional()
  contentType?: ContentType;

  @ApiProperty({
    description: 'Content profile ID',
    example: 'profile123',
    required: false,
  })
  @IsString()
  @IsOptional()
  contentProfileId?: string;

  @ApiProperty({
    description: 'Keywords for content generation',
    type: [String],
    example: ['AI', 'machine learning'],
    required: false,
  })
  @IsArray()
  @IsString({ each: true })
  @IsOptional()
  keywords?: string[];

  @ApiProperty({
    description: 'Reference page URL for content generation',
    example: 'https://example.com',
    required: false,
  })
  @IsString()
  @IsOptional()
  referencePageUrl?: string;

  @ApiProperty({
    description:
      'Social media platform (required when contentType is social_media_post)',
    enum: SocialPlatform,
    example: SocialPlatform.Facebook,
    required: false,
  })
  @IsEnum(SocialPlatform)
  @IsOptional()
  platform?: SocialPlatform;

  @ApiProperty({
    description:
      'User instruction for how to improve/change the content during regeneration',
    example: 'Make it shorter and more engaging',
    required: false,
  })
  @IsString()
  @IsOptional()
  improvement?: string;

  @ApiProperty({
    description:
      'How the reference page was selected: "search" (from top 10 results) or "custom" (user-entered URL)',
    enum: ['search', 'custom'],
    required: false,
  })
  @IsString()
  @IsOptional()
  referenceType?: 'search' | 'custom';

  @ApiProperty({
    description:
      'Customer persona ID to target content for. Falls back to primary persona if not provided.',
    example: '123e4567-e89b-12d3-a456-426614174000',
    required: false,
  })
  @IsString()
  @IsOptional()
  customerPersonaId?: string;
}
