import { ApiProperty } from '@nestjs/swagger';

export class CustomerPersonaResponseDto {
  @ApiProperty({ description: 'Unique persona identifier' })
  id: string;

  @ApiProperty({ description: 'Brand ID this persona belongs to' })
  brandId: string;

  @ApiProperty({ description: 'Persona name' })
  name: string;

  @ApiProperty({ description: 'Free-form description', required: false })
  description?: string | null;

  @ApiProperty({ description: 'Demographics (JSONB)', required: false })
  demographics?: Record<string, string> | null;

  @ApiProperty({
    description: 'Professional background (JSONB)',
    required: false,
  })
  professional?: Record<string, string> | null;

  @ApiProperty({ description: 'Goals and motivations', required: false })
  goalsAndMotivations?: string | null;

  @ApiProperty({ description: 'Pain points and challenges', required: false })
  painPoints?: string | null;

  @ApiProperty({ description: 'Content preferences (JSONB)', required: false })
  contentPreferences?: Record<string, unknown> | null;

  @ApiProperty({ description: 'Buying behavior (JSONB)', required: false })
  buyingBehavior?: Record<string, unknown> | null;

  @ApiProperty({ description: 'Whether this is the primary persona' })
  isPrimary: boolean;

  @ApiProperty({ description: 'Creation timestamp' })
  createdAt: string;

  @ApiProperty({ description: 'Last update timestamp' })
  updatedAt: string;
}
