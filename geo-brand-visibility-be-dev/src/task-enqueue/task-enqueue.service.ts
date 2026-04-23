import { Injectable, Logger, NotFoundException } from '@nestjs/common';
import { InjectQueue } from '@nestjs/bullmq';
import { Queue } from 'bullmq';
import { TaskRepository } from '../task/task.repository';
import { JOB_NAMES } from '../utils/const';
import { QueueNames } from '../processors/contants/queue';
import { PromptRepository } from 'src/prompt/prompt.repository';
import { ContentType } from 'src/content/dto/generate-content.dto';
import { ContentAgentRepository } from 'src/content-agent/content-agent.repository';

@Injectable()
export class TaskEnqueueService {
  private readonly logger = new Logger(TaskEnqueueService.name);

  constructor(
    private readonly taskRepository: TaskRepository,
    private readonly promptRepository: PromptRepository,
    private readonly contentAgentRepository: ContentAgentRepository,
    @InjectQueue(QueueNames.CreateProject) private createProjectQueue: Queue,
    @InjectQueue(QueueNames.ContentGeneration)
    private contentGenerationQueue: Queue,
    @InjectQueue(QueueNames.ProjectAnalysis)
    private projectAnalysisQueue: Queue,
    @InjectQueue(QueueNames.PromptAnalysis)
    private promptAnalysisQueue: Queue,
  ) {}

  async analyzeNewProject(projectId: string, userId: string) {
    const task = await this.taskRepository.create({
      taskType: JOB_NAMES.ANALYZE_PROJECT,
      projectId: projectId,
      payload: {
        projectId,
        userId,
      },
    });

    const job = await this.createProjectQueue.add(JOB_NAMES.ANALYZE_PROJECT, {
      taskId: task.id,
      projectId,
      userId,
    });

    this.logger.log(
      `Queued critical analysis job ${job.id} (Task ${task.id}) for project ${projectId}`,
    );
    return {
      jobId: job.id,
      taskId: task.id,
    };
  }

  async triggerPromptAnalysis(promptId: string, userId: string) {
    this.logger.log(`Started fetching prompt for analysis`);
    const prompt = await this.promptRepository.getPromptWithProjectAndBrandById(
      promptId,
      userId,
    );
    this.logger.log(`Finished fetching prompt for analysis`);

    if (!prompt) {
      throw new NotFoundException(`Prompt ${promptId} not found`);
    }

    this.logger.log('Started creating task for prompt analysis');
    const task = await this.taskRepository.create({
      taskType: JOB_NAMES.PROMPT_ANALYSIS,
      projectId: prompt.projectId,
      payload: { prompt, userId },
    });
    this.logger.log('Finished creating task for prompt analysis');

    this.logger.log('Started queuing prompt analysis job');
    const job = await this.promptAnalysisQueue.add(JOB_NAMES.PROMPT_ANALYSIS, {
      prompt,
      taskId: task.id,
      userId,
    });
    this.logger.log('Finished queuing prompt analysis job');

    return { jobId: job.id, taskId: task.id };
  }

  async triggerProjectAnalysis(projectId: string, userId: string) {
    const task = await this.taskRepository.create({
      taskType: JOB_NAMES.ANALYZE_PROJECT,
      projectId,
      payload: { projectId, userId },
    });

    const job = await this.projectAnalysisQueue.add(JOB_NAMES.ANALYZE_PROJECT, {
      projectId,
      userId,
      taskId: task.id,
    });

    this.logger.log(
      `[Manual] Queued analysis job ${job.id} (Task ${task.id}) for project ${projectId} via projectAnalysisQueue`,
    );

    return { jobId: job.id, taskId: task.id };
  }

  async triggerDailyContentGenerationForProject(
    projectId: string,
    userId: string,
    blogBatchSize = 100,
    socialBatchSize = 100,
  ) {
    this.logger.log(
      `[Manual] Daily content generation requested for project ${projectId}`,
    );

    const [blogItems, socialItems] = await Promise.all([
      this.contentAgentRepository.getPromptsForBlogScheduler(
        projectId,
        blogBatchSize,
      ),
      this.contentAgentRepository.getPromptsForSocialMediaScheduler(
        projectId,
        socialBatchSize,
      ),
    ]);

    if (!blogItems.length && !socialItems.length) {
      this.logger.log(`[Manual] Project ${projectId} has no prompts to queue`);
      return {
        queuedCount: 0,
        promptCount: 0,
        taskIds: [],
        promptIds: [],
      };
    }

    const blogJobs = blogItems.map(async (item) => {
      const payload = {
        projectId,
        userId,
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
      return { promptId: item.promptId, taskId: task.id };
    });

    const socialJobs = socialItems.map(async (item) => {
      const payload = {
        projectId,
        userId,
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
      return { promptId: item.promptId, taskId: task.id };
    });

    const results = await Promise.allSettled([...blogJobs, ...socialJobs]);

    const fulfilled = results.filter(
      (r): r is PromiseFulfilledResult<{ promptId: string; taskId: string }> =>
        r.status === 'fulfilled',
    );
    const taskIds = fulfilled.map((r) => r.value.taskId);
    const promptIds = fulfilled.map((r) => r.value.promptId);

    this.logger.log(
      `[Manual] Queued ${taskIds.length} jobs (${blogItems.length} blog + ${socialItems.length} social) for project ${projectId}`,
    );

    return {
      queuedCount: taskIds.length,
      promptCount: blogItems.length + socialItems.length,
      taskIds,
      promptIds,
    };
  }
}
