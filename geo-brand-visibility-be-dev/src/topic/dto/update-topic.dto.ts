import { ApiProperty } from '@nestjs/swagger';
import { IsBoolean, IsOptional, IsString } from 'class-validator';
import { TopicDTO } from './topic.dto';

export class UpdateTopicRequestDTO {
  @ApiProperty({
    description: 'The name of the topic',
    example: 'Machine Learning',
    type: 'string',
    required: false,
  })
  @IsOptional()
  @IsString()
  name?: string;

  @ApiProperty({
    description: 'The alias of the topic',
    example: 'machine-learning',
    type: 'string',
    required: false,
  })
  @IsOptional()
  @IsString()
  alias?: string;

  @ApiProperty({
    description: 'Short description of the topic',
    example: 'High-level use cases and common questions about AI products.',
    type: 'string',
    required: false,
  })
  @IsOptional()
  @IsString()
  description?: string;

  @ApiProperty({
    description: 'Whether this topic is actively being monitored',
    example: true,
    type: Boolean,
    required: false,
  })
  @IsOptional()
  @IsBoolean()
  isMonitored?: boolean;
}

export class UpdateTopicResponseDTO extends TopicDTO {}
