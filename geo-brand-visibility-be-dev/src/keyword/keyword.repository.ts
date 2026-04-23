import { Injectable, Inject } from '@nestjs/common';
import { SupabaseClient } from '@supabase/supabase-js';
import { SUPABASE } from '../utils/const';
import { Database, Tables, TablesInsert } from '../supabase/supabase.types';
import { mapSqlError } from '../utils/map-sql-error.util';

const KEYWORD_TABLE = 'Keyword';
const PROMPT_KEYWORD_TABLE = 'Prompt_Keyword';

type Keyword = Tables<'Keyword'>;
type KeywordInsert = TablesInsert<'Keyword'>;
type PromptKeywordInsert = TablesInsert<'Prompt_Keyword'>;

@Injectable()
export class KeywordRepository {
  constructor(
    @Inject(SUPABASE) private readonly supabase: SupabaseClient<Database>,
  ) {}

  async findByTopicId(topicId: string): Promise<Keyword[]> {
    const { data, error } = await this.supabase
      .from(KEYWORD_TABLE)
      .select('*')
      .eq('topicId', topicId)
      .order('createdAt', { ascending: true });

    if (error) {
      throw mapSqlError(error);
    }
    return data;
  }

  async findByProjectId(
    projectId: string,
  ): Promise<(Keyword & { topic: { name: string } })[]> {
    const { data, error } = await this.supabase
      .from(KEYWORD_TABLE)
      .select('*, topic:Topic!inner(projectId, name)')
      .eq('topic.projectId', projectId)
      .order('createdAt', { ascending: true });

    if (error) {
      throw mapSqlError(error);
    }
    // eslint-disable-next-line @typescript-eslint/no-unsafe-return
    return data as any;
  }

  async insertMany(keywords: KeywordInsert[]): Promise<Keyword[]> {
    const { data, error } = await this.supabase
      .from(KEYWORD_TABLE)
      .insert(keywords)
      .select();

    if (error) {
      throw mapSqlError(error);
    }
    return data;
  }

  async delete(id: string): Promise<void> {
    const { error } = await this.supabase
      .from(KEYWORD_TABLE)
      .delete()
      .eq('id', id);

    if (error) {
      throw mapSqlError(error);
    }
  }

  async update(id: string, data: { keyword?: string }): Promise<Keyword> {
    const { data: result, error } = await this.supabase
      .from(KEYWORD_TABLE)
      .update(data)
      .eq('id', id)
      .select()
      .single();

    if (error) {
      throw mapSqlError(error);
    }
    return result;
  }

  async deleteByTopicId(topicId: string): Promise<void> {
    const { error } = await this.supabase
      .from(KEYWORD_TABLE)
      .delete()
      .eq('topicId', topicId);

    if (error) {
      throw mapSqlError(error);
    }
  }

  async insertPromptKeywords(mappings: PromptKeywordInsert[]): Promise<void> {
    if (mappings.length === 0) return;

    const { error } = await this.supabase
      .from(PROMPT_KEYWORD_TABLE)
      .insert(mappings);

    if (error) {
      throw mapSqlError(error);
    }
  }

  async findKeywordsByPromptId(promptId: string): Promise<Keyword[]> {
    const { data, error } = await this.supabase
      .from(PROMPT_KEYWORD_TABLE)
      .select('keywordId, Keyword(*)')
      .eq('promptId', promptId);

    if (error) {
      throw mapSqlError(error);
    }

    return data.map((item) => item.Keyword as unknown as Keyword);
  }
}
