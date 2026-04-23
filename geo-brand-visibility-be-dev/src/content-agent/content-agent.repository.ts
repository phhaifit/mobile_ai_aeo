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
import { AgentType } from './dto/content-agent.dto';
import { AgentExecutionQueryDto } from './dto/agent-execution-query.dto';
import { createPaginatedResponse } from '../utils/common';

const CONTENT_AGENT_TABLE = 'ContentAgent';
const TASK_TABLE = 'Task';

export interface BlogQueueItem {
  promptId: string;
  referenceUrl: string | null;
  contentProfileId: string | null;
  contentAgentId: string;
  userId: string;
}

export interface SocialMediaQueueItem {
  promptId: string;
  referenceUrl: string | null;
  platform: string;
  contentProfileId: string | null;
  contentAgentId: string;
  userId: string;
}

export type ContentAgent = Tables<'ContentAgent'>;
export type ContentAgentInsert = TablesInsert<'ContentAgent'>;
export type ContentAgentUpdate = TablesUpdate<'ContentAgent'>;

export interface AgentTaskPayload {
  userId: string;
  keywords: string[];
  promptId: string;
  projectId: string;
  contentType: string;
  contentAgentId: string;
  contentProfileId: string;
}

interface AgentTaskResult {
  results?: {
    contentId?: string;
    body?: string;
  };
  reason?: string;
  error?: string;
}

@Injectable()
export class ContentAgentRepository {
  private readonly logger = new Logger(ContentAgentRepository.name);

  constructor(
    @Inject(SUPABASE) private readonly supabase: SupabaseClient<Database>,
  ) {}

  async seedDefaults(projectId: string): Promise<void> {
    const defaults: ContentAgentInsert[] = [
      {
        projectId,
        agentType: AgentType.SOCIAL_MEDIA_GENERATOR,
        isActive: false,
      },
      {
        projectId,
        agentType: AgentType.BLOG_GENERATOR,
        isActive: false,
      },
    ];

    const { error } = await this.supabase
      .from(CONTENT_AGENT_TABLE)
      .insert(defaults);

    if (error) {
      throw mapSqlError(error);
    }
  }

  async findActiveAgentsByProjectId(projectId: string) {
    const { data, error } = await this.supabase
      .from(CONTENT_AGENT_TABLE)
      .select('*')
      .eq('projectId', projectId)
      .eq('isActive', true);

    if (error) {
      throw mapSqlError(error);
    }

    return data;
  }

  async findByProjectId(projectId: string) {
    const { data, error } = await this.supabase
      .from(CONTENT_AGENT_TABLE)
      .select('*')
      .eq('projectId', projectId)
      .order('agentType', { ascending: true });

    if (error) {
      throw mapSqlError(error);
    }

    return data;
  }

  async findById(id: string) {
    const { data, error } = await this.supabase
      .from(CONTENT_AGENT_TABLE)
      .select('*')
      .eq('id', id)
      .single();

    if (error) {
      throw mapSqlError(error);
    }

    return data;
  }

  async update(id: string, data: ContentAgentUpdate) {
    const { data: result, error } = await this.supabase
      .from(CONTENT_AGENT_TABLE)
      .update(data)
      .eq('id', id)
      .select()
      .single();

    if (error) {
      throw mapSqlError(error);
    }

    return result;
  }

  async deactivateAllAgents(projectId: string) {
    const { error } = await this.supabase
      .from(CONTENT_AGENT_TABLE)
      .update({ isActive: false })
      .eq('projectId', projectId);

    if (error) {
      throw mapSqlError(error);
    }
  }

  async getAvailableBlogPromptCount(projectId: string): Promise<number> {
    const { count, error } = await this.supabase
      .from('Prompt')
      .select('id, Topic!inner(id)', { count: 'exact', head: true })
      .eq('Topic.projectId', projectId)
      .eq('Topic.isDeleted', false)
      .eq('status', 'active')
      .eq('isExhausted', false);

    if (error) {
      this.logger.warn(
        `Failed to count available blog prompts for project ${projectId}: ${error.message}`,
      );
      return 0;
    }

    return count ?? 0;
  }

  async getAgentStats(projectId: string) {
    const { data: tasks, error } = await this.supabase
      .from(TASK_TABLE)
      .select('status, payload')
      .eq('projectId', projectId)
      .not('payload', 'is', null);

    if (error) {
      throw mapSqlError(error);
    }

    const agentTasks = tasks.filter(
      (t) => (t.payload as unknown as AgentTaskPayload)?.contentAgentId,
    );

    const successCount = agentTasks.filter((t) => t.status === 'DONE').length;
    const failCount = agentTasks.filter((t) => t.status === 'FAILED').length;
    const totalCount = successCount + failCount;
    const successRate = totalCount > 0 ? (successCount / totalCount) * 100 : 0;

    return {
      successRate: Math.round(successRate * 10) / 10,
      successCount,
      failCount,
    };
  }

  async getAgentExecutions(projectId: string, query: AgentExecutionQueryDto) {
    const from = query.skip;
    const to = from + query.take - 1;

    let supabaseQuery = this.supabase
      .from(TASK_TABLE)
      .select('*', { count: 'exact' })
      .eq('projectId', projectId)
      .not('payload', 'is', null)
      .filter('payload->>contentAgentId', 'neq', 'null');

    supabaseQuery = supabaseQuery.neq('status', 'PENDING');

    if (query.agentType) {
      const { data: agentsOfThisType } = await this.supabase
        .from(CONTENT_AGENT_TABLE)
        .select('id')
        .eq('projectId', projectId)
        .in('agentType', query.agentType);

      const agentIds = agentsOfThisType?.map((a) => a.id) || [];
      if (agentIds.length > 0) {
        supabaseQuery = supabaseQuery.in('payload->>contentAgentId', agentIds);
      } else {
        return createPaginatedResponse([], 0, query, (item) => item);
      }
    }

    if (query.startDate) {
      supabaseQuery = supabaseQuery.gte(
        'createdAt',
        query.startDate.toISOString(),
      );
    }

    if (query.endDate) {
      supabaseQuery = supabaseQuery.lte(
        'createdAt',
        query.endDate.toISOString(),
      );
    }

    const {
      data: tasks,
      error,
      count,
    } = await supabaseQuery
      .order('createdAt', { ascending: false })
      .range(from, to);

    if (error) {
      throw mapSqlError(error);
    }

    // Get ContentAgent details to get agentType
    const agentIds = [
      ...new Set(
        tasks.map(
          (t) => (t.payload as unknown as AgentTaskPayload).contentAgentId,
        ),
      ),
    ];
    const { data: agents } = await this.supabase
      .from(CONTENT_AGENT_TABLE)
      .select('id, agentType')
      .in('id', agentIds);

    const agentMap = new Map(agents?.map((a) => [a.id, a.agentType]));

    const contentIds = tasks
      .map((t) => (t.result as unknown as AgentTaskResult)?.results?.contentId)
      .filter(Boolean) as string[];

    let contentMap = new Map<
      string,
      {
        title: string;
        completionStatus: string;
        slug: string;
        platform: string | null;
      }
    >();
    if (contentIds.length > 0) {
      const { data: contents } = await this.supabase
        .from('Content')
        .select('id, title, completionStatus, slug, platform')
        .in('id', contentIds);
      contentMap = new Map(
        contents?.map((c) => [
          c.id,
          {
            title: c.title ?? '',
            completionStatus: c.completionStatus ?? '',
            slug: c.slug ?? '',
            platform: c.platform ?? null,
          },
        ]),
      );
    }

    const mappedData = tasks.map((t) => {
      const payload = t.payload as unknown as AgentTaskPayload;
      const result = t.result as unknown as AgentTaskResult;
      const contentId = result?.results?.contentId;

      const content = contentId ? contentMap.get(contentId) : undefined;

      return {
        id: t.id,
        createdAt: t.createdAt,
        startedAt: t.startedAt ?? null,
        agentType: agentMap.get(payload.contentAgentId) || 'N/A',
        contentAgentId: payload.contentAgentId,
        articleId: contentId || null,
        articleTitle: content?.title || null,
        articleCompletionStatus: content?.completionStatus || null,
        articleSlug: content?.slug || null,
        articlePlatform: content?.platform || null,
        status: t.status,
        reason: result?.reason || result?.error || null,
        durationSeconds:
          t.startedAt && t.finishedAt
            ? Math.round(
                (new Date(t.finishedAt).getTime() -
                  new Date(t.startedAt).getTime()) /
                  1000,
              )
            : null,
      };
    });

    return createPaginatedResponse(
      mappedData,
      count || 0,
      query,
      (item) => item,
    );
  }

  async getPromptsForBlogScheduler(
    projectId: string,
    maxTasks = 100,
  ): Promise<BlogQueueItem[]> {
    const { data, error } = await this.supabase.rpc(
      'get_prompts_for_blog_scheduler',
      { p_project_id: projectId, p_max_tasks: maxTasks },
    );

    if (error) {
      throw mapSqlError(error);
    }

    return (data as BlogQueueItem[]) || [];
  }

  async getPromptsForSocialMediaScheduler(
    projectId: string,
    maxTasks = 100,
  ): Promise<SocialMediaQueueItem[]> {
    const { data, error } = await this.supabase.rpc(
      'get_prompts_for_social_media_scheduler',
      { p_project_id: projectId, p_max_tasks: maxTasks },
    );

    if (error) {
      throw mapSqlError(error);
    }

    return (data as SocialMediaQueueItem[]) || [];
  }
}
