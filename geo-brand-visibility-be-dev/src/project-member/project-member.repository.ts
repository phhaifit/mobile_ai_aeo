import { Inject, Injectable } from '@nestjs/common';
import { SUPABASE } from '../utils/const';
import { SupabaseClient } from '@supabase/supabase-js';
import { Database, TablesInsert } from '../supabase/supabase.types';
import { mapSqlError } from '../utils/map-sql-error.util';
import {
  PaginationQueryDto,
  SortOrder,
} from '../shared/dtos/pagination-query.dto';

const PROJECT_MEMBER_TABLE = 'Project_Member';

@Injectable()
export class ProjectMemberRepository {
  constructor(
    @Inject(SUPABASE) private readonly supabase: SupabaseClient<Database>,
  ) {}

  async findAllByProjectId(projectId: string, params: PaginationQueryDto) {
    let query = this.supabase
      .from(PROJECT_MEMBER_TABLE)
      .select('*, user:User!inner(*)', { count: 'exact' })
      .eq('projectId', projectId);

    if (params.sortBy) {
      query = query.order(params.sortBy, {
        ascending: params.sortOrder === SortOrder.ASC,
      });
    } else {
      query = query.order('createdAt', { ascending: false });
    }

    if (params.search) {
      query = query.or(
        `email.ilike.%${params.search}%,fullname.ilike.%${params.search}%`,
        { referencedTable: 'User' },
      );
    }

    const from = params.skip;
    const to = from + params.take - 1;

    const { data, error, count } = await query.range(from, to);

    if (error) {
      throw mapSqlError(error);
    }

    return { data, total: count || 0 };
  }

  async findOneByProjectIdAndUserId(projectId: string, userId: string) {
    const { data, error } = await this.supabase
      .from(PROJECT_MEMBER_TABLE)
      .select('*')
      .eq('projectId', projectId)
      .eq('userId', userId)
      .maybeSingle();

    if (error) {
      throw mapSqlError(error);
    }

    return data;
  }

  async create(member: TablesInsert<'Project_Member'>) {
    const { data, error } = await this.supabase
      .from(PROJECT_MEMBER_TABLE)
      .insert(member)
      .select()
      .single();

    if (error) {
      throw mapSqlError(error);
    }

    return data;
  }

  async findAllMemberEmails(projectId: string): Promise<string[]> {
    const { data, error } = await this.supabase
      .from(PROJECT_MEMBER_TABLE)
      .select('user:User!inner(email)')
      .eq('projectId', projectId);

    if (error) {
      throw mapSqlError(error);
    }

    return data.map((item) => item.user.email);
  }

  async removeMember(projectId: string, userId: string) {
    const { data, error } = await this.supabase
      .from(PROJECT_MEMBER_TABLE)
      .delete()
      .eq('projectId', projectId)
      .eq('userId', userId)
      .select()
      .maybeSingle();

    if (error) {
      throw mapSqlError(error);
    }

    return data;
  }

  async updateMemberRole(
    projectId: string,
    userId: string,
    role: Database['public']['Enums']['ProjectRole'],
  ) {
    const { data, error } = await this.supabase
      .from(PROJECT_MEMBER_TABLE)
      .update({ role })
      .eq('projectId', projectId)
      .eq('userId', userId)
      .select()
      .single();

    if (error) {
      throw mapSqlError(error);
    }

    return data;
  }
}
