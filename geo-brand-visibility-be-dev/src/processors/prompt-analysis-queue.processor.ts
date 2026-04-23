import { Processor } from '@nestjs/bullmq';
import { Job } from 'bullmq';
import { Logger } from '@nestjs/common';
import { TaskRepository } from '../task/task.repository';
import { AGENTS, JOB_NAMES } from '../utils/const';
import { BaseQueueProcessor } from './base-queue.processor';
import { QueueNames } from './contants/queue';
import { AnalyzePromptJob } from './types/analyze-prompt.type';
import { AgentService } from 'src/agent/agent.service';
import { AnalysisResult } from 'src/shared/types';
import { PromptRepository } from 'src/prompt/prompt.repository';

@Processor(QueueNames.PromptAnalysis)
export class PromptAnalysisQueueProcessor extends BaseQueueProcessor {
  protected readonly logger = new Logger(PromptAnalysisQueueProcessor.name);

  constructor(
    private readonly promptRepository: PromptRepository,
    private readonly agentService: AgentService,
    taskRepository: TaskRepository,
  ) {
    super(taskRepository);
  }

  protected async handleProcess(job: Job<AnalyzePromptJob>): Promise<any> {
    const { prompt, taskId, userId } = job.data;

    if (job.name === JOB_NAMES.PROMPT_ANALYSIS) {
      this.logger.log(
        `Starting prompt analysis: task-id=${taskId}, prompt-id=${prompt.id}`,
      );

      for (const model of prompt.models) {
        try {
          const data = await this.agentService.execute<AnalysisResult>(
            userId,
            AGENTS.VISIBILITY_ANALYSIS_AGENT,
            prompt.content,
            {
              engine_name: model.name,
              brand_id: prompt.brand.id,
              brand_name: prompt.brand.name,
              brand_domain: prompt.brand.domain,
              industry: prompt.brand.industry,
            },
          );

          if (data && data.response && data.response.length > 0) {
            await this.promptRepository.insertResponse({
              promptId: prompt.id,
              modelId: model.id,
              ...data,
            });
          }
        } catch (error) {
          this.logger.error(error);
        }
      }

      await this.promptRepository.update(prompt.id, {
        lastRun: new Date().toISOString(),
      });
      this.logger.log(
        `Finished prompt analysis: task-id=${taskId}, prompt-id=${prompt.id}`,
      );
    } else {
      throw new Error(`Unknown job type: ${job.name}`);
    }
  }
}
