import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsArray, IsOptional } from 'class-validator';

export class ReferenceSourceDto {
  @ApiProperty({
    description: 'URL of the reference page',
    example: 'https://example.com/ai-trends',
  })
  @IsString()
  url: string;

  @ApiProperty({
    description: 'Title of the page',
    example: 'Top AI Trends 2025',
  })
  @IsString()
  title: string;

  @ApiProperty({
    description: 'Ranking or relevance score',
    example: 95,
  })
  @IsOptional()
  ranking?: number;
}

export class GeneratedContentDto {
  @ApiProperty({
    description: 'Title of the generated content',
    example: 'The Future of Artificial Intelligence',
  })
  @IsString()
  title: string;

  @ApiProperty({
    description: 'Body content of the generated article',
    example: 'Artificial Intelligence is transforming...',
  })
  @IsString()
  body: string;

  @ApiProperty({
    description: 'Type of content generated',
    example: 'blog',
    enum: ['blog', 'copy', 'email'],
  })
  @IsString()
  contentType?: string;

  @ApiProperty({
    description: 'Topic the content is based on',
    example: 'Artificial Intelligence',
  })
  @IsString()
  topic?: string;

  @ApiProperty({
    description: 'Reference sources used in generation',
    type: [ReferenceSourceDto],
    required: false,
  })
  @IsOptional()
  @IsArray()
  referenceSources?: ReferenceSourceDto[];

  @ApiProperty({
    description: 'Keywords incorporated in the content',
    type: [String],
    example: ['AI', 'machine learning'],
    required: false,
  })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  keywords?: string[];
}
