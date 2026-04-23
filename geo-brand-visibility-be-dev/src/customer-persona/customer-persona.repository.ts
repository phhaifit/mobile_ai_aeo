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

const TABLE = 'CustomerPersona';

type CustomerPersona = Tables<'CustomerPersona'>;
type CustomerPersonaInsert = TablesInsert<'CustomerPersona'>;
type CustomerPersonaUpdate = TablesUpdate<'CustomerPersona'>;

// Auth select: join through Brand → Project → Project_Member
const AUTH_SELECT =
  '*, brand:Brand!inner(project:Project!inner(projectMembers:Project_Member!inner(userId)))';

@Injectable()
export class CustomerPersonaRepository {
  constructor(
    @Inject(SUPABASE) private readonly supabase: SupabaseClient<Database>,
  ) {}

  async findByBrandId(
    brandId: string,
    userId: string,
  ): Promise<CustomerPersona[]> {
    const { data, error } = await this.supabase
      .from(TABLE)
      .select(AUTH_SELECT)
      .eq('brandId', brandId)
      .eq('brand.project.projectMembers.userId', userId)
      .order('isPrimary', { ascending: false })
      .order('name', { ascending: true });

    if (error) throw mapSqlError(error);

    return (
      data?.map(({ brand: _, ...persona }) => persona as CustomerPersona) || []
    );
  }

  async findById(id: string): Promise<CustomerPersona | null> {
    const { data, error } = await this.supabase
      .from(TABLE)
      .select('*')
      .eq('id', id)
      .maybeSingle();

    if (error) throw mapSqlError(error);
    return data;
  }

  async findPrimaryByBrandId(brandId: string): Promise<CustomerPersona | null> {
    const { data, error } = await this.supabase
      .from(TABLE)
      .select('*')
      .eq('brandId', brandId)
      .eq('isPrimary', true)
      .maybeSingle();

    if (error) throw mapSqlError(error);
    return data;
  }

  async create(data: CustomerPersonaInsert): Promise<CustomerPersona> {
    const { data: created, error } = await this.supabase
      .from(TABLE)
      .insert(data)
      .select()
      .single();

    if (error) throw mapSqlError(error);
    return created;
  }

  async update(
    id: string,
    data: CustomerPersonaUpdate,
  ): Promise<CustomerPersona | null> {
    const { data: updated, error } = await this.supabase
      .from(TABLE)
      .update(data)
      .eq('id', id)
      .select()
      .maybeSingle();

    if (error) throw mapSqlError(error);
    return updated;
  }

  async delete(id: string): Promise<void> {
    const { error } = await this.supabase.from(TABLE).delete().eq('id', id);
    if (error) throw mapSqlError(error);
  }

  async clearPrimaryForBrand(brandId: string): Promise<void> {
    const { error } = await this.supabase
      .from(TABLE)
      .update({ isPrimary: false })
      .eq('brandId', brandId)
      .eq('isPrimary', true);

    if (error) throw mapSqlError(error);
  }
}
