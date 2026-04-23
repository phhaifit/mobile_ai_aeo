import { Inject, Injectable, Logger } from '@nestjs/common';
import { SUPABASE } from '../utils/const';
import { SupabaseClient } from '@supabase/supabase-js';
import { Database } from '../supabase/supabase.types';
import { mapSqlError } from '../utils/map-sql-error.util';

const TABLE_NAME = 'SocialPostTarget';

// TODO: After running migration and `pnpm gen:types`, replace with Tables<'SocialPostTarget'>
export interface SocialPostTarget {
  id: string;
  socialPostId: string;
  socialAccountId: string;
  status: string;
  platformPayload: Record<string, any>;
  platformPostId: string | null;
  platformPostUrl: string | null;
  errorMessage: string | null;
  errorType: string | null;
  publishedAt: string | null;
  bullmqJobId: string | null;
  createdAt: string;
  updatedAt: string;
}

export type SocialPostTargetInsert = Omit<
  SocialPostTarget,
  | 'id'
  | 'createdAt'
  | 'updatedAt'
  | 'platformPostId'
  | 'platformPostUrl'
  | 'errorMessage'
  | 'errorType'
  | 'publishedAt'
  | 'bullmqJobId'
> & {
  id?: string;
  platformPostId?: string;
  platformPostUrl?: string;
  errorMessage?: string;
  errorType?: string;
  publishedAt?: string;
  bullmqJobId?: string;
};

export type SocialPostTargetUpdate = Partial<
  Omit<SocialPostTarget, 'id' | 'createdAt' | 'updatedAt'>
>;

@Injectable()
export class SocialPostTargetRepository {
  private readonly logger = new Logger(SocialPostTargetRepository.name);

  constructor(
    @Inject(SUPABASE) private readonly supabase: SupabaseClient<Database>,
  ) {}

  async create(data: SocialPostTargetInsert): Promise<SocialPostTarget> {
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

  async createMany(
    data: SocialPostTargetInsert[],
  ): Promise<SocialPostTarget[]> {
    const { data: result, error } = await (this.supabase as any)
      .from(TABLE_NAME)
      .insert(data)
      .select();

    if (error) {
      throw mapSqlError(error);
    }
    return result || [];
  }

  async findById(id: string): Promise<SocialPostTarget | null> {
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

  async findByIdWithRelations(id: string): Promise<any | null> {
    const { data, error } = await (this.supabase as any)
      .from(TABLE_NAME)
      .select(
        `
        *,
        post:SocialPost(*),
        account:SocialAccount(*)
      `,
      )
      .eq('id', id)
      .maybeSingle();

    if (error) {
      throw mapSqlError(error);
    }
    return data;
  }

  async findBySocialPostId(socialPostId: string): Promise<SocialPostTarget[]> {
    const { data, error } = await (this.supabase as any)
      .from(TABLE_NAME)
      .select('*')
      .eq('socialPostId', socialPostId);

    if (error) {
      throw mapSqlError(error);
    }
    return data || [];
  }

  async update(
    id: string,
    data: SocialPostTargetUpdate,
  ): Promise<SocialPostTarget> {
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

  async updateStatus(
    id: string,
    status: string,
    extra?: {
      platformPostId?: string;
      platformPostUrl?: string;
      errorMessage?: string;
      errorType?: string;
      publishedAt?: string;
    },
  ): Promise<void> {
    const updateData: SocialPostTargetUpdate = {
      status,
      ...extra,
    };

    const { error } = await (this.supabase as any)
      .from(TABLE_NAME)
      .update(updateData)
      .eq('id', id);

    if (error) {
      throw mapSqlError(error);
    }
  }

  async findPendingByAccountId(accountId: string): Promise<SocialPostTarget[]> {
    const { data, error } = await (this.supabase as any)
      .from(TABLE_NAME)
      .select('*')
      .eq('socialAccountId', accountId)
      .in('status', ['PENDING', 'QUEUED']);

    if (error) {
      throw mapSqlError(error);
    }
    return data || [];
  }

  async findStuckQueuedTargets(olderThan: Date): Promise<any[]> {
    const { data, error } = await (this.supabase as any)
      .from(TABLE_NAME)
      .select(
        `
        *,
        post:SocialPost(*),
        account:SocialAccount(*)
      `,
      )
      .eq('status', 'QUEUED')
      .lt('createdAt', olderThan.toISOString());

    if (error) {
      throw mapSqlError(error);
    }
    return data || [];
  }

  async countPublishedInLast24Hours(socialAccountId: string): Promise<number> {
    const since = new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString();
    const { count, error } = await (this.supabase as any)
      .from(TABLE_NAME)
      .select('*', { count: 'exact', head: true })
      .eq('socialAccountId', socialAccountId)
      .eq('status', 'PUBLISHED')
      .gte('publishedAt', since);

    if (error) {
      throw mapSqlError(error);
    }
    return count || 0;
  }

  async findOldestQueuedForAccount(
    socialAccountId: string,
  ): Promise<any | null> {
    const { data, error } = await (this.supabase as any)
      .from(TABLE_NAME)
      .select(
        `
        *,
        post:SocialPost(*),
        account:SocialAccount(*)
      `,
      )
      .eq('socialAccountId', socialAccountId)
      .eq('status', 'QUEUED')
      .order('createdAt', { ascending: true })
      .limit(1)
      .maybeSingle();

    if (error) {
      throw mapSqlError(error);
    }
    return data;
  }

  async findQueuedByAccountId(
    socialAccountId: string,
  ): Promise<SocialPostTarget[]> {
    const { data, error } = await (this.supabase as any)
      .from(TABLE_NAME)
      .select(
        `
        *,
        post:SocialPost(id, message, title, mediaUrls, contentId, createdAt)
      `,
      )
      .eq('socialAccountId', socialAccountId)
      .eq('status', 'QUEUED')
      .order('createdAt', { ascending: true });

    if (error) {
      throw mapSqlError(error);
    }
    return data || [];
  }

  async findPendingByContentAndAccounts(
    contentId: string,
    socialAccountIds: string[],
  ): Promise<any[]> {
    const { data, error } = await (this.supabase as any)
      .from(TABLE_NAME)
      .select(
        `
        id, socialAccountId, status,
        post:SocialPost!inner(contentId)
      `,
      )
      .in('socialAccountId', socialAccountIds)
      .in('status', ['QUEUED', 'PENDING'])
      .eq('post.contentId', contentId);

    if (error) {
      throw mapSqlError(error);
    }
    return data || [];
  }

  /**
   * Count PUBLISHED targets in rolling 24h window (by publishedAt).
   * Accepts one or more accountIds — pass siblings for global cross-project count.
   */
  async countPublishedTargetsInLast24Hours(
    socialAccountId: string | string[],
  ): Promise<number> {
    const ids = Array.isArray(socialAccountId)
      ? socialAccountId
      : [socialAccountId];
    const since = new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString();
    const { count, error } = await (this.supabase as any)
      .from(TABLE_NAME)
      .select('*', { count: 'exact', head: true })
      .in('socialAccountId', ids)
      .eq('status', 'PUBLISHED')
      .gte('publishedAt', since);

    if (error) {
      throw mapSqlError(error);
    }
    return count || 0;
  }

  /**
   * Count PENDING+QUEUED+PUBLISHING targets in rolling 24h window (by createdAt).
   * Accepts one or more accountIds — pass siblings for global cross-project count.
   */
  async countScheduledTargetsInLast24Hours(
    socialAccountId: string | string[],
  ): Promise<number> {
    const ids = Array.isArray(socialAccountId)
      ? socialAccountId
      : [socialAccountId];
    const since = new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString();
    const { count, error } = await (this.supabase as any)
      .from(TABLE_NAME)
      .select('*', { count: 'exact', head: true })
      .in('socialAccountId', ids)
      .in('status', ['PENDING', 'QUEUED', 'PUBLISHING'])
      .gte('createdAt', since);

    if (error) {
      throw mapSqlError(error);
    }
    return count || 0;
  }

  /**
   * Find PENDING/QUEUED targets, ordered by scheduledAt/createdAt.
   * Accepts one or more accountIds — pass siblings for global spacing check.
   */
  async findNearestTargetsByAccountId(
    socialAccountId: string | string[],
  ): Promise<any[]> {
    const ids = Array.isArray(socialAccountId)
      ? socialAccountId
      : [socialAccountId];
    const { data, error } = await (this.supabase as any)
      .from(TABLE_NAME)
      .select(
        `
        id, socialAccountId, status, createdAt,
        post:SocialPost(id, scheduledAt)
      `,
      )
      .in('socialAccountId', ids)
      .in('status', ['PENDING', 'QUEUED'])
      .order('createdAt', { ascending: true });

    if (error) {
      throw mapSqlError(error);
    }
    return data || [];
  }

  /**
   * Bulk-cancel all PENDING/QUEUED targets for an account (circuit breaker).
   * Returns the number of cancelled targets.
   */
  async cancelPendingAndQueuedForAccount(
    socialAccountId: string,
    reason: string,
  ): Promise<number> {
    const { data, error } = await (this.supabase as any)
      .from(TABLE_NAME)
      .update({
        status: 'CANCELLED',
        errorMessage: reason,
        errorType: 'FATAL',
      })
      .eq('socialAccountId', socialAccountId)
      .in('status', ['PENDING', 'QUEUED'])
      .select('id');

    if (error) {
      throw mapSqlError(error);
    }
    return data?.length || 0;
  }

  /**
   * Find the latest "commit" timestamp across committed targets for an account.
   * Returns MAX(publishedAt, post.scheduledAt, createdAt) for PUBLISHED/PENDING/QUEUED/PUBLISHING targets.
   * Excludes FAILED/CANCELLED.
   */
  async findLastCommitAt(
    socialAccountId: string | string[],
  ): Promise<string | null> {
    const ids = Array.isArray(socialAccountId)
      ? socialAccountId
      : [socialAccountId];
    const { data, error } = await (this.supabase as any)
      .from(TABLE_NAME)
      .select(
        `
        publishedAt, createdAt,
        post:SocialPost(scheduledAt)
      `,
      )
      .in('socialAccountId', ids)
      .in('status', ['PUBLISHED', 'PENDING', 'QUEUED', 'PUBLISHING'])
      .order('createdAt', { ascending: false })
      .limit(50);

    if (error) {
      throw mapSqlError(error);
    }

    if (!data || data.length === 0) {
      return null;
    }

    let maxTime = 0;
    for (const target of data) {
      const candidates = [
        target.publishedAt ? new Date(target.publishedAt).getTime() : 0,
        target.post?.scheduledAt
          ? new Date(target.post.scheduledAt).getTime()
          : 0,
        new Date(target.createdAt).getTime(),
      ];
      const best = Math.max(...candidates);
      if (best > maxTime) {
        maxTime = best;
      }
    }

    return maxTime > 0 ? new Date(maxTime).toISOString() : null;
  }

  async findAllQueuedGroupedByAccount(): Promise<any[]> {
    const { data, error } = await (this.supabase as any)
      .from(TABLE_NAME)
      .select(
        `
        *,
        post:SocialPost(*),
        account:SocialAccount(*)
      `,
      )
      .eq('status', 'QUEUED')
      .order('createdAt', { ascending: true });

    if (error) {
      throw mapSqlError(error);
    }
    return data || [];
  }

  async updateBullmqJobId(targetId: string, jobId: string): Promise<void> {
    const { error } = await (this.supabase as any)
      .from(TABLE_NAME)
      .update({ bullmqJobId: jobId })
      .eq('id', targetId);

    if (error) {
      throw mapSqlError(error);
    }
  }

  async findStuckPublishingTargets(olderThan: Date): Promise<any[]> {
    const { data, error } = await (this.supabase as any)
      .from(TABLE_NAME)
      .select(
        `
        *,
        post:SocialPost(*),
        account:SocialAccount(*)
      `,
      )
      .eq('status', 'PUBLISHING')
      .lt('updatedAt', olderThan.toISOString());

    if (error) {
      throw mapSqlError(error);
    }
    return data || [];
  }
}
