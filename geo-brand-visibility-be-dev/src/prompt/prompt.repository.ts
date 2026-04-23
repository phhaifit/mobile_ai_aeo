import { Inject, Injectable } from '@nestjs/common';
import { SUPABASE } from '../utils/const';
import { SupabaseClient } from '@supabase/supabase-js';
import {
  Database,
  Json,
  Tables,
  TablesInsert,
  TablesUpdate,
} from '../supabase/supabase.types';
import { mapSqlError } from '../utils/map-sql-error.util';

const PROMPT_TABLE = 'Prompt';
type Prompt = Tables<'Prompt'> & {
  topicName: string;
  keywords?: string[];
  latestResults?: Json;
  projectLocation?: string;
};
type PromptUpdate = TablesUpdate<'Prompt'>;
type PromptInsert = TablesInsert<'Prompt'>;
type PromptWithTotalCount = Prompt & {
  totalCount: number;
};
export type ResponseInsert =
  Database['public']['Functions']['insert_response']['Args'];
export type PromptsInsert =
  Database['public']['Functions']['insert_prompts']['Args'];

const RESPONSE_TABLE = 'Response';
export type ResponseForMetrics = {
  id: string;
  position: number | null;
  isCited: boolean;
  model: {
    id: string;
    name: string;
  };
  citations: {
    url: string;
    title: string | null;
    domain: string;
  }[];
  competitors: {
    name: string;
    position: number;
  }[];
};

type Response = {
  id: string;
  response: string;
  relatedQuestions: string[];
  model: {
    id: string;
    name: string;
  };
  citations: {
    url: string;
    title: string | null;
    domain: string;
  }[];
};

export type AnalysisResult = {
  id: string;
  position: number | null;
  createdAt: string;
  model: {
    id: string;
    name: string;
  };
  citations: {
    url: string;
    domain: string;
  }[];
  competitors: {
    competitor: {
      id: string;
      name: string;
    };
    position: number;
  }[];
  prompt: {
    topic: {
      projectId: string;
    };
  };
};

export type PromptBatchItem = {
  id: string;
  topic: {
    id: string;
    keywords: { keyword: string }[];
    project: {
      id: string;
      contentProfile: { id: string }[];
    };
  };
  [key: string]: any;
};

@Injectable()
export class PromptRepository {
  constructor(
    @Inject(SUPABASE) private readonly supabase: SupabaseClient<Database>,
  ) {}

  async getProjectIdByPromptId(
    promptId: string,
    userId: string,
  ): Promise<string | null> {
    const { data, error } = await this.supabase
      .from(PROMPT_TABLE)
      .select(
        'id, topic:Topic!inner(projectId, project:Project!inner(projectMembers:Project_Member!inner(userId)))',
      )
      .eq('id', promptId)
      .eq('topic.project.projectMembers.userId', userId)
      .maybeSingle();

    if (error) {
      throw mapSqlError(error);
    }

    if (!data) {
      return null;
    }

    return data.topic.projectId;
  }

  async findAllByProjectId(
    projectId: string,
    userId: string,
  ): Promise<Prompt[]> {
    const { data, error } = await this.supabase
      .from(PROMPT_TABLE)
      .select(
        `
        *, 
        topic:Topic!inner(
          projectId, 
          name,
          project:Project!inner(
            projectMembers:Project_Member!inner(userId)
          )
        ),
        Prompt_Keyword(Keyword(keyword))
       `,
      )
      .eq('topic.project.projectMembers.userId', userId)
      .eq('topic.projectId', projectId)
      .eq('status', 'active')
      .eq('isDeleted', false)
      .order('createdAt', { ascending: true });

    if (error) {
      throw mapSqlError(error);
    }

    return data.map(({ topic, Prompt_Keyword, ...prompt }) => ({
      ...prompt,
      topicName: topic.name,
      // eslint-disable-next-line @typescript-eslint/no-unsafe-return,@typescript-eslint/no-unsafe-member-access
      keywords: Prompt_Keyword.map((pk: any) => pk.Keyword?.keyword).filter(
        (k: any): k is string => !!k,
      ),
    }));
  }

  async findPromptsWithLatestAnalysis(
    projectId: string,
    userId: string,
    pagination?: {
      page?: number;
      pageSize?: number;
    },
    filters?: {
      type?: Database['public']['Enums']['PromptType'][];
      isMonitored?: boolean;
    },
    search?: string,
  ): Promise<{ data: Prompt[]; total: number }> {
    if (pagination && pagination.page && pagination.pageSize) {
      const [{ data, error: rpcError }, { count: total, error: countError }] =
        await Promise.all([
          this.supabase.rpc(
            'get_prompts_with_latest_analysis_result_pagination',
            {
              p_project_id: projectId,
              p_user_id: userId,
              p_limit: pagination.pageSize,
              p_offset:
                pagination.page && pagination.pageSize
                  ? (pagination.page - 1) * pagination.pageSize
                  : 0,
              p_search: search,
              p_type:
                filters?.type && filters.type.length > 0
                  ? filters.type
                  : undefined,
              p_is_monitored: filters?.isMonitored,
            },
          ),
          (() => {
            let query = this.supabase
              .from(PROMPT_TABLE)
              .select(
                'id, topic:Topic!inner(projectId, project:Project!inner(projectMembers:Project_Member!inner(userId)))',
                {
                  count: 'exact',
                  head: true,
                },
              )
              .eq('topic.projectId', projectId)
              .eq('topic.project.projectMembers.userId', userId)
              .eq('status', 'active')
              .eq('isDeleted', false);

            if (search) {
              query = query.ilike('content', `%${search}%`);
            }

            if (filters?.type && filters.type.length > 0) {
              query = query.in('type', filters.type);
            }

            if (filters?.isMonitored !== undefined) {
              query = query.eq('isMonitored', filters.isMonitored);
            }

            return query;
          })(),
        ]);

      if (rpcError) {
        throw mapSqlError(rpcError);
      }

      if (countError) {
        throw mapSqlError(countError);
      }

      return {
        data,
        total: total ?? 0,
      };
    }

    const { data, error } = await this.supabase.rpc(
      'get_prompts_with_latest_analysis_result',
      {
        p_project_id: projectId,
        p_user_id: userId,
      },
    );

    if (error) {
      throw mapSqlError(error);
    }

    return { data, total: data.length };
  }

  async getPromptStatsByProjectId(projectId: string): Promise<{
    totalCount: number;
    monitoredCount: number;
    exhaustedCount: number;
  }> {
    const { data, error } = await this.supabase
      .from(PROMPT_TABLE)
      .select(
        `
        id,
        isMonitored,
        isExhausted,
        topic:Topic!inner(
          projectId
        )
      `,
      )
      .match({
        'topic.projectId': projectId,
        'topic.isDeleted': false,
        status: 'active',
        isDeleted: false,
      });

    if (error) {
      throw mapSqlError(error);
    }

    const rows = data ?? [];

    for (const row of rows) {
      if (!row.isExhausted) {
        console.log('row::', row);
      }
    }
    return {
      totalCount: rows.length,
      monitoredCount: rows.filter((p) => p.isMonitored).length,
      exhaustedCount: rows.filter((p) => p.isExhausted).length,
    };
  }

  async findAllMonitoredPromptsByProjectId(
    projectId: string,
    userId: string,
  ): Promise<Prompt[]> {
    const { data, error } = await this.supabase
      .from(PROMPT_TABLE)
      .select(
        `
        *, 
        topic:Topic!inner(
          projectId, 
          name,
          project:Project!inner(
            projectMembers:Project_Member!inner(userId)
          )
        ),
        Prompt_Keyword(Keyword(keyword))
       `,
      )
      .eq('topic.project.projectMembers.userId', userId)
      .eq('topic.projectId', projectId)
      .match({
        isMonitored: true,
        status: 'active',
        isDeleted: false,
      })
      .match({
        'topic.isMonitored': true,
        'topic.isDeleted': false,
      })
      .order('createdAt', { ascending: true });

    if (error) {
      throw mapSqlError(error);
    }

    return data.map(({ topic, Prompt_Keyword, ...prompt }) => ({
      ...prompt,
      topicName: topic.name,
      // eslint-disable-next-line @typescript-eslint/no-unsafe-return,@typescript-eslint/no-unsafe-member-access
      keywords: Prompt_Keyword.map((pk: any) => pk.Keyword?.keyword).filter(
        (k: any): k is string => !!k,
      ),
    }));
  }

  async findAllByTopicId(
    topicId: string,
    userId: string,
    includeAllStatuses = false,
  ): Promise<Prompt[]> {
    const query = this.supabase
      .from(PROMPT_TABLE)
      .select(
        `
        *, 
        topic:Topic!inner(
          name,
          project:Project!inner(
            id,
            projectMembers:Project_Member!inner(userId)
          )
        ), 
        Prompt_Keyword(Keyword(keyword))
       `,
      )
      .eq('topicId', topicId)
      .eq('topic.project.projectMembers.userId', userId);

    if (!includeAllStatuses) {
      query.eq('status', 'active');
    }

    query.eq('isDeleted', false);
    query.order('createdAt', { ascending: true });

    const { data, error } = await query;

    if (error) {
      throw mapSqlError(error);
    }

    return data.map(({ topic, Prompt_Keyword, ...prompt }) => ({
      ...prompt,
      topicName: topic.name,
      // eslint-disable-next-line @typescript-eslint/no-unsafe-return,@typescript-eslint/no-unsafe-member-access
      keywords: Prompt_Keyword.map((pk: any) => pk.Keyword?.keyword).filter(
        (k: any): k is string => !!k,
      ),
    }));
  }

  async findPromptsWithLatestAnalysisByTopicId(
    topicId: string,
    userId: string,
    pagination?: {
      page?: number;
      pageSize?: number;
    },
    filters?: {
      type?: Database['public']['Enums']['PromptType'][];
      isMonitored?: boolean;
    },
    search?: string,
  ): Promise<{ data: Prompt[]; total: number }> {
    if (pagination && pagination.page && pagination.pageSize) {
      const [{ data, error: rpcError }, { count: total, error: countError }] =
        await Promise.all([
          this.supabase.rpc(
            'get_prompts_with_latest_analysis_result_by_topic_pagination',
            {
              p_topic_id: topicId,
              p_user_id: userId,
              p_limit: pagination.pageSize,
              p_offset: (pagination.page - 1) * pagination.pageSize,
              p_search: search,
              p_type:
                filters?.type && filters.type.length > 0
                  ? filters.type
                  : undefined,
              p_is_monitored: filters?.isMonitored,
            },
          ),
          (() => {
            let query = this.supabase
              .from(PROMPT_TABLE)
              .select(
                'id, topic:Topic!inner(projectId, project:Project!inner(projectMembers:Project_Member!inner(userId)))',
                {
                  count: 'exact',
                  head: true,
                },
              )
              .eq('topic.id', topicId)
              .eq('topic.project.projectMembers.userId', userId)
              .eq('status', 'active')
              .eq('isDeleted', false);

            if (search) {
              query = query.ilike('content', `%${search}%`);
            }

            if (filters?.type && filters.type.length > 0) {
              query = query.in('type', filters.type);
            }

            if (filters?.isMonitored !== undefined) {
              query = query.eq('isMonitored', filters.isMonitored);
            }

            return query;
          })(),
        ]);

      if (rpcError) {
        throw mapSqlError(rpcError);
      }

      if (countError) {
        throw mapSqlError(countError);
      }

      return {
        data,
        total: total ?? 0,
      };
    }

    const { data, error } = await this.supabase.rpc(
      'get_prompts_with_latest_analysis_result_by_topic',
      {
        p_topic_id: topicId,
        p_user_id: userId,
      },
    );

    if (error) {
      throw mapSqlError(error);
    }

    return { data, total: data.length };
  }

  async insert(data: PromptsInsert) {
    const { error } = await this.supabase.rpc('insert_prompts', data);

    if (error) {
      throw mapSqlError(error);
    }
  }

  async findSuggestedByProjectId(
    projectId: string,
    pagination?: { page?: number; pageSize?: number },
    filters?: {
      type?: Database['public']['Enums']['PromptType'][];
      isMonitored?: boolean;
    },
    search?: string,
  ): Promise<{ data: Prompt[]; total: number }> {
    const query = this.supabase
      .from(PROMPT_TABLE)
      .select(
        '*, topic:Topic!inner(projectId, name), Prompt_Keyword(Keyword(keyword))',
        { count: 'exact' },
      )
      .eq('topic.projectId', projectId)
      .eq('status', 'suggested')
      .eq('isDeleted', false)
      .order('createdAt', { ascending: false });

    if (pagination?.page && pagination?.pageSize) {
      query.range(
        (pagination.page - 1) * pagination.pageSize,
        pagination.page * pagination.pageSize - 1,
      );
    }

    if (filters?.type && filters.type.length > 0) {
      query.in('type', filters.type);
    }

    if (filters?.isMonitored !== undefined) {
      query.eq('isMonitored', filters.isMonitored);
    }

    if (search) {
      query.ilike('content', `%${search}%`);
    }

    const { data, error, count } = await query;

    if (error) {
      throw mapSqlError(error);
    }

    return {
      data: (data || []).map(({ topic, Prompt_Keyword, ...prompt }) => ({
        ...prompt,
        topicName: topic.name,
        keywords: Prompt_Keyword.map((pk: any) => pk.Keyword?.keyword).filter(
          (k: any): k is string => !!k,
        ),
      })),
      total: count ?? 0,
    };
  }

  async findSuggestedByTopicId(
    topicId: string,
    pagination?: { page?: number; pageSize?: number },
    filters?: {
      type?: Database['public']['Enums']['PromptType'][];
      isMonitored?: boolean;
    },
    search?: string,
  ): Promise<{ data: Prompt[]; total: number }> {
    const query = this.supabase
      .from(PROMPT_TABLE)
      .select('*, topic:Topic!inner(name), Prompt_Keyword(Keyword(keyword))', {
        count: 'exact',
      })
      .eq('topicId', topicId)
      .eq('status', 'suggested')
      .eq('isDeleted', false)
      .order('createdAt', { ascending: false });

    if (pagination && pagination.page && pagination.pageSize) {
      query.range(
        (pagination.page - 1) * pagination.pageSize,
        pagination.page * pagination.pageSize - 1,
      );
    }

    if (filters?.type && filters.type.length > 0) {
      query.in('type', filters.type);
    }

    if (filters?.isMonitored !== undefined) {
      query.eq('isMonitored', filters.isMonitored);
    }

    if (search) {
      query.ilike('content', `%${search}%`);
    }

    const { data, error, count } = await query;

    if (error) {
      throw mapSqlError(error);
    }

    return {
      data: data.map(({ topic, Prompt_Keyword, ...prompt }) => ({
        ...prompt,
        topicName: topic.name,
        // eslint-disable-next-line @typescript-eslint/no-unsafe-return,@typescript-eslint/no-unsafe-member-access
        keywords: Prompt_Keyword.map((pk: any) => pk.Keyword?.keyword).filter(
          (k: any): k is string => !!k,
        ),
      })),
      total: count ?? 0,
    };
  }

  async insertPromptsForTopic(
    topicId: string,
    prompts: Array<{
      content: string;
      type: Database['public']['Enums']['PromptType'];
      keywordIds?: string[];
    }>,
    status: string,
    isMonitored?: boolean,
  ): Promise<void> {
    const inserts = prompts.map((prompt) => ({
      topicId,
      content: prompt.content,
      type: prompt.type,
      status,
      ...(isMonitored !== undefined && { isMonitored }),
    }));

    const { data: insertedPrompts, error } = await this.supabase
      .from(PROMPT_TABLE)
      .insert(inserts)
      .select('id, content');

    if (error) {
      throw mapSqlError(error);
    }

    if (!insertedPrompts) return;

    // Create a map of content to promptId to associate keywords
    const contentToIdMap = new Map<string, string>();
    insertedPrompts.forEach((p) => contentToIdMap.set(p.content, p.id));

    const keywordInserts: { promptId: string; keywordId: string }[] = [];

    prompts.forEach((p) => {
      const promptId = contentToIdMap.get(p.content);
      if (promptId && p.keywordIds && p.keywordIds.length > 0) {
        p.keywordIds.forEach((keywordId) => {
          keywordInserts.push({
            promptId,
            keywordId,
          });
        });
      }
    });

    if (keywordInserts.length > 0) {
      const { error: keywordError } = await this.supabase
        .from('Prompt_Keyword')
        .insert(keywordInserts);

      if (keywordError) {
        throw mapSqlError(keywordError);
      }
    }
  }

  async createOne(prompt: PromptInsert): Promise<Prompt> {
    const { data, error } = await this.supabase
      .from(PROMPT_TABLE)
      .insert(prompt)
      .select('*, topic:Topic!inner(name)')
      .single();

    if (error) {
      throw mapSqlError(error);
    }

    const { topic, ...rest } = data;
    return {
      ...rest,
      topicName: topic.name,
    };
  }

  async delete(id: string): Promise<void> {
    const { error } = await this.supabase
      .from(PROMPT_TABLE)
      .update({
        isDeleted: true,
      })
      .eq('id', id);

    if (error) {
      throw mapSqlError(error);
    }
  }

  async findDeletedByProjectId(
    projectId: string,
    pagination?: { page?: number; pageSize?: number },
    filters?: {
      type?: Database['public']['Enums']['PromptType'][];
      isMonitored?: boolean;
    },
    search?: string,
  ): Promise<{ data: Prompt[]; total: number }> {
    const query = this.supabase
      .from(PROMPT_TABLE)
      .select(
        '*, topic:Topic!inner(projectId, name), Prompt_Keyword(Keyword(keyword))',
        { count: 'exact' },
      )
      .eq('topic.projectId', projectId)
      .eq('status', 'inactive')
      .eq('isDeleted', false)
      .order('updatedAt', { ascending: false });

    if (pagination?.page && pagination?.pageSize) {
      query.range(
        (pagination.page - 1) * pagination.pageSize,
        pagination.page * pagination.pageSize - 1,
      );
    }

    if (filters?.type && filters.type.length > 0) {
      query.in('type', filters.type);
    }

    if (filters?.isMonitored !== undefined) {
      query.eq('isMonitored', filters.isMonitored);
    }

    if (search) {
      query.ilike('content', `%${search}%`);
    }

    const { data, error, count } = await query;

    if (error) {
      throw mapSqlError(error);
    }

    return {
      data: data.map(({ topic, Prompt_Keyword, ...prompt }) => ({
        ...prompt,
        topicName: topic.name,
        // eslint-disable-next-line @typescript-eslint/no-unsafe-return,@typescript-eslint/no-unsafe-member-access
        keywords: Prompt_Keyword.map((pk: any) => pk.Keyword?.keyword).filter(
          (k: any): k is string => !!k,
        ),
      })),
      total: count ?? 0,
    };
  }

  async findDeletedByTopicId(
    topicId: string,
    pagination?: { page?: number; pageSize?: number },
    filters?: {
      type?: Database['public']['Enums']['PromptType'][];
      isMonitored?: boolean;
    },
    search?: string,
  ): Promise<{ data: Prompt[]; total: number }> {
    const query = this.supabase
      .from(PROMPT_TABLE)
      .select('*, topic:Topic!inner(name), Prompt_Keyword(Keyword(keyword))', {
        count: 'exact',
      })
      .eq('topicId', topicId)
      .eq('status', 'inactive')
      .eq('isDeleted', false)
      .order('updatedAt', { ascending: false });

    if (pagination && pagination.page && pagination.pageSize) {
      query.range(
        (pagination.page - 1) * pagination.pageSize,
        pagination.page * pagination.pageSize - 1,
      );
    }

    if (filters?.type && filters.type.length > 0) {
      query.in('type', filters.type);
    }

    if (filters?.isMonitored !== undefined) {
      query.eq('isMonitored', filters.isMonitored);
    }

    if (search) {
      query.ilike('content', `%${search}%`);
    }

    const { data, error, count } = await query;

    if (error) {
      throw mapSqlError(error);
    }

    return {
      data: data.map(({ topic, Prompt_Keyword, ...prompt }) => ({
        ...prompt,
        topicName: topic.name,
        // eslint-disable-next-line @typescript-eslint/no-unsafe-return,@typescript-eslint/no-unsafe-member-access
        keywords: Prompt_Keyword.map((pk: any) => pk.Keyword?.keyword).filter(
          (k: any): k is string => !!k,
        ),
      })),
      total: count ?? 0,
    };
  }

  async hardDelete(id: string): Promise<void> {
    const { error } = await this.supabase
      .from(PROMPT_TABLE)
      .delete()
      .eq('id', id);

    if (error) {
      throw mapSqlError(error);
    }
  }
  async update(id: string, updates: PromptUpdate): Promise<Prompt | null> {
    const { data, error } = await this.supabase
      .from(PROMPT_TABLE)
      .update(updates)
      .eq('id', id)
      .select('*, topic:Topic!inner(name), Prompt_Keyword(Keyword(keyword))')
      .maybeSingle();

    if (error) {
      throw mapSqlError(error);
    }

    if (!data) {
      return null;
    }

    const { topic, Prompt_Keyword, ...prompt } = data;
    return {
      ...prompt,
      topicName: topic.name,
      // eslint-disable-next-line @typescript-eslint/no-unsafe-return,@typescript-eslint/no-unsafe-member-access
      keywords: Prompt_Keyword.map((pk: any) => pk.Keyword?.keyword).filter(
        (k: any): k is string => !!k,
      ),
    };
  }

  async getBlacklistedUrlsWithReasons(
    promptId: string,
  ): Promise<Array<{ url: string; reason: string | null }>> {
    const { data, error } = await this.supabase
      .from('BlacklistedUrl')
      .select('url, reason')
      .eq('promptId', promptId);

    if (error) {
      throw mapSqlError(error);
    }

    return (data ?? []) as Array<{ url: string; reason: string | null }>;
  }

  async getBlacklistedUrls(promptId: string): Promise<string[]> {
    const { data, error } = await this.supabase
      .from('BlacklistedUrl')
      .select('url')
      .eq('promptId', promptId);

    if (error) {
      throw mapSqlError(error);
    }

    return (data ?? []).map((row) => row.url);
  }

  async addBlacklistedUrl(
    promptId: string,
    url: string,
    reason?: string,
  ): Promise<void> {
    const { error } = await this.supabase
      .from('BlacklistedUrl')
      .upsert(
        { promptId, url, reason: reason ?? null },
        { onConflict: 'promptId,url', ignoreDuplicates: true },
      );

    if (error) {
      throw mapSqlError(error);
    }
  }

  async setExhausted(promptId: string, isExhausted: boolean): Promise<void> {
    const { error } = await this.supabase
      .from('Prompt')
      .update({ isExhausted })
      .eq('id', promptId);

    if (error) {
      throw mapSqlError(error);
    }
  }

  async insertResponse(response: ResponseInsert) {
    const { data, error } = await this.supabase.rpc(
      'insert_response',
      response,
    );
    if (error) {
      throw mapSqlError(error);
    }

    return data;
  }

  async getResponses(
    promptId: string,
    start: string,
    end: string,
    userId: string,
  ): Promise<Response[]> {
    const { data, error } = await this.supabase
      .from(RESPONSE_TABLE)
      .select(
        `
        id, 
        response, 
        relatedQuestions, 
        model:Model(id, name), 
        citations:Citation(url, title, domain),
        prompt:Prompt!inner(
          topic:Topic!inner(
            project:Project!inner(
              projectMembers:Project_Member!inner(userId)
            )
          )
        )
        `,
      )
      .eq('promptId', promptId)
      .eq('prompt.topic.project.projectMembers.userId', userId)
      .gte('createdAt', start)
      .lte('createdAt', end)
      .order('createdAt', { ascending: true });

    if (error) {
      throw mapSqlError(error);
    }

    return data.map(({ prompt: _prompt, ...response }) => response);
  }

  async findAllResponsesByProjectId(
    projectId: string,
    start: string,
    end: string,
    userId: string,
  ): Promise<ResponseForMetrics[]> {
    const { data, error } = await this.supabase
      .from(RESPONSE_TABLE)
      .select(
        `id, 
        position, 
        isCited, 
        model:Model(id, name), 
        citations:Citation(url, title, domain), 
        prompt:Prompt!inner(
          isDeleted,
          Topic!inner(
            projectId,
            project:Project!inner(
              projectMembers:Project_Member!inner(userId)
            )
          )
        ), 
        competitors:CompetitorAnalysisResult(
          Competitor(name), 
          position
        )`,
      )
      .eq('prompt.Topic.projectId', projectId)
      .eq('prompt.isDeleted', false)
      .eq('prompt.Topic.project.projectMembers.userId', userId)
      .gte('createdAt', start)
      .lte('createdAt', end);

    if (error) {
      throw mapSqlError(error);
    }

    return data.map(({ prompt: _prompt, ...rest }) => ({
      ...rest,
      competitors: rest.competitors.map((competitor) => ({
        name: competitor.Competitor.name,
        position: competitor.position,
      })),
    }));
  }

  async getAnalysisResultByProjectId(
    projectId: string,
    start: string,
    end: string,
  ) {
    const { data, error } = await this.supabase
      .from(RESPONSE_TABLE)
      .select(
        `id, 
        position, 
        isCited, 
        model:Model(id, name), 
        citations:Citation(url, title, domain), 
        prompt:Prompt!inner(
          id,
          content,
          isDeleted,
          Topic!inner(
            projectId
          )
        ), 
        competitors:CompetitorAnalysisResult(
          Competitor(name), 
          position
        )`,
      )
      .eq('prompt.Topic.projectId', projectId)
      .eq('prompt.isDeleted', false)
      .gte('createdAt', start)
      .lte('createdAt', end);

    if (error) {
      throw mapSqlError(error);
    }

    return data.map(({ prompt, ...rest }) => ({
      ...rest,
      promptId: prompt.id,
      prompt: prompt.content,
      competitors: rest.competitors.map((competitor) => ({
        name: competitor.Competitor.name,
        position: competitor.position,
      })),
    }));
  }

  async getNewPromptStats(
    projectId: string,
    start: string,
    end: string,
  ): Promise<{
    newPromptsCreated: number;
    newPromptsMentioningBrand: number;
  }> {
    const newPromptCountQuery = this.supabase
      .from(PROMPT_TABLE)
      .select('id, topic:Topic!inner(projectId)', {
        count: 'exact',
      })
      .eq('topic.projectId', projectId)
      .eq('isDeleted', false)
      .eq('topic.isDeleted', false)
      .gte('createdAt', start)
      .lte('createdAt', end);

    const newPromptMentioningBrandQuery = this.supabase
      .from(PROMPT_TABLE)
      .select(
        'id, topic:Topic!inner(projectId), response:Response!inner(promptId)',
      )
      .eq('topic.projectId', projectId)
      .eq('isDeleted', false)
      .eq('topic.isDeleted', false)
      .or('position.not.is.null,isCited.eq.true', { foreignTable: 'response' })
      .gte('createdAt', start)
      .lte('createdAt', end);

    const [
      { count: newPromptsCreated, error: newPromptsError },
      { data: promptsMentioningBrand, error: mentioningBrandError },
    ] = await Promise.all([newPromptCountQuery, newPromptMentioningBrandQuery]);

    const error = newPromptsError || mentioningBrandError;
    if (error) {
      throw mapSqlError(error);
    }

    return {
      newPromptsCreated: newPromptsCreated || 0,
      newPromptsMentioningBrand: new Set(
        (promptsMentioningBrand || []).map((prompt) => prompt.id),
      ).size,
    };
  }

  async getPromptById(id: string): Promise<Prompt | null> {
    const { data, error } = await this.supabase
      .from(PROMPT_TABLE)
      .select(
        `
        *,
        topic:Topic!inner(
          name,
          project:Project!inner(location)
        ),
        Prompt_Keyword(Keyword(keyword))
      `,
      )
      .eq('id', id)
      .maybeSingle();

    if (error) {
      throw mapSqlError(error);
    }

    if (!data) {
      return null;
    }

    const { topic, Prompt_Keyword, ...prompt } = data;
    return {
      ...prompt,
      topicName: topic.name,
      // eslint-disable-next-line @typescript-eslint/no-unsafe-return,@typescript-eslint/no-unsafe-member-access
      keywords: Prompt_Keyword.map((pk: any) => pk.Keyword?.keyword).filter(
        (k: any): k is string => !!k,
      ),
      projectLocation: topic.project.location,
    };
  }

  async getAnalysisResultById(
    promptId: string,
    start: string,
    end: string,
  ): Promise<AnalysisResult[] | null> {
    const { data, error } = await this.supabase
      .from(RESPONSE_TABLE)
      .select(
        `
        id,
        position,
        model:modelId ( id, name ),
        citations:Citation ( url, domain ),
        competitors:CompetitorAnalysisResult (
          competitor:competitorId ( id, name ),
          position
        ),
        prompt:Prompt!inner(
          topic:Topic!inner(projectId)
        ),
        createdAt
    `,
      )
      .eq('promptId', promptId)
      .gte('createdAt', start)
      .lte('createdAt', end);

    if (error) {
      throw mapSqlError(error);
    }

    return data;
  }

  async getPromptsForGenerateContentBatch(
    projectId: string,
    limit: number,
    offset: number,
    excludeIds?: string[],
  ): Promise<PromptBatchItem[]> {
    let query = this.supabase
      .from(PROMPT_TABLE)
      .select(
        `
        *,
        topic:Topic!inner(
          *,
          keywords:Keyword(keyword),
          project:Project!inner(
            *,
            contentProfile:ContentProfile(*)
          )
        ),
        content_count
      `,
      )
      .eq('status', 'active')
      .eq('topic.isDeleted', false)
      .eq('topic.projectId', projectId);

    if (excludeIds && excludeIds.length > 0) {
      query = query.not('id', 'in', `(${excludeIds.join(',')})`);
    }

    const { data, error } = await query
      .range(offset, offset + limit - 1)
      .order('content_count', { ascending: true })
      .order('createdAt', { ascending: true });

    if (error) throw mapSqlError(error);
    return (data as any) || [];
  }

  async getPromptWithProjectAndBrandById(promptId: string, userId: string) {
    const { data, error } = await this.supabase
      .from(PROMPT_TABLE)
      .select(
        `
        *,
        topic:Topic!inner(
          projectId,
          project:Project!inner(
            id,
            projectMembers:Project_Member!inner(userId),
            brand:Brand!inner(id, name, domain, industry),
            models:Model(id, name)
          )
        )
      `,
      )
      .eq('id', promptId)
      .eq('topic.project.projectMembers.userId', userId)
      .maybeSingle();

    if (error) {
      throw mapSqlError(error);
    }

    if (!data) {
      return null;
    }

    const { topic, ...prompt } = data;
    return {
      ...prompt,
      projectId: topic.projectId,
      brand: topic.project.brand,
      models: topic.project.models,
    };
  }
}
