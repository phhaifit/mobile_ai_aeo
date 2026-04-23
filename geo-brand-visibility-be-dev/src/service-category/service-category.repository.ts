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

const TABLE = 'ServiceCategory';

type ServiceCategory = Tables<'ServiceCategory'>;
type ServiceCategoryInsert = TablesInsert<'ServiceCategory'>;
type ServiceCategoryUpdate = TablesUpdate<'ServiceCategory'>;

const AUTH_SELECT =
  '*, brand:Brand!inner(project:Project!inner(projectMembers:Project_Member!inner(userId)))';

@Injectable()
export class ServiceCategoryRepository {
  constructor(
    @Inject(SUPABASE) private readonly supabase: SupabaseClient<Database>,
  ) {}

  async findByBrandId(
    brandId: string,
    userId: string,
  ): Promise<ServiceCategory[]> {
    const { data, error } = await this.supabase
      .from(TABLE)
      .select(AUTH_SELECT)
      .eq('brandId', brandId)
      .eq('brand.project.projectMembers.userId', userId)
      .order('name', { ascending: true });

    if (error) throw mapSqlError(error);
    return data?.map(({ brand: _, ...cat }) => cat as ServiceCategory) || [];
  }

  async findById(id: string, userId: string): Promise<ServiceCategory | null> {
    const { data, error } = await this.supabase
      .from(TABLE)
      .select(AUTH_SELECT)
      .eq('id', id)
      .eq('brand.project.projectMembers.userId', userId)
      .maybeSingle();

    if (error) throw mapSqlError(error);
    if (data) {
      const { brand: _, ...cat } = data;
      return cat as ServiceCategory;
    }
    return null;
  }

  async findByName(
    brandId: string,
    name: string,
  ): Promise<ServiceCategory | null> {
    const { data, error } = await this.supabase
      .from(TABLE)
      .select('*')
      .eq('brandId', brandId)
      .ilike('name', name)
      .maybeSingle();

    if (error) throw mapSqlError(error);
    return data;
  }

  async create(data: ServiceCategoryInsert): Promise<ServiceCategory> {
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
    data: ServiceCategoryUpdate,
  ): Promise<ServiceCategory | null> {
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
}
