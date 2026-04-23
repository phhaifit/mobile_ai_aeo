import { Injectable } from '@nestjs/common';
import { SupabaseClient } from '@supabase/supabase-js';
import { Inject } from '@nestjs/common';
import { SUPABASE } from '../utils/const';
import {
  Database,
  Tables,
  TablesInsert,
  TablesUpdate,
} from '../supabase/supabase.types';
import { mapSqlError } from '../utils/map-sql-error.util';

const TOPIC_TABLE = 'Topic';
type Topic = Tables<'Topic'>;
type TopicInsert = TablesInsert<'Topic'>;
type TopicUpdate = TablesUpdate<'Topic'>;

@Injectable()
export class TopicRepository {
  constructor(
    @Inject(SUPABASE) private readonly supabase: SupabaseClient<Database>,
  ) {}

  async getTopic(topicId: string, userId: string): Promise<Topic | null> {
    const { data, error } = await this.supabase
      .from(TOPIC_TABLE)
      .select(
        '*, project:Project!inner(projectMembers:Project_Member!inner(userId))',
      )
      .eq('id', topicId)
      .eq('isDeleted', false)
      .eq('project.projectMembers.userId', userId)
      .maybeSingle();

    if (error) {
      throw mapSqlError(error);
    }

    if (data) {
      const { project, ...rest } = data;
      return rest;
    }

    return null;
  }

  async getTopics(ids: string[], userId: string): Promise<Topic[]> {
    const { data, error } = await this.supabase
      .from(TOPIC_TABLE)
      .select(
        '*, project:Project!inner(projectMembers:Project_Member!inner(userId))',
      )
      .in('id', ids)
      .eq('isDeleted', false)
      .eq('project.projectMembers.userId', userId);

    if (error) {
      throw mapSqlError(error);
    }
    return data.map(({ project, ...topic }) => topic);
  }

  async getTopicsByProjectId(
    projectId: string,
    userId: string,
  ): Promise<Topic[]> {
    const { data, error } = await this.supabase
      .from(TOPIC_TABLE)
      .select(
        '*, project:Project!inner(projectMembers:Project_Member!inner(userId)), active_prompt_count',
      )
      .eq('project.projectMembers.userId', userId)
      .eq('projectId', projectId)
      .eq('isDeleted', false)
      .order('createdAt', { ascending: false });

    if (error) {
      throw mapSqlError(error);
    }

    return (
      data as unknown as (Topic & {
        project: unknown;
        active_prompt_count: number | null;
      })[]
    ).map(({ project, ...topic }) => ({
      ...topic,
      promptCount: topic.active_prompt_count ?? 0,
    }));
  }

  async findById(topicId: string): Promise<Topic | null> {
    const { data, error } = await this.supabase
      .from(TOPIC_TABLE)
      .select('*')
      .eq('id', topicId)
      .eq('isDeleted', false)
      .single();

    if (error) {
      // PGRST116 means no rows matched — treat as not found
      if (error.code === 'PGRST116') return null;
      throw mapSqlError(error);
    }
    return data;
  }

  async insertMany(topicsData: TopicInsert[]): Promise<Topic[]> {
    const { data, error } = await this.supabase
      .from(TOPIC_TABLE)
      .insert(topicsData)
      .select();

    if (error) {
      throw mapSqlError(error);
    }
    return data;
  }

  async update(topicId: string, dto: TopicUpdate): Promise<Topic> {
    const { data, error } = await this.supabase
      .from(TOPIC_TABLE)
      .update(dto)
      .eq('id', topicId)
      .eq('isDeleted', false)
      .select()
      .single();

    if (error) {
      throw mapSqlError(error);
    }
    return data;
  }

  async deleteMany(ids: string[]): Promise<void> {
    const { error } = await this.supabase
      .from(TOPIC_TABLE)
      .update({ isDeleted: true })
      .in('id', ids);

    if (error) {
      throw mapSqlError(error);
    }
  }
}
