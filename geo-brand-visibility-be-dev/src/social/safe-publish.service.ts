import { Injectable, Logger } from '@nestjs/common';
import { SocialAccountRepository } from './social-account.repository';
import { SocialPostTargetRepository } from './social-post-target.repository';
import {
  getSafePublishConfig,
  HARD_FLOOR_MINUTES,
  MAX_CONSECUTIVE_ERRORS,
} from './constants/safe-publish-limits';
import { CooldownReason, RateLimitErrorCode } from './enums';

export interface CanPublishResult {
  eligible: boolean;
  reason?: string;
  retryAfterMs?: number;
}

export interface PublishErrorResult {
  shouldPause: boolean;
  pauseUntil?: Date;
  shouldDisableAutoPublish?: boolean;
  cancelledCount?: number;
}

export interface QueueStatusResult {
  postsPublishedToday: number;
  maxPostsPerDay: number;
  lastPublishedAt: string | null;
  pausedUntil: string | null;
  consecutiveErrorCount: number;
  queuedCount: number;
  nextEligibleAt: string | null;
}

export interface RateLimitRejection {
  accountId: string;
  platform: string;
  code: RateLimitErrorCode;
  message: string;
  details: {
    limit?: number;
    current?: number;
    resetAt?: string;
    retryAfter?: number;
  };
}

export interface PublishEligibilityResult {
  eligible: boolean;
  rejection?: RateLimitRejection;
}

export interface PostStatsResult {
  accountId: string;
  platform: string;
  window: string;
  publishedCount: number;
  scheduledCount: number;
  totalCount: number;
  dailyLimit: number;
  remaining: number;
  minSpacingMinutes: number;
  lastPublishedAt: string | null;
  lastCommitAt: string | null;
  nextAvailableAt: string | null;
}

export interface ScheduledSlot {
  targetId: string;
  postId: string;
  scheduledAt: string | null;
  status: string;
  createdAt: string;
}

@Injectable()
export class SafePublishService {
  private readonly logger = new Logger(SafePublishService.name);

  constructor(
    private readonly socialAccountRepo: SocialAccountRepository,
    private readonly socialPostTargetRepo: SocialPostTargetRepository,
  ) {}

  // ============================================================
  // P0: Publish eligibility validation (structured error codes)
  // ============================================================

  /**
   * Resolve all sibling account IDs sharing the same platformAccountId.
   * Used to enforce global cross-project cadence limits.
   */
  private async resolveSiblingIds(account: {
    id: string;
    platformAccountId: string;
    connectedByUserId: string;
  }): Promise<string[]> {
    const siblings =
      await this.socialAccountRepo.findSiblingsByPlatformAccountId(
        account.platformAccountId,
        account.connectedByUserId,
      );
    const ids = siblings.map((s) => s.id);
    // Always include current account even if not returned by siblings query
    return ids.includes(account.id) ? ids : [account.id, ...ids];
  }

  async validatePublishEligibility(
    accountId: string,
    scheduledAt?: string,
    bypassSoftLimits = false,
  ): Promise<PublishEligibilityResult> {
    const account = await this.socialAccountRepo.findById(accountId);

    // 1. Account not found / inactive
    if (!account || !account.isActive) {
      return {
        eligible: false,
        rejection: {
          accountId,
          platform: account?.platform || 'unknown',
          code: RateLimitErrorCode.AccountInvalid,
          message: account
            ? 'Account is inactive or disconnected'
            : 'Account not found',
          details: {},
        },
      };
    }

    const platform = account.platform;
    const config = getSafePublishConfig(platform);

    // 2. Token expired
    if (account.tokenExpiresAt) {
      const expiresAt = new Date(account.tokenExpiresAt).getTime();
      if (expiresAt < Date.now()) {
        return {
          eligible: false,
          rejection: {
            accountId,
            platform,
            code: RateLimitErrorCode.AccountTokenExpired,
            message: `OAuth token expired for ${platform}`,
            details: {
              resetAt: account.tokenExpiresAt,
            },
          },
        };
      }
    }

    // 3. Cooldown check
    if (account.pausedUntil) {
      const pauseEnd = new Date(account.pausedUntil).getTime();
      const now = Date.now();
      if (pauseEnd > now) {
        const code =
          account.cooldownReason === CooldownReason.PlatformRateLimit
            ? RateLimitErrorCode.PlatformRateLimited
            : RateLimitErrorCode.AccountCooldown;

        return {
          eligible: false,
          rejection: {
            accountId,
            platform,
            code,
            message: `Account paused until ${account.pausedUntil}`,
            details: {
              resetAt: account.pausedUntil,
              retryAfter: Math.ceil((pauseEnd - now) / 1000),
            },
          },
        };
      }
      // Pause expired — clear it
      await this.socialAccountRepo.updatePublishStats(accountId, {
        pausedUntil: null,
        cooldownReason: null,
      });
    }

    // Resolve sibling account IDs (same platformAccountId, same user, any project)
    const siblingIds = await this.resolveSiblingIds(account);

    // 4. Daily cap — global count across all sibling accounts
    const publishedCount =
      await this.socialPostTargetRepo.countPublishedTargetsInLast24Hours(
        siblingIds,
      );
    const scheduledCount =
      await this.socialPostTargetRepo.countScheduledTargetsInLast24Hours(
        siblingIds,
      );
    const totalCount = publishedCount + scheduledCount;

    if (!bypassSoftLimits && totalCount >= config.maxPostsPerDay) {
      return {
        eligible: false,
        rejection: {
          accountId,
          platform,
          code: RateLimitErrorCode.DailyCap,
          message: `Daily post limit reached for ${platform} (${totalCount}/${config.maxPostsPerDay})`,
          details: {
            limit: config.maxPostsPerDay,
            current: totalCount,
          },
        },
      };
    }

    const effectiveSpacing = Math.max(
      HARD_FLOOR_MINUTES,
      config.minSpacingMinutes,
    );
    const effectiveSpacingMs = effectiveSpacing * 60 * 1000;
    const isImmediate = !scheduledAt;

    // 5 & 6. Hard floor + platform spacing from last publish (immediate only)
    if (isImmediate && account.lastPublishedAt) {
      const lastTime = new Date(account.lastPublishedAt).getTime();
      const elapsed = Date.now() - lastTime;

      if (elapsed < HARD_FLOOR_MINUTES * 60 * 1000) {
        const remainingMs = HARD_FLOOR_MINUTES * 60 * 1000 - elapsed;
        return {
          eligible: false,
          rejection: {
            accountId,
            platform,
            code: RateLimitErrorCode.HardFloor,
            message: `Minimum ${HARD_FLOOR_MINUTES} minutes between posts`,
            details: {
              retryAfter: Math.ceil(remainingMs / 1000),
              resetAt: new Date(
                lastTime + HARD_FLOOR_MINUTES * 60 * 1000,
              ).toISOString(),
            },
          },
        };
      }

      if (!bypassSoftLimits && elapsed < effectiveSpacingMs) {
        const remainingMs = effectiveSpacingMs - elapsed;
        return {
          eligible: false,
          rejection: {
            accountId,
            platform,
            code: RateLimitErrorCode.Spacing,
            message: `Minimum ${effectiveSpacing} minutes spacing required for ${platform}`,
            details: {
              retryAfter: Math.ceil(remainingMs / 1000),
              resetAt: new Date(lastTime + effectiveSpacingMs).toISOString(),
            },
          },
        };
      }
    }

    // 7. Spacing vs nearest PENDING/QUEUED targets — global across sibling accounts
    const upcomingTargets =
      await this.socialPostTargetRepo.findNearestTargetsByAccountId(siblingIds);

    if (upcomingTargets.length > 0) {
      const proposedTime = scheduledAt
        ? new Date(scheduledAt).getTime()
        : Date.now();

      for (const target of upcomingTargets) {
        const targetTime = target.post?.scheduledAt
          ? new Date(target.post.scheduledAt).getTime()
          : new Date(target.createdAt).getTime();

        const gap = Math.abs(proposedTime - targetTime);
        if (gap < effectiveSpacingMs) {
          return {
            eligible: false,
            rejection: {
              accountId,
              platform,
              code: RateLimitErrorCode.Spacing,
              message: `Too close to another scheduled post (minimum ${effectiveSpacing} minutes)`,
              details: {
                retryAfter: Math.ceil((effectiveSpacingMs - gap) / 1000),
              },
            },
          };
        }
      }
    }

    return { eligible: true };
  }

  // ============================================================
  // Existing: canPublishNow (used by scheduler — kept for compat)
  // ============================================================

  async canPublishNow(accountId: string): Promise<CanPublishResult> {
    const account = await this.socialAccountRepo.findById(accountId);
    if (!account) {
      return { eligible: false, reason: 'Account not found' };
    }

    if (!account.isActive) {
      return { eligible: false, reason: 'Account is inactive' };
    }

    // Check pause
    if (account.pausedUntil) {
      const pauseEnd = new Date(account.pausedUntil).getTime();
      const now = Date.now();
      if (pauseEnd > now) {
        return {
          eligible: false,
          reason: `Account paused until ${account.pausedUntil}`,
          retryAfterMs: pauseEnd - now,
        };
      }
      // Pause expired — clear it
      await this.socialAccountRepo.updatePublishStats(accountId, {
        pausedUntil: null,
        cooldownReason: null,
      });
    }

    const config = getSafePublishConfig(account.platform);

    // Check daily limit (rolling 24h)
    const publishedToday =
      await this.socialPostTargetRepo.countPublishedInLast24Hours(accountId);
    if (publishedToday >= config.maxPostsPerDay) {
      return {
        eligible: false,
        reason: `Daily limit reached (${publishedToday}/${config.maxPostsPerDay})`,
      };
    }

    // Check spacing
    if (account.lastPublishedAt) {
      const lastTime = new Date(account.lastPublishedAt).getTime();
      const minGapMs = config.minSpacingMinutes * 60 * 1000;
      const elapsed = Date.now() - lastTime;
      if (elapsed < minGapMs) {
        return {
          eligible: false,
          reason: `Spacing not met (${Math.ceil((minGapMs - elapsed) / 60000)} min remaining)`,
          retryAfterMs: minGapMs - elapsed,
        };
      }
    }

    return { eligible: true };
  }

  // ============================================================
  // Publish success/error handling
  // ============================================================

  async onPublishSuccess(accountId: string): Promise<void> {
    await this.socialAccountRepo.updatePublishStats(accountId, {
      lastPublishedAt: new Date().toISOString(),
      consecutiveErrorCount: 0,
      pausedUntil: null,
      cooldownReason: null,
    });
  }

  async onPublishError(
    accountId: string,
    platform: string,
    errorCode: string,
    httpStatus?: number,
  ): Promise<PublishErrorResult> {
    const config = getSafePublishConfig(platform);
    const result: PublishErrorResult = { shouldPause: false };

    // Facebook Error 368: "misusing this feature"
    if (errorCode === '368') {
      const pauseUntil = new Date(Date.now() + 24 * 60 * 60 * 1000);
      await this.socialAccountRepo.updatePublishStats(accountId, {
        pausedUntil: pauseUntil.toISOString(),
        cooldownReason: CooldownReason.PlatformRateLimit,
      });
      this.logger.warn(
        `[SafePublish] Account ${accountId} paused 24h due to Facebook error 368`,
      );
      return { shouldPause: true, pauseUntil };
    }

    // HTTP 429: rate limit
    if (httpStatus === 429) {
      const pauseUntil = new Date(
        Date.now() + config.errorCooldownHours * 60 * 60 * 1000,
      );
      await this.socialAccountRepo.updatePublishStats(accountId, {
        pausedUntil: pauseUntil.toISOString(),
        cooldownReason: CooldownReason.PlatformRateLimit,
      });
      this.logger.warn(
        `[SafePublish] Account ${accountId} paused ${config.errorCooldownHours}h due to HTTP 429`,
      );
      return { shouldPause: true, pauseUntil };
    }

    // Facebook Error 506: duplicate content — no pause, just skip
    if (errorCode === '506') {
      return { shouldPause: false };
    }

    // Increment consecutive errors
    const errorCount =
      await this.socialAccountRepo.incrementConsecutiveErrors(accountId);

    // 3+ consecutive errors: circuit breaker
    if (errorCount >= MAX_CONSECUTIVE_ERRORS) {
      const pauseUntil = new Date(
        Date.now() + config.errorCooldownHours * 60 * 60 * 1000,
      );
      await this.socialAccountRepo.updatePublishStats(accountId, {
        pausedUntil: pauseUntil.toISOString(),
        cooldownReason: CooldownReason.CircuitBreaker,
      });

      // Cancel all pending/queued targets
      const cancelledCount =
        await this.socialPostTargetRepo.cancelPendingAndQueuedForAccount(
          accountId,
          'Auto-cancelled: circuit breaker triggered after consecutive failures',
        );

      this.logger.warn(
        `[SafePublish] Circuit breaker: account ${accountId} paused + auto-publish disabled, cancelled ${cancelledCount} pending targets`,
      );
      return {
        shouldPause: true,
        pauseUntil,
        shouldDisableAutoPublish: true,
        cancelledCount,
      };
    }

    return result;
  }

  // ============================================================
  // P1: Post stats and scheduled slots
  // ============================================================

  async getPostStats(accountId: string): Promise<PostStatsResult> {
    const account = await this.socialAccountRepo.findById(accountId);
    if (!account) {
      return {
        accountId,
        platform: 'unknown',
        window: '24h',
        publishedCount: 0,
        scheduledCount: 0,
        totalCount: 0,
        dailyLimit: 0,
        remaining: 0,
        minSpacingMinutes: 0,
        lastPublishedAt: null,
        lastCommitAt: null,
        nextAvailableAt: null,
      };
    }

    const config = getSafePublishConfig(account.platform);
    const siblingIds = await this.resolveSiblingIds(account);
    const [publishedCount, scheduledCount, lastCommitAt] = await Promise.all([
      this.socialPostTargetRepo.countPublishedTargetsInLast24Hours(siblingIds),
      this.socialPostTargetRepo.countScheduledTargetsInLast24Hours(siblingIds),
      this.socialPostTargetRepo.findLastCommitAt(siblingIds),
    ]);

    const totalCount = publishedCount + scheduledCount;
    const remaining = Math.max(0, config.maxPostsPerDay - totalCount);

    const nextAvailableAt = this.computeNextAvailableAt(
      account,
      config,
      totalCount,
    );

    return {
      accountId,
      platform: account.platform,
      window: '24h',
      publishedCount,
      scheduledCount,
      totalCount,
      dailyLimit: config.maxPostsPerDay,
      remaining,
      minSpacingMinutes: config.minSpacingMinutes,
      lastPublishedAt: account.lastPublishedAt,
      lastCommitAt,
      nextAvailableAt,
    };
  }

  async getScheduledSlots(
    accountId: string,
  ): Promise<{ accountId: string; slots: ScheduledSlot[] }> {
    const account = await this.socialAccountRepo.findById(accountId);
    const siblingIds = account
      ? await this.resolveSiblingIds(account)
      : [accountId];
    const targets =
      await this.socialPostTargetRepo.findNearestTargetsByAccountId(siblingIds);

    const slots: ScheduledSlot[] = targets.map((t) => ({
      targetId: t.id,
      postId: t.post?.id || '',
      scheduledAt: t.post?.scheduledAt || null,
      status: t.status,
      createdAt: t.createdAt,
    }));

    return { accountId, slots };
  }

  // ============================================================
  // Existing: Queue status (kept for compat)
  // ============================================================

  async getQueueStatus(accountId: string): Promise<QueueStatusResult> {
    const account = await this.socialAccountRepo.findById(accountId);
    if (!account) {
      return {
        postsPublishedToday: 0,
        maxPostsPerDay: 0,
        lastPublishedAt: null,
        pausedUntil: null,
        consecutiveErrorCount: 0,
        queuedCount: 0,
        nextEligibleAt: null,
      };
    }

    const config = getSafePublishConfig(account.platform);
    const publishedToday =
      await this.socialPostTargetRepo.countPublishedInLast24Hours(accountId);
    const queuedTargets =
      await this.socialPostTargetRepo.findQueuedByAccountId(accountId);

    let nextEligibleAt: string | null = null;

    // Calculate next eligible time
    if (account.pausedUntil && new Date(account.pausedUntil) > new Date()) {
      nextEligibleAt = account.pausedUntil;
    } else if (publishedToday >= config.maxPostsPerDay) {
      nextEligibleAt = null; // Will be eligible after 24h rolling window clears
    } else if (account.lastPublishedAt) {
      const nextSpacing = new Date(
        new Date(account.lastPublishedAt).getTime() +
          config.minSpacingMinutes * 60 * 1000,
      );
      if (nextSpacing > new Date()) {
        nextEligibleAt = nextSpacing.toISOString();
      }
    }

    return {
      postsPublishedToday: publishedToday,
      maxPostsPerDay: config.maxPostsPerDay,
      lastPublishedAt: account.lastPublishedAt,
      pausedUntil: account.pausedUntil,
      consecutiveErrorCount: account.consecutiveErrorCount,
      queuedCount: queuedTargets.length,
      nextEligibleAt,
    };
  }

  // ============================================================
  // Helpers
  // ============================================================

  private computeNextAvailableAt(
    account: { pausedUntil: string | null; lastPublishedAt: string | null },
    config: { minSpacingMinutes: number; maxPostsPerDay: number },
    totalCount: number,
  ): string | null {
    const now = Date.now();
    const candidates: number[] = [];

    // Cooldown
    if (account.pausedUntil) {
      const pauseEnd = new Date(account.pausedUntil).getTime();
      if (pauseEnd > now) {
        candidates.push(pauseEnd);
      }
    }

    // Spacing from last publish
    if (account.lastPublishedAt) {
      const effectiveSpacing = Math.max(
        HARD_FLOOR_MINUTES,
        config.minSpacingMinutes,
      );
      const spacingEnd =
        new Date(account.lastPublishedAt).getTime() +
        effectiveSpacing * 60 * 1000;
      if (spacingEnd > now) {
        candidates.push(spacingEnd);
      }
    }

    // Daily cap exhausted — no simple reset time (rolling window)
    if (totalCount >= config.maxPostsPerDay) {
      // Conservative: assume next slot opens in ~1h (rolling window)
      // Exact calculation would require querying oldest target's timestamp
      candidates.push(now + 60 * 60 * 1000);
    }

    if (candidates.length === 0) {
      return null; // Available now
    }

    const nextAvailable = Math.max(...candidates);
    return nextAvailable <= now ? null : new Date(nextAvailable).toISOString();
  }
}
