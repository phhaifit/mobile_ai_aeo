import {
  ForbiddenException,
  HttpException,
  HttpStatus,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { PublicBlogRepository } from './public-blog.repository';
import {
  PublicArticleListItemDto,
  PublicArticleDetailDto,
  PublicArticleQueryDto,
  PublicArticleNavigationDto,
  PublicTopicLatestPostsItemDto,
} from './dto/public-article.dto';
import { PublicBrandDto } from './dto/public-brand.dto';
import { DomainLookupDto } from './dto/domain-lookup.dto';
import { BrandRepository } from '../brand/brand.repository';
import { PaginationResult } from '../shared/dtos/pagination-result.dto';
import { createPaginatedResponse } from '../utils/common';
import MarkdownIt from 'markdown-it';
import { R2StorageService } from '../r2-storage/r2-storage.service';
import { ThumbnailDto } from 'src/content/dto/image-metadata.dto';

const EXCERPT_LENGTH = 160; // Optimal length for meta descriptions

const md = new MarkdownIt({
  html: true,
  linkify: true,
  typographer: true,
  breaks: true,
});

@Injectable()
export class PublicBlogService {
  constructor(
    private readonly publicBlogRepository: PublicBlogRepository,
    private readonly brandRepository: BrandRepository,
    private readonly r2StorageService: R2StorageService,
  ) {}

  private toThumbnailDto(
    thumbnailKey?: string | null,
  ): ThumbnailDto | undefined {
    if (!thumbnailKey) return undefined;
    return {
      key: thumbnailKey,
      url: this.r2StorageService.getPublicUrl(thumbnailKey),
    };
  }

  async getArticlesByBrand(
    brandSlug: string,
    params: PublicArticleQueryDto,
  ): Promise<PaginationResult<PublicArticleListItemDto>> {
    const brand = await this.brandRepository.findBySlugPro(brandSlug);
    if (!brand) {
      throw new NotFoundException(`Blog not found for: ${brandSlug}`);
    }

    const { data, total } =
      await this.publicBlogRepository.findArticlesByBrandSlug(
        brandSlug,
        params,
      );

    type ContentItem = (typeof data)[0];

    return createPaginatedResponse(
      data,
      total,
      params,
      (content: ContentItem) => {
        const title = content.title ?? content.topic.name;
        const displayBody = content.publishedBody ?? content.body;
        return {
          id: content.id,
          title,
          excerpt: this.generateExcerpt(displayBody),
          body: displayBody,
          createdAt: content.createdAt,
          publishedAt: content.publishedAt ?? null,
          topicName: content.topic.alias || content.topic.name,
          slug: content.slug,
          thumbnail: this.toThumbnailDto(content.thumbnailKey),
        };
      },
    );
  }

  async getArticleByBrand(
    brandSlug: string,
    articleSlug: string,
  ): Promise<PublicArticleDetailDto> {
    const content = await this.publicBlogRepository.findArticleBySlug(
      brandSlug,
      articleSlug,
    );

    if (!content) {
      throw new NotFoundException(`Article not found: ${articleSlug}`);
    }

    if (content.completionStatus !== 'PUBLISHED') {
      throw new ForbiddenException(`Article is not published: ${articleSlug}`);
    }

    // Parse targetKeywords from JSON
    const keywords = Array.isArray(content.targetKeywords)
      ? content.targetKeywords
      : [];

    const title = content.title || content.topic.name || '';

    return {
      id: content.id,
      title,
      content: this.markdownToHtml(content.publishedBody ?? content.body),
      createdAt: content.createdAt,
      publishedAt: content.publishedAt ?? null,
      topicName: content.topic.name,
      keywords: keywords as string[],
      slug: content.slug,
      thumbnail: this.toThumbnailDto(content.thumbnailKey),
    };
  }

  async getArticleNavigation(
    brandSlug: string,
    articleSlug: string,
  ): Promise<PublicArticleNavigationDto> {
    const content = await this.publicBlogRepository.findArticleBySlug(
      brandSlug,
      articleSlug,
    );

    if (!content) {
      throw new NotFoundException(`Article not found: ${articleSlug}`);
    }

    const [relatedRaw, adjacent] = await Promise.all([
      this.publicBlogRepository.findRelatedArticles(
        content.topic.projectId,
        content.id,
      ),
      content.publishedAt
        ? this.publicBlogRepository.findAdjacentArticles(
            content.topicId,
            content.publishedAt,
            content.id,
          )
        : Promise.resolve({ prev: null, next: null }),
    ]);

    const relatedArticles = relatedRaw.map((a) => ({
      id: a.id,
      title: a.title,
      slug: a.slug,
      topicName: a.topicName,
      thumbnail: this.toThumbnailDto(a.thumbnail),
      publishedAt: a.publishedAt,
    }));

    return {
      relatedArticles,
      prevArticle: adjacent.prev,
      nextArticle: adjacent.next,
    };
  }

  async getLatestArticlesGroupedByTopic(
    brandSlug: string,
  ): Promise<PublicTopicLatestPostsItemDto[]> {
    const brand = await this.brandRepository.findBySlugPro(brandSlug);
    if (!brand) {
      throw new NotFoundException(`Blog not found for: ${brandSlug}`);
    }

    const contents =
      await this.publicBlogRepository.findLatestArticlesGroupedByTopic(
        brand.projectId,
      );

    const grouped = new Map<string, PublicTopicLatestPostsItemDto>();

    for (const content of contents) {
      const topicId = content.topicId;
      const topicName = content.topicName;
      const topicAlias = content.topicAlias ?? null;

      if (!grouped.has(topicId)) {
        grouped.set(topicId, {
          topicId,
          topicName,
          topicAlias,
          articles: [],
        });
      }

      const topicGroup = grouped.get(topicId)!;

      topicGroup.articles.push({
        id: content.id,
        title: content.title ?? topicName,
        excerpt: this.generateExcerpt(content.publishedBody ?? content.body),
        createdAt: content.createdAt,
        publishedAt: content.publishedAt,
        topicName: topicAlias || topicName,
        slug: content.slug,
        thumbnail: this.toThumbnailDto(content.thumbnailKey),
      });
    }

    return Array.from(grouped.values());
  }

  private generateExcerpt(markdown: string): string {
    // Remove markdown formatting
    let text = markdown
      .replace(/^#+\s+.+$/gm, '') // Remove headings
      .replace(/\*\*([^*]+)\*\*/g, '$1') // Remove bold
      .replace(/\*([^*]+)\*/g, '$1') // Remove italic
      .replace(/\[([^\]]+)\]\([^)]+\)/g, '$1') // Remove links, keep text
      .replace(/`[^`]+`/g, '') // Remove inline code
      .replace(/```[\s\S]*?```/g, '') // Remove code blocks
      .replace(/\n+/g, ' ') // Replace newlines with spaces
      .trim();

    // Truncate to excerpt length
    if (text.length > EXCERPT_LENGTH) {
      text = text.substring(0, EXCERPT_LENGTH - 3).trim() + '...';
    }

    return text;
  }

  private markdownToHtml(markdown: string): string {
    return md.render(markdown);
  }

  async getBrandBySlug(slug: string): Promise<PublicBrandDto> {
    const exists = await this.brandRepository.findBySlug(slug);
    if (!exists) {
      throw new NotFoundException(`Brand not found for: ${slug}`);
    }

    const brand = await this.brandRepository.findBySlugPro(slug);
    if (!brand) {
      throw new HttpException('Pro plan required', HttpStatus.PAYMENT_REQUIRED);
    }

    return {
      name: brand.name,
      industry: brand.industry,
      description: brand.description,
      mission: brand.mission,
      website: brand.domain,
      logoUrl: brand.logoUrl ?? null,
      defaultArticleImageUrl: brand.defaultArticleImageUrl ?? null,
      updatedAt: brand.updatedAt,
      blogTitle: brand.blogTitle ?? null,
      blogHotline: brand.blogHotline ?? null,
      customDomain: brand.customDomain ?? null,
      domainConfigMethod: brand.domainConfigMethod ?? null,
      headerHtml: brand.headerHtml ?? null,
      footerHtml: brand.footerHtml ?? null,
      theme: brand.theme ?? null,
    };
  }

  async getAllBrandSlugs(): Promise<{ name: string; slug: string }[]> {
    return this.brandRepository.findAllNamesAndSlugs();
  }

  async getSitemapDataByBrand(brandSlug: string): Promise<{
    slug: string;
    customDomain: string | null;
    domainConfigMethod: string | null;
    articles: { slug: string; createdAt: string }[];
  } | null> {
    const brand = await this.brandRepository.findBySlugPro(brandSlug);
    if (!brand) return null;
    return this.publicBlogRepository.findSitemapDataByBrand(brandSlug);
  }

  async lookupByDomain(domain: string): Promise<DomainLookupDto> {
    const brand = await this.brandRepository.findByCustomDomain(domain);

    if (!brand) {
      throw new NotFoundException(`No brand configured for domain: ${domain}`);
    }

    return {
      brandName: brand.name,
      brandSlug: brand.slug,
    };
  }
}
