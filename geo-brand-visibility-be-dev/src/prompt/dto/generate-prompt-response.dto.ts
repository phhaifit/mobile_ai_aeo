import { ApiProperty } from '@nestjs/swagger';
import { type Enums } from '../../supabase/supabase.types';

export class PromptDTO {
  @ApiProperty({
    description:
      'Search intent type (e.g., Informational, Commercial, Transactional, Navigational)',
    example: 'Informational',
  })
  type: Enums<'PromptType'>;

  @ApiProperty({
    description:
      'AI-generated prompt addressing the pain points in user-friendly language',
    example: 'Explain how users can optimize AI content for better visibility.',
  })
  content: string;

  @ApiProperty({
    description: 'List of keywords covered by this prompt',
    example: ['AI content', 'optimization'],
    required: false,
  })
  keywords?: string[];
}

export class TopicDTO {
  @ApiProperty({
    description: 'The topic name',
    example: 'AI content optimization',
  })
  topic: string;

  @ApiProperty({
    description: 'List of prompts related to this topic',
    type: [PromptDTO],
  })
  prompts: PromptDTO[];

  @ApiProperty({
    description: 'List of all keywords for this topic',
    example: ['AI', 'visibility'],
    required: false,
  })
  keywords?: string[];
}

export class GeneratePromptResponseDTO {
  @ApiProperty({
    description: 'List of topics with their prompts',
    type: [TopicDTO],
  })
  data: TopicDTO[];
}
