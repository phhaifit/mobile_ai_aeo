import { Inject, Injectable } from '@nestjs/common';
import { SUPABASE } from '../utils/const';
import { SupabaseClient } from '@supabase/supabase-js';
import {
  Database,
  Tables,
  TablesInsert,
  TablesUpdate,
  Enums,
} from '../supabase/supabase.types';
import { mapSqlError } from '../utils/map-sql-error.util';
import { calcVisibilityScore } from '../utils/metrics.util';
import { ProjectStatus } from './enum/project-status.enum';
import { ACTIVE_STATUSES } from '../subscription/subscription.constants';

const PROJECT_TABLE = 'Project';
const PROJECT_MODEL_TABLE = 'Project_Model';

type Project = Tables<'Project'> & { status: ProjectStatus };
type ProjectDetail = Project & {
  brand: Tables<'Brand'> | null | undefined;
  models: string[];
  brandVisibilityScore?: number;
};
type ProjectUpdate = TablesUpdate<'Project'> & {
  models?: string[];
  status?: ProjectStatus;
  brandName?: string;
};
type ProjectInsert = TablesInsert<'Project'> & { status?: ProjectStatus };

export type AnalyticsByDate = {
  date: string;
  totalResponses: number;
  brandMentions: number;
  linkReferences: number;
  positiveCount: number;
  neutralCount: number;
  negativeCount: number;
};

export type MetricsAnalytics = {
  brandMentions: number;
  brandMentionsRate: number;
  linkReferences: number;
  linkReferencesRate: number;
  totalResponses: number;
  AIOverviewsCount: number;
  AIOverviewsRate: number;
  sentimentStats: {
    positive: number;
    neutral: number;
    negative: number;
  };
  analyticsByDate: AnalyticsByDate[];
  analyticsByModel: {
    modelName: string;
    totalMentions: number;
    brandMentions: number;
    competitorMentions: Record<string, number>;
  }[];
};

@Injectable()
export class ProjectRepository {
  constructor(
    @Inject(SUPABASE) private readonly supabase: SupabaseClient<Database>,
  ) {}

  async findById(id: string): Promise<ProjectDetail | null> {
    const { data, error } = await this.supabase
      .from(PROJECT_TABLE)
      .select(
        '*, brand:Brand(*), models:Model(*), subscription:ProjectSubscription(*)',
      )
      .eq('id', id)
      .maybeSingle();

    if (error) {
      throw mapSqlError(error);
    }

    if (data) {
      const subscription = (data as any).subscription;
      const subRecord = Array.isArray(subscription)
        ? subscription[0]
        : subscription;
      const isPro = ACTIVE_STATUSES.includes(subRecord?.status);
      return {
        ...data,
        brand: data.brand || undefined,
        models: data.models ? data.models.map((model) => model.id) : [],
        isPro,
      } as unknown as ProjectDetail;
    }

    return null;
  }

  async findDraftByUserId(userId: string): Promise<ProjectDetail | null> {
    const { data, error } = await this.supabase
      .from(PROJECT_TABLE)
      .select('*')
      .eq('createdBy', userId)
      .eq('status', ProjectStatus.DRAFT)
      .order('createdAt', { ascending: false })
      .limit(1)
      .maybeSingle();

    if (error) {
      throw mapSqlError(error);
    }

    if (data) {
      return {
        ...data,
        brand: undefined,
        models: [],
      } as unknown as ProjectDetail;
    }

    return null;
  }

  async findAllByUserId(
    userId: string,
    status?: ProjectStatus,
  ): Promise<ProjectDetail[]> {
    let query = this.supabase
      .from(PROJECT_TABLE)
      .select(
        '*, projectMembers:Project_Member!inner(*), brand:Brand(*), models:Model(*), subscription:ProjectSubscription(*)',
      )
      .eq('Project_Member.userId', userId)
      .order('createdAt', { ascending: false });

    if (status) {
      query = query.eq('status', status);
    }

    if (status !== ProjectStatus.DRAFT) {
      query = query.not('brand', 'is', null);
    }

    const { data, error } = await query;

    if (error) {
      throw mapSqlError(error);
    }

    const projects = data.map((project) => {
      const subscription = (project as any).subscription;
      const subRecord = Array.isArray(subscription)
        ? subscription[0]
        : subscription;
      const isPro = ACTIVE_STATUSES.includes(subRecord?.status);
      return {
        ...project,
        models: project.models ? project.models.map((model) => model.id) : [],
        isPro,
      };
    }) as unknown as ProjectDetail[];

    // Compute visibility scores for active projects in a single query
    const activeProjectIds = projects
      .filter((p) => p.status === ProjectStatus.ACTIVE)
      .map((p) => p.id);

    if (activeProjectIds.length === 0) {
      return projects;
    }

    const now = new Date();
    const thirtyDaysAgo = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);

    const { data: responses, error: respError } = await this.supabase
      .from('Response')
      .select(
        `position,
        isCited,
        prompt:Prompt!inner(
          isDeleted,
          Topic!inner(
            projectId,
            project:Project!inner(
              projectMembers:Project_Member!inner(userId)
            )
          )
        )`,
      )
      .in('prompt.Topic.projectId', activeProjectIds)
      .eq('prompt.isDeleted', false)
      .eq('prompt.Topic.project.projectMembers.userId', userId)
      .gte('createdAt', thirtyDaysAgo.toISOString())
      .lte('createdAt', now.toISOString());

    if (respError) {
      throw mapSqlError(respError);
    }

    const statsMap = new Map<
      string,
      { total: number; brandMentions: number; linkReferences: number }
    >();
    for (const r of responses as any[]) {
      const projectId = r.prompt.Topic.projectId;
      let stats = statsMap.get(projectId);
      if (!stats) {
        stats = { total: 0, brandMentions: 0, linkReferences: 0 };
        statsMap.set(projectId, stats);
      }
      stats.total++;
      if (r.position != null) stats.brandMentions++;
      if (r.isCited) stats.linkReferences++;
    }

    return projects.map((p) => {
      const stats = statsMap.get(p.id);
      return {
        ...p,
        brandVisibilityScore: stats
          ? calcVisibilityScore(
              stats.brandMentions,
              stats.linkReferences,
              stats.total,
            )
          : 0,
      };
    });
  }

  async findProjectsByUserId(userId: string): Promise<ProjectDetail[]> {
    // Get project IDs where user is a member
    const { data: memberships, error: memberError } = await this.supabase
      .from('Project_Member')
      .select('projectId')
      .eq('userId', userId);

    if (memberError) {
      throw mapSqlError(memberError);
    }

    const memberProjectIds = (memberships || []).map((m) => m.projectId);

    // Get projects owned by user OR where user is a member
    const { data, error } = await this.supabase
      .from(PROJECT_TABLE)
      .select('*, brand:Brand(*), models:Model(*)')
      .or(
        `createdBy.eq.${userId}${memberProjectIds.length > 0 ? `,id.in.(${memberProjectIds.join(',')})` : ''}`,
      )
      .order('createdAt', { ascending: false });

    if (error) {
      throw mapSqlError(error);
    }

    return data.map((project) => ({
      ...project,
      models: project.models ? project.models.map((model) => model.id) : [],
    })) as unknown as ProjectDetail[];
  }

  async findAll(): Promise<Project[]> {
    const { data, error } = await this.supabase
      .from(PROJECT_TABLE)
      .select('*')
      .neq('status', ProjectStatus.DRAFT);

    if (error) {
      throw mapSqlError(error);
    }

    return data as unknown as Project[];
  }

  async findProjectsWithAutoAnalysisEnabled() {
    const { data, error } = await this.supabase
      .from(PROJECT_TABLE)
      .select('*')
      .match({
        autoAnalysis: true,
        status: ProjectStatus.ACTIVE,
      });

    if (error) {
      throw mapSqlError(error);
    }

    return data;
  }

  async findProjectsWithAutoGenerateEnabled() {
    const { data, error } = await this.supabase
      .from(PROJECT_TABLE)
      .select('id, createdBy, ContentAgent!inner(id)')
      .eq('autoGenerate', true)
      .eq('status', ProjectStatus.ACTIVE)
      .eq('ContentAgent.isActive', true);

    if (error) {
      throw mapSqlError(error);
    }

    const uniqueProjects = Array.from(
      new Map(data.map((p) => [p.id, p])).values(),
    );

    return uniqueProjects.map(({ id, createdBy }) => ({ id, createdBy }));
  }

  async create(project: ProjectInsert): Promise<Project> {
    const { data, error } = await this.supabase
      .from('Project')
      .insert(project)
      .select()
      .single();

    if (error) {
      throw mapSqlError(error);
    }

    return data as unknown as Project;
  }

  async update(id: string, project: ProjectUpdate): Promise<ProjectDetail> {
    const { data, error } = await this.supabase.rpc('update_project', {
      _id: id,
      _language: project.language,
      _location: project.location,
      _monitoring_frequency: project.monitoringFrequency,
      _project_name: project.name ?? undefined,
      _brand_name: project.brandName,
      _models: project.models,
    });

    if (error) {
      throw mapSqlError(error);
    }

    if (project.status) {
      await this.updateStatus(id, project.status);
      (data as ProjectDetail).status = project.status;
    }

    return data as ProjectDetail;
  }

  async updateStatus(id: string, status: ProjectStatus): Promise<void> {
    const { error } = await this.supabase
      .from(PROJECT_TABLE)
      .update({ status } as any)
      .eq('id', id);

    if (error) {
      throw mapSqlError(error);
    }
  }

  async deleteStaleDrafts(olderThan: string): Promise<number> {
    const { data, error } = await this.supabase
      .from(PROJECT_TABLE)
      .delete()
      .eq('status', ProjectStatus.DRAFT)
      .lt('createdAt', olderThan)
      .select('id');

    if (error) {
      throw mapSqlError(error);
    }

    return data.length;
  }

  async delete(id: string): Promise<Project | null> {
    const { data, error } = await this.supabase
      .from(PROJECT_TABLE)
      .delete()
      .eq('id', id)
      .select()
      .maybeSingle();

    if (error) {
      throw mapSqlError(error);
    }

    return data as unknown as Project;
  }

  async getAnalytics(
    projectId: string,
    start: string,
    end: string,
    models?: string[],
    promptTypes?: Enums<'PromptType'>[],
    granularity?: 'day' | 'month',
  ): Promise<MetricsAnalytics> {
    const { data, error } = await this.supabase.rpc('get_analytics', {
      p_project_id: projectId,
      p_start: start,
      p_end: end,
      p_models: models || undefined,
      p_prompt_types: promptTypes || undefined,
      p_granularity: granularity || 'day',
    });

    if (error) {
      throw mapSqlError(error);
    }

    return data as MetricsAnalytics;
  }

  async updateStrategyReview(
    projectId: string,
    fields: {
      strategyReviewedAt: string | null;
      strategyReviewedById: string | null;
      strategyReviewedByName: string | null;
      strategyReviewedTopicCount: number | null;
      strategyReviewedPromptCount: number | null;
      strategyReviewedScore: number | null;
    },
  ): Promise<{
    strategyReviewedAt: string | null;
    strategyReviewedById: string | null;
    strategyReviewedByName: string | null;
  } | null> {
    const { data, error } = await this.supabase
      .from(PROJECT_TABLE)
      .update(fields as any)
      .eq('id', projectId)
      .select('*')
      .maybeSingle();

    if (error) {
      throw mapSqlError(error);
    }

    if (!data) return null;

    return {
      strategyReviewedAt: (data as any).strategyReviewedAt,
      strategyReviewedById: (data as any).strategyReviewedById,
      strategyReviewedByName: (data as any).strategyReviewedByName,
    };
  }

  async getModelsByProjectId(projectId: string): Promise<Tables<'Model'>[]> {
    const { data, error } = await this.supabase
      .from(PROJECT_MODEL_TABLE)
      .select('Model!inner(*)')
      .eq('projectId', projectId);

    if (error) {
      throw mapSqlError(error);
    }

    return data.map((item) => item.Model);
  }
}
