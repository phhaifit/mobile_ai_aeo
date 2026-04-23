import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsString } from 'class-validator';
import { Database } from '../../supabase/supabase.types';

export class BasePromptDTO {
  @ApiProperty({
    description: 'The content of the prompt to save',
    example: 'Top 10 software development companies in Ho Chi Minh City',
  })
  @IsNotEmpty()
  @IsString()
  content: string;

  @ApiProperty({
    description: 'The customer journey stage category',
    enum: ['AWARENESS', 'INTEREST', 'CONSIDERATION', 'PURCHASE', 'LOYALTY'],
    example: 'AWARENESS',
  })
  @IsNotEmpty()
  @IsString()
  type: Database['public']['Enums']['PromptType'];
}

export class PromptDTO extends BasePromptDTO {
  @ApiProperty({
    description: 'The ID of the prompt',
    example: 'prompt123',
    type: String,
  })
  id: string;
  @ApiProperty({
    description: 'The topic ID associated with the prompt',
    example: 'topic456',
    type: String,
  })
  topicId: string;

  @ApiProperty({
    description: 'The topic name associated with the prompt',
    example: 'Artificial Intelligence',
    type: String,
  })
  topicName: string;

  @ApiProperty({
    description: 'Indicates if the prompt is deleted',
    example: false,
    type: Boolean,
  })
  isDeleted: boolean;

  @ApiProperty({
    description:
      'Indicates if all available web sources have been used or found irrelevant for content generation',
    example: false,
    type: Boolean,
  })
  isExhausted: boolean;

  @ApiProperty({
    description: 'Indicates if the prompt is monitored',
    example: true,
    type: Boolean,
  })
  isMonitored: boolean;

  @ApiProperty({
    description: 'The last time the prompt was run',
    example: '2023-10-03T12:34:56Z',
    type: String,
    nullable: true,
  })
  lastRun: string | null;

  @ApiProperty({
    description: 'Timestamp when the prompt was created',
    example: '2023-10-01T12:34:56Z',
    type: String,
  })
  createdAt: string;

  @ApiProperty({
    description: 'Timestamp when the prompt was last updated',
    example: '2023-10-02T12:34:56Z',
    type: String,
  })
  updatedAt: string;

  @ApiProperty({
    description: 'List of keywords associated with the prompt',
    example: ['keyword1', 'keyword2'],
    type: [String],
    required: false,
  })
  keywords?: string[];
}
