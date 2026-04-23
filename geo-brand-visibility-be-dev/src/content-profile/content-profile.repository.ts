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

const CONTENT_PROFILE_TABLE = 'ContentProfile';
const DEFAULT_CONTENT_PROFILE_TABLE = 'DefaultContentProfile';

type ContentProfile = Tables<'ContentProfile'>;
type ContentProfileInsert = TablesInsert<'ContentProfile'>;
type ContentProfileUpdate = TablesUpdate<'ContentProfile'>;

@Injectable()
export class ContentProfileRepository {
  constructor(
    @Inject(SUPABASE) private readonly supabase: SupabaseClient<Database>,
  ) {}

  async findById(id: string): Promise<ContentProfile | null> {
    const { data, error } = await this.supabase
      .from(CONTENT_PROFILE_TABLE)
      .select('*')
      .eq('id', id)
      .maybeSingle();

    if (error) {
      throw mapSqlError(error);
    }

    return data;
  }

  async findByProjectId(
    projectId: string,
    userId: string,
  ): Promise<ContentProfile[]> {
    const { data, error } = await this.supabase
      .from(CONTENT_PROFILE_TABLE)
      .select('*, project:Project(createdBy)')
      .eq('project.createdBy', userId)
      .eq('projectId', projectId)
      .order('name', { ascending: true });

    if (error) {
      throw mapSqlError(error);
    }

    return data || [];
  }

  async create(contentProfile: ContentProfileInsert): Promise<ContentProfile> {
    const { data, error } = await this.supabase
      .from(CONTENT_PROFILE_TABLE)
      .insert(contentProfile)
      .select()
      .single();

    if (error) {
      throw mapSqlError(error);
    }

    return data;
  }

  async update(
    id: string,
    contentProfile: ContentProfileUpdate,
  ): Promise<ContentProfile | null> {
    const { data, error } = await this.supabase
      .from(CONTENT_PROFILE_TABLE)
      .update(contentProfile)
      .eq('id', id)
      .select()
      .maybeSingle();

    if (error) {
      throw mapSqlError(error);
    }

    return data;
  }

  async seedDefaults(
    projectId: string,
    language: string = 'en',
  ): Promise<void> {
    const { data: defaults, error: fetchError } = await this.supabase
      .from(DEFAULT_CONTENT_PROFILE_TABLE)
      .select('name, description, voiceAndTone, audience')
      .eq('language', language);

    if (fetchError) {
      throw mapSqlError(fetchError);
    }

    if (!defaults || defaults.length === 0) {
      return;
    }

    const profiles: ContentProfileInsert[] = defaults.map((d) => ({
      projectId,
      name: d.name,
      description: d.description,
      voiceAndTone: d.voiceAndTone,
      audience: d.audience,
    }));

    const { error } = await this.supabase
      .from(CONTENT_PROFILE_TABLE)
      .insert(profiles);

    if (error) {
      throw mapSqlError(error);
    }
  }

  async delete(id: string): Promise<void> {
    const { error } = await this.supabase
      .from(CONTENT_PROFILE_TABLE)
      .delete()
      .eq('id', id);

    if (error) {
      throw mapSqlError(error);
    }
  }
}
