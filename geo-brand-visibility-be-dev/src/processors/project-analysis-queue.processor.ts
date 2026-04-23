import { Processor } from '@nestjs/bullmq';
import { Job } from 'bullmq';
import { Logger } from '@nestjs/common';
import { ProjectService } from '../project/project.service';
import { TaskRepository } from '../task/task.repository';
import { JOB_NAMES } from '../utils/const';
import { AnalyzeProjectJob } from './types/analyze-project.type';
import { BaseQueueProcessor } from './base-queue.processor';
import { QueueNames } from './contants/queue';

@Processor(QueueNames.ProjectAnalysis)
export class ProjectAnalysisQueueProcessor extends BaseQueueProcessor {
  protected readonly logger = new Logger(ProjectAnalysisQueueProcessor.name);

  constructor(
    private readonly projectService: ProjectService,
    taskRepository: TaskRepository,
  ) {
    super(taskRepository);
  }

  protected async handleProcess(job: Job<AnalyzeProjectJob>): Promise<any> {
    const { projectId, userId, taskId } = job.data;

    if (job.name === JOB_NAMES.ANALYZE_PROJECT) {
      this.logger.log(`[Critical] Starting analysis for task ${taskId}`);
      return await this.projectService.analyzeProjectHelper(projectId, userId);
    }

    throw new Error(`Unknown job type: ${job.name}`);
  }
}
