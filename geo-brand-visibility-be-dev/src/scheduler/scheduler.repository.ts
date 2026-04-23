import { Inject, Injectable } from '@nestjs/common';
import { SupabaseClient } from '@supabase/supabase-js';
import { SUPABASE } from '../utils/const';
import { Database } from '../supabase/supabase.types';

export interface ActiveAgent {
  agentType: string;
  postsPerDay: number;
}

export interface BlogQueueItem {
  promptId: string;
  referenceUrl: string | null;
  contentProfileId: string | null;
  contentAgentId: string;
}

export interface SocialMediaQueueItem {
  promptId: string;
  referenceUrl: string | null;
  platform: string;
  contentProfileId: string | null;
  contentAgentId: string;
}

@Injectable()
export class SchedulerRepository {
  constructor(
    @Inject(SUPABASE) private readonly supabase: SupabaseClient<Database>,
  ) {}

  async findActiveAgents(projectId: string): Promise<ActiveAgent[]> {
    const { data, error } = await this.supabase
      .from('ContentAgent')
      .select('agentType, postsPerDay')
      .eq('projectId', projectId)
      .eq('isActive', true);

    if (error) throw error;
    return (data ?? []) as ActiveAgent[];
  }

  async getPromptsForBlogScheduler(
    projectId: string,
    maxTasks = 100,
  ): Promise<BlogQueueItem[]> {
    const { data, error } = await this.supabase.rpc(
      'get_prompts_for_blog_scheduler',
      {
        p_project_id: projectId,
        p_max_tasks: maxTasks,
      },
    );

    if (error) throw error;
    return (data as BlogQueueItem[]) || [];
  }

  async getPromptsForSocialMediaScheduler(
    projectId: string,
    maxTasks = 100,
  ): Promise<SocialMediaQueueItem[]> {
    const { data, error } = await this.supabase.rpc(
      'get_prompts_for_social_media_scheduler',
      {
        p_project_id: projectId,
        p_max_tasks: maxTasks,
      },
    );

    if (error) throw error;
    return (data as SocialMediaQueueItem[]) || [];
  }
}
