import { Injectable, Logger } from '@nestjs/common';
import { Cron, CronExpression } from '@nestjs/schedule';
import { InjectQueue } from '@nestjs/bullmq';
import { Queue } from 'bullmq';
import { TaskRepository } from '../task/task.repository';
import { ProjectRepository } from '../project/project.repository';
import { JOB_NAMES } from '../utils/const';
import { ContentType } from 'src/content/dto/generate-content.dto';
import { QueueNames } from '../processors/contants/queue';
import { ContentRepository } from '../content/content.repository';
import {
  SchedulerRepository,
  BlogQueueItem,
  SocialMediaQueueItem,
  ActiveAgent,
} from './scheduler.repository';
import { SubscriptionService } from '../subscription/subscription.service';
import { SubscriptionRepository } from '../subscription/subscription.repository';
import { MailService } from '../mail/mail.service';
import { PLANS } from '../subscription/subscription.constants';
import { buildRenewalReminderEmailHtml } from '../subscription/templates/renewal-reminder-email.template';

@Injectable()
export class SchedulerService {
  private readonly logger = new Logger(SchedulerService.name);
  private readonly MAX_TASKS_PER_PROJECT = 100;

  constructor(
    private readonly taskRepository: TaskRepository,
    private readonly projectRepository: ProjectRepository,
    private readonly contentRepository: ContentRepository,
    private readonly schedulerRepository: SchedulerRepository,
    private readonly subscriptionService: SubscriptionService,
    private readonly subscriptionRepository: SubscriptionRepository,
    private readonly mailService: MailService,
    @InjectQueue(QueueNames.ProjectAnalysis)
    private projectAnalysisQueue: Queue,
    @InjectQueue(QueueNames.ContentGeneration)
    private contentGenerationQueue: Queue,
  ) {}

  @Cron(CronExpression.EVERY_DAY_AT_4AM, { timeZone: 'Asia/Ho_Chi_Minh' })
  async scheduleDailyContentGeneration() {
    this.logger.log('[Bulk] Daily content generation scheduled...');
    try {
      const projects =
        await this.projectRepository.findProjectsWithAutoGenerateEnabled();

      if (!projects?.length) {
        this.logger.log('[Bulk] No projects found for content generation');
        return;
      }

      const projectStats = new Map<string, number>();

      for (const project of projects) {
        const activeAgents: ActiveAgent[] =
          await this.schedulerRepository.findActiveAgents(project.id);

        if (activeAgents.length === 0) {
          this.logger.log(
            `[Bulk] Project ${project.id}: no active agents, skipping`,
          );
          continue;
        }

        const blogAgent = activeAgents.find(
          (a) => a.agentType === 'BLOG_GENERATOR',
        );
        const mediaAgent = activeAgents.find(
          (a) => a.agentType === 'SOCIAL_MEDIA_GENERATOR',
        );

        const [blogItems, mediaItems] = await Promise.all([
          blogAgent
            ? this.schedulerRepository.getPromptsForBlogScheduler(
                project.id,
                Math.min(blogAgent.postsPerDay, this.MAX_TASKS_PER_PROJECT),
              )
            : Promise.resolve([] as BlogQueueItem[]),
          mediaAgent
            ? this.schedulerRepository.getPromptsForSocialMediaScheduler(
                project.id,
                Math.min(mediaAgent.postsPerDay, this.MAX_TASKS_PER_PROJECT),
              )
            : Promise.resolve([] as SocialMediaQueueItem[]),
        ]);

        const blogQueued = await this.queueBlogJobs(project.id, blogItems);
        const mediaQueued = await this.queueSocialMediaJobs(
          project.id,
          mediaItems,
        );

        const totalQueued = blogQueued + mediaQueued;
        if (totalQueued > 0) {
          projectStats.set(project.id, totalQueued);
        }

        this.logger.log(
          `[Bulk] Project ${project.id}: ${blogQueued} blog (postsPerDay=${blogAgent?.postsPerDay ?? 0}) + ${mediaQueued} social media (postsPerDay=${mediaAgent?.postsPerDay ?? 0}) jobs queued`,
        );
      }

      this.logger.log('[Bulk] Content generation scheduling complete:');
      projectStats.forEach((count, projectId) => {
        this.logger.log(`  - Project ${projectId}: ${count} jobs queued`);
      });
    } catch (error) {
      this.logger.error(
        `Failed to schedule daily content generation: ${error.message}`,
      );
    }
  }

  private async queueBlogJobs(
    projectId: string,
    items: BlogQueueItem[],
  ): Promise<number> {
    let queued = 0;

    await Promise.allSettled(
      items.map(async (item) => {
        const payload = {
          projectId,
          promptId: item.promptId,
          contentType: ContentType.BLOG_POST,
          contentProfileId: item.contentProfileId,
          contentAgentId: item.contentAgentId,
          referencePageUrl: item.referenceUrl || null,
        };

        const task = await this.taskRepository.create({
          taskType: JOB_NAMES.CONTENT_GENERATION,
          projectId,
          payload,
        });

        await this.contentGenerationQueue.add(JOB_NAMES.CONTENT_GENERATION, {
          ...payload,
          taskId: task.id,
        });
        queued++;
      }),
    );

    return queued;
  }

  private async queueSocialMediaJobs(
    projectId: string,
    items: SocialMediaQueueItem[],
  ): Promise<number> {
    let queued = 0;

    await Promise.allSettled(
      items.map(async (item) => {
        const payload = {
          projectId,
          promptId: item.promptId,
          contentType: ContentType.SOCIAL_MEDIA_POST,
          contentProfileId: item.contentProfileId,
          contentAgentId: item.contentAgentId,
          referencePageUrl: item.referenceUrl || null,
          platform: item.platform,
        };

        const task = await this.taskRepository.create({
          taskType: JOB_NAMES.CONTENT_GENERATION,
          projectId,
          payload,
        });

        await this.contentGenerationQueue.add(JOB_NAMES.CONTENT_GENERATION, {
          ...payload,
          taskId: task.id,
        });
        queued++;
      }),
    );

    return queued;
  }

  @Cron('30 2 * * *', { timeZone: 'Asia/Ho_Chi_Minh' }) // Daily at 2:30 AM
  async cleanupFailedContent() {
    this.logger.log('[Cleanup] Starting failed content cleanup...');
    try {
      const threeDaysAgo = new Date();
      threeDaysAgo.setDate(threeDaysAgo.getDate() - 3);
      const deletedCount =
        await this.contentRepository.deleteFailedContentOlderThan(
          threeDaysAgo.toISOString(),
        );
      this.logger.log(
        `[Cleanup] Deleted ${deletedCount} failed content record(s) older than 3 days`,
      );
    } catch (error) {
      this.logger.error(
        `[Cleanup] Failed to cleanup failed content: ${error.message}`,
      );
    }
  }

  @Cron('0 2 * * *', { timeZone: 'Asia/Ho_Chi_Minh' }) // Daily at 2 AM
  async cleanupStaleDraftProjects() {
    this.logger.log('[Cleanup] Starting stale draft projects cleanup...');
    try {
      const sevenDaysAgo = new Date();
      sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);
      const deletedCount = await this.projectRepository.deleteStaleDrafts(
        sevenDaysAgo.toISOString(),
      );
      this.logger.log(
        `[Cleanup] Deleted ${deletedCount} stale draft project(s)`,
      );
    } catch (error) {
      this.logger.error(
        `[Cleanup] Failed to cleanup stale drafts: ${error.message}`,
      );
    }
  }

  @Cron('0 3 15 * *', { timeZone: 'Asia/Ho_Chi_Minh' }) // 3 AM on the 15th of every month
  async scheduleAnalysis() {
    this.logger.log('[Bulk] Starting analysis scheduling...');

    try {
      const autoAnalysisProjects =
        await this.projectRepository.findProjectsWithAutoAnalysisEnabled();

      await Promise.allSettled(
        autoAnalysisProjects.map(async (project) => {
          const task = await this.taskRepository.create({
            taskType: JOB_NAMES.ANALYZE_PROJECT,
            projectId: project.id,
            payload: {
              projectId: project.id,
            },
          });

          await this.projectAnalysisQueue.add(JOB_NAMES.ANALYZE_PROJECT, {
            projectId: project.id,
            userId: project.createdBy,
            taskId: task.id,
          });

          this.logger.log(
            `[Bulk] Queued analysis task ${task.id} for project ${project.id}`,
          );

          return { projectId: project.id, taskId: task.id };
        }),
      );
    } catch (error) {
      this.logger.error(
        `[Bulk] Failed to schedule weekly analysis: ${error.message}`,
      );
    }
  }

  @Cron('0 9 * * *', { timeZone: 'Asia/Ho_Chi_Minh' }) // Daily at 9 AM
  async sendRenewalReminders() {
    this.logger.log(
      '[Reminder] Checking for upcoming subscription renewals...',
    );
    try {
      const targetDate = new Date();
      targetDate.setDate(targetDate.getDate() + 3);
      const targetDateStr = targetDate.toISOString().split('T')[0];

      const subscriptions =
        await this.subscriptionRepository.findSubscriptionsExpiringOn(
          targetDateStr,
        );

      if (!subscriptions.length) {
        this.logger.log('[Reminder] No subscriptions renewing in 3 days');
        return;
      }

      this.logger.log(
        `[Reminder] Found ${subscriptions.length} subscription(s) renewing on ${targetDateStr}`,
      );

      let sent = 0;
      let skipped = 0;
      for (const sub of subscriptions) {
        try {
          const email = await this.subscriptionService.getCustomerEmail(
            sub.stripeCustomerId,
          );
          if (!email) {
            this.logger.warn(
              `[Reminder] No email found for Stripe customer ${sub.stripeCustomerId} (project ${sub.projectId}), skipping`,
            );
            skipped++;
            continue;
          }

          const renewalDate = new Date(
            sub.currentPeriodEnd!,
          ).toLocaleDateString('en-US', {
            year: 'numeric',
            month: 'long',
            day: 'numeric',
          });

          const html = buildRenewalReminderEmailHtml({
            renewalDate,
            planName: PLANS.PRO.name,
            billingPageUrl: `${this.subscriptionService.frontendUrl}/settings/billing`,
          });

          await this.mailService.sendMail(
            email,
            'Your AEO Pro Subscription Renews Soon',
            html,
          );
          await this.subscriptionRepository.updateRenewalReminderSentAt(
            sub.stripeSubscriptionId,
          );
          sent++;
          this.logger.log(
            `[Reminder] Renewal reminder sent to ${email} for project ${sub.projectId} (renews ${renewalDate})`,
          );
        } catch (error) {
          this.logger.error(
            `[Reminder] Failed to send reminder for subscription ${sub.stripeSubscriptionId} (project ${sub.projectId}): ${error instanceof Error ? error.message : String(error)}`,
          );
        }
      }

      this.logger.log(
        `[Reminder] Complete: ${sent} sent, ${skipped} skipped, ${subscriptions.length - sent - skipped} failed`,
      );
    } catch (error) {
      this.logger.error(
        `[Reminder] Failed to process renewal reminders: ${error instanceof Error ? error.message : String(error)}`,
      );
    }
  }
}
