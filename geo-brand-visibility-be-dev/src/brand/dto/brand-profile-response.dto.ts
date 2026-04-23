import { ApiProperty } from '@nestjs/swagger';
import { IsString } from 'class-validator';

export class ServiceResponseDto {
  @ApiProperty({
    description: 'Unique identifier of the service',
    example: 'uuid-v4',
  })
  id: string;

  @ApiProperty({
    description: 'Name of the service',
    example: 'Software Development',
  })
  @IsString()
  name: string;

  @ApiProperty({
    description: 'Description of the service',
    example: 'Custom software solutions',
    required: false,
  })
  description: string | null;
}

export class BrandProfileResponseDto {
  @ApiProperty({
    description: 'Unique identifier of the brand',
    example: 'uuid-v4',
  })
  id: string;

  @ApiProperty({
    description: 'The project ID this brand belongs to',
    example: 'uuid-v4',
  })
  projectId: string;

  @ApiProperty({
    description: 'Name of the brand',
    example: 'Example Brand',
  })
  name: string;

  @ApiProperty({
    description: 'URL-safe slug for the brand',
    example: 'example-brand',
  })
  slug: string;

  @ApiProperty({
    description: 'Description of the brand',
    example: 'A leading provider of...',
  })
  description?: string;

  @ApiProperty({
    description: 'Domain of the brand website',
    example: 'example.com',
  })
  domain: string;

  @ApiProperty({
    description: 'Target market of the brand',
    example: 'Global B2B',
  })
  targetMarket?: string;

  @ApiProperty({
    description: 'Industry the brand operates in',
    example: 'Technology',
  })
  industry?: string;

  @ApiProperty({
    description: 'Services offered by the brand',
    type: 'array',
    example: [
      { id: 'service-uuid', name: 'Software Development', description: '...' },
    ],
    required: false,
  })
  services: ServiceResponseDto[];

  @ApiProperty({
    description: 'Mission statement of the brand',
    example: 'To revolutionize...',
  })
  mission?: string;

  @ApiProperty({
    description: 'Custom domain for the blog',
    example: 'blog.example.com',
    required: false,
  })
  customDomain?: string | null;

  @ApiProperty({
    description: 'Public URL of the brand logo image',
    example:
      'https://your-project.supabase.co/storage/v1/object/public/images/brands/brand-id/logo.png',
    required: false,
  })
  logoUrl?: string | null;

  @ApiProperty({
    description: 'Public URL of the default article cover image',
    example:
      'https://your-project.supabase.co/storage/v1/object/public/images/brands/brand-id/default-article-image.png',
    required: false,
  })
  defaultArticleImageUrl?: string | null;

  @ApiProperty({
    description: 'Domain configuration method (CNAME or Rewrite)',
    enum: ['cname', 'rewrite'],
    example: 'cname',
    required: false,
  })
  domainConfigMethod?: 'cname' | 'rewrite' | null;

  @ApiProperty({
    description: 'Cloudflare custom hostname ID',
    example: '023e105f4ecef8ad9ca31a8372d0c353',
    required: false,
  })
  cloudflareHostnameId?: string | null;

  @ApiProperty({
    description: 'Creation timestamp in ISO 8601 format',
    example: '2025-01-28T10:00:00Z',
  })
  createdAt: string;

  @ApiProperty({
    description: 'Last update timestamp in ISO 8601 format',
    example: '2025-01-28T10:00:00Z',
  })
  updatedAt: string;

  @ApiProperty({
    description: 'Blog title',
    example: 'Insights by Example Brand',
    required: false,
  })
  blogTitle?: string | null;

  @ApiProperty({
    description: 'Blog hotline',
    example: 'News, updates, and insights from the team at Example Brand',
    required: false,
  })
  blogHotline?: string | null;

  @ApiProperty({
    description: 'Revenue models of the brand (free-form text)',
    type: String,
    example: 'Subscription, Retail',
    required: false,
  })
  revenueModel?: string | null;

  @ApiProperty({
    description: 'Customer segments the brand serves (free-form text)',
    type: String,
    example: 'B2B, B2C',
    required: false,
  })
  customerType?: string | null;
}
