import { ApiProperty } from '@nestjs/swagger';

export class PublicBrandDto {
  @ApiProperty({ description: 'Brand name' })
  name: string;

  @ApiProperty({ description: 'Brand industry', required: false })
  industry?: string;

  @ApiProperty({ description: 'Brand description', required: false })
  description?: string;

  @ApiProperty({ description: 'Brand mission statement', required: false })
  mission?: string;

  @ApiProperty({ description: 'Brand website URL', required: false })
  website?: string;

  @ApiProperty({ description: 'Public logo URL', required: false })
  logoUrl?: string | null;

  @ApiProperty({ description: 'Default article image URL', required: false })
  defaultArticleImageUrl?: string | null;

  @ApiProperty({ description: 'Last update timestamp', required: false })
  updatedAt?: string;

  @ApiProperty({ description: 'Blog title', required: false })
  blogTitle?: string | null;

  @ApiProperty({ description: 'Blog hotline', required: false })
  blogHotline?: string | null;

  @ApiProperty({ description: 'Custom domain for blog', required: false })
  customDomain?: string | null;

  @ApiProperty({
    description: 'Domain config method (cname = subdomain, rewrite = path)',
    required: false,
    enum: ['cname', 'rewrite'],
  })
  domainConfigMethod?: 'cname' | 'rewrite' | null;

  @ApiProperty({ description: 'Custom header HTML for blog', required: false })
  headerHtml?: string | null;

  @ApiProperty({ description: 'Custom footer HTML for blog', required: false })
  footerHtml?: string | null;

  @ApiProperty({
    description: 'Blog theme (light or dark)',
    required: false,
    enum: ['light', 'dark'],
  })
  theme?: string | null;
}
