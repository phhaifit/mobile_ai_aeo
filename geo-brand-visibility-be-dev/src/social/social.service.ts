import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  Inject,
  Injectable,
  Logger,
  NotFoundException,
  UnprocessableEntityException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { InjectQueue } from '@nestjs/bullmq';
import { Queue } from 'bullmq';
import { SupabaseClient } from '@supabase/supabase-js';
import { SocialAccountRepository } from './social-account.repository';
import { SocialPostRepository } from './social-post.repository';
import {
  SocialPostTargetRepository,
  SocialPostTarget,
} from './social-post-target.repository';
import { PlatformProviderRegistry } from './platforms/platform-provider.registry';
import {
  isOAuthConnectable,
  isPostPublishable,
  PlatformChannel,
} from './platforms/platform-provider.interface';
import {
  encryptCredentials,
  decryptCredentials,
} from './utils/token-encryption.util';
import {
  PostTargetStatus,
  PublishErrorType,
  RateLimitErrorCode,
  SocialPlatform,
  SocialPostSource,
} from './enums';
import {
  SaveSocialAccountsDto,
  SocialAccountResponseDto,
} from './dto/social-account.dto';
import { CreateSocialPostDto } from './dto/social-post.dto';
import { SafePublishService, RateLimitRejection } from './safe-publish.service';
import { getSafePublishConfig } from './constants/safe-publish-limits';
import { QueueNames } from '../processors/contants/queue';
import { JOB_NAMES, SUPABASE } from '../utils/const';
import { Database } from '../supabase/supabase.types';
import { extractImagesFromMarkdown } from '../utils/markdown-image-extractor.util';

@Injectable()
export class SocialService {
  private readonly logger = new Logger(SocialService.name);
  private readonly encryptionKey: string;

  constructor(
    private readonly configService: ConfigService,
    private readonly registry: PlatformProviderRegistry,
    private readonly socialAccountRepo: SocialAccountRepository,
    private readonly socialPostRepo: SocialPostRepository,
    private readonly socialPostTargetRepo: SocialPostTargetRepository,
    private readonly safePublishService: SafePublishService,
    @InjectQueue(QueueNames.SocialPublish)
    private readonly publishQueue: Queue,
    @Inject(SUPABASE)
    private readonly supabase: SupabaseClient<Database>,
  ) {
    const key = this.configService.get<string>('SOCIAL_TOKEN_ENCRYPTION_KEY');
    if (!key || Buffer.from(key, 'hex').length !== 32) {
      throw new Error(
        'SOCIAL_TOKEN_ENCRYPTION_KEY must be a 64-character hex string (32 bytes for AES-256)',
      );
    }
    this.encryptionKey = key;
  }

  // ============================================================
  // Platform discovery
  // ============================================================

  getAvailablePlatforms() {
    return this.registry.getAllProviders().map((p) => {
      const config = getSafePublishConfig(p.platform);
      return {
        ...p.getConnectionConfig(),
        rateLimits: {
          maxPostsPerDay: config.maxPostsPerDay,
          minSpacingMinutes: config.minSpacingMinutes,
        },
      };
    });
  }

  // ============================================================
  // OAuth flow
  // ============================================================

  getConnectUrl(
    platform: SocialPlatform,
    projectId: string,
    userId: string,
  ): string {
    const provider = this.registry.getProvider(platform);
    if (!isOAuthConnectable(provider)) {
      throw new BadRequestException(
        `Platform ${platform} does not support OAuth. Use direct credentials instead.`,
      );
    }

    // Encode state as base64 JSON (projectId + userId for callback)
    const state = Buffer.from(
      JSON.stringify({ projectId, userId, platform }),
    ).toString('base64url');

    return provider.getConnectUrl(state);
  }

  async handleOAuthCallback(
    platform: SocialPlatform,
    code: string,
    state: string,
  ): Promise<{ channels: PlatformChannel[]; state: any }> {
    const provider = this.registry.getProvider(platform);
    if (!isOAuthConnectable(provider)) {
      throw new BadRequestException(
        `Platform ${platform} does not support OAuth`,
      );
    }

    // Decode state
    const stateData = JSON.parse(
      Buffer.from(state, 'base64url').toString('utf8'),
    );

    const callbackUrl =
      this.configService.get<string>('SOCIAL_OAUTH_CALLBACK_URL') +
      `/${platform}`;

    // Exchange code for short-lived token
    const { userAccessToken } = await provider.handleCallback(
      code,
      callbackUrl,
    );

    // Exchange for long-lived token
    const longLived = await provider.exchangeForLongLivedToken(userAccessToken);

    // List available channels/pages
    const channels = await provider.listChannels(longLived.token);

    return { channels, state: stateData };
  }

  // ============================================================
  // Account management
  // ============================================================

  async saveOAuthAccounts(
    projectId: string,
    userId: string,
    dto: SaveSocialAccountsDto,
  ): Promise<SocialAccountResponseDto[]> {
    const provider = this.registry.getProvider(dto.platform);

    // Conflict check: each platformAccountId must not be connected to a different project by this user
    const conflicts = await this.checkPlatformAccountConflicts(
      dto.accounts.map((a) => a.platformAccountId),
      projectId,
      userId,
    );
    if (conflicts.length > 0) {
      const c = conflicts[0];
      const message =
        `${c.platform} account '${c.accountName}' is already connected to project '${c.existingProjectName}'. ` +
        `Disconnect it there first.`;
      throw new ConflictException({
        code: 'ACCOUNT_ALREADY_CONNECTED',
        message,
        conflicts,
      });
    }

    const results: SocialAccountResponseDto[] = [];

    for (const account of dto.accounts) {
      const credentials = encryptCredentials(
        { accessToken: account.accessToken },
        this.encryptionKey,
      );

      const saved = await this.socialAccountRepo.upsert({
        projectId,
        platform: dto.platform,
        connectionType: provider.connectionType,
        platformAccountId: account.platformAccountId,
        accountName: account.accountName,
        accountAvatar: account.accountAvatar || null,
        credentials,
        tokenExpiresAt: null, // Page tokens don't expire for Facebook
        metadata: account.metadata || {},
        connectedByUserId: userId,
        isActive: true,
      });

      results.push(this.mapAccountToDto(saved));
    }

    return results;
  }

  async saveDirectAccount(
    projectId: string,
    userId: string,
    platform: SocialPlatform,
    accountName: string,
    rawCredentials: Record<string, any>,
  ): Promise<SocialAccountResponseDto> {
    const provider = this.registry.getProvider(platform);

    // Validate credentials before saving
    const validation = await provider.validateConnection(rawCredentials);
    if (!validation.valid) {
      throw new BadRequestException(`Invalid credentials: ${validation.error}`);
    }

    const resolvedPlatformAccountId =
      validation.accountId || rawCredentials.webhookUrl || platform;

    const conflicts = await this.checkPlatformAccountConflicts(
      [resolvedPlatformAccountId],
      projectId,
      userId,
    );
    if (conflicts.length > 0) {
      const c = conflicts[0];
      const message =
        `${c.platform} account '${c.accountName}' is already connected to project '${c.existingProjectName}'. ` +
        `Disconnect it there first.`;
      throw new ConflictException({
        code: 'ACCOUNT_ALREADY_CONNECTED',
        message,
        conflicts,
      });
    }

    const credentials = encryptCredentials(rawCredentials, this.encryptionKey);

    const saved = await this.socialAccountRepo.upsert({
      projectId,
      platform,
      connectionType: provider.connectionType,
      platformAccountId: resolvedPlatformAccountId,
      accountName: validation.accountName || accountName,
      accountAvatar: validation.accountAvatar || null,
      credentials,
      metadata: {},
      connectedByUserId: userId,
      isActive: true,
    });

    return this.mapAccountToDto(saved);
  }

  async getAccountsByProject(
    projectId: string,
  ): Promise<SocialAccountResponseDto[]> {
    const accounts = await this.socialAccountRepo.findByProjectId(projectId);
    return accounts.map((a) => this.mapAccountToDto(a));
  }

  async disconnectAccount(accountId: string, userId: string): Promise<void> {
    const account = await this.socialAccountRepo.findById(accountId);
    if (!account) {
      throw new NotFoundException('Social account not found');
    }
    if (account.connectedByUserId !== userId) {
      throw new ForbiddenException(
        'Only the user who connected this account can disconnect it',
      );
    }

    // Cancel pending/queued targets for this account
    const pendingTargets =
      await this.socialPostTargetRepo.findPendingByAccountId(accountId);
    for (const target of pendingTargets) {
      await this.socialPostTargetRepo.updateStatus(
        target.id,
        PostTargetStatus.Failed,
        {
          errorMessage: 'Account disconnected',
          errorType: PublishErrorType.Fatal,
        },
      );
    }

    await this.socialAccountRepo.deactivate(accountId);
  }

  // ============================================================
  // Post creation & publishing
  // ============================================================

  async createPost(
    projectId: string,
    userId: string,
    dto: CreateSocialPostDto,
  ) {
    // Validate scheduledAt constraints
    if (dto.scheduledAt) {
      const scheduledTime = new Date(dto.scheduledAt).getTime();
      if (isNaN(scheduledTime)) {
        throw new BadRequestException('Invalid scheduledAt date format');
      }
      const minTime = Date.now() + 10 * 60 * 1000; // 10 minutes
      const maxTime = Date.now() + 24 * 24 * 60 * 60 * 1000; // 24 days (BullMQ limit)
      if (scheduledTime < minTime) {
        throw new BadRequestException(
          'Scheduled time must be at least 10 minutes in the future',
        );
      }
      if (scheduledTime > maxTime) {
        throw new BadRequestException(
          'Scheduled time cannot be more than 24 days in the future',
        );
      }
    }

    // Validate all target accounts exist and belong to this project
    const accounts = await this.socialAccountRepo.findByProjectId(projectId);
    const accountMap = new Map(accounts.map((a) => [a.id, a]));

    for (const accountId of dto.socialAccountIds) {
      if (!accountMap.has(accountId)) {
        throw new BadRequestException(
          `Social account ${accountId} not found in this project`,
        );
      }
    }

    // Duplicate prevention: check if contentId + accountId already has pending/queued target
    if (dto.contentId) {
      const existingTargets =
        await this.socialPostTargetRepo.findPendingByContentAndAccounts(
          dto.contentId,
          dto.socialAccountIds,
        );
      if (existingTargets.length > 0) {
        const duplicateAccountIds = [
          ...new Set(existingTargets.map((t) => t.socialAccountId)),
        ];
        const duplicateNames = duplicateAccountIds
          .map((id) => accountMap.get(id)?.accountName || id)
          .join(', ');
        throw new BadRequestException(
          `Content already has a pending/scheduled post for: ${duplicateNames}`,
        );
      }
    }

    // Validate cadence override consent if provided
    if (dto.cadenceOverride) {
      const ackTime = new Date(dto.cadenceOverride.acknowledgedAt).getTime();
      const now = Date.now();
      if (ackTime > now) {
        throw new BadRequestException(
          'cadenceOverride.acknowledgedAt cannot be in the future',
        );
      }
      if (now - ackTime > 5 * 60 * 1000) {
        throw new BadRequestException(
          'cadenceOverride.acknowledgedAt is too old (max 5 minutes)',
        );
      }
      // Validate that override accounts match socialAccountIds
      for (const oa of dto.cadenceOverride.accounts) {
        if (!dto.socialAccountIds.includes(oa.accountId)) {
          throw new BadRequestException(
            `cadenceOverride account ${oa.accountId} not in socialAccountIds`,
          );
        }
      }

      // Rate-limit override abuse: >5 overrides in 7 days → reject
      const recentOverrides = await this.countUserOverrides(userId);
      if (recentOverrides >= 5) {
        throw new UnprocessableEntityException({
          code: 'PARTIAL_FAILURE',
          results: dto.cadenceOverride.accounts.map((oa) => ({
            accountId: oa.accountId,
            status: 'rejected',
            error: {
              code: RateLimitErrorCode.OverrideRateLimited,
              message:
                'Too many cadence overrides in the last 7 days. Please wait before overriding again.',
              details: {
                current: recentOverrides,
                limit: 5,
                windowDays: 7,
              },
            },
          })),
        });
      }
    }

    // Per-account rate limit validation
    const eligible: string[] = [];
    const rejections: RateLimitRejection[] = [];

    for (const accountId of dto.socialAccountIds) {
      const hasSoftOverride =
        dto.cadenceOverride?.severity === 'soft' &&
        dto.cadenceOverride.accounts.some((oa) => oa.accountId === accountId);

      const result = await this.safePublishService.validatePublishEligibility(
        accountId,
        dto.scheduledAt,
        hasSoftOverride,
      );
      if (result.eligible) {
        eligible.push(accountId);
      } else {
        rejections.push(result.rejection!);
        // Fire-and-forget audit log
        this.logRateLimitRejection(userId, result.rejection!).catch(() => {});
      }
    }

    // All accounts rejected
    if (eligible.length === 0) {
      throw new UnprocessableEntityException({
        code: 'PARTIAL_FAILURE',
        results: rejections.map((r) => ({
          accountId: r.accountId,
          status: 'rejected',
          error: { code: r.code, message: r.message, details: r.details },
        })),
      });
    }

    // Auto-resolve mediaUrls from linked content if not provided
    let resolvedMediaUrls = dto.mediaUrls || [];
    this.logger.log(
      `[createPost] mediaUrls from dto: ${JSON.stringify(dto.mediaUrls)}, contentId: ${dto.contentId}, resolvedMediaUrls length: ${resolvedMediaUrls.length}`,
    );
    if (resolvedMediaUrls.length === 0 && dto.contentId) {
      resolvedMediaUrls = await this.resolveMediaUrlsFromContent(
        dto.contentId,
        projectId,
      );
      this.logger.log(
        `[createPost] After resolve: ${JSON.stringify(resolvedMediaUrls)}`,
      );
    }

    // Build metadata with override consent if provided
    const metadata: Record<string, any> = { ...(dto.metadata || {}) };
    if (dto.cadenceOverride) {
      metadata.override_consent = {
        ...dto.cadenceOverride,
        server_captured_at: new Date().toISOString(),
        user_id: userId,
      };
    }

    // Create post, targets, and enqueue jobs (only for eligible accounts)
    const post = await this.socialPostRepo.create({
      projectId,
      createdByUserId: userId,
      title: dto.title || null,
      message: dto.message,
      mediaUrls: resolvedMediaUrls,
      linkUrl: dto.linkUrl || null,
      scheduledAt: dto.scheduledAt || null,
      contentId: dto.contentId || null,
      metadata,
      source: SocialPostSource.Manual,
    });

    try {
      // Create targets and adapt content per platform
      const targets: SocialPostTarget[] = [];
      for (const accountId of eligible) {
        const account = accountMap.get(accountId)!;
        const provider = this.registry.getProvider(
          account.platform as SocialPlatform,
        );

        let platformPayload = {};
        if (isPostPublishable(provider)) {
          platformPayload = await provider.adaptContent({
            title: dto.title,
            message: dto.message,
            mediaUrls: resolvedMediaUrls,
            linkUrl: dto.linkUrl,
            metadata: dto.metadata,
          });
        }

        const target = await this.socialPostTargetRepo.create({
          socialPostId: post.id,
          socialAccountId: accountId,
          status: dto.scheduledAt
            ? PostTargetStatus.Queued
            : PostTargetStatus.Pending,
          platformPayload,
        });
        targets.push(target);
      }

      // Enqueue jobs
      for (const target of targets) {
        const delayMs = dto.scheduledAt
          ? Math.max(0, new Date(dto.scheduledAt).getTime() - Date.now())
          : 0;

        const job = await this.publishQueue.add(
          JOB_NAMES.SOCIAL_PUBLISH,
          {
            socialPostId: post.id,
            socialPostTargetId: target.id,
          },
          {
            delay: delayMs,
            attempts: 3,
            backoff: { type: 'exponential', delay: 60000 },
          },
        );
        await this.socialPostTargetRepo.updateBullmqJobId(target.id, job.id!);
      }
    } catch (error) {
      // Cleanup: delete post (cascades to targets via DB foreign key)
      this.logger.error(
        `[createPost] Failed after post creation, cleaning up post ${post.id}: ${(error as Error).message}`,
      );
      await this.socialPostRepo.delete(post.id).catch((cleanupErr) => {
        this.logger.error(
          `[createPost] Cleanup failed for post ${post.id}: ${cleanupErr.message}`,
        );
      });
      throw error;
    }

    const createdPost = await this.socialPostRepo.findByIdWithTargets(post.id);

    // Log cadence override audit entries (fire-and-forget)
    if (dto.cadenceOverride) {
      for (const oa of dto.cadenceOverride.accounts) {
        this.logOverrideAudit(userId, oa, post.id).catch(() => {});
      }
    }

    // If some accounts were rejected, return partial failure
    if (rejections.length > 0) {
      const results: any[] = [];
      for (const accountId of eligible) {
        results.push({
          accountId,
          status: 'created',
          postId: post.id,
        });
      }
      for (const rejection of rejections) {
        results.push({
          accountId: rejection.accountId,
          status: 'rejected',
          error: {
            code: rejection.code,
            message: rejection.message,
            details: rejection.details,
          },
        });
      }
      return { code: 'PARTIAL_FAILURE', post: createdPost, results };
    }

    // All pass — backward compatible response
    return createdPost;
  }

  async getPostsByProject(projectId: string, limit?: number, offset?: number) {
    return this.socialPostRepo.findByProjectId(projectId, {
      limit,
      offset,
    });
  }

  async getPostById(postId: string) {
    const post = await this.socialPostRepo.findByIdWithTargets(postId);
    if (!post) {
      throw new NotFoundException('Social post not found');
    }
    return post;
  }

  async deletePost(postId: string, userId: string): Promise<void> {
    const post = await this.socialPostRepo.findById(postId);
    if (!post) {
      throw new NotFoundException('Social post not found');
    }
    if (post.createdByUserId !== userId) {
      throw new ForbiddenException('Only the creator can delete this post');
    }

    // Check if any target is already published
    const targets = await this.socialPostTargetRepo.findBySocialPostId(postId);
    const hasPublished = targets.some(
      (t) => t.status === PostTargetStatus.Published,
    );
    if (hasPublished) {
      throw new BadRequestException(
        'Cannot delete a post that has already been published',
      );
    }

    // Remove pending BullMQ jobs for this post
    const pendingTargets = targets.filter((t) =>
      [PostTargetStatus.Queued, PostTargetStatus.Pending].includes(
        t.status as PostTargetStatus,
      ),
    );
    for (const target of pendingTargets) {
      await this.removeBullMQJobForTarget(target.id);
      await this.socialPostTargetRepo.updateStatus(
        target.id,
        PostTargetStatus.Cancelled,
      );
    }

    await this.socialPostRepo.delete(postId);
  }

  /**
   * Remove a BullMQ delayed/waiting job that matches a given target ID.
   * Uses O(1) lookup via stored bullmqJobId, falls back to O(n) scan for legacy targets.
   */
  private async removeBullMQJobForTarget(targetId: string): Promise<void> {
    try {
      // O(1) lookup via stored jobId
      const target = await this.socialPostTargetRepo.findById(targetId);
      if (target?.bullmqJobId) {
        const job = await this.publishQueue.getJob(target.bullmqJobId);
        if (job) {
          await job.remove();
          this.logger.log(
            `[cancelPost] Removed BullMQ job ${job.id} for target ${targetId}`,
          );
          return;
        }
      }

      // Fallback O(n) scan for legacy targets without bullmqJobId
      const jobs = await this.publishQueue.getJobs(['delayed', 'waiting']);
      for (const job of jobs) {
        if (job.data?.socialPostTargetId === targetId) {
          await job.remove();
          this.logger.log(
            `[cancelPost] Removed BullMQ job ${job.id} for target ${targetId} (fallback scan)`,
          );
          return;
        }
      }
    } catch (error) {
      this.logger.warn(
        `[cancelPost] Failed to remove BullMQ job for target ${targetId}: ${(error as Error).message}`,
      );
    }
  }

  // ============================================================
  // Auto-publish from content generation
  // ============================================================

  /**
   * Called by ContentGenerationQueueProcessor after content is generated.
   * Creates social posts and enqueues BullMQ jobs directly (same path as manual posts).
   * Uses BullMQ delay for scheduled posts instead of relying on cron dispatch.
   */
  async autoPublishContent(
    contentId: string,
    projectId: string,
    userId: string | null,
    contentBody: string,
    contentTitle?: string,
  ): Promise<{ postsCreated: number }> {
    const accounts =
      await this.socialAccountRepo.findAutoPublishByProjectId(projectId);

    if (accounts.length === 0) {
      return { postsCreated: 0 };
    }

    // Filter to only accounts whose platform supports publishing
    const publishableAccounts = accounts.filter((account) => {
      try {
        const provider = this.registry.getProvider(
          account.platform as SocialPlatform,
        );
        return isPostPublishable(provider);
      } catch {
        return false;
      }
    });

    if (publishableAccounts.length === 0) {
      this.logger.log(
        `[autoPublish] No publishable auto-publish accounts for project ${projectId}`,
      );
      return { postsCreated: 0 };
    }

    this.logger.log(
      `[autoPublish] Enqueuing social posts for ${publishableAccounts.length} account(s) from content ${contentId}`,
    );

    // Resolve media URLs from content
    let resolvedMediaUrls: string[] = [];
    if (contentId) {
      resolvedMediaUrls = await this.resolveMediaUrlsFromContent(
        contentId,
        projectId,
      );
    }

    let totalCreated = 0;
    for (const account of publishableAccounts) {
      const scheduledAt = this.resolveScheduledTime(
        account.autoPublishSchedule,
      );

      try {
        const post = await this.socialPostRepo.create({
          projectId,
          createdByUserId: userId,
          title: contentTitle || null,
          message: contentBody,
          mediaUrls: resolvedMediaUrls,
          linkUrl: null,
          scheduledAt: scheduledAt || null,
          contentId,
          metadata: {},
          source: SocialPostSource.AutoPublish,
        });

        const provider = this.registry.getProvider(
          account.platform as SocialPlatform,
        );
        let platformPayload = {};
        if (isPostPublishable(provider)) {
          platformPayload = await provider.adaptContent({
            message: contentBody,
            title: contentTitle,
            mediaUrls: resolvedMediaUrls,
          });
        }

        const delayMs = scheduledAt
          ? Math.max(0, new Date(scheduledAt).getTime() - Date.now())
          : 0;

        const target = await this.socialPostTargetRepo.create({
          socialPostId: post.id,
          socialAccountId: account.id,
          status: PostTargetStatus.Pending,
          platformPayload,
        });

        const job = await this.publishQueue.add(
          JOB_NAMES.SOCIAL_PUBLISH,
          {
            socialPostId: post.id,
            socialPostTargetId: target.id,
          },
          {
            delay: delayMs,
            attempts: 3,
            backoff: { type: 'exponential', delay: 60000 },
          },
        );
        await this.socialPostTargetRepo.updateBullmqJobId(target.id, job.id!);

        totalCreated++;
        this.logger.log(
          `[autoPublish] Enqueued job ${job.id} for account ${account.id} (${account.platform}), delay: ${delayMs}ms`,
        );
      } catch (error) {
        this.logger.error(
          `[autoPublish] Failed to queue post for account ${account.id}: ${(error as Error).message}`,
        );
      }
    }

    return { postsCreated: totalCreated };
  }

  /**
   * Resolve the next publish time based on autoPublishSchedule config.
   * Returns ISO string for scheduled time, or null for immediate publish.
   */
  private resolveScheduledTime(
    schedule: Record<string, any> | null | undefined,
  ): string | null {
    if (!schedule || schedule.type === 'immediate') {
      return null;
    }

    const now = new Date();

    if (schedule.type === 'peak_hours') {
      // Peak hours: 9:00, 12:00, 18:00 (common social media peak times)
      const peakSlots = ['09:00', '12:00', '18:00'];
      return this.findNextSlot(now, peakSlots);
    }

    if (schedule.type === 'custom') {
      const customSlots: string[] = schedule.customSlots || ['09:00'];
      const customDays: string[] | undefined = schedule.customDays;
      return this.findNextSlot(now, customSlots, customDays);
    }

    return null;
  }

  /**
   * Find the next available time slot from now.
   * If customDays is provided, only consider those days of the week.
   * Returns ISO string at least 15 minutes in the future (BullMQ safety margin).
   */
  private findNextSlot(
    now: Date,
    slots: string[],
    allowedDays?: string[],
  ): string {
    const dayNames = ['sun', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat'];
    const minTime = new Date(now.getTime() + 15 * 60 * 1000); // 15 min buffer

    // Check up to 8 days ahead to find a valid slot
    for (let dayOffset = 0; dayOffset < 8; dayOffset++) {
      const candidate = new Date(now);
      candidate.setDate(candidate.getDate() + dayOffset);

      const dayName = dayNames[candidate.getDay()];
      if (
        allowedDays &&
        allowedDays.length > 0 &&
        !allowedDays.includes(dayName)
      ) {
        continue;
      }

      for (const slot of slots) {
        const [hours, minutes] = slot.split(':').map(Number);
        const slotTime = new Date(candidate);
        slotTime.setHours(hours, minutes, 0, 0);

        if (slotTime > minTime) {
          return slotTime.toISOString();
        }
      }
    }

    // Fallback: 15 minutes from now if no valid slot found
    return minTime.toISOString();
  }

  async getAccountQueueStatus(accountId: string) {
    return this.safePublishService.getQueueStatus(accountId);
  }

  async updateAccount(
    accountId: string,
    userId: string,
    data: {
      autoPublish?: boolean;
      autoPublishSchedule?: Record<string, any> | null;
    },
  ) {
    const account = await this.socialAccountRepo.findById(accountId);
    if (!account) {
      throw new NotFoundException('Social account not found');
    }
    if (account.connectedByUserId !== userId) {
      throw new ForbiddenException(
        'Only the user who connected this account can update it',
      );
    }
    return this.socialAccountRepo.update(accountId, data);
  }

  // ============================================================
  // P1: Post stats and scheduled slots
  // ============================================================

  async getAccountPostStats(accountId: string) {
    return this.safePublishService.getPostStats(accountId);
  }

  async getAccountScheduledSlots(accountId: string) {
    return this.safePublishService.getScheduledSlots(accountId);
  }

  // ============================================================
  // Helpers
  // ============================================================

  private async logRateLimitRejection(
    userId: string,
    rejection: RateLimitRejection,
  ): Promise<void> {
    try {
      await (this.supabase as any).from('SocialPostRateLimitLog').insert({
        userId,
        accountId: rejection.accountId,
        platform: rejection.platform,
        errorCode: rejection.code,
        attemptedAt: new Date().toISOString(),
      });
    } catch (error) {
      this.logger.warn(
        `[createPost] Failed to log rate limit rejection: ${(error as Error).message}`,
      );
    }
  }

  private async logOverrideAudit(
    userId: string,
    overrideAccount: { accountId: string; platform: string; reason: string },
    postId: string,
  ): Promise<void> {
    try {
      await (this.supabase as any).from('SocialPostRateLimitLog').insert({
        userId,
        accountId: overrideAccount.accountId,
        platform: overrideAccount.platform,
        errorCode: RateLimitErrorCode.UserOverrideSoft,
        attemptedAt: new Date().toISOString(),
        requestPayloadHash: postId,
      });
    } catch (error) {
      this.logger.warn(
        `[createPost] Failed to log override audit: ${(error as Error).message}`,
      );
    }
  }

  private async countUserOverrides(userId: string): Promise<number> {
    const since = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString();
    const { count, error } = await (this.supabase as any)
      .from('SocialPostRateLimitLog')
      .select('*', { count: 'exact', head: true })
      .eq('userId', userId)
      .eq('errorCode', RateLimitErrorCode.UserOverrideSoft)
      .gte('attemptedAt', since);

    if (error) {
      this.logger.warn(
        `[createPost] Failed to count user overrides: ${(error as Error).message}`,
      );
      return 0;
    }
    return count || 0;
  }

  getDecryptedCredentials(
    credentials: Record<string, any>,
  ): Record<string, any> {
    return decryptCredentials(credentials, this.encryptionKey);
  }

  /**
   * Resolve image URL from linked content body (first image in markdown).
   * Falls back to brand's defaultArticleImageUrl if no image found.
   */
  /**
   * Check if any platformAccountId is already connected to a different project by this user.
   * Returns conflict descriptors (with project name) for the FE to display.
   */
  private async checkPlatformAccountConflicts(
    platformAccountIds: string[],
    currentProjectId: string,
    userId: string,
  ): Promise<
    {
      platformAccountId: string;
      accountName: string;
      platform: string;
      existingProjectId: string;
      existingProjectName: string;
    }[]
  > {
    const conflicts: {
      platformAccountId: string;
      accountName: string;
      platform: string;
      existingProjectId: string;
      existingProjectName: string;
    }[] = [];

    for (const platformAccountId of platformAccountIds) {
      const siblings =
        await this.socialAccountRepo.findSiblingsByPlatformAccountId(
          platformAccountId,
          userId,
        );
      const conflict = siblings.find((s) => s.projectId !== currentProjectId);
      if (conflict) {
        const { data: project } = await (this.supabase as any)
          .from('Project')
          .select('name')
          .eq('id', conflict.projectId)
          .maybeSingle();

        conflicts.push({
          platformAccountId,
          accountName: conflict.accountName,
          platform: conflict.platform,
          existingProjectId: conflict.projectId,
          existingProjectName: project?.name || conflict.projectId,
        });
      }
    }

    return conflicts;
  }

  private async resolveMediaUrlsFromContent(
    contentId: string,
    projectId: string,
  ): Promise<string[]> {
    try {
      // Fetch content body and featuredImageUrl
      const { data: content } = await (this.supabase as any)
        .from('Content')
        .select('body, featuredImageUrl')
        .eq('id', contentId)
        .maybeSingle();

      if (content?.body) {
        const images = extractImagesFromMarkdown(content.body, '');
        if (images.length > 0) {
          this.logger.log(
            `[resolveMediaUrls] Using first image from content body: ${images[0].sourceUrl}`,
          );
          return [images[0].sourceUrl];
        }
      }

      // Fallback: featured image from content generation (reference page image)
      if (content?.featuredImageUrl) {
        this.logger.log(
          `[resolveMediaUrls] Using featured image: ${content.featuredImageUrl}`,
        );
        return [content.featuredImageUrl];
      }

      // Fallback: brand's default article image
      const { data: brand, error: brandError } = await (this.supabase as any)
        .from('Brand')
        .select('defaultArticleImageUrl')
        .eq('projectId', projectId)
        .maybeSingle();

      this.logger.log(
        `[resolveMediaUrls] Brand query result: ${JSON.stringify(brand)}, error: ${JSON.stringify(brandError)}`,
      );

      if (brand?.defaultArticleImageUrl) {
        this.logger.log(
          `[resolveMediaUrls] Using brand default image: ${brand.defaultArticleImageUrl}`,
        );
        return [brand.defaultArticleImageUrl];
      }
    } catch (error) {
      this.logger.warn(
        `[resolveMediaUrls] Failed to resolve media URLs: ${(error as Error).message}`,
      );
    }

    return [];
  }

  private mapAccountToDto(account: any): SocialAccountResponseDto {
    return {
      id: account.id,
      platform: account.platform,
      connectionType: account.connectionType,
      platformAccountId: account.platformAccountId,
      accountName: account.accountName,
      accountAvatar: account.accountAvatar,
      isActive: account.isActive,
      autoPublish: account.autoPublish ?? false,
      autoPublishSchedule: account.autoPublishSchedule ?? null,
      tokenExpiresAt: account.tokenExpiresAt,
      metadata: account.metadata,
      lastPublishedAt: account.lastPublishedAt ?? null,
      pausedUntil: account.pausedUntil ?? null,
      consecutiveErrorCount: account.consecutiveErrorCount ?? 0,
      createdAt: account.createdAt,
    };
  }
}
