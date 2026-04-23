import { Inject, Injectable } from '@nestjs/common';
import { SUPABASE } from '../utils/const';
import { SupabaseClient } from '@supabase/supabase-js';
import { Database, Tables } from '../supabase/supabase.types';
import { mapSqlError } from '../utils/map-sql-error.util';

const DEFAULT_CONTENT_PROFILE_TABLE = 'DefaultContentProfile';

type DefaultContentProfile = Tables<'DefaultContentProfile'>;
type DefaultContentProfileTemplate = Pick<
  DefaultContentProfile,
  'id' | 'language' | 'name' | 'description' | 'voiceAndTone' | 'audience'
>;

@Injectable()
export class DefaultContentProfileRepository {
  constructor(
    @Inject(SUPABASE) private readonly supabase: SupabaseClient<Database>,
  ) {}

  async findDefaultTemplatesByLanguage(
    language: string = 'en',
  ): Promise<DefaultContentProfileTemplate[]> {
    const { data, error } = await this.supabase
      .from(DEFAULT_CONTENT_PROFILE_TABLE)
      .select('id, language, name, description, voiceAndTone, audience')
      .eq('language', language)
      .order('name', { ascending: true });

    if (error) {
      throw mapSqlError(error);
    }

    return data || [];
  }
}
