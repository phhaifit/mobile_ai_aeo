import { ApiProperty } from '@nestjs/swagger';
import {
  IsArray,
  IsString,
  ArrayMinSize,
  IsOptional,
  IsIn,
} from 'class-validator';
import {
  CompletionStatus,
  ContentFormat,
  SocialPlatform,
} from 'src/content/enums';
import { ContentType } from './generate-content.dto';
import { ThumbnailDto } from './image-metadata.dto';

class ContentProfileDto {
  @ApiProperty()
  id: string;

  @ApiProperty()
  name: string;

  @ApiProperty()
  voiceAndTone: string;

  @ApiProperty()
  audience: string;

  @ApiProperty()
  description: string | null;
}

class TopicDto {
  @ApiProperty()
  id: string;

  @ApiProperty()
  name: string;

  @ApiProperty()
  projectId: string;
}

class RetrievedPageDto {
  @ApiProperty()
  url: string;

  @ApiProperty({ required: false })
  title?: string;

  @ApiProperty({ required: false })
  snippet?: string;
}

class PromptDto {
  @ApiProperty()
  id: string;

  @ApiProperty()
  content: string;

  @ApiProperty()
  type: string;
}

export class ContentDto {
  @ApiProperty()
  id: string;

  @ApiProperty({ required: false })
  title?: string;

  @ApiProperty({ required: false })
  slug?: string;

  @ApiProperty({
    required: false,
    description: 'Thumbnail image metadata (key + public URL)',
    example: {
      key: 'thumbnails/2026/03/thumb.jpg',
      url: 'https://example.com/thumbnail.jpg',
    },
  })
  thumbnail?: ThumbnailDto;

  @ApiProperty()
  body: string;

  @ApiProperty()
  publishedBody: string | null;

  @ApiProperty({
    enum: CompletionStatus,
  })
  completionStatus: CompletionStatus;

  @ApiProperty({
    enum: ContentFormat,
  })
  contentFormat: ContentFormat;

  @ApiProperty()
  createdAt: string;

  @ApiProperty({
    required: false,
    description: 'Timestamp when content was published',
    example: '2025-01-28T10:00:00Z',
  })
  publishedAt?: string | null;

  @ApiProperty({
    required: false,
    description:
      'Primary image URL selected for this content (og:image or first body image)',
  })
  featuredImageUrl?: string | null;

  @ApiProperty({ type: [String] })
  targetKeywords: string[];

  @ApiProperty({ type: [RetrievedPageDto] })
  retrievedPages: RetrievedPageDto[];

  @ApiProperty({ type: TopicDto })
  topic: TopicDto;

  @ApiProperty({ type: ContentProfileDto })
  profile: ContentProfileDto;

  @ApiProperty()
  prompt: PromptDto;

  @ApiProperty({
    enum: ContentType,
    description: 'Type of content',
    example: ContentType.BLOG_POST,
  })
  contentType: ContentType;

  @ApiProperty({
    enum: SocialPlatform,
    required: false,
    description: 'Social media platform (only for social_media_post)',
  })
  platform?: SocialPlatform | null;
}

class ContentProfileSimpleDto {
  @ApiProperty()
  id: string;

  @ApiProperty()
  name: string;
}

export class ContentListItemDto {
  @ApiProperty()
  id: string;

  @ApiProperty({ required: false })
  title?: string;

  @ApiProperty({ required: false })
  slug?: string;

  @ApiProperty({
    required: false,
    description: 'Thumbnail image metadata (key + public URL)',
    example: {
      key: 'thumbnails/2026/03/thumb.jpg',
      url: 'https://example.com/thumbnail.jpg',
    },
  })
  thumbnail?: ThumbnailDto;

  @ApiProperty()
  body: string;

  @ApiProperty()
  publishedBody: string | null;

  @ApiProperty({
    enum: CompletionStatus,
  })
  completionStatus: CompletionStatus;

  @ApiProperty()
  createdAt: string;

  @ApiProperty({
    required: false,
    description: 'Timestamp when content was published',
  })
  publishedAt?: string | null;

  @ApiProperty({
    required: false,
    description:
      'Primary image URL selected for this content (og:image or first body image)',
  })
  featuredImageUrl?: string | null;

  @ApiProperty({ type: [String] })
  targetKeywords: string[];

  @ApiProperty({ type: [RetrievedPageDto] })
  retrievedPages: RetrievedPageDto[];

  @ApiProperty({ type: TopicDto })
  topic: TopicDto;

  @ApiProperty({ type: ContentProfileSimpleDto })
  profile: ContentProfileSimpleDto;

  @ApiProperty()
  @IsOptional()
  prompt?: {
    id: string;
    content: string;
    type: string;
  };

  @ApiProperty({
    enum: ContentType,
    description: 'Type of content',
    example: ContentType.BLOG_POST,
  })
  contentType: ContentType;

  @ApiProperty({
    enum: SocialPlatform,
    required: false,
    description: 'Social media platform (only for social_media_post)',
  })
  platform?: SocialPlatform | null;
}

// Simpler DTO for topic-scoped content list (used by existing endpoint)
export class ContentTopicListItemDto {
  @ApiProperty()
  id: string;

  @ApiProperty({
    required: false,
    description: 'Thumbnail image metadata (key + public URL)',
    example: {
      key: 'thumbnails/2026/03/thumb.jpg',
      url: 'https://example.com/thumbnail.jpg',
    },
  })
  thumbnail?: ThumbnailDto;

  @ApiProperty()
  body: string;

  @ApiProperty({ required: false, nullable: true })
  publishedBody: string | null;

  @ApiProperty({
    enum: CompletionStatus,
  })
  completionStatus: CompletionStatus;

  @ApiProperty()
  createdAt: string;

  @ApiProperty({ type: TopicDto })
  topic: TopicDto;
}

export class DeleteContentsDto {
  @ApiProperty({
    type: [String],
    description: 'Array of content IDs to delete',
  })
  @IsArray()
  @IsString({ each: true })
  @ArrayMinSize(1)
  ids: string[];
}

export class UpdateContentDto {
  @ApiProperty({
    required: false,
    description: 'Content body in Markdown format',
  })
  @IsString()
  @IsOptional()
  body?: string;

  @ApiProperty({
    required: false,
    description: 'Content title',
  })
  @IsString()
  @IsOptional()
  title?: string;

  @ApiProperty({
    required: false,
    description: 'Content slug',
  })
  @IsString()
  @IsOptional()
  slug?: string;

  @ApiProperty({
    required: false,
    enum: CompletionStatus,
    description: 'Completion status of the content',
  })
  @IsIn(Object.values(CompletionStatus))
  @IsOptional()
  completionStatus?: CompletionStatus;

  @ApiProperty({
    required: false,
    description: 'Thumbnail storage key (object storage path)',
    example: 'thumbnails/2026/03/thumb.jpg',
    nullable: true,
  })
  @IsString()
  @IsOptional()
  thumbnailKey?: string | null;
}
