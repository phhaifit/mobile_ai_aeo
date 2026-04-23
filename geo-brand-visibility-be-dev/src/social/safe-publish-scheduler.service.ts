import { Injectable, Logger } from '@nestjs/common';
import { Cron } from '@nestjs/schedule';
import { InjectQueue } from '@nestjs/bullmq';
import { Queue } from 'bullmq';
import { SocialPostTargetRepository } from './social-post-target.repository';
import { SafePublishService } from './safe-publish.service';
import { PostTargetStatus, PublishErrorType } from './enums';
import { QueueNames } from '../processors/contants/queue';
import { JOB_NAMES } from '../utils/const';

@Injectable()
export class SafePublishSchedulerService {
  private readonly logger = new Logger(SafePublishSchedulerService.name);
  private isProcessing = false;

  constructor(
    private readonly socialPostTargetRepo: SocialPostTargetRepository,
    private readonly safePublishService: SafePublishService,
    @InjectQueue(QueueNames.SocialPublish)
    private readonly publishQueue: Queue,
  ) {}

  @Cron('*/5 * * * *', { timeZone: 'Asia/Ho_Chi_Minh' })
  async processRecovery(): Promise<void> {
    if (this.isProcessing) {
      this.logger.debug('[SafePublishCron] Already processing, skipping');
      return;
    }

    this.isProcessing = true;
    try {
      await this.recoverOrphanedQueuedTargets();
      await this.recoverStuckPublishingTargets();
    } catch (error) {
      this.logger.error(
        `[SafePublishCron] Unexpected error: ${error.message}`,
        error.stack,
      );
    } finally {
      this.isProcessing = false;
    }
  }

  /**
   * Recover QUEUED targets that have no BullMQ job (orphaned).
   * This handles legacy targets created before bullmqJobId was stored,
   * and targets whose BullMQ job was lost (Redis flush, etc.).
   */
  private async recoverOrphanedQueuedTargets(): Promise<void> {
    const stuckTargets = await this.socialPostTargetRepo.findStuckQueuedTargets(
      new Date(Date.now() - 5 * 60 * 1000),
    );

    if (stuckTargets.length === 0) return;

    let recovered = 0;
    for (const target of stuckTargets) {
      // If target has a bullmqJobId, check if job still exists in Redis
      if (target.bullmqJobId) {
        const job = await this.publishQueue.getJob(target.bullmqJobId);
        if (job) continue; // Job exists, not orphaned
      }

      const account = target.account;
      if (!account || !account.isActive) continue;

      // Only auto-recover targets from auto-publish accounts
      if (!account.autoPublish) continue;

      const canPublish = await this.safePublishService.canPublishNow(
        account.id,
      );
      if (!canPublish.eligible) continue;

      try {
        await this.socialPostTargetRepo.updateStatus(
          target.id,
          PostTargetStatus.Pending,
        );

        const job = await this.publishQueue.add(
          JOB_NAMES.SOCIAL_PUBLISH,
          {
            socialPostId: target.socialPostId,
            socialPostTargetId: target.id,
          },
          {
            attempts: 3,
            backoff: { type: 'exponential', delay: 60000 },
          },
        );
        await this.socialPostTargetRepo.updateBullmqJobId(target.id, job.id!);

        recovered++;
        this.logger.log(
          `[SafePublishCron] Recovered orphaned target ${target.id}, job ${job.id}`,
        );
      } catch (error) {
        this.logger.error(
          `[SafePublishCron] Failed to recover target ${target.id}: ${error.message}`,
        );
      }
    }

    if (recovered > 0) {
      this.logger.log(
        `[SafePublishCron] Recovered ${recovered} orphaned target(s)`,
      );
    }
  }

  /**
   * Recover targets stuck in PUBLISHING for > 10 minutes (worker crash scenario).
   * Mark them as FAILED so they don't stay in limbo forever.
   */
  private async recoverStuckPublishingTargets(): Promise<void> {
    const stuckTargets =
      await this.socialPostTargetRepo.findStuckPublishingTargets(
        new Date(Date.now() - 10 * 60 * 1000),
      );

    for (const target of stuckTargets) {
      try {
        await this.socialPostTargetRepo.updateStatus(
          target.id,
          PostTargetStatus.Failed,
          {
            errorMessage:
              'Publishing timed out — worker may have crashed during publish',
            errorType: PublishErrorType.Retryable,
          },
        );
        this.logger.warn(
          `[SafePublishCron] Marked stuck PUBLISHING target ${target.id} as FAILED`,
        );
      } catch (error) {
        this.logger.error(
          `[SafePublishCron] Failed to recover stuck target ${target.id}: ${error.message}`,
        );
      }
    }
  }
}
