import { Inject, Injectable } from '@nestjs/common';
import { SUPABASE } from '../utils/const';
import { SupabaseClient } from '@supabase/supabase-js';
import { Database, Tables } from '../supabase/supabase.types';
import { mapSqlError } from '../utils/map-sql-error.util';
import { PublicArticleQueryDto } from './dto/public-article.dto';

const CONTENT_TABLE = 'Content';

type ContentWithTopic = Tables<'Content'> & {
  slug: string;
  topic: {
    id: string;
    name: string;
    projectId: string;
    alias?: string | null;
  };
};

@Injectable()
export class PublicBlogRepository {
  constructor(
    @Inject(SUPABASE) private readonly supabase: SupabaseClient<Database>,
  ) {}

  async findArticlesByBrandSlug(
    slug: string,
    params: PublicArticleQueryDto,
  ): Promise<{ data: ContentWithTopic[]; total: number }> {
    const { data: brand, error: brandError } = await this.supabase
      .from('Brand')
      .select('projectId')
      .eq('slug', slug)
      .single();

    if (brandError || !brand) {
      return { data: [], total: 0 };
    }

    let query = this.supabase
      .from(CONTENT_TABLE)
      .select(
        `
        *,
        topic:Topic!Content_topicId_fkey!inner(
          id,
          name,
          projectId,
          alias
        )
      `,
        { count: 'exact' },
      )
      .eq('topic.projectId', brand.projectId)
      .eq('completionStatus', 'PUBLISHED' as any)
      .eq('contentType', 'blog_post');

    if (params.topic) {
      query = query.ilike('topic.alias', `%${params.topic}%`);
    }

    const { data, error, count } = await query
      .order('createdAt', { ascending: false })
      .range(params.skip, params.skip + params.take - 1);

    if (error) {
      throw mapSqlError(error);
    }

    return {
      data: (data as ContentWithTopic[]) || [],
      total: count ?? 0,
    };
  }

  async findArticleById(
    id: string,
    brandSlug: string,
  ): Promise<ContentWithTopic | null> {
    const { data: brand } = await this.supabase
      .from('Brand')
      .select('projectId')
      .eq('slug', brandSlug)
      .single();

    if (!brand) {
      return null;
    }

    const { data, error } = await this.supabase
      .from(CONTENT_TABLE)
      .select(
        `
        *,
        topic:Topic!Content_topicId_fkey!inner(
          id,
          name,
          projectId
        )
      `,
      )
      .eq('id', id)
      .eq('topic.projectId', brand.projectId)
      .eq('completionStatus', 'PUBLISHED' as any)
      .eq('contentType', 'blog_post')
      .maybeSingle();

    if (error) {
      throw mapSqlError(error);
    }

    return data as ContentWithTopic;
  }

  async findArticleBySlug(
    brandSlug: string,
    articleSlug: string,
  ): Promise<ContentWithTopic | null> {
    const { data: brand } = await this.supabase
      .from('Brand')
      .select('projectId')
      .eq('slug', brandSlug)
      .single();

    if (!brand) {
      return null;
    }

    const { data, error } = await this.supabase
      .from(CONTENT_TABLE)
      .select(
        `
        *,
        topic:Topic!Content_topicId_fkey!inner(
          id,
          name,
          projectId
        )
      `,
      )
      .eq('slug', articleSlug)
      .eq('topic.projectId', brand.projectId)
      .eq('contentType', 'blog_post')
      .maybeSingle();

    if (error) {
      throw mapSqlError(error);
    }

    return data as ContentWithTopic;
  }

  async findRelatedArticles(
    projectId: string,
    excludeContentId: string,
  ): Promise<
    {
      id: string;
      title: string;
      slug: string;
      topicName: string;
      thumbnail: string | null;
      publishedAt: string | null;
    }[]
  > {
    // Fetch a pool of recent articles then pick 3 at random
    const { data: articles, error } = await this.supabase
      .from(CONTENT_TABLE)
      .select(
        `
        id, title, slug, publishedAt, thumbnailKey,
        topic:Topic!Content_topicId_fkey!inner(name, alias, projectId)
      `,
      )
      .eq('topic.projectId', projectId)
      .eq('completionStatus', 'PUBLISHED' as any)
      .eq('contentType', 'blog_post' as any)
      .neq('id', excludeContentId)
      .order('publishedAt', { ascending: false })
      .limit(20);

    if (error) throw mapSqlError(error);
    if (!articles || articles.length === 0) return [];

    // Shuffle and pick 3
    const shuffled = articles.sort(() => Math.random() - 0.5).slice(0, 3);

    return shuffled.map((a: any) => ({
      id: a.id,
      title: a.title,
      slug: a.slug,
      topicName: a.topic?.alias || a.topic?.name || '',
      thumbnail: a.thumbnailKey,
      publishedAt: a.publishedAt,
    }));
  }

  async findAdjacentArticles(
    topicId: string,
    publishedAt: string,
    currentId: string,
  ): Promise<{
    prev: { title: string; slug: string } | null;
    next: { title: string; slug: string } | null;
  }> {
    const [prevResult, nextResult] = await Promise.all([
      this.supabase
        .from(CONTENT_TABLE)
        .select('title, slug, publishedAt')
        .eq('topicId', topicId)
        .eq('completionStatus', 'PUBLISHED')
        .eq('contentType', 'blog_post')
        .neq('id', currentId)
        .lt('publishedAt', publishedAt)
        .order('publishedAt', { ascending: false })
        .limit(1),
      this.supabase
        .from(CONTENT_TABLE)
        .select('title, slug, publishedAt')
        .eq('topicId', topicId)
        .eq('completionStatus', 'PUBLISHED')
        .eq('contentType', 'blog_post')
        .neq('id', currentId)
        .gt('publishedAt', publishedAt)
        .order('publishedAt', { ascending: true })
        .limit(1),
    ]);

    if (prevResult.error) throw mapSqlError(prevResult.error);
    if (nextResult.error) throw mapSqlError(nextResult.error);

    return {
      prev: prevResult.data?.[0]
        ? {
            title: prevResult.data[0].title ?? '',
            slug: prevResult.data[0].slug ?? '',
          }
        : null,
      next: nextResult.data?.[0]
        ? {
            title: nextResult.data[0].title ?? '',
            slug: nextResult.data[0].slug ?? '',
          }
        : null,
    };
  }

  async findSitemapDataByBrand(brandSlug: string): Promise<{
    slug: string;
    customDomain: string | null;
    domainConfigMethod: string | null;
    articles: { slug: string; createdAt: string }[];
  } | null> {
    const { data: brand, error: brandError } = await this.supabase
      .from('Brand')
      .select('slug, customDomain, domainConfigMethod, projectId')
      .eq('slug', brandSlug)
      .single();

    if (brandError || !brand || !brand.slug) return null;

    const PAGE_SIZE = 1000;
    const allArticles: { slug: string; createdAt: string }[] = [];
    let from = 0;

    while (true) {
      const { data, error } = await this.supabase
        .from(CONTENT_TABLE)
        .select(
          `
          slug,
          createdAt,
          topic:Topic!Content_topicId_fkey!inner(projectId)
        `,
        )
        .eq('completionStatus', 'PUBLISHED')
        .eq('contentType', 'blog_post')
        .eq('topic.projectId', brand.projectId)
        .not('slug', 'is', null)
        .order('createdAt', { ascending: false })
        .range(from, from + PAGE_SIZE - 1);

      if (error) throw mapSqlError(error);
      if (!data || data.length === 0) break;

      for (const a of data) {
        if (a.slug) allArticles.push({ slug: a.slug, createdAt: a.createdAt });
      }

      if (data.length < PAGE_SIZE) break;
      from += PAGE_SIZE;
    }

    return {
      slug: brand.slug,
      customDomain: brand.customDomain ?? null,
      domainConfigMethod: brand.domainConfigMethod ?? null,
      articles: allArticles,
    };
  }

  async findLatestArticlesGroupedByTopic(projectId: string): Promise<any[]> {
    const { data, error } = await this.supabase
      .from('latest_articles_by_topic_view')
      .select('*')
      .eq('projectId', projectId)
      .lte('articleRank', 3)
      .order('createdAt', { ascending: false });

    if (error) throw mapSqlError(error);
    return data || [];
  }
}
