import { ApiProperty } from '@nestjs/swagger';
import {
  IsNotEmpty,
  IsString,
  IsUUID,
  IsArray,
  ValidateNested,
  ArrayMinSize,
  IsOptional,
} from 'class-validator';
import { Type } from 'class-transformer';

export class AddedTopicDTO {
  @ApiProperty({
    description: 'The name of the topic',
    example: 'Artificial Intelligence',
    type: 'string',
  })
  @IsNotEmpty()
  @IsString()
  name: string;

  @ApiProperty({
    description: 'The alias of the topic',
    example: 'Artificial Intelligence',
    type: 'string',
  })
  @IsNotEmpty()
  @IsString()
  alias: string;

  @ApiProperty({
    description: 'Short description of the topic',
    example: 'High-level use cases and common questions about AI products.',
    type: 'string',
    required: false,
  })
  @IsOptional()
  @IsString()
  description?: string;

  //TODO: consider making numOfPrompts optional with a default value
}

export class CreateTopicRequestDTO {
  @ApiProperty({
    description: 'The ID of the project the topic belongs to',
    example: '123e4567-e89b-12d3-a456-426614174000',
    type: 'string',
  })
  @IsNotEmpty()
  @IsUUID()
  projectId: string;

  @ApiProperty({
    description: 'Array of topics to be added',
    example: [
      {
        name: 'Artificial Intelligence',
        alias: 'Artificial Intelligence',
        description: 'High-level use cases and common questions about AI.',
      },
      {
        name: 'Machine Learning',
        alias: 'Machine Learning',
        description: 'Practical ML workflows and evaluation considerations.',
      },
    ],
    type: [AddedTopicDTO],
  })
  @IsNotEmpty()
  @IsArray()
  @ArrayMinSize(1)
  @ValidateNested({ each: true })
  @Type(() => AddedTopicDTO)
  topicData: AddedTopicDTO[];
}
