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

const TABLE = 'Service';

type Service = Tables<'Service'>;
type ServiceInsert = TablesInsert<'Service'>;
type ServiceUpdate = TablesUpdate<'Service'>;

// Auth select: join through Brand → Project → Project_Member, include category
const AUTH_SELECT =
  '*, category:ServiceCategory(id, name, createdAt, updatedAt, brandId), brand:Brand!inner(project:Project!inner(projectMembers:Project_Member!inner(userId)))';

@Injectable()
export class ServiceRepository {
  constructor(
    @Inject(SUPABASE) private readonly supabase: SupabaseClient<Database>,
  ) {}

  async findByBrandId(brandId: string, userId: string): Promise<Service[]> {
    const { data, error } = await this.supabase
      .from(TABLE)
      .select(AUTH_SELECT)
      .eq('brandId', brandId)
      .eq('brand.project.projectMembers.userId', userId)
      .order('name', { ascending: true });

    if (error) throw mapSqlError(error);

    return data?.map(({ brand: _, ...service }) => service as Service) || [];
  }

  async findById(id: string, userId: string): Promise<Service | null> {
    const { data, error } = await this.supabase
      .from(TABLE)
      .select(AUTH_SELECT)
      .eq('id', id)
      .eq('brand.project.projectMembers.userId', userId)
      .maybeSingle();

    if (error) throw mapSqlError(error);

    if (data) {
      const { brand: _, ...service } = data;
      return service as Service;
    }

    return null;
  }

  async create(data: ServiceInsert): Promise<Service> {
    const { data: created, error } = await this.supabase
      .from(TABLE)
      .insert(data)
      .select()
      .single();

    if (error) throw mapSqlError(error);
    return created;
  }

  async createMany(items: ServiceInsert[]): Promise<Service[]> {
    const { data, error } = await this.supabase
      .from(TABLE)
      .insert(items)
      .select();

    if (error) throw mapSqlError(error);
    return data || [];
  }

  async update(id: string, data: ServiceUpdate): Promise<Service | null> {
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
