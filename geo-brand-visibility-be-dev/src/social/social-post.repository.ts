import { Inject, Injectable, Logger } from '@nestjs/common';
import { SUPABASE } from '../utils/const';
import { SupabaseClient } from '@supabase/supabase-js';
import { Database } from '../supabase/supabase.types';
import { mapSqlError } from '../utils/map-sql-error.util';
import { SocialPostSource } from './enums';

const TABLE_NAME = 'SocialPost';

// TODO: After running migration and `pnpm gen:types`, replace with Tables<'SocialPost'>
export interface SocialPost {
  id: string;
  projectId: string;
  contentId: string | null;
  title: string | null;
  message: string;
  mediaUrls: string[];
  linkUrl: string | null;
  metadata: Record<string, any>;
  createdByUserId: string | null;
  scheduledAt: string | null;
  source: SocialPostSource;
  createdAt: string;
  updatedAt: string;
}

export type SocialPostInsert = Omit<
  SocialPost,
  'id' | 'createdAt' | 'updatedAt' | 'source'
> & {
  id?: string;
  source?: SocialPostSource;
};

export type SocialPostUpdate = Partial<
  Omit<SocialPost, 'id' | 'createdAt' | 'updatedAt'>
>;

@Injectable()
export class SocialPostRepository {
  private readonly logger = new Logger(SocialPostRepository.name);

  constructor(
    @Inject(SUPABASE) private readonly supabase: SupabaseClient<Database>,
  ) {}

  async create(data: SocialPostInsert): Promise<SocialPost> {
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

  async findById(id: string): Promise<SocialPost | null> {
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

  async findByIdWithTargets(id: string): Promise<any | null> {
    const { data, error } = await (this.supabase as any)
      .from(TABLE_NAME)
      .select(
        `
        *,
        targets:SocialPostTarget(
          *,
          account:SocialAccount(id, platform, accountName, accountAvatar)
        )
      `,
      )
      .eq('id', id)
      .maybeSingle();

    if (error) {
      throw mapSqlError(error);
    }
    return data;
  }

  async findByProjectId(
    projectId: string,
    options?: { limit?: number; offset?: number },
  ): Promise<{ data: any[]; count: number }> {
    const limit = options?.limit || 20;
    const offset = options?.offset || 0;

    const { data, error, count } = await (this.supabase as any)
      .from(TABLE_NAME)
      .select(
        `
        *,
        targets:SocialPostTarget(
          id, status, platformPostId, platformPostUrl, publishedAt, errorMessage,
          account:SocialAccount(id, platform, accountName, accountAvatar)
        )
      `,
        { count: 'exact' },
      )
      .eq('projectId', projectId)
      .order('createdAt', { ascending: false })
      .range(offset, offset + limit - 1);

    if (error) {
      throw mapSqlError(error);
    }
    return { data: data || [], count: count || 0 };
  }

  async update(id: string, data: SocialPostUpdate): Promise<SocialPost> {
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

  async delete(id: string): Promise<void> {
    const { error } = await (this.supabase as any)
      .from(TABLE_NAME)
      .delete()
      .eq('id', id);

    if (error) {
      throw mapSqlError(error);
    }
  }
}
