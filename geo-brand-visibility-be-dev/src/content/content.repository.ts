import { Inject, Injectable, Logger } from '@nestjs/common';
import { SUPABASE } from '../utils/const';
import { SupabaseClient } from '@supabase/supabase-js';
import {
  Database,
  Tables,
  TablesInsert,
  TablesUpdate,
} from '../supabase/supabase.types';
import { mapSqlError } from '../utils/map-sql-error.util';
import { ContentQueryDto } from 'src/content/dto/content-query.dto';
import { CompletionStatus } from 'src/content/enums';

const CONTENT_TABLE = 'Content';
const TASK_TABLE = 'Task';

export type Content = Tables<'Content'>;
export type ContentInsert = TablesInsert<'Content'>;
export type ContentUpdate = TablesUpdate<'Content'>;

export type ContentWithRelations = Content & {
  publishedAt?: string | null;
  contentType?: string;
  platform?: string | null;
  prompt: {
    id: string;
    content: string;
    type: string;
  };
  topic: {
    id: string;
    name: string;
    projectId: string;
  } | null;
  profile: {
    id: string;
    name: string;
    voiceAndTone: string;
    audience: string;
    description: string | null;
  } | null;
};

@Injectable()
export class ContentRepository {
  private readonly logger = new Logger(ContentRepository.name);

  constructor(
    @Inject(SUPABASE) private readonly supabase: SupabaseClient<Database>,
  ) {}

  async create(data: ContentInsert): Promise<Content> {
    const { data: result, error } = await this.supabase
      .from(CONTENT_TABLE)
      .insert(data)
      .select()
      .single();

    if (error) {
      throw mapSqlError(error);
    }
    return result;
  }

  async findById(id: string): Promise<Content | null> {
    const { data, error } = await this.supabase
      .from(CONTENT_TABLE)
      .select('*')
      .eq('id', id)
      .single();

    if (error) {
      if (error.code === 'PGRST116') {
        return null;
      }
      throw mapSqlError(error);
    }
    return data;
  }

  async findBySlug(slug: string): Promise<Content | null> {
    const { data, error } = await this.supabase
      .from(CONTENT_TABLE)
      .select('*')
      .eq('slug', slug)
      .single();

    if (error) {
      // Not exists
      if (error.code === 'PGRST116') {
        return null;
      }
      throw mapSqlError(error);
    }
    return data;
  }

  async update(id: string, data: ContentUpdate): Promise<Content> {
    const { data: result, error } = await this.supabase
      .from(CONTENT_TABLE)
      .update(data)
      .eq('id', id)
      .select()
      .single();

    if (error) {
      throw mapSqlError(error);
    }
    return result;
  }

  async getUsedReferenceUrls(promptId: string): Promise<string[]> {
    const { data, error } = await this.supabase
      .from(CONTENT_TABLE)
      .select('retrievedPages')
      .eq('promptId', promptId)
      .in('completionStatus', ['COMPLETE', 'PUBLISHED'])
      .not('retrievedPages', 'is', null);

    if (error) {
      throw mapSqlError(error);
    }

    const urls: string[] = [];
    for (const row of data ?? []) {
      if (Array.isArray(row.retrievedPages)) {
        for (const page of row.retrievedPages as Array<{ url?: string }>) {
          if (page?.url) urls.push(page.url);
        }
      }
    }
    return urls;
  }

  async findByPromptId(promptId: string): Promise<ContentWithRelations[]> {
    let query = this.supabase
      .from(CONTENT_TABLE)
      .select(
        `
        *,
        prompt:Prompt!Content_promptId_fkey (
          id,
          content,
          type
        ),
        topic:Topic!Content_topicId_fkey!inner(
          id,
          name,
          projectId
        )
      `,
      )
      .eq('promptId', promptId)
      .eq('prompt.isDeleted', false);

    query = query.order('createdAt', { ascending: false });

    const { data, error } = await query;

    if (error) {
      throw mapSqlError(error);
    }

    return data as ContentWithRelations[];
  }
  async findOneByPromptIdForRewrite(
    promptId: string,
    projectId: string,
    contentType?: string,
  ): Promise<ContentWithRelations | null> {
    let query = this.supabase
      .from(CONTENT_TABLE)
      .select(
        `
        *,
        prompt:Prompt!Content_promptId_fkey (
          id,
          content,
          type
        ),
        topic:Topic!Content_topicId_fkey!inner(
          id,
          name,
          projectId
        )
      `,
      )
      .eq('promptId', promptId)
      .eq('topic.projectId', projectId)
      .eq('prompt.isDeleted', false)
      .in('completionStatus', [
        CompletionStatus.Complete,
        CompletionStatus.Published,
      ])
      .neq('contentStrategy', 'CLUSTER')
      .neq('body', '');

    if (contentType) {
      query = query.eq('contentType', contentType);
    }

    const { data, error } = await query.order('createdAt', {
      ascending: false,
    });

    if (error) {
      throw mapSqlError(error);
    }

    if (!data || data.length === 0) {
      return null;
    }

    // Pick the one with the most retrievedPages
    const contents = data as ContentWithRelations[];
    return contents.reduce((best, current) => {
      const bestPages = Array.isArray(best.retrievedPages)
        ? (best.retrievedPages as any[]).length
        : 0;
      const currentPages = Array.isArray(current.retrievedPages)
        ? (current.retrievedPages as any[]).length
        : 0;
      return currentPages > bestPages ? current : best;
    }, contents[0]);
  }

  async findExistingPlatformsByPromptId(
    promptId: string,
    projectId: string,
  ): Promise<string[]> {
    const { data, error } = await this.supabase
      .from(CONTENT_TABLE)
      .select('platform, topic:Topic!Content_topicId_fkey!inner(projectId)')
      .eq('promptId', promptId)
      .eq('topic.projectId', projectId)
      .eq('contentType', 'social_media_post')
      .in('completionStatus', [
        CompletionStatus.Complete,
        CompletionStatus.Published,
      ])
      .neq('body', '')
      .not('platform', 'is', null);

    if (error) {
      throw mapSqlError(error);
    }

    return [...new Set((data || []).map((r) => r.platform as string))];
  }

  async findByProjectId(projectId: string): Promise<ContentWithRelations[]> {
    const { data, error } = await this.supabase
      .from(CONTENT_TABLE)
      .select(
        `
        *,
        prompt:Prompt!Content_promptId_fkey (
          id,
          content,
          type,
          isDeleted
        ),
        topic:Topic!Content_topicId_fkey!inner (
          id,
          name,
          projectId,
          isDeleted
        ),
        profile:ContentProfile!Content_profileId_fkey (
          id,
          name,
          voiceAndTone,
          audience,
          description
        )
      `,
      )
      .eq('topic.projectId', projectId)
      .eq('topic.isDeleted', false)
      .eq('prompt.isDeleted', false)
      .order('createdAt', { ascending: false });

    if (error) {
      throw mapSqlError(error);
    }

    return data as ContentWithRelations[];
  }

  async findAllPublishedBlogs(limit?: number): Promise<ContentWithRelations[]> {
    const SELECT = `
        *,
        prompt:Prompt!Content_promptId_fkey (
          id,
          content,
          type,
          isDeleted
        ),
        topic:Topic!Content_topicId_fkey!inner (
          id,
          name,
          projectId,
          isDeleted
        ),
        profile:ContentProfile!Content_profileId_fkey (
          id,
          name,
          voiceAndTone,
          audience,
          description
        )
      `;

    if (limit) {
      const { data, error } = await this.supabase
        .from(CONTENT_TABLE)
        .select(SELECT)
        .eq('completionStatus', CompletionStatus.Published)
        .eq('contentType', 'blog_post')
        .eq('topic.isDeleted', false)
        .eq('prompt.isDeleted', false)
        .order('createdAt', { ascending: false })
        .limit(limit);

      if (error) throw mapSqlError(error);
      return data as ContentWithRelations[];
    }

    // Paginate to bypass Supabase's 1000-row default cap
    const PAGE_SIZE = 1000;
    const all: ContentWithRelations[] = [];
    let from = 0;

    while (true) {
      const { data, error } = await this.supabase
        .from(CONTENT_TABLE)
        .select(SELECT)
        .eq('completionStatus', CompletionStatus.Published)
        .eq('contentType', 'blog_post')
        .eq('topic.isDeleted', false)
        .eq('prompt.isDeleted', false)
        .order('createdAt', { ascending: false })
        .range(from, from + PAGE_SIZE - 1);

      if (error) throw mapSqlError(error);
      all.push(...(data as ContentWithRelations[]));
      if (data.length < PAGE_SIZE) break;
      from += PAGE_SIZE;
    }

    return all;
  }

  async getNewContentStats(
    projectId: string,
    start: string,
    end: string,
  ): Promise<{
    newContentCreated: number;
    socialMediaPublishedContent: number;
    systemGeneratedContent: number;
    userCreatedContent: number;
  }> {
    const allContentCountQuery = this.supabase
      .from(CONTENT_TABLE)
      .select('id, topic:Topic!inner(projectId)', {
        count: 'exact',
      })
      .eq('topic.projectId', projectId)
      .in('completionStatus', ['COMPLETE', 'PUBLISHED'])
      .gte('createdAt', start)
      .lte('createdAt', end);

    const publishedToSocialMediaCountQuery = this.supabase
      .from(CONTENT_TABLE)
      .select('id, topic:Topic!inner(projectId)', {
        count: 'exact',
      })
      .eq('topic.projectId', projectId)
      .eq('completionStatus', 'PUBLISHED')
      .not('platform', 'is', null)
      .not('publishedAt', 'is', null)
      .gte('createdAt', start)
      .lte('createdAt', end);

    const systemGeneratedContentCountQuery = this.supabase
      .from(TASK_TABLE)
      .select('id', {
        count: 'exact',
      })
      .eq('projectId', projectId)
      .eq('status', 'DONE')
      .gte('finishedAt', start)
      .lte('finishedAt', end);

    const [
      { count: newContentCreated, error: generatedError },
      { count: socialMediaPublishedContent, error: socialPublishedError },
      { count: systemGeneratedContent, error: systemGeneratedError },
    ] = await Promise.all([
      allContentCountQuery,
      publishedToSocialMediaCountQuery,
      systemGeneratedContentCountQuery,
    ]);

    const error =
      generatedError || socialPublishedError || systemGeneratedError;

    if (error) {
      throw mapSqlError(error);
    }

    return {
      newContentCreated: newContentCreated || 0,
      socialMediaPublishedContent: socialMediaPublishedContent || 0,
      systemGeneratedContent: systemGeneratedContent || 0,
      userCreatedContent:
        (newContentCreated || 0) - (systemGeneratedContent || 0),
    };
  }

  async findAllByProjectIdPaginated(
    projectId: string,
    params: ContentQueryDto,
  ): Promise<{ data: ContentWithRelations[]; total: number }> {
    let query = this.supabase
      .from(CONTENT_TABLE)
      .select(
        `
        *,
        prompt:Prompt!Content_promptId_fkey (
          id,
          content,
          type,
          isDeleted
        ),
        topic:Topic!Content_topicId_fkey!inner (
          id,
          name,
          projectId,
          isDeleted
        ),
        profile:ContentProfile!Content_profileId_fkey (
          id,
          name,
          voiceAndTone,
          audience,
          description
        )
      `,
        { count: 'exact' },
      )
      .eq('topic.projectId', projectId)
      .eq('topic.isDeleted', false);

    if (params.search) {
      query = query.or(`title.ilike.%${params.search}%`);
    }

    if (params.status && params.status.length > 0) {
      query = query.in('completionStatus', params.status);
    }

    if (params.topicName && params.topicName.length > 0) {
      query = query.in('topic.name', params.topicName);
    }

    if (params.startDate) {
      const startDate = new Date(params.startDate);
      if (!Number.isNaN(startDate.getTime())) {
        startDate.setHours(0, 0, 0, 0);
        query = query.gte('createdAt', startDate.toISOString());
      }
    }

    if (params.endDate) {
      const endDate = new Date(params.endDate);
      if (!Number.isNaN(endDate.getTime())) {
        endDate.setHours(23, 59, 59, 999);
        query = query.lte('createdAt', endDate.toISOString());
      }
    }

    if (params.contentType) {
      query = query.eq('contentType', params.contentType);
    }

    if (params.platform) {
      query = query.eq('platform', params.platform);
    }

    const from = params.skip;
    const to = from + params.take - 1;

    const { data, error, count } = await query
      .range(from, to)
      .order('createdAt', { ascending: false });

    if (error) {
      this.logger.error('findAllByProjectIdPaginated error', error);
      throw mapSqlError(error);
    }

    return { data: data as ContentWithRelations[], total: count || 0 };
  }

  async findByIdWithRelations(
    id: string,
  ): Promise<ContentWithRelations | null> {
    const { data, error } = await this.supabase
      .from(CONTENT_TABLE)
      .select(
        `
        *,
        prompt:Prompt!Content_promptId_fkey (
          id,
          content,
          type
        ),
        topic:Topic!Content_topicId_fkey!inner (
          id,
          name,
          projectId
        ),
        profile:ContentProfile!Content_profileId_fkey (
          id,
          name,
          voiceAndTone,
          audience,
          description
        )
      `,
      )
      .eq('id', id)
      .single();

    if (error) {
      if (error.code === 'PGRST116') {
        return null;
      }
      throw mapSqlError(error);
    }
    return data as ContentWithRelations;
  }

  async findByIdWithAccess(
    id: string,
    userId: string,
  ): Promise<Content | null> {
    const { data, error } = await this.supabase
      .from(CONTENT_TABLE)
      .select(
        `
        *,
        topic:Topic!Content_topicId_fkey!inner(
          project:Project!inner(
            projectMembers:Project_Member!inner(userId)
          )
        )
      `,
      )
      .eq('id', id)
      .eq('topic.project.projectMembers.userId', userId)
      .maybeSingle();

    if (error) {
      throw mapSqlError(error);
    }
    return data;
  }

  async findManyByIdsWithAccess(
    ids: string[],
    userId: string,
  ): Promise<Content[]> {
    const { data, error } = await this.supabase
      .from(CONTENT_TABLE)
      .select(
        `
        *,
        topic:Topic!Content_topicId_fkey!inner(
          project:Project!inner(
            projectMembers:Project_Member!inner(userId)
          )
        )
      `,
      )
      .in('id', ids)
      .eq('topic.project.projectMembers.userId', userId);

    if (error) {
      throw mapSqlError(error);
    }
    return data as Content[];
  }

  async deleteMany(ids: string[]): Promise<void> {
    const { error } = await this.supabase
      .from(CONTENT_TABLE)
      .delete()
      .in('id', ids);

    if (error) {
      throw mapSqlError(error);
    }
  }

  async deleteFailedContentOlderThan(olderThan: string): Promise<number> {
    const { data, error } = await this.supabase
      .from(CONTENT_TABLE)
      .delete()
      .eq('completionStatus', CompletionStatus.Failed)
      .lt('createdAt', olderThan)
      .select('id');

    if (error) {
      throw mapSqlError(error);
    }

    return data?.length ?? 0;
  }

  async publishContent(
    id: string,
    publishedAt: string,
    publishedBody: string,
  ): Promise<boolean> {
    const { data, error } = await this.supabase
      .from(CONTENT_TABLE)
      .update({
        completionStatus: 'PUBLISHED' as any,
        publishedAt,
        publishedBody,
      } as any)
      .eq('id', id)
      .eq('completionStatus', 'COMPLETE')
      .select('id');

    if (error) {
      throw mapSqlError(error);
    }

    return data !== null && data.length > 0;
  }

  async unpublishContent(id: string): Promise<boolean> {
    const { data, error } = await this.supabase
      .from(CONTENT_TABLE)
      .update({
        completionStatus: 'COMPLETE',
        publishedAt: null,
        publishedBody: null,
      })
      .eq('id', id)
      .eq('completionStatus', 'PUBLISHED' as any)
      .select('id');

    if (error) {
      throw mapSqlError(error);
    }

    return data !== null && data.length > 0;
  }

  async republishContent(id: string, publishedBody: string): Promise<boolean> {
    const { data, error } = await this.supabase
      .from(CONTENT_TABLE)
      .update({ publishedBody } as any)
      .eq('id', id)
      .eq('completionStatus', 'PUBLISHED' as any)
      .select('id');

    if (error) {
      throw mapSqlError(error);
    }

    return data !== null && data.length > 0;
  }

  async findByJobId(jobId: string): Promise<ContentWithRelations | null> {
    const { data, error } = await this.supabase
      .from(CONTENT_TABLE)
      .select(
        `
        *,
        prompt:Prompt!Content_promptId_fkey (
          id,
          content,
          type
        ),
        topic:Topic!Content_topicId_fkey!inner (
          id,
          name,
          projectId
        ),
        profile:ContentProfile!Content_profileId_fkey (
          id,
          name,
          voiceAndTone,
          audience,
          description
        )
      `,
      )
      .eq('jobId', jobId)
      .order('createdAt', { ascending: false })
      .limit(1)
      .maybeSingle();

    if (error) {
      throw mapSqlError(error);
    }
    return data as ContentWithRelations | null;
  }

  async updateJobProgress(
    contentId: string,
    newStep: string,
  ): Promise<Content> {
    const { data: current, error: fetchError } = await this.supabase
      .from(CONTENT_TABLE)
      .select('stepHistory')
      .eq('id', contentId)
      .single();

    if (fetchError) {
      throw mapSqlError(fetchError);
    }

    const currentHistory = (current?.stepHistory as string[]) || [];
    const updatedHistory = [...currentHistory, newStep];

    const { data: result, error } = await this.supabase
      .from(CONTENT_TABLE)
      .update({ stepHistory: updatedHistory as any })
      .eq('id', contentId)
      .select()
      .single();

    if (error) {
      throw mapSqlError(error);
    }

    return result;
  }
}
