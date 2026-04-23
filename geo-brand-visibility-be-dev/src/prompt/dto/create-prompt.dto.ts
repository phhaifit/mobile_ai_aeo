import { ApiProperty } from '@nestjs/swagger';
import {
  IsArray,
  IsNotEmpty,
  IsOptional,
  IsString,
  IsUUID,
} from 'class-validator';
import { Database } from '../../supabase/supabase.types';

export class CreatePromptDto {
  @ApiProperty({
    description: 'ID of the topic to which the prompt belongs',
    example: '507f1f77bcf86cd799439011',
  })
  @IsNotEmpty()
  @IsString()
  @IsUUID()
  topicId: string;

  @ApiProperty({
    description: 'The content of the prompt',
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

  @ApiProperty({
    description: 'List of keyword IDs associated with the prompt',
    example: ['uuid1', 'uuid2'],
    required: false,
  })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  @IsUUID(undefined, { each: true })
  keywordIds?: string[];
}
