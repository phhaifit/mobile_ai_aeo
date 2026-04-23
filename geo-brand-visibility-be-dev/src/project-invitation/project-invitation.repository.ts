import { Inject, Injectable } from '@nestjs/common';
import { SUPABASE } from '../utils/const';
import { SupabaseClient } from '@supabase/supabase-js';
import {
  Database,
  TablesInsert,
  TablesUpdate,
} from '../supabase/supabase.types';
import { mapSqlError } from '../utils/map-sql-error.util';
import {
  PaginationQueryDto,
  SortOrder,
} from '../shared/dtos/pagination-query.dto';
import { InvitationStatus } from './enum/invitation-status.enum';

const PROJECT_INVITATIONS_TABLE = 'Project_Invitation';

@Injectable()
export class ProjectInvitationRepository {
  constructor(
    @Inject(SUPABASE) private readonly supabase: SupabaseClient<Database>,
  ) {}

  async create(invitation: TablesInsert<'Project_Invitation'>) {
    const { data, error } = await this.supabase
      .from(PROJECT_INVITATIONS_TABLE)
      .insert(invitation)
      .select()
      .single();

    if (error) {
      throw mapSqlError(error);
    }

    return data;
  }

  async findById(invitationId: string) {
    const { data, error } = await this.supabase
      .from(PROJECT_INVITATIONS_TABLE)
      .select('*')
      .eq('id', invitationId)
      .single();

    if (error) {
      throw mapSqlError(error);
    }

    return data;
  }

  async findOneByProjectIdAndInviteeId(
    projectId: string,
    inviteeId: string,
  ): Promise<Database['public']['Tables']['Project_Invitation']['Row'] | null> {
    const { data, error } = await this.supabase
      .from(PROJECT_INVITATIONS_TABLE)
      .select('*')
      .eq('projectId', projectId)
      .eq('inviteeId', inviteeId)
      .eq('status', 'Pending')
      .maybeSingle();

    if (error) {
      throw mapSqlError(error);
    }

    return data;
  }

  async findAllByInviteeId(
    inviteeId: string,
    params: PaginationQueryDto,
    status: InvitationStatus = InvitationStatus.Pending,
  ) {
    let query = this.supabase
      .from(PROJECT_INVITATIONS_TABLE)
      .select(
        '*, user:User!inviterId!inner(*), project:Project!inner(brand:Brand!inner(name))',
        {
          count: 'exact',
        },
      )
      .eq('inviteeId', inviteeId)
      .eq('status', status);

    if (params.sortBy) {
      query = query.order(params.sortBy, {
        ascending: params.sortOrder === SortOrder.ASC,
      });
    } else {
      query = query.order('createdAt', { ascending: false });
    }

    if (params.search) {
      query = query
        .or(`name.ilike.${params.search}`, { foreignTable: 'project.brand' })
        .or(`fullname.ilike.${params.search}`, { foreignTable: 'user' });
    }

    const from = params.skip;
    const to = from + params.take - 1;

    const { data, error, count } = await query.range(from, to);

    if (error) {
      throw mapSqlError(error);
    }

    return { data, total: count || 0 };
  }

  async findByToken(token: string) {
    const { data, error } = await this.supabase
      .from(PROJECT_INVITATIONS_TABLE)
      .select(
        '*, user:User!inviterId!inner(*), project:Project!inner(brand:Brand!inner(name))',
      )
      .eq('token', token)
      .maybeSingle();

    if (error) {
      throw mapSqlError(error);
    }

    return data;
  }

  async findOneByProjectIdAndEmail(
    projectId: string,
    email: string,
  ): Promise<Database['public']['Tables']['Project_Invitation']['Row'] | null> {
    const { data, error } = await this.supabase
      .from(PROJECT_INVITATIONS_TABLE)
      .select('*')
      .eq('projectId', projectId)
      .ilike('inviteeEmail', email)
      .eq('status', 'Pending')
      .maybeSingle();

    if (error) {
      throw mapSqlError(error);
    }

    return data;
  }

  async update(
    invitationId: string,
    invitation: TablesUpdate<'Project_Invitation'>,
  ) {
    const { data, error } = await this.supabase
      .from(PROJECT_INVITATIONS_TABLE)
      .update(invitation)
      .eq('id', invitationId)
      .select()
      .single();

    if (error) {
      throw mapSqlError(error);
    }

    return data;
  }
}
