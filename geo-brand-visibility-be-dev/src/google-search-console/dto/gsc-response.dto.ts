import { ApiProperty } from '@nestjs/swagger';

export class GscSuccessDto {
  @ApiProperty({ example: true })
  success: boolean;
}

export class GscConnectionStatusDto {
  @ApiProperty({
    description: 'Whether the user has connected a Google account',
    example: true,
  })
  connected: boolean;

  @ApiProperty({
    description: 'OAuth scopes granted by the user',
    example: ['https://www.googleapis.com/auth/webmasters.readonly'],
    type: [String],
  })
  scopes: string[];

  @ApiProperty({
    description:
      'Whether the stored credential is still valid (false if token was revoked or expired)',
    example: true,
  })
  isValid: boolean;
}

export class GscSiteDto {
  @ApiProperty({
    description:
      'URL of the GSC property (e.g. https://example.com/ or sc-domain:example.com)',
    example: 'https://example.com/',
  })
  siteUrl: string;

  @ApiProperty({
    description: 'Permission level granted to the user for this property',
    example: 'siteOwner',
    enum: [
      'siteOwner',
      'siteFullUser',
      'siteRestrictedUser',
      'siteUnverifiedUser',
    ],
  })
  permissionLevel: string;
}

export class GscPropertyDto {
  @ApiProperty({
    description: 'Unique identifier of the linked GSC property record',
    example: '3fa85f64-5717-4562-b3fc-2c963f66afa6',
  })
  id: string;

  @ApiProperty({
    description: 'ID of the project this property is linked to',
    example: '3fa85f64-5717-4562-b3fc-2c963f66afa6',
  })
  projectId: string;

  @ApiProperty({
    description: 'ID of the user who connected GSC',
    example: '3fa85f64-5717-4562-b3fc-2c963f66afa6',
  })
  userId: string;

  @ApiProperty({
    description: 'The GSC property URL',
    example: 'https://example.com/',
  })
  siteUrl: string;

  @ApiProperty({
    description: "User's permission level for this property",
    example: 'siteOwner',
    nullable: true,
  })
  permissionLevel: string | null;

  @ApiProperty({ example: '2024-01-01T00:00:00.000Z' })
  createdAt: string;

  @ApiProperty({ example: '2024-01-01T00:00:00.000Z' })
  updatedAt: string;
}

export class GscAnalyticsSummaryDto {
  @ApiProperty({
    description: 'Total number of clicks from Google Search',
    example: 1240,
  })
  clicks: number;

  @ApiProperty({
    description: 'Total number of impressions in Google Search results',
    example: 45200,
  })
  impressions: number;

  @ApiProperty({
    description: 'Click-through rate (clicks / impressions)',
    example: 0.0274,
  })
  ctr: number;

  @ApiProperty({
    description: 'Average position in Google Search results (lower is better)',
    example: 12.4,
  })
  position: number;
}

export class GscQueryRowDto {
  @ApiProperty({
    description: 'The search query string',
    example: 'brand visibility platform',
  })
  query: string;

  @ApiProperty({ description: 'Number of clicks for this query', example: 87 })
  clicks: number;

  @ApiProperty({
    description: 'Number of impressions for this query',
    example: 3200,
  })
  impressions: number;

  @ApiProperty({
    description: 'Click-through rate for this query',
    example: 0.0272,
  })
  ctr: number;

  @ApiProperty({
    description: 'Average position for this query',
    example: 8.1,
  })
  position: number;
}

export class GscPageRowDto {
  @ApiProperty({
    description: 'The full URL of the page',
    example: 'https://example.com/blog/geo-optimization',
  })
  page: string;

  @ApiProperty({ description: 'Number of clicks for this page', example: 210 })
  clicks: number;

  @ApiProperty({
    description: 'Number of impressions for this page',
    example: 7500,
  })
  impressions: number;

  @ApiProperty({
    description: 'Click-through rate for this page',
    example: 0.028,
  })
  ctr: number;

  @ApiProperty({
    description: 'Average position for this page',
    example: 6.3,
  })
  position: number;
}

export class GscTrendPointDto {
  @ApiProperty({
    description: 'Date in YYYY-MM-DD format',
    example: '2024-03-15',
  })
  date: string;

  @ApiProperty({ description: 'Number of clicks on this date', example: 42 })
  clicks: number;

  @ApiProperty({
    description: 'Number of impressions on this date',
    example: 1500,
  })
  impressions: number;

  @ApiProperty({
    description: 'Click-through rate on this date',
    example: 0.028,
  })
  ctr: number;

  @ApiProperty({
    description: 'Average search position on this date',
    example: 11.2,
  })
  position: number;
}
