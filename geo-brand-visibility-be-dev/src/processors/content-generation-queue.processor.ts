import { Processor } from '@nestjs/bullmq';
import { Job } from 'bullmq';
import { Logger } from '@nestjs/common';
import { BaseQueueProcessor } from './base-queue.processor';
import { TaskRepository } from '../task/task.repository';
import { JOB_NAMES } from '../utils/const';
import { ContentGenerationJob } from './types/content-generation.type';
import { QueueNames } from './contants/queue';
import { ContentService } from 'src/content/content.service';
import { ContentType } from 'src/content/dto/generate-content.dto';
import { ContentAgentRepository } from 'src/content-agent/content-agent.repository';
import { SocialService } from 'src/social/social.service';

@Processor(QueueNames.ContentGeneration, {
  concurrency: 3,
  stalledInterval: 30_000,
  maxStalledCount: 2,
})
export class ContentGenerationQueueProcessor extends BaseQueueProcessor {
  protected readonly logger = new Logger(ContentGenerationQueueProcessor.name);

  constructor(
    taskRepository: TaskRepository,
    private readonly contentService: ContentService,
    private readonly contentAgentRepository: ContentAgentRepository,
    private readonly socialService: SocialService,
  ) {
    super(taskRepository);
  }

  protected async handleProcess(job: Job<ContentGenerationJob>): Promise<any> {
    const { name, data } = job;
    const {
      promptId,
      projectId,
      userId,
      contentType,
      contentProfileId,
      keywords,
      platform,
      contentAgentId,
      referencePageUrl,
    } = data;

    if (name !== JOB_NAMES.CONTENT_GENERATION) {
      throw new Error(`Unknown job type: ${name}`);
    }

    this.logger.log(
      `[ContentGeneration] Starting content generation for prompt ${promptId}`,
    );

    const result = await this.contentService.generateContentForScheduler(
      promptId,
      {
        projectId,
        contentType: contentType as ContentType,
        contentProfileId,
        keywords,
        referencePageUrl,
        platform: platform as any,
      },
    );

    if (contentAgentId) {
      try {
        await this.contentAgentRepository.update(contentAgentId, {
          lastRunAt: new Date().toISOString(),
        });
        this.logger.log(
          `[ContentGeneration] Updated agent ${contentAgentId} lastRunAt`,
        );
      } catch (error: any) {
        this.logger.error(
          `[ContentGeneration] Failed to update agent ${contentAgentId}: ${error.message}`,
        );
      }
    }

    // Auto-publish to social accounts if any have autoPublish enabled
    try {
      const { postsCreated } = await this.socialService.autoPublishContent(
        result.id,
        projectId,
        userId ?? null,
        result.body,
        result.title,
      );
      if (postsCreated > 0) {
        this.logger.log(
          `[ContentGeneration] Auto-published content ${result.id} to ${postsCreated} social account(s)`,
        );
      }
    } catch (error: any) {
      this.logger.error(
        `[ContentGeneration] Auto-publish failed for content ${result.id}: ${error.message}`,
      );
    }

    return {
      contentId: result.id,
      body: result.body,
    };
  }
}
