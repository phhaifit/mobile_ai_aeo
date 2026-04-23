import { Inject, Injectable } from '@nestjs/common';
import { SUPABASE } from '../utils/const';
import { SupabaseClient } from '@supabase/supabase-js';
import { Database, Tables } from '../supabase/supabase.types';
import { mapSqlError } from '../utils/map-sql-error.util';

const MODEL_TABLE = 'Model';
type Model = Tables<'Model'>;

@Injectable()
export class ModelRepository {
  constructor(
    @Inject(SUPABASE) private readonly supabase: SupabaseClient<Database>,
  ) {}

  async findAll(): Promise<Model[]> {
    const { data, error } = await this.supabase.from(MODEL_TABLE).select('*');

    if (error) {
      throw mapSqlError(error);
    }

    return data ?? [];
  }
}
