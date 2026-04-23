import { Inject, Injectable, Logger } from '@nestjs/common';
import { SUPABASE } from '../utils/const';
import { SupabaseClient } from '@supabase/supabase-js';
import { Database } from '../supabase/supabase.types';
import { mapSqlError } from '../utils/map-sql-error.util';

const TABLE_NAME = 'SocialAccount';

// TODO: After running migration and `pnpm gen:types`, replace these with:
// export type SocialAccount = Tables<'SocialAccount'>;
// export type SocialAccountInsert = TablesInsert<'SocialAccount'>;
// export type SocialAccountUpdate = TablesUpdate<'SocialAccount'>;
export interface SocialAccount {
  id: string;
  projectId: string;
  platform: string;
  connectionType: string;
  platformAccountId: string;
  accountName: string;
  accountAvatar: string | null;
  credentials: Record<string, any>;
  tokenExpiresAt: string | null;
  metadata: Record<string, any>;
  connectedByUserId: string;
  isActive: boolean;
  autoPublish: boolean;
  autoPublishSchedule: Record<string, any> | null;
  lastPublishedAt: string | null;
  consecutiveErrorCount: number;
  pausedUntil: string | null;
  cooldownReason: string | null;
  createdAt: string;
  updatedAt: string;
}

export type SocialAccountInsert = Omit<
  SocialAccount,
  | 'id'
  | 'createdAt'
  | 'updatedAt'
  | 'tokenExpiresAt'
  | 'accountAvatar'
  | 'metadata'
  | 'autoPublish'
  | 'autoPublishSchedule'
  | 'lastPublishedAt'
  | 'consecutiveErrorCount'
  | 'pausedUntil'
  | 'cooldownReason'
> & {
  id?: string;
  tokenExpiresAt?: string | null;
  accountAvatar?: string | null;
  metadata?: Record<string, any>;
  autoPublish?: boolean;
  autoPublishSchedule?: Record<string, any> | null;
};

export type SocialAccountUpdate = Partial<
  Omit<SocialAccount, 'id' | 'createdAt' | 'updatedAt'>
>;

@Injectable()
export class SocialAccountRepository {
  private readonly logger = new Logger(SocialAccountRepository.name);

  constructor(
    @Inject(SUPABASE) private readonly supabase: SupabaseClient<Database>,
  ) {}

  async create(data: SocialAccountInsert): Promise<SocialAccount> {
    const { data: result, error } = await (this.supabase as any)
      .from(TABLE_NAME)
      .insert(data)
      .select()
      .single();

    if (error) {
      throw mapSqlError(error);
    }
    return result;
  }

  async upsert(data: SocialAccountInsert): Promise<SocialAccount> {
    const { data: result, error } = await (this.supabase as any)
      .from(TABLE_NAME)
      .upsert(data, {
        onConflict: 'projectId,platform,platformAccountId',
      })
      .select()
      .single();

    if (error) {
      throw mapSqlError(error);
    }
    return result;
  }

  async findById(id: string): Promise<SocialAccount | null> {
    const { data, error } = await (this.supabase as any)
      .from(TABLE_NAME)
      .select('*')
      .eq('id', id)
      .maybeSingle();

    if (error) {
      throw mapSqlError(error);
    }
    return data;
  }

  async findByProjectId(projectId: string): Promise<SocialAccount[]> {
    const { data, error } = await (this.supabase as any)
      .from(TABLE_NAME)
      .select('*')
      .eq('projectId', projectId)
      .eq('isActive', true)
      .order('createdAt', { ascending: false });

    if (error) {
      throw mapSqlError(error);
    }
    return data || [];
  }

  /**
   * Find all active SocialAccount records sharing the same platformAccountId
   * connected by the same user — across all projects.
   * Used for: conflict detection at connect time, global cadence aggregation.
   */
  async findSiblingsByPlatformAccountId(
    platformAccountId: string,
    userId: string,
  ): Promise<SocialAccount[]> {
    const { data, error } = await (this.supabase as any)
      .from(TABLE_NAME)
      .select('*')
      .eq('platformAccountId', platformAccountId)
      .eq('connectedByUserId', userId)
      .eq('isActive', true);

    if (error) {
      throw mapSqlError(error);
    }
    return data || [];
  }

  async findByProjectIdAndPlatform(
    projectId: string,
    platform: string,
  ): Promise<SocialAccount[]> {
    const { data, error } = await (this.supabase as any)
      .from(TABLE_NAME)
      .select('*')
      .eq('projectId', projectId)
      .eq('platform', platform)
      .eq('isActive', true)
      .order('createdAt', { ascending: false });

    if (error) {
      throw mapSqlError(error);
    }
    return data || [];
  }

  async update(id: string, data: SocialAccountUpdate): Promise<SocialAccount> {
    const { data: result, error } = await (this.supabase as any)
      .from(TABLE_NAME)
      .update(data)
      .eq('id', id)
      .select()
      .single();

    if (error) {
      throw mapSqlError(error);
    }
    return result;
  }

  async deactivate(id: string): Promise<void> {
    const { error } = await (this.supabase as any)
      .from(TABLE_NAME)
      .update({ isActive: false })
      .eq('id', id);

    if (error) {
      throw mapSqlError(error);
    }
  }

  async delete(id: string): Promise<void> {
    const { error } = await (this.supabase as any)
      .from(TABLE_NAME)
      .delete()
      .eq('id', id);

    if (error) {
      throw mapSqlError(error);
    }
  }

  async findAutoPublishByProjectId(
    projectId: string,
  ): Promise<SocialAccount[]> {
    const { data, error } = await (this.supabase as any)
      .from(TABLE_NAME)
      .select('*')
      .eq('projectId', projectId)
      .eq('isActive', true)
      .eq('autoPublish', true)
      .order('createdAt', { ascending: false });

    if (error) {
      throw mapSqlError(error);
    }
    return data || [];
  }

  async findExpiringTokens(beforeDate: Date): Promise<SocialAccount[]> {
    const { data, error } = await (this.supabase as any)
      .from(TABLE_NAME)
      .select('*')
      .eq('isActive', true)
      .eq('connectionType', 'oauth')
      .not('tokenExpiresAt', 'is', null)
      .lt('tokenExpiresAt', beforeDate.toISOString());

    if (error) {
      throw mapSqlError(error);
    }
    return data || [];
  }

  async findAllAutoPublishActive(): Promise<SocialAccount[]> {
    const { data, error } = await (this.supabase as any)
      .from(TABLE_NAME)
      .select('*')
      .eq('isActive', true)
      .eq('autoPublish', true)
      .order('createdAt', { ascending: true });

    if (error) {
      throw mapSqlError(error);
    }
    return data || [];
  }

  async updatePublishStats(
    id: string,
    stats: {
      lastPublishedAt?: string;
      consecutiveErrorCount?: number;
      pausedUntil?: string | null;
      cooldownReason?: string | null;
    },
  ): Promise<void> {
    const { error } = await (this.supabase as any)
      .from(TABLE_NAME)
      .update(stats)
      .eq('id', id);

    if (error) {
      throw mapSqlError(error);
    }
  }

  async incrementConsecutiveErrors(id: string): Promise<number> {
    const account = await this.findById(id);
    if (!account) return 0;

    const newCount = (account.consecutiveErrorCount || 0) + 1;
    await this.updatePublishStats(id, { consecutiveErrorCount: newCount });
    return newCount;
  }

  async resetConsecutiveErrors(id: string): Promise<void> {
    await this.updatePublishStats(id, { consecutiveErrorCount: 0 });
  }
}
