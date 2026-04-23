import { ApiProperty } from '@nestjs/swagger';

export class ContentProfileResponseDto {
  @ApiProperty({
    description: 'Unique content profile identifier',
    example: '123e4567-e89b-12d3-a456-426614174000',
  })
  id: string;

  @ApiProperty({
    description: 'Project ID this content profile belongs to',
    example: '123e4567-e89b-12d3-a456-426614174000',
  })
  projectId: string;

  @ApiProperty({
    description: 'Name of the content profile',
    example: 'Blog Posts',
  })
  name: string;

  @ApiProperty({
    description: 'Description of the content profile',
    example: 'Content profile for blog posts and articles',
    required: false,
  })
  description?: string | null;

  @ApiProperty({
    description: 'Voice and tone guidelines for this content profile',
    example: 'Professional yet friendly, informative and engaging',
  })
  voiceAndTone: string;

  @ApiProperty({
    description: 'Target audience for this content profile',
    example: 'Tech-savvy professionals aged 25-45',
  })
  audience: string;
}
