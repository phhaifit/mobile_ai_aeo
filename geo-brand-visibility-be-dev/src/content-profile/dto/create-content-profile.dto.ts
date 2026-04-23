import { IsString, IsNotEmpty, IsOptional } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateContentProfileDto {
  @ApiProperty({
    description: 'Name of the content profile',
    example: 'Blog Posts',
  })
  @IsString()
  @IsNotEmpty()
  name: string;

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
  })
  @IsString()
  @IsNotEmpty()
  voiceAndTone: string;

  @ApiProperty({
    description: 'Target audience for this content profile',
    example: 'Tech-savvy professionals aged 25-45',
  })
  @IsString()
  @IsNotEmpty()
  audience: string;
}
