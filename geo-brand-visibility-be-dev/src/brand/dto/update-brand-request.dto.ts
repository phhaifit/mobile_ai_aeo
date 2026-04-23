import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsArray, IsIn, IsOptional, IsString, IsUUID } from 'class-validator';

export class ServiceRequestDto {
  @ApiPropertyOptional({
    description: 'Unique identifier of the service',
    example: '123e4567-e89b-12d3-a456-426614174000',
  })
  @IsOptional()
  @IsUUID()
  id?: string;

  @ApiProperty({
    description: 'Name of the service',
    example: 'Software Development',
  })
  @IsString()
  name: string;

  @ApiPropertyOptional({
    description: 'Description of the service',
    example: 'Custom software solutions',
  })
  @IsOptional()
  @IsString()
  description?: string;
}

export class UpdateBrandRequestDTO {
  @ApiProperty({
    description: 'Name of the brand',
    example: 'Example Brand',
  })
  @IsOptional()
  @IsString()
  name?: string;

  @ApiProperty({
    description: 'Description of the brand',
    example: 'A leading provider of...',
  })
  @IsOptional()
  @IsString()
  description?: string;

  @ApiProperty({
    description: 'Domain of the brand website',
    example: 'example.com',
  })
  @IsOptional()
  @IsString()
  domain?: string;

  @ApiProperty({
    description: 'Target market of the brand',
    example: 'Global B2B',
  })
  @IsOptional()
  @IsString()
  targetMarket?: string;

  @ApiProperty({
    description: 'Industry the brand operates in',
    example: 'Technology',
  })
  @IsOptional()
  @IsString()
  industry?: string;

  @ApiProperty({
    description: 'Mission statement of the brand',
    example: 'To revolutionize...',
  })
  @IsOptional()
  @IsString()
  mission?: string;

  @ApiProperty({
    description: 'Services offered by the brand',
    type: 'array',
    example: [
      {
        id: 'service-uuid',
        name: 'Software Development',
        description: 'Custom software solutions',
      },
      { name: 'New Service', description: 'Without ID means new service' },
    ],
    required: false,
  })
  @IsOptional()
  services?: ServiceRequestDto[];

  @ApiPropertyOptional({
    description: 'Custom domain for the blog',
    example: 'blog.example.com',
  })
  @IsOptional()
  @IsString()
  customDomain?: string | null;

  @ApiPropertyOptional({
    description: 'Public URL of the brand logo image',
    example:
      'https://your-project.supabase.co/storage/v1/object/public/images/brands/brand-id/logo.png',
  })
  @IsOptional()
  @IsString()
  logoUrl?: string | null;

  @ApiPropertyOptional({
    description: 'Public URL of the default article cover image',
    example:
      'https://your-project.supabase.co/storage/v1/object/public/images/brands/brand-id/default-article-image.png',
  })
  @IsOptional()
  @IsString()
  defaultArticleImageUrl?: string | null;

  @ApiPropertyOptional({
    description: 'Domain configuration method (CNAME or Rewrite)',
    enum: ['cname', 'rewrite'],
    example: 'cname',
  })
  @IsOptional()
  @IsIn(['cname', 'rewrite'])
  @IsOptional()
  @IsIn(['cname', 'rewrite'])
  domainConfigMethod?: 'cname' | 'rewrite';

  @ApiPropertyOptional({
    description: 'Blog title',
    example: 'Insights by Example Brand',
  })
  @IsOptional()
  @IsString()
  blogTitle?: string | null;

  @ApiPropertyOptional({
    description: 'Blog hotline',
    example: 'News, updates, and insights from the team at Example Brand',
  })
  @IsOptional()
  @IsString()
  blogHotline?: string | null;

  @ApiPropertyOptional({
    description: 'Revenue models of the brand (free-form text)',
    type: String,
    example: 'Subscription, Retail',
  })
  @IsOptional()
  @IsString()
  revenueModel?: string | null;

  @ApiPropertyOptional({
    description: 'Customer segments the brand serves (free-form text)',
    type: String,
    example: 'B2B, B2C',
  })
  @IsOptional()
  @IsString()
  customerType?: string | null;
}
