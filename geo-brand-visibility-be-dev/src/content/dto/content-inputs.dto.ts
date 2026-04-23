import { ApiProperty } from '@nestjs/swagger';
import {
  IsString,
  IsArray,
  IsObject,
  ValidateNested,
  IsOptional,
} from 'class-validator';
import { Type } from 'class-transformer';
import { DEFAULT_LANGUAGE, DEFAULT_LOCATION } from 'src/shared/constant';
import { ReferencePageContentDto } from 'src/web-search/dtos/web-search-response.dto';

export class CustomerPersonaInputDto {
  @ApiProperty({
    description: 'Persona name',
    example: 'Marketing Manager Mai',
  })
  @IsString()
  name: string;

  @ApiProperty({ description: 'Persona description', required: false })
  @IsString()
  @IsOptional()
  description?: string;

  @ApiProperty({
    description: 'Demographics (ageRange, gender, location, etc.)',
    required: false,
  })
  @IsObject()
  @IsOptional()
  demographics?: Record<string, string>;

  @ApiProperty({
    description: 'Professional background (jobTitle, industry, etc.)',
    required: false,
  })
  @IsObject()
  @IsOptional()
  professional?: Record<string, string>;

  @ApiProperty({ description: 'Goals and motivations', required: false })
  @IsString()
  @IsOptional()
  goalsAndMotivations?: string;

  @ApiProperty({ description: 'Pain points and challenges', required: false })
  @IsString()
  @IsOptional()
  painPoints?: string;

  @ApiProperty({
    description: 'Content preferences (channels, formats, etc.)',
    required: false,
  })
  @IsObject()
  @IsOptional()
  contentPreferences?: Record<string, unknown>;

  @ApiProperty({
    description: 'Buying behavior (triggers, objections, etc.)',
    required: false,
  })
  @IsObject()
  @IsOptional()
  buyingBehavior?: Record<string, unknown>;
}

class ContentProfileDto {
  @ApiProperty({
    description: 'Content profile ID',
    example: 'profile123',
  })
  @IsString()
  id?: string;

  @ApiProperty({
    description: 'Content profile description',
    example: '',
  })
  @IsString()
  description?: string;

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

class ServiceDto {
  @ApiProperty({
    description: 'Service ID',
    example: 'service123',
  })
  @IsString()
  id: string;

  @ApiProperty({
    description: 'Service name',
    example: 'Cloud Computing',
  })
  @IsString()
  name: string;

  @ApiProperty({
    description: 'Service description',
    example: 'Scalable cloud solutions',
    required: false,
  })
  @IsString()
  description?: string;
}

class BrandIdentityDto {
  @ApiProperty({
    description: 'Brand ID',
    example: 'brand123',
  })
  @IsString()
  id: string;

  @ApiProperty({
    description: 'Brand name',
    example: 'Example Brand',
  })
  @IsString()
  name: string;

  @ApiProperty({
    description: 'Brand description',
    example: 'A leading provider...',
  })
  @IsString()
  description: string;

  @ApiProperty({
    description: 'Brand mission',
    example: 'To revolutionize...',
  })
  @IsString()
  mission: string;

  @ApiProperty({
    description: 'Target market',
    example: 'Global B2B',
  })
  @IsString()
  targetMarket: string;

  @ApiProperty({
    description: 'Industry',
    example: 'Technology',
  })
  @IsString()
  industry: string;

  @ApiProperty({
    description: 'Services offered',
    type: [ServiceDto],
  })
  @IsArray()
  services: ServiceDto[];
}

class PromptDto {
  @ApiProperty({
    description: 'Prompt ID',
    example: 'prompt123',
  })
  @IsString()
  id: string;

  @ApiProperty({
    description: 'Prompt content',
    example: 'Top 10 AI companies',
  })
  @IsString()
  content: string;

  @ApiProperty({
    description: 'Prompt type',
    example: 'AWARENESS',
  })
  @IsString()
  type: string;
}

class TopicDto {
  @ApiProperty({
    description: 'Topic ID',
    example: 'topic123',
  })
  @IsString()
  id: string;
  @ApiProperty({
    description: 'Topic name',
    example: 'Artificial Intelligence',
  })
  @IsString()
  name: string;
}

export class ArticleAngleDto {
  @ApiProperty({ description: 'Proposed article title' })
  @IsString()
  title: string;

  @ApiProperty({ description: 'Unique angle description' })
  @IsString()
  angle: string;

  @ApiProperty({
    description: 'Key differentiators from existing content',
    type: [String],
  })
  @IsArray()
  @IsString({ each: true })
  differentiators: string[];
}

export class ContentInputsDto {
  @ApiProperty({
    description: 'Job ID for tracking async workflow',
    example: 'job123',
    required: false,
  })
  @IsString()
  @IsOptional()
  jobId?: string;

  @ApiProperty({
    description: 'Callback URL for workflow progress updates',
    example: 'https://api.example.com/webhooks/n8n/content-progress',
    required: false,
  })
  @IsString()
  @IsOptional()
  callbackUrl?: string;

  @ApiProperty({
    description: 'Content ID',
    example: 'content123',
  })
  @IsString()
  contentId: string;

  @ApiProperty({
    description: 'Project ID',
    example: 'project123',
  })
  @IsString()
  projectId: string;

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
    type: BrandIdentityDto,
  })
  @IsObject()
  brandIdentity: BrandIdentityDto;

  @ApiProperty({
    description: 'Specific topic for content generation',
    example: 'Artificial Intelligence',
  })
  @IsObject()
  specificTopic: TopicDto;

  @ApiProperty({
    description: 'Prompt for the specific topic',
    type: PromptDto,
  })
  @IsObject()
  prompt: PromptDto;

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

  @ApiProperty({
    description: 'Optional reference page content to guide content generation',
    example: 'This is the content of the reference page...',
    required: false,
  })
  @ValidateNested()
  @Type(() => ReferencePageContentDto)
  referencePageContent?: ReferencePageContentDto;

  @ApiProperty({
    description: 'AI-generated article angle for cannibalization avoidance',
    type: ArticleAngleDto,
    required: false,
  })
  @IsOptional()
  @ValidateNested()
  @Type(() => ArticleAngleDto)
  articleAngle?: ArticleAngleDto;

  @ApiProperty({
    description: 'Optional customer persona to target content for',
    type: CustomerPersonaInputDto,
    required: false,
  })
  @IsObject()
  @IsOptional()
  customerPersona?: CustomerPersonaInputDto;
}
