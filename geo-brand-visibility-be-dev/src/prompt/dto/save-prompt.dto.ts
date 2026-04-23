import { ApiProperty } from '@nestjs/swagger';
import { IsArray, IsString, IsUUID, IsOptional } from 'class-validator';
import { PromptDTO } from './generate-prompt-response.dto';

export class TopicPromptsDTO {
  @ApiProperty({
    description: 'The UUID of the previously saved topic',
    example: '123e4567-e89b-12d3-a456-426614174000',
  })
  @IsString()
  @IsUUID()
  topicId: string;

  @ApiProperty({
    description: 'List of prompts related to this topic',
    type: [PromptDTO],
  })
  @IsArray()
  prompts: PromptDTO[];

  @ApiProperty({
    description: 'List of all keywords for this topic',
    example: ['AI', 'visibility'],
    required: false,
  })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  keywords?: string[];
}

export class SavePromptRequestDto {
  @ApiProperty({
    description: 'ID of the project to which the prompts belong',
    example: '507f1f77bcf86cd799439011',
  })
  @IsString()
  @IsUUID()
  projectId: string;

  @ApiProperty({
    description: 'Array of prompts that the user wants to save',
    type: [TopicPromptsDTO],
  })
  @IsArray()
  data: TopicPromptsDTO[];
}
