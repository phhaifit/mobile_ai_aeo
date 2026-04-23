import { Inject, Injectable } from '@nestjs/common';
import { SUPABASE } from '../utils/const';
import { SupabaseClient } from '@supabase/supabase-js';
import {
  Database,
  Tables,
  TablesInsert,
  TablesUpdate,
} from '../supabase/supabase.types';
import { mapSqlError } from '../utils/map-sql-error.util';

const CONTENT_INSIGHT_TABLE = 'ContentInsight';

type ContentInsight = Tables<'ContentInsight'>;
type ContentInsightInsert = TablesInsert<'ContentInsight'>;
type ContentInsightUpdate = TablesUpdate<'ContentInsight'>;

@Injectable()
export class ContentInsightRepository {
  constructor(
    @Inject(SUPABASE) private readonly supabase: SupabaseClient<Database>,
  ) {}

  async create(data: ContentInsightInsert): Promise<ContentInsight> {
    const { data: result, error } = await this.supabase
      .from(CONTENT_INSIGHT_TABLE)
      .insert(data)
      .select()
      .single();

    if (error) {
      throw mapSqlError(error);
    }

    return result;
  }

  async findById(id: string, userId: string): Promise<ContentInsight | null> {
    const { data, error } = await this.supabase
      .from(CONTENT_INSIGHT_TABLE)
      .select(
        '*, content_object:Content!inner(topic:Topic!inner(project:Project!inner(project_member:Project_Member!inner(userId))))',
      )
      .eq('content_object.topic.project.project_member.userId', userId)
      .eq('id', id)
      .single();

    if (data) {
      const { content_object, ...rest } = data as any;
      return rest as ContentInsight;
    }

    if (error) {
      if (error.code === 'PGRST116') {
        return null;
      }
      throw mapSqlError(error);
    }

    return data;
  }

  async findByContentId(contentId: string): Promise<ContentInsight[]> {
    const { data, error } = await this.supabase
      .from(CONTENT_INSIGHT_TABLE)
      .select('*')
      .eq('contentId', contentId)
      .order('createdAt', { ascending: true });

    if (error) {
      throw mapSqlError(error);
    }

    return data || [];
  }

  async updateById(
    id: string,
    data: ContentInsightUpdate,
  ): Promise<ContentInsight> {
    const { data: result, error } = await this.supabase
      .from(CONTENT_INSIGHT_TABLE)
      .update(data)
      .eq('id', id)
      .select()
      .single();

    if (error) {
      throw mapSqlError(error);
    }

    return result;
  }

  async deleteById(id: string): Promise<void> {
    const { error } = await this.supabase
      .from(CONTENT_INSIGHT_TABLE)
      .delete()
      .eq('id', id);

    if (error) {
      throw mapSqlError(error);
    }
  }

  async deleteByContentId(contentId: string): Promise<void> {
    const { error } = await this.supabase
      .from(CONTENT_INSIGHT_TABLE)
      .delete()
      .eq('contentId', contentId);

    if (error) {
      throw mapSqlError(error);
    }
  }

  async insertMany(
    insights: ContentInsightInsert[],
  ): Promise<ContentInsight[]> {
    const { data, error } = await this.supabase
      .from(CONTENT_INSIGHT_TABLE)
      .insert(insights)
      .select();

    if (error) {
      throw mapSqlError(error);
    }

    return data || [];
  }
}
