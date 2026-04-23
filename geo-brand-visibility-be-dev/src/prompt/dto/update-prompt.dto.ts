import { ApiProperty } from '@nestjs/swagger';
import { PromptDTO } from './prompt.dto';
import { IsBoolean, IsOptional, IsString } from 'class-validator';
import { Database } from '../../supabase/supabase.types';

export class UpdatePromptRequestDTO {
  @ApiProperty({
    description: 'Mark the prompt as monitored',
    example: true,
    type: Boolean,
    required: false,
  })
  @IsOptional()
  @IsBoolean()
  isMonitored?: boolean;

  @ApiProperty({
    description: 'Mark the prompt as deleted (soft delete/restore)',
    example: false,
    type: Boolean,
    required: false,
  })
  @IsOptional()
  @IsBoolean()
  isDeleted?: boolean;

  @ApiProperty({
    description: 'Update the prompt content',
    example: 'New prompt content',
    type: String,
    required: false,
  })
  @IsOptional()
  @IsString()
  content?: string;

  @ApiProperty({
    description: 'Update the prompt type',
    example: 'Informational',
    type: String,
    required: false,
  })
  @IsOptional()
  @IsString()
  type?: Database['public']['Enums']['PromptType'];

  @ApiProperty({
    description: 'Update the prompt topic',
    example: 'uuid',
    type: String,
    required: false,
  })
  @IsOptional()
  @IsString()
  topicId?: string;
}

export class UpdatePromptResponseDTO extends PromptDTO {}
