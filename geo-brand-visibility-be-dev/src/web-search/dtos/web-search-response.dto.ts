import { ApiProperty } from '@nestjs/swagger';
import { ImageMetadata } from '../../content/dto/image-metadata.dto';

export class WebSearchResponseDto {
  @ApiProperty()
  title: string;

  @ApiProperty()
  url: string;

  @ApiProperty()
  description: string;

  @ApiProperty({
    required: false,
    description: 'Relevance score from 0 to 100',
  })
  relevanceScore?: number;

  @ApiProperty({
    required: false,
    description: 'Relevance label: HIGH, MEDIUM, or LOW',
  })
  relevanceLabel?: string;
}

export class WebCrawlResponseDto {
  @ApiProperty()
  content: string;

  @ApiProperty()
  url: string;

  @ApiProperty()
  title: string;

  @ApiProperty({ required: false })
  html?: string;
}

export class ReferencePageContentDto extends WebCrawlResponseDto {
  @ApiProperty({
    description: 'Images extracted from the reference page content',
    type: [ImageMetadata],
    required: false,
  })
  images?: ImageMetadata[];

  @ApiProperty({
    description: 'og:image URL from the reference page meta tags',
    required: false,
  })
  ogImage?: string | null;
}
