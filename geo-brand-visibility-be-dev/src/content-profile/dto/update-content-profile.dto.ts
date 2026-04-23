import { IsString, IsNotEmpty, IsOptional } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class UpdateContentProfileDto {
  @ApiProperty({
    description: 'Name of the content profile',
    example: 'Blog Posts',
    required: false,
  })
  @IsString()
  @IsNotEmpty()
  @IsOptional()
  name?: string;

  @ApiProperty({
    description: 'Description of the content profile',
    example: 'Content profile for blog posts and articles',
    required: false,
  })
  @IsString()
  @IsOptional()
  description?: string;

  @ApiProperty({
    description: 'Voice and tone guidelines for this content profile',
    example: 'Professional yet friendly, informative and engaging',
    required: false,
  })
  @IsString()
  @IsOptional()
  voiceAndTone?: string;

  @ApiProperty({
    description: 'Target audience for this content profile',
    example: 'Tech-savvy professionals aged 25-45',
    required: false,
  })
  @IsString()
  @IsOptional()
  audience?: string;
}
