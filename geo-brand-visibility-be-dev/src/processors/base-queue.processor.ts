import { WorkerHost, OnWorkerEvent } from '@nestjs/bullmq';
import { Job } from 'bullmq';
import { Logger } from '@nestjs/common';
import { TaskRepository } from '../task/task.repository';
import { TASK_STATUS } from '../utils/const';
import { TaskSkippedException } from './exceptions/task-skipped.exception';

export abstract class BaseQueueProcessor extends WorkerHost {
  protected abstract readonly logger: Logger;

  constructor(protected readonly taskRepository: TaskRepository) {
    super();
  }

  async process(job: Job<any>): Promise<void> {
    const { taskId } = job.data;
    this.logger.log(`[Critical] Processing job ${job.id} type ${job.name}`);

    try {
      await this.taskRepository.updateStatus(taskId, TASK_STATUS.RUNNING);

      const results = await this.handleProcess(job);

      await this.taskRepository.updateStatus(taskId, TASK_STATUS.DONE, {
        results,
      });
      this.logger.log(`[Critical] Task ${taskId} completed successfully`);
    } catch (error) {
      if (error instanceof TaskSkippedException) {
        this.logger.log(`[Critical] Task ${taskId} skipped: ${error.message}`);
        await this.taskRepository.updateStatus(taskId, TASK_STATUS.SKIPPED, {
          reason: error.message,
        });
        return;
      }

      this.logger.error(`[Critical] Task ${taskId} failed: ${error.message}`);

      await this.taskRepository.updateStatus(taskId, TASK_STATUS.FAILED, {
        error: error.message,
      });

      throw error;
    }
  }

  protected abstract handleProcess(job: Job<any>): Promise<any>;

  @OnWorkerEvent('failed')
  onFailed(job: Job, error: Error) {
    this.logger.error(`[Critical] Job ${job.id} failed: ${error.message}`);
  }

  @OnWorkerEvent('completed')
  onCompleted(job: Job) {
    this.logger.log(`[Critical] Job ${job.id} completed successfully`);
  }
}
