import { ApiProperty } from '@nestjs/swagger';
import { DEFAULT_LANGUAGE, DEFAULT_LOCATION } from 'src/shared/constant';

export class ProjectResponseDto {
  @ApiProperty({
    description: 'Unique project identifier',
    example: 'uuid-v4',
  })
  id: string;

  @ApiProperty({
    description: 'Project status',
    enum: ['DRAFT', 'ACTIVE'],
    example: 'ACTIVE',
  })
  status: 'DRAFT' | 'ACTIVE';

  @ApiProperty({
    description: 'User ID who created the project',
    example: 'uuid-v4',
  })
  createdBy: string;

  @ApiProperty({
    description: 'Monitoring frequency for the project',
    example: 'weekly',
  })
  monitoringFrequency: 'hourly' | 'daily' | 'weekly' | 'monthly';

  @ApiProperty({
    description: 'Project location',
    example: DEFAULT_LOCATION,
  })
  location: string;

  @ApiProperty({
    description: 'Project language',
    example: DEFAULT_LANGUAGE,
  })
  language: string;

  @ApiProperty({
    description: 'Array of model IDs associated with the project',
    example: [
      '437d2884-a459-4908-8cec-c9e9f8df8e28',
      '123e4567-e89b-12d3-a456-426614174000',
    ],
  })
  models: string[];

  @ApiProperty({
    description: 'Project creation timestamp in ISO 8601 format',
    example: '2025-01-28T10:00:00Z',
  })
  createdAt: string;

  @ApiProperty({
    description: 'Last modification timestamp in ISO 8601 format',
    example: '2025-01-28T10:00:00Z',
  })
  updatedAt: string;

  @ApiProperty({
    description: 'Brand visibility score (0-100), only for ACTIVE projects',
    example: 75.5,
    required: false,
  })
  brandVisibilityScore?: number;

  @ApiProperty({
    description: 'Whether the project has an active Pro subscription',
    example: false,
    required: false,
  })
  isPro?: boolean;

  @ApiProperty({
    description: 'Timestamp when strategy was reviewed',
    example: '2026-04-20T12:00:00Z',
    required: false,
    nullable: true,
  })
  strategyReviewedAt?: string | null;

  @ApiProperty({
    description: 'User ID of the strategy reviewer',
    example: 'uuid-v4',
    required: false,
    nullable: true,
  })
  strategyReviewedById?: string | null;

  @ApiProperty({
    description: 'Display name of the strategy reviewer at time of review',
    example: 'Jane Doe',
    required: false,
    nullable: true,
  })
  strategyReviewedByName?: string | null;
}
