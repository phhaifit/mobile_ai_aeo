import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsEnum } from 'class-validator';

export class ValidateReferenceDto {
  @ApiProperty({ description: 'Project ID' })
  @IsString()
  projectId: string;

  @ApiProperty({ description: 'Reference page URL to validate' })
  @IsString()
  referencePageUrl: string;

  @ApiProperty({
    description: 'How the URL was selected',
    enum: ['search', 'custom'],
  })
  @IsEnum(['search', 'custom'] as const)
  referenceType: 'search' | 'custom';
}

export class ValidateReferenceResponseDto {
  @ApiProperty({ description: 'Whether the reference page is relevant' })
  isRelevant: boolean;

  @ApiProperty({
    description: 'Reason for the relevance verdict',
    required: false,
  })
  reason?: string;
}
