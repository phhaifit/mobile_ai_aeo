import { ApiProperty } from '@nestjs/swagger';

export class ContentProfileTemplateDto {
  @ApiProperty({
    description: 'Unique template identifier',
    example: '123e4567-e89b-12d3-a456-426614174000',
  })
  id: string;

  @ApiProperty({
    description: 'Template language (project language)',
    example: 'en',
  })
  language: string;

  @ApiProperty({
    description: 'Name of the writing style template',
    example: 'Professional',
  })
  name: string;

  @ApiProperty({
    description: 'Description of the writing style template',
    required: false,
    example: 'A professional, informative style for general audiences.',
  })
  description?: string | null;

  @ApiProperty({
    description: 'Voice and tone guidelines for this writing style template',
    example: 'Professional yet friendly, informative and engaging',
  })
  voiceAndTone: string;

  @ApiProperty({
    description: 'Target audience for this writing style template',
    example: 'Tech-savvy professionals aged 25-45',
  })
  audience: string;
}
