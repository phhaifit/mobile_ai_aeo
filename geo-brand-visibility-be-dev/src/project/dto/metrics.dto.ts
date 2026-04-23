import { ApiProperty } from '@nestjs/swagger';

export class BaseMetricsDto {
  @ApiProperty({
    description: 'Number of responses mentioning the brand',
    example: 42,
    type: Number,
  })
  brandMentions: number;

  @ApiProperty({
    description: 'Brand visibility percentage based on brand mentions',
    example: 78.3,
    type: Number,
  })
  brandMentionsRate: number;

  @ApiProperty({
    description: 'Number of responses containing links to the brand',
    example: 15,
    type: Number,
  })
  linkReferences: number;
  @ApiProperty({
    description: 'Link visibility percentage based on link references',
    example: 65.2,
    type: Number,
  })
  linkReferencesRate: number;
}

export class DomainDistributionItemDto {
  @ApiProperty({
    description: 'Domain name (e.g., github.com)',
    example: 'github.com',
  })
  domain: string;

  @ApiProperty({
    description: 'Total number of times this domain was mentioned',
    example: 1247,
  })
  count: number;

  @ApiProperty({
    description: 'Distribution percentage across different AI models',
    example: {
      ChatGPT: 45.2,
      Gemini: 15.7,
      'AI Overview': 39.1,
    },
    type: 'object',
    additionalProperties: { type: 'number' },
  })
  distribution: {
    [modelName: string]: number;
  };
}

export class MetricsOverviewDto extends BaseMetricsDto {
  @ApiProperty({
    description:
      'Overall brand visibility score calculated from various metrics',
    example: 85.5,
    type: Number,
  })
  brandVisibilityScore: number;

  @ApiProperty({
    description:
      'Domain distribution showing which domains appear in citations across models',
    type: [DomainDistributionItemDto],
  })
  domainDistribution: DomainDistributionItemDto[];

  @ApiProperty({
    description: 'Competitor performance metrics',
    example: {
      'Competitor A': 75,
      'Competitor B': 60,
      'Competitor C': 90,
    },
  })
  competitors: {
    [competitor: string]: number;
  };
}

export class AnalyticsByDateDto {
  @ApiProperty({
    description: 'Date for the analytics data (YYYY-MM-DD format)',
    example: '2025-11-01',
    type: String,
  })
  date: string;

  @ApiProperty({
    description: 'Total number of responses on this date',
    example: 120,
    type: Number,
  })
  totalResponses: number;

  @ApiProperty({
    description: 'Number of responses mentioning the brand',
    example: 42,
    type: Number,
  })
  brandMentions: number;

  @ApiProperty({
    description: 'Number of responses containing links to the brand',
    example: 15,
    type: Number,
  })
  linkReferences: number;

  @ApiProperty({
    description: 'Number of responses with positive sentiment',
    example: 20,
    type: Number,
  })
  positiveCount: number;

  @ApiProperty({
    description: 'Number of responses with neutral sentiment',
    example: 70,
    type: Number,
  })
  neutralCount: number;

  @ApiProperty({
    description: 'Number of responses with negative sentiment',
    example: 30,
    type: Number,
  })
  negativeCount: number;
}

export class CompetitorMentionsDto {
  [competitor: string]: number;
}

export class AnalyticsByModelDto {
  @ApiProperty({
    description: 'Name of the AI model (ChatGPT, Claude, Gemini...)',
    example: 'ChatGPT',
    type: String,
  })
  modelName: string;

  @ApiProperty({
    description: 'Total number of mentions detected by this model',
    example: 52,
    type: Number,
  })
  totalMentions: number;

  @ApiProperty({
    description: 'Number of brand mentions detected by this model',
    example: 12,
    type: Number,
  })
  brandMentions: number;

  @ApiProperty({
    description: 'Competitor mentions breakdown for this model',
    example: {
      'KMS TECHNOLOGY': 1,
      'FPT SOFTWARE': 1,
      'TMA SOLUTIONS': 0,
      RELIASOFTWARE: 8,
      BESTARION: 0,
      OTROS: 30,
    },
    type: 'object',
    additionalProperties: { type: 'number' },
  })
  competitorMentions: CompetitorMentionsDto;
}

export class SentimentStatsDto {
  @ApiProperty({
    description: 'Number of responses with positive sentiment',
    example: 42,
    type: Number,
  })
  positive: number;

  @ApiProperty({
    description: 'Number of responses with neutral sentiment',
    example: 78,
    type: Number,
  })
  neutral: number;

  @ApiProperty({
    description: 'Number of responses with negative sentiment',
    example: 15,
    type: Number,
  })
  negative: number;
}

export class MetricsAnalyticsDto extends BaseMetricsDto {
  @ApiProperty({
    description: 'Total number of responses analyzed',
    example: 1000,
    type: Number,
  })
  totalResponses: number;

  @ApiProperty({
    description: 'Number of AI Overviews provided in the responses',
    example: 350,
    type: Number,
  })
  AIOverviewsCount: number;

  @ApiProperty({
    description: 'Rate of AI Overviews provided in the responses',
    example: 35.0,
    type: Number,
  })
  AIOverviewsRate: number;

  @ApiProperty({
    description: 'Sentiment statistics breakdown',
    type: SentimentStatsDto,
  })
  sentimentStats: SentimentStatsDto;

  @ApiProperty({
    description: 'Array of analytics data grouped by date',
    type: [AnalyticsByDateDto],
  })
  analyticsByDate: AnalyticsByDateDto[];

  @ApiProperty({
    description: 'Array of analytics data grouped by AI model',
    type: [AnalyticsByModelDto],
  })
  analyticsByModel: AnalyticsByModelDto[];
}
