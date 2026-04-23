import { Module, forwardRef } from '@nestjs/common';
import { BullModule } from '@nestjs/bullmq';
import { TaskModule } from '../task/task.module';
import { QueueNames } from '../processors/contants/queue';
import { TaskEnqueueService } from './task-enqueue.service';
import { PromptModule } from 'src/prompt/prompt.module';
import { ContentAgentModule } from 'src/content-agent/content-agent.module';

@Module({
  imports: [
    BullModule.registerQueue({
      name: QueueNames.CreateProject,
    }),
    BullModule.registerQueue({
      name: QueueNames.ContentGeneration,
    }),
    BullModule.registerQueue({
      name: QueueNames.ProjectAnalysis,
    }),
    BullModule.registerQueue({
      name: QueueNames.PromptAnalysis,
    }),
    TaskModule,
    ContentAgentModule,
    forwardRef(() => PromptModule),
  ],
  providers: [TaskEnqueueService],
  exports: [TaskEnqueueService],
})
export class TaskEnqueueModule {}
