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

const COMPETITOR_TABLE = 'Competitor';
type Competitor = Tables<'Competitor'>;
type CompetitorUpdate = TablesUpdate<'Competitor'>;
type CompetitorInsert = TablesInsert<'Competitor'>;

@Injectable()
export class CompetitorRepository {
  constructor(
    @Inject(SUPABASE) private readonly supabase: SupabaseClient<Database>,
  ) {}

  async findById(id: string): Promise<Competitor | null> {
    const { data, error } = await this.supabase
      .from(COMPETITOR_TABLE)
      .select('*')
      .eq('id', id)
      .maybeSingle();

    if (error) {
      throw mapSqlError(error);
    }

    return data;
  }

  async findByBrandId(brandId: string): Promise<Competitor[]> {
    const { data, error } = await this.supabase
      .from(COMPETITOR_TABLE)
      .select('*')
      .eq('brandId', brandId);

    if (error) {
      throw mapSqlError(error);
    }

    return data || [];
  }

  async create(competitor: CompetitorInsert): Promise<Competitor> {
    const { data, error } = await this.supabase
      .from(COMPETITOR_TABLE)
      .insert(competitor)
      .select()
      .single();

    if (error) {
      throw mapSqlError(error);
    }

    return data;
  }

  async updateById(
    id: string,
    competitor: CompetitorUpdate,
  ): Promise<Competitor | null> {
    const { data, error } = await this.supabase
      .from(COMPETITOR_TABLE)
      .update(competitor)
      .eq('id', id)
      .select()
      .maybeSingle();

    if (error) {
      throw mapSqlError(error);
    }

    return data;
  }

  async deleteById(id: string): Promise<void> {
    const { error } = await this.supabase
      .from(COMPETITOR_TABLE)
      .delete()
      .eq('id', id);

    if (error) {
      throw mapSqlError(error);
    }
  }
}
