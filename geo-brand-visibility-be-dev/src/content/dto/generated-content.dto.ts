import { ApiProperty } from '@nestjs/swagger';
import { ContentInsightDto } from '../../content-insight/dto/content-insight-response.dto';
import { CompletionStatus, ContentFormat } from 'src/content/enums';
import { ContentType } from './generate-content.dto';
import { ThumbnailDto } from './image-metadata.dto';

export type RetrievedPage = {
  url: string;
  title: string;
  score: number;
};

export class GeneratedContentDto {
  @ApiProperty({
    description: 'Content ID',
    example: 'content123',
  })
  id: string;

  @ApiProperty({
    description: 'Topic ID',
    example: 'topic123',
  })
  topicId: string;

  @ApiProperty({
    description: 'Profile ID',
    example: 'profile123',
  })
  profileId: string;

  @ApiProperty({
    description: 'Prompt ID',
    example: 'prompt123',
    required: false,
  })
  promptId?: string | null;

  @ApiProperty({
    description: 'Target keywords',
    example: ['AI', 'machine learning'],
  })
  targetKeywords: string[];

  @ApiProperty({
    description: 'Retrieved pages',
    example: [{ url: 'https://example.com', title: 'Example' }],
  })
  retrievedPages: Array<{ url: string; title?: string }>;

  @ApiProperty({
    description: 'Content insights',
    type: [ContentInsightDto],
  })
  contentInsight: ContentInsightDto[];

  @ApiProperty({
    description: 'Completion status',
    example: 'COMPLETE',
    enum: CompletionStatus,
  })
  completionStatus: CompletionStatus;

  @ApiProperty({
    description: 'Content type',
    example: ContentType.BLOG_POST,
    enum: ContentType,
  })
  contentType: ContentType;

  @ApiProperty({
    description: 'Content format',
    example: ContentFormat.Markdown,
    enum: ContentFormat,
  })
  contentFormat: ContentFormat;

  @ApiProperty({
    description: 'Content body',
    example: 'Content here',
  })
  body: string;

  @ApiProperty({
    description: 'Content title',
    example: '# Title',
  })
  title: string;

  @ApiProperty({
    description: 'Thumbnail URL',
    example: 'https://example.com/thumbnail.jpg',
    required: false,
  })
  thumbnail?: ThumbnailDto;

  @ApiProperty({
    description: 'Created at',
    example: '2023-01-01T00:00:00Z',
  })
  createdAt: string;
}
