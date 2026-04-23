import {
  Controller,
  Get,
  NotFoundException,
  Param,
  Query,
} from '@nestjs/common';
import { ApiOperation, ApiQuery, ApiResponse, ApiTags } from '@nestjs/swagger';
import { PublicBlogService } from './public-blog.service';
import {
  PublicArticleDetailDto,
  PublicArticleNavigationDto,
  PublicArticleQueryDto,
  PublicTopicLatestPostsItemDto,
} from './dto/public-article.dto';
import { PublicBrandDto } from './dto/public-brand.dto';
import { DomainLookupDto } from './dto/domain-lookup.dto';
import { Public } from '../auth/decorators/public.decorator';

@ApiTags('public-blog')
@Controller('public')
export class PublicBlogController {
  constructor(private readonly publicBlogService: PublicBlogService) {}

  @Public()
  @Get('brands')
  @ApiOperation({
    summary: 'Get all brand slugs',
    description:
      'Returns list of all brand names + slugs for sitemap generation',
  })
  @ApiResponse({
    status: 200,
    description: 'Array of brand names and slugs',
    schema: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          name: { type: 'string' },
          slug: { type: 'string' },
        },
      },
    },
  })
  async getBrands(): Promise<{ name: string; slug: string }[]> {
    return this.publicBlogService.getAllBrandSlugs();
  }

  @Public()
  @Get('domain-lookup')
  @ApiOperation({
    summary: 'Lookup brand by custom domain',
    description: 'Returns brand info for custom domain routing in middleware',
  })
  @ApiQuery({
    name: 'domain',
    required: true,
    description: 'Custom domain to lookup (e.g., jarvis.cx)',
  })
  @ApiResponse({
    status: 200,
    description: 'Domain configuration found',
    type: DomainLookupDto,
  })
  @ApiResponse({ status: 404, description: 'Domain not configured' })
  async lookupDomain(
    @Query('domain') domain: string,
  ): Promise<DomainLookupDto> {
    return this.publicBlogService.lookupByDomain(domain);
  }

  @Public()
  @Get(':brandSlug/_aeo-health')
  @ApiOperation({
    summary: 'Health check for custom domain verification',
    description:
      'Returns brand slug for verifying that custom domain proxy is correctly configured',
  })
  @ApiResponse({
    status: 200,
    description: 'Health check response with brand slug',
    schema: {
      type: 'object',
      properties: {
        slug: { type: 'string' },
        ts: { type: 'number' },
      },
    },
  })
  @ApiResponse({ status: 404, description: 'Brand not found' })
  async healthCheck(
    @Param('brandSlug') brandSlug: string,
  ): Promise<{ slug: string; ts: number }> {
    const brand = await this.publicBlogService.getBrandBySlug(brandSlug);
    if (!brand) {
      throw new NotFoundException(`Brand not found: ${brandSlug}`);
    }
    return { slug: brandSlug, ts: Date.now() };
  }

  @Public()
  @Get(':brandSlug/sitemap-data')
  @ApiOperation({
    summary: 'Get sitemap data for a brand',
    description:
      'Returns brand domain info and all published article slugs/dates for sitemap generation',
  })
  @ApiResponse({
    status: 200,
    description: 'Brand sitemap data with articles',
  })
  @ApiResponse({ status: 404, description: 'Brand not found' })
  async getSitemapDataByBrand(@Param('brandSlug') brandSlug: string): Promise<{
    slug: string;
    customDomain: string | null;
    domainConfigMethod: string | null;
    articles: { slug: string; createdAt: string }[];
  }> {
    const data = await this.publicBlogService.getSitemapDataByBrand(brandSlug);
    if (!data) {
      throw new NotFoundException(`Brand not found: ${brandSlug}`);
    }
    return data;
  }

  @Public()
  @Get(':brandSlug/articles')
  @ApiOperation({
    summary: 'Get public blog articles by brand name',
    description:
      'Returns paginated list of published articles for SEO/public access',
  })
  @ApiResponse({
    status: 200,
    description: 'List of articles with pagination info',
  })
  @ApiResponse({ status: 404, description: 'Brand not found' })
  async getArticles(
    @Param('brandSlug') brandSlug: string,
    @Query() query: PublicArticleQueryDto,
  ) {
    return this.publicBlogService.getArticlesByBrand(brandSlug, query);
  }

  @Public()
  @Get(':brandSlug/topics/latest-articles')
  @ApiOperation({
    summary: 'Get latest 3 public articles for each topic',
    description:
      'Returns up to 3 newest published articles grouped by topic for public access',
  })
  @ApiResponse({
    status: 200,
    description: 'Latest 3 published articles for each topic',
    type: PublicTopicLatestPostsItemDto,
    isArray: true,
  })
  @ApiResponse({ status: 404, description: 'Brand not found' })
  async getLatestArticlesGroupedByTopic(
    @Param('brandSlug') brandSlug: string,
  ): Promise<PublicTopicLatestPostsItemDto[]> {
    return this.publicBlogService.getLatestArticlesGroupedByTopic(brandSlug);
  }

  @Public()
  @Get(':brandSlug/articles/:slug/navigation')
  @ApiOperation({
    summary: 'Get article navigation context',
    description:
      'Returns related articles (contextual links) and prev/next articles in same topic',
  })
  @ApiResponse({
    status: 200,
    description: 'Navigation context for the article',
    type: PublicArticleNavigationDto,
  })
  @ApiResponse({ status: 404, description: 'Article not found' })
  async getArticleNavigation(
    @Param('brandSlug') brandSlug: string,
    @Param('slug') slug: string,
  ): Promise<PublicArticleNavigationDto> {
    return this.publicBlogService.getArticleNavigation(brandSlug, slug);
  }

  @Public()
  @Get(':brandSlug/articles/:slug')
  @ApiOperation({
    summary: 'Get single article by slug',
    description: 'Returns full article content for SEO/public access',
  })
  @ApiResponse({
    status: 200,
    description: 'Article details',
    type: PublicArticleDetailDto,
  })
  @ApiResponse({ status: 404, description: 'Article not found' })
  async getArticle(
    @Param('brandSlug') brandSlug: string,
    @Param('slug') slug: string,
  ): Promise<PublicArticleDetailDto> {
    return this.publicBlogService.getArticleByBrand(brandSlug, slug);
  }

  @Public()
  @Get('brands/:slug')
  @ApiOperation({
    summary: 'Get public brand info by slug',
    description: 'Returns brand name, description, mission... for footer/meta',
  })
  @ApiResponse({
    status: 200,
    description: 'Brand details',
    type: PublicBrandDto,
  })
  @ApiResponse({ status: 404, description: 'Brand not found' })
  async getBrand(@Param('slug') slug: string): Promise<PublicBrandDto> {
    return this.publicBlogService.getBrandBySlug(slug);
  }
}
