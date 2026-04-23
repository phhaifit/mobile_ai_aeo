import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsString, IsBoolean, IsOptional } from 'class-validator';

export class TopicDTO {
  @ApiProperty({
    description: 'The unique identifier of the topic',
    example: '123e4567-e89b-12d3-a456-426614174000',
    type: 'string',
  })
  @IsNotEmpty()
  id: string;

  @ApiProperty({
    description: 'The name of the topic',
    example: 'Artificial Intelligence',
    type: 'string',
  })
  @IsNotEmpty()
  @IsString()
  name: string;

  @ApiProperty({
    description: 'Short description of the topic',
    example: 'High-level use cases and common questions about AI products.',
    type: 'string',
    required: false,
  })
  @IsOptional()
  @IsString()
  description?: string | null;

  @ApiProperty({
    description: 'The ID of the project the topic belongs to',
    example: '123e4567-e89b-12d3-a456-426614174000',
    type: 'string',
  })
  @IsNotEmpty()
  projectId: string;

  @ApiProperty({
    description: 'The search volume of the topic',
    example: 1000,
    type: 'number',
  })
  searchVolume: number | null;

  @ApiProperty({
    description: 'Whether this topic is actively being monitored',
    example: true,
    type: Boolean,
  })
  @IsNotEmpty()
  @IsBoolean()
  isMonitored: boolean;

  @ApiProperty({
    description: 'Soft delete flag for the topic',
    example: false,
    type: Boolean,
  })
  @IsNotEmpty()
  @IsBoolean()
  isDeleted: boolean;

  @ApiProperty({
    description: 'The creation date of the topic',
    example: '2023-01-01T00:00:00Z',
    type: 'string',
  })
  @IsNotEmpty()
  createdAt: string;

  @ApiProperty({
    description: 'The last update date of the topic',
    example: '2023-01-01T00:00:00Z',
    type: 'string',
  })
  @IsNotEmpty()
  updatedAt: string;
}
