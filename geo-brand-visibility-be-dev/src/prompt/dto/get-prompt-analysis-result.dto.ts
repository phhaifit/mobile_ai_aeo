import { ApiProperty } from '@nestjs/swagger';

class CompetitorSummaryDTO {
  @ApiProperty({
    description: 'Brand or competitor ID',
    example: '123e4567-e89b-12d3-a456-426614174000',
  })
  id: string;

  @ApiProperty({
    description: 'Brand or competitor name',
    example: 'Competitor Brand',
  })
  name: string;

  @ApiProperty({
    description: 'Number of mentions',
    example: 15,
  })
  frequency: number;

  @ApiProperty({
    description: 'Average position in results',
    example: 2.5,
  })
  avgPosition: number;
}

class DomainSummaryDTO {
  @ApiProperty({
    description: 'Domain name',
    example: 'example.com',
  })
  domain: string;

  @ApiProperty({
    description: 'Number of citations',
    example: 10,
  })
  frequency: number;
}

class BrandPositionDTO {
  @ApiProperty({
    description: 'Brand ID',
    example: '123e4567-e89b-12d3-a456-426614174000',
  })
  id: string;

  @ApiProperty({
    description: 'Brand name',
    example: 'My Brand',
  })
  name: string;

  @ApiProperty({
    description: 'Average position',
    example: 1.5,
  })
  position: number;
}

class PositionOverTimeDTO {
  @ApiProperty({
    description: 'Date of the analysis',
    example: '2024-01-15',
  })
  date: string;

  @ApiProperty({
    description: 'Brand positions on this date',
    type: [BrandPositionDTO],
  })
  brands: BrandPositionDTO[];
}

class BrandSoVDTO {
  @ApiProperty({
    description: 'Brand ID',
    example: '123e4567-e89b-12d3-a456-426614174000',
  })
  id: string;

  @ApiProperty({
    description: 'Brand name',
    example: 'My Brand',
  })
  name: string;

  @ApiProperty({
    description: 'Share of voice percentage',
    example: 45.5,
  })
  sov: number;
}

class ShareOfVoiceDTO {
  @ApiProperty({
    description: 'AI model name',
    example: 'GPT-4',
  })
  model: string;

  @ApiProperty({
    description: 'Brand share of voice data for this model',
    type: [BrandSoVDTO],
  })
  brands: BrandSoVDTO[];
}

export class GetPromptAnalysisResultDTO {
  @ApiProperty({
    description: 'Competitor summary data',
    type: [CompetitorSummaryDTO],
  })
  competitors: CompetitorSummaryDTO[];

  @ApiProperty({
    description: 'Domain citation summary',
    type: [DomainSummaryDTO],
  })
  domains: DomainSummaryDTO[];

  @ApiProperty({
    description: 'Position over time data',
    type: [PositionOverTimeDTO],
  })
  positionOverTime: PositionOverTimeDTO[];

  @ApiProperty({
    description: 'Share of voice data by model',
    type: [ShareOfVoiceDTO],
  })
  shareOfVoice: ShareOfVoiceDTO[];
}
