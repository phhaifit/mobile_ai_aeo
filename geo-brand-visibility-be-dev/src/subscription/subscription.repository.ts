import { Inject, Injectable } from '@nestjs/common';
import { SUPABASE } from '../utils/const';
import { SupabaseClient } from '@supabase/supabase-js';
import { Database, Tables, TablesInsert } from '../supabase/supabase.types';
import { mapSqlError } from '../utils/map-sql-error.util';
import { startOfDayUTC, endOfDayUTC } from '../utils/date.util';
import {
  SUBSCRIPTION_TABLE,
  STRIPE_EVENT_TABLE,
  PROJECT_TABLE,
} from './subscription.constants';

type ProjectSubscription = Tables<'ProjectSubscription'>;
type ProjectSubscriptionInsert = TablesInsert<'ProjectSubscription'>;

@Injectable()
export class SubscriptionRepository {
  constructor(
    @Inject(SUPABASE) private readonly supabase: SupabaseClient<Database>,
  ) {}

  async findByProjectId(
    projectId: string,
  ): Promise<ProjectSubscription | null> {
    const { data, error } = await this.supabase
      .from(SUBSCRIPTION_TABLE)
      .select('*')
      .eq('projectId', projectId)
      .maybeSingle();

    if (error) {
      throw mapSqlError(error);
    }

    return data;
  }

  async findByStripeSubscriptionId(
    stripeSubscriptionId: string,
  ): Promise<ProjectSubscription | null> {
    const { data, error } = await this.supabase
      .from(SUBSCRIPTION_TABLE)
      .select('*')
      .eq('stripeSubscriptionId', stripeSubscriptionId)
      .maybeSingle();

    if (error) {
      throw mapSqlError(error);
    }

    return data;
  }

  async upsertByStripeSubscriptionId(
    subscription: ProjectSubscriptionInsert,
  ): Promise<ProjectSubscription> {
    const { data, error } = await this.supabase
      .from(SUBSCRIPTION_TABLE)
      .upsert(subscription, { onConflict: 'stripeSubscriptionId' })
      .select()
      .single();

    if (error) {
      throw mapSqlError(error);
    }

    return data;
  }

  async isEventProcessed(stripeEventId: string): Promise<boolean> {
    const { data, error } = await this.supabase
      .from(STRIPE_EVENT_TABLE)
      .select('id')
      .eq('id', stripeEventId)
      .maybeSingle();

    if (error) {
      throw mapSqlError(error);
    }

    return !!data;
  }

  async recordEvent(
    stripeEventId: string,
    eventType: string,
    data: Record<string, unknown> | null,
    status: 'success' | 'error' = 'success',
    errorMessage?: string | null,
  ): Promise<void> {
    const { error } = await this.supabase.from(STRIPE_EVENT_TABLE).insert({
      id: stripeEventId,
      eventType,
      data: data as any,
      status,
      errorMessage: errorMessage ?? null,
    });

    if (error) {
      throw mapSqlError(error);
    }
  }

  async updateProjectStripeCustomerId(
    projectId: string,
    stripeCustomerId: string | null,
  ): Promise<void> {
    const { error } = await this.supabase
      .from(PROJECT_TABLE)
      .update({ stripeCustomerId } as any)
      .eq('id', projectId);

    if (error) {
      throw mapSqlError(error);
    }
  }

  async getUsageCount(
    projectId: string,
    periodStart: string,
    periodEnd: string,
  ): Promise<number> {
    const { data, error } = await this.supabase
      .from('Content')
      .select('id, Topic!inner(projectId)')
      .eq('Topic.projectId', projectId)
      .in('completionStatus', ['COMPLETE', 'PUBLISHED'])
      .gte('createdAt', periodStart)
      .lte('createdAt', periodEnd);

    if (error) {
      throw mapSqlError(error);
    }

    return (data as any[])?.length ?? 0;
  }

  async getDailyUsage(
    projectId: string,
    startDate: string,
    endDate: string,
  ): Promise<{ date: string; count: number }[]> {
    const { data, error } = await this.supabase
      .from('Content')
      .select('createdAt, Topic!inner(projectId)')
      .eq('Topic.projectId', projectId)
      .in('completionStatus', ['COMPLETE', 'PUBLISHED'])
      .gte('createdAt', startDate)
      .lte('createdAt', endDate)
      .order('createdAt', { ascending: true });

    if (error) {
      throw mapSqlError(error);
    }

    // Group by date (YYYY-MM-DD)
    const rows = (data as { createdAt: string }[]) ?? [];
    const dailyMap = new Map<string, number>();
    for (const row of rows) {
      const date = row.createdAt.split('T')[0];
      dailyMap.set(date, (dailyMap.get(date) ?? 0) + 1);
    }

    return Array.from(dailyMap.entries()).map(([date, count]) => ({
      date,
      count,
    }));
  }

  async updateProjectAutoFlags(
    projectId: string,
    flags: { autoGenerate: boolean; autoAnalysis: boolean },
  ): Promise<void> {
    const { error } = await this.supabase
      .from(PROJECT_TABLE)
      .update({
        autoGenerate: flags.autoGenerate,
        autoAnalysis: flags.autoAnalysis,
      } as any)
      .eq('id', projectId);

    if (error) {
      throw mapSqlError(error);
    }
  }

  async getProjectStripeCustomerId(projectId: string): Promise<string | null> {
    const { data, error } = await this.supabase
      .from(PROJECT_TABLE)
      .select('stripeCustomerId')
      .eq('id', projectId)
      .single();

    if (error) {
      throw mapSqlError(error);
    }

    return data?.stripeCustomerId ?? null;
  }

  async getSubscriptionStripeCustomerId(
    projectId: string,
  ): Promise<string | null> {
    const { data, error } = await this.supabase
      .from(SUBSCRIPTION_TABLE)
      .select('stripeCustomerId')
      .eq('projectId', projectId)
      .order('createdAt', { ascending: false })
      .limit(1)
      .maybeSingle();

    if (error) {
      throw mapSqlError(error);
    }

    return data?.stripeCustomerId ?? null;
  }

  async findSubscriptionsExpiringOn(
    targetDate: string,
  ): Promise<ProjectSubscription[]> {
    const targetDateObj = new Date(`${targetDate}T00:00:00.000Z`);
    const startOfDay = startOfDayUTC(targetDateObj);
    const endOfDay = endOfDayUTC(targetDateObj);

    const { data, error } = await this.supabase
      .from(SUBSCRIPTION_TABLE)
      .select('*')
      .eq('status', 'active')
      .eq('cancelAtPeriodEnd', false)
      .gte('currentPeriodEnd', startOfDay)
      .lte('currentPeriodEnd', endOfDay);

    if (error) {
      throw mapSqlError(error);
    }

    // Only include subscriptions not yet reminded for the current period
    return (data ?? []).filter(
      (sub) =>
        !sub.lastRenewalReminderSentAt ||
        sub.lastRenewalReminderSentAt < (sub.currentPeriodStart ?? ''),
    );
  }

  async updateRenewalReminderSentAt(
    stripeSubscriptionId: string,
  ): Promise<void> {
    const { error } = await this.supabase
      .from(SUBSCRIPTION_TABLE)
      .update({ lastRenewalReminderSentAt: new Date().toISOString() } as any)
      .eq('stripeSubscriptionId', stripeSubscriptionId);

    if (error) {
      throw mapSqlError(error);
    }
  }

  async deleteByProjectId(projectId: string): Promise<void> {
    const { error } = await this.supabase
      .from(SUBSCRIPTION_TABLE)
      .delete()
      .eq('projectId', projectId);

    if (error) {
      throw mapSqlError(error);
    }
  }
}
