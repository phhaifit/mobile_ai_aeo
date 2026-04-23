import { Processor, WorkerHost, OnWorkerEvent } from '@nestjs/bullmq';
import { Job } from 'bullmq';
import { Logger } from '@nestjs/common';
import { QueueNames } from '../processors/contants/queue';
import { SocialPostTargetRepository } from './social-post-target.repository';
import { SocialAccountRepository } from './social-account.repository';
import { PlatformProviderRegistry } from './platforms/platform-provider.registry';
import { isPostPublishable } from './platforms/platform-provider.interface';
import { decryptCredentials } from './utils/token-encryption.util';
import { SafePublishService } from './safe-publish.service';
import { ConfigService } from '@nestjs/config';
import { PostTargetStatus, PublishErrorType, SocialPlatform } from './enums';

export interface SocialPublishJobData {
  socialPostId: string;
  socialPostTargetId: string;
}

@Processor(QueueNames.SocialPublish, {
  concurrency: 1,
  stalledInterval: 30_000,
  maxStalledCount: 2,
})
export class SocialPublishProcessor extends WorkerHost {
  private readonly logger = new Logger(SocialPublishProcessor.name);
  private readonly encryptionKey: string;

  constructor(
    private readonly postTargetRepo: SocialPostTargetRepository,
    private readonly accountRepo: SocialAccountRepository,
    private readonly registry: PlatformProviderRegistry,
    private readonly configService: ConfigService,
    private readonly safePublishService: SafePublishService,
  ) {
    super();
    const key = this.configService.get<string>('SOCIAL_TOKEN_ENCRYPTION_KEY');
    if (!key || Buffer.from(key, 'hex').length !== 32) {
      throw new Error(
        'SOCIAL_TOKEN_ENCRYPTION_KEY must be a 64-character hex string (32 bytes for AES-256)',
      );
    }
    this.encryptionKey = key;
  }

  async process(job: Job<SocialPublishJobData>): Promise<any> {
    const { socialPostTargetId } = job.data;

    this.logger.log(`[SocialPublish] Processing target ${socialPostTargetId}`);

    // Load target with post and account relations
    const target =
      await this.postTargetRepo.findByIdWithRelations(socialPostTargetId);

    if (!target) {
      this.logger.error(
        `[SocialPublish] Target ${socialPostTargetId} not found`,
      );
      return;
    }

    // Idempotency guard: skip if target is already in a terminal state
    const terminalStatuses = [
      PostTargetStatus.Published,
      PostTargetStatus.Failed,
      PostTargetStatus.Cancelled,
    ];
    if (terminalStatuses.includes(target.status as PostTargetStatus)) {
      this.logger.warn(
        `[SocialPublish] Target ${socialPostTargetId} already in terminal state '${target.status}', skipping`,
      );
      return;
    }

    const { post, account } = target;

    if (!post || !account) {
      this.logger.error(
        `[SocialPublish] Missing post or account for target ${socialPostTargetId}`,
      );
      await this.postTargetRepo.updateStatus(
        socialPostTargetId,
        PostTargetStatus.Failed,
        {
          errorMessage: 'Missing post or account data',
          errorType: PublishErrorType.Fatal,
        },
      );
      return;
    }

    // Get platform provider
    const provider = this.registry.getProvider(
      account.platform as SocialPlatform,
    );

    if (!isPostPublishable(provider)) {
      await this.postTargetRepo.updateStatus(
        socialPostTargetId,
        PostTargetStatus.Failed,
        {
          errorMessage: `Platform ${account.platform} does not support publishing`,
          errorType: PublishErrorType.Fatal,
        },
      );
      return;
    }

    // Update status to publishing
    await this.postTargetRepo.updateStatus(
      socialPostTargetId,
      PostTargetStatus.Publishing,
    );

    // Decrypt credentials
    const credentials = decryptCredentials(
      account.credentials as Record<string, any>,
      this.encryptionKey,
    );

    // Use pre-adapted platform payload, or adapt on the fly
    const platformPayload =
      target.platformPayload && Object.keys(target.platformPayload).length > 0
        ? target.platformPayload
        : await provider.adaptContent({
            title: post.title,
            message: post.message,
            mediaUrls: post.mediaUrls,
            linkUrl: post.linkUrl,
            metadata: post.metadata,
          });

    // Publish
    const result = await provider.publishPost(
      credentials,
      account.platformAccountId,
      platformPayload,
    );

    if (result.success) {
      this.logger.log(
        `[SocialPublish] Target ${socialPostTargetId} published successfully: ${result.platformPostId}`,
      );
      await this.postTargetRepo.updateStatus(
        socialPostTargetId,
        PostTargetStatus.Published,
        {
          platformPostId: result.platformPostId,
          platformPostUrl: result.platformPostUrl,
          publishedAt: new Date().toISOString(),
        },
      );

      // Update safe publish stats on success
      await this.safePublishService.onPublishSuccess(account.id);
    } else {
      this.logger.error(
        `[SocialPublish] Target ${socialPostTargetId} failed: ${result.error?.message}`,
      );

      const errorCode = result.error?.code || '';
      const httpStatus = errorCode === '429' ? 429 : undefined;

      // Handle safe publish error (pause/disable logic)
      const errorResult = await this.safePublishService.onPublishError(
        account.id,
        account.platform,
        errorCode,
        httpStatus,
      );

      if (errorResult.shouldDisableAutoPublish) {
        await this.accountRepo.update(account.id, { autoPublish: false });
        this.logger.warn(
          `[SocialPublish] Disabled auto-publish for account ${account.id} due to repeated errors`,
        );
      }

      // Facebook Error 506 (duplicate): mark failed, no retry
      if (errorCode === '506') {
        await this.postTargetRepo.updateStatus(
          socialPostTargetId,
          PostTargetStatus.Failed,
          {
            errorMessage: result.error?.message || 'Duplicate content',
            errorType: PublishErrorType.Duplicate,
          },
        );
        return;
      }

      // HTTP 429 (rate limit): mark failed, no retry
      if (httpStatus === 429) {
        await this.postTargetRepo.updateStatus(
          socialPostTargetId,
          PostTargetStatus.Failed,
          {
            errorMessage: result.error?.message || 'Rate limited',
            errorType: PublishErrorType.RateLimited,
          },
        );
        return;
      }

      // If error is non-retryable, don't throw (prevents BullMQ retry)
      if (
        result.error?.type === PublishErrorType.Fatal ||
        result.error?.type === PublishErrorType.AuthExpired
      ) {
        await this.postTargetRepo.updateStatus(
          socialPostTargetId,
          PostTargetStatus.Failed,
          {
            errorMessage: result.error.message,
            errorType: result.error.type,
          },
        );

        // If auth expired, deactivate the account and disable auto-publish
        if (result.error.type === PublishErrorType.AuthExpired) {
          await this.accountRepo.deactivate(account.id);
          await this.accountRepo.update(account.id, { autoPublish: false });
          this.logger.warn(
            `[SocialPublish] Deactivated account ${account.id} due to expired auth`,
          );
        }
        return;
      }

      // Retryable — throw to trigger BullMQ retry
      await this.postTargetRepo.updateStatus(
        socialPostTargetId,
        PostTargetStatus.Failed,
        {
          errorMessage: result.error?.message,
          errorType: PublishErrorType.Retryable,
        },
      );
      throw new Error(result.error?.message || 'Publishing failed');
    }
  }

  @OnWorkerEvent('failed')
  async onFailed(job: Job<SocialPublishJobData>, error: Error) {
    const maxAttempts = job.opts.attempts || 1;
    const isExhausted = job.attemptsMade >= maxAttempts;

    this.logger.error(
      `[SocialPublish] Job ${job.id} failed (attempt ${job.attemptsMade}/${maxAttempts}): ${error.message}`,
    );

    // All retries exhausted: ensure DB reflects final FAILED state
    if (isExhausted) {
      const { socialPostTargetId } = job.data;
      try {
        const target = await this.postTargetRepo.findById(socialPostTargetId);
        if (
          target &&
          target.status !== PostTargetStatus.Published &&
          target.status !== PostTargetStatus.Cancelled
        ) {
          await this.postTargetRepo.updateStatus(
            socialPostTargetId,
            PostTargetStatus.Failed,
            {
              errorMessage: `Exhausted ${maxAttempts} attempts. Last error: ${error.message}`,
              errorType: PublishErrorType.Fatal,
            },
          );
          this.logger.warn(
            `[SocialPublish] Target ${socialPostTargetId} marked FAILED after exhausting all retries`,
          );
        }
      } catch (dbError) {
        this.logger.error(
          `[SocialPublish] Failed to update DB for exhausted job ${job.id}: ${(dbError as Error).message}`,
        );
      }
    }
  }

  @OnWorkerEvent('completed')
  onCompleted(job: Job) {
    this.logger.log(`[SocialPublish] Job ${job.id} completed successfully`);
  }
}
