import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsArray, IsObject } from 'class-validator';
import { DEFAULT_LANGUAGE, DEFAULT_LOCATION } from 'src/shared/constant';

export class ContentProfileDto {
  @ApiProperty({
    description: 'Voice and tone of the content',
    example: 'Professional and friendly',
  })
  @IsString()
  voiceAndTone: string;

  @ApiProperty({
    description: 'Target audience description',
    example: 'Tech-savvy professionals aged 25-45',
  })
  @IsString()
  audience: string;
}

export class ContentInputsDto {
  @ApiProperty({
    description: 'Project language',
    example: DEFAULT_LANGUAGE,
  })
  @IsString()
  language: string;

  @ApiProperty({
    description: 'Project location',
    example: DEFAULT_LOCATION,
  })
  @IsString()
  location: string;

  @ApiProperty({
    description: 'Brand identity information',
    type: Object,
    example: {
      name: 'Example Brand',
      description: 'A leading provider...',
      mission: 'To revolutionize...',
      targetMarket: 'Global B2B',
      industry: 'Technology',
      services: [
        { name: 'Cloud Computing', description: 'Scalable cloud solutions' },
        { name: 'AI Services', description: 'Cutting-edge AI applications' },
      ],
    },
  })
  @IsObject()
  brandIdentity: Record<string, any>;

  @ApiProperty({
    description: 'Specific topic for content generation',
    example: 'Artificial Intelligence',
  })
  @IsString()
  specificTopic: string;

  @ApiProperty({
    description: 'List of prompts for the specific topic',
    type: [Object],
    example: [
      {
        id: 'prompt1',
        content: 'Top 10 AI companies',
        type: 'AWARENESS',
        responses: ['Response 1', 'Response 2'],
      },
    ],
  })
  @IsArray()
  prompts: Array<{
    id: string;
    content: string;
    type: string;
    responses?: string[];
  }>;

  @ApiProperty({
    description: 'Content profile including voice, tone, and audience',
    type: ContentProfileDto,
  })
  @IsObject()
  contentProfile: ContentProfileDto;

  @ApiProperty({
    description: 'List of keywords for the content',
    type: [String],
    example: ['AI', 'machine learning', 'automation'],
  })
  @IsArray()
  @IsString({ each: true })
  keywords: string[];
}
