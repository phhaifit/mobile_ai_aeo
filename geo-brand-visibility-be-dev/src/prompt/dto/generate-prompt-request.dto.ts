import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsArray,
  IsOptional,
  IsString,
  IsUUID,
  ValidateNested,
} from 'class-validator';
import { Type } from 'class-transformer';

export class KeywordInputDTO {
  @ApiPropertyOptional({
    description: 'Topic ID. Preferred over topic name.',
    example: '123e4567-e89b-12d3-a456-426614174000',
  })
  @IsOptional()
  @IsString()
  @IsUUID()
  topicId?: string;

  @ApiPropertyOptional({
    description: 'Topic name (legacy fallback).',
    example: 'Software Development',
  })
  @IsOptional()
  @IsString()
  topicName?: string;

  @ApiProperty()
  @IsArray()
  @IsString({ each: true })
  keywords: string[];
}

export class GeneratePromptRequestDTO {
  @ApiProperty()
  @IsString()
  @IsUUID()
  projectId: string;

  @ApiPropertyOptional({ type: [KeywordInputDTO] })
  @IsOptional()
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => KeywordInputDTO)
  keywords?: KeywordInputDTO[];
}
