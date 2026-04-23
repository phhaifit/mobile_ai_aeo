import { ApiProperty } from '@nestjs/swagger';
import { IsOptional, IsString } from 'class-validator';
import { PaginationQueryDto } from 'src/shared/dtos/pagination-query.dto';
import { ThumbnailDto } from 'src/content/dto/image-metadata.dto';

export class PublicArticleListItemDto {
  @ApiProperty({ description: 'Unique article identifier' })
  id: string;

  @ApiProperty({
    description: 'Article title extracted from content or topic name',
  })
  title: string;

  @ApiProperty({
    description: 'Brief excerpt (~160 chars for meta description)',
  })
  excerpt: string;

  @ApiProperty({
    description: 'Raw article content in markdown format',
  })
  body: string;

  @ApiProperty({ description: 'Creation date in ISO format' })
  createdAt: string;

  @ApiProperty({
    description: 'Publication date in ISO format',
    required: false,
  })
  publishedAt?: string | null;

  @ApiProperty({ description: 'Topic/category name' })
  topicName: string;

  @ApiProperty({ description: 'Article slug for URL', required: false })
  slug: string;

  @ApiProperty({
    description: 'Thumbnail image (key + public URL)',
    required: false,
  })
  thumbnail?: ThumbnailDto;
}

export class PublicBrandInfoDto {
  @ApiProperty()
  name: string;

  @ApiProperty({ nullable: true })
  industry: string;

  @ApiProperty({ nullable: true })
  description: string;
}

export class PublicArticleListResponseDto {
  @ApiProperty({ type: [PublicArticleListItemDto] })
  articles: PublicArticleListItemDto[];

  @ApiProperty({ type: PublicBrandInfoDto })
  brand: PublicBrandInfoDto;

  @ApiProperty({
    description: 'Cursor for next page, null if no more pages',
    nullable: true,
  })
  nextCursor: string | null;

  @ApiProperty({ description: 'Total number of articles' })
  total: number;
}

export class PublicArticleDetailDto {
  @ApiProperty()
  id: string;

  @ApiProperty()
  title: string;

  @ApiProperty({ description: 'Full article content in HTML format' })
  content: string;

  @ApiProperty()
  createdAt: string;

  @ApiProperty()
  topicName: string;

  @ApiProperty({ type: [String] })
  keywords: string[];

  @ApiProperty({ required: false })
  slug?: string;

  @ApiProperty({
    description: 'Publication date in ISO format',
    required: false,
  })
  publishedAt?: string | null;

  @ApiProperty({
    description: 'Thumbnail image (key + public URL)',
    required: false,
  })
  thumbnail?: ThumbnailDto;
}

export class PublicArticleQueryDto extends PaginationQueryDto {
  @ApiProperty({
    description: 'Topic name',
    required: false,
  })
  @IsOptional()
  @IsString()
  topic?: string;
}

export class PublicTopicLatestArticleDto {
  @ApiProperty({ description: 'Unique article identifier' })
  id: string;

  @ApiProperty({
    description: 'Article title extracted from content or topic name',
  })
  title: string;

  @ApiProperty({
    description: 'Brief excerpt (~160 chars for meta description)',
  })
  excerpt: string;

  @ApiProperty({ description: 'Created date in ISO format' })
  createdAt: string;

  @ApiProperty({ description: 'Published date in ISO format' })
  publishedAt: string;

  @ApiProperty({ description: 'Topic/category name' })
  topicName: string;

  @ApiProperty({ description: 'Article slug for URL', required: false })
  slug: string;

  @ApiProperty({
    description: 'Thumbnail image (key + public URL)',
    required: false,
  })
  thumbnail?: ThumbnailDto;
}

export class PublicAdjacentArticleDto {
  @ApiProperty({ description: 'Article title' })
  title: string;

  @ApiProperty({ description: 'Article slug for URL' })
  slug: string;
}

export class PublicRelatedArticleDto {
  @ApiProperty({ description: 'Article identifier' })
  id: string;

  @ApiProperty({ description: 'Article title' })
  title: string;

  @ApiProperty({ description: 'Article slug for URL' })
  slug: string;

  @ApiProperty({ description: 'Topic/category name' })
  topicName: string;

  @ApiProperty({
    description: 'Thumbnail image (key + public URL)',
    required: false,
  })
  thumbnail?: ThumbnailDto;

  @ApiProperty({
    description: 'Publication date in ISO format',
    required: false,
  })
  publishedAt?: string | null;
}

export class PublicArticleNavigationDto {
  @ApiProperty({
    description: 'Articles linked within the current article body',
    type: [PublicRelatedArticleDto],
  })
  relatedArticles: PublicRelatedArticleDto[];

  @ApiProperty({
    description: 'Previous article in same topic by publish date',
    nullable: true,
    type: PublicAdjacentArticleDto,
  })
  prevArticle: PublicAdjacentArticleDto | null;

  @ApiProperty({
    description: 'Next article in same topic by publish date',
    nullable: true,
    type: PublicAdjacentArticleDto,
  })
  nextArticle: PublicAdjacentArticleDto | null;
}

export class PublicTopicLatestPostsItemDto {
  @ApiProperty({ description: 'Topic id' })
  topicId: string;

  @ApiProperty({ description: 'Topic name' })
  topicName: string;

  @ApiProperty({ description: 'Topic alias', nullable: true })
  topicAlias: string | null;

  @ApiProperty({ type: [PublicTopicLatestArticleDto] })
  articles: PublicTopicLatestArticleDto[];
}
