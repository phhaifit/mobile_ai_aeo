import { Module, DynamicModule, forwardRef } from '@nestjs/common';
import { BullModule } from '@nestjs/bullmq';
import { ProjectAnalysisQueueProcessor } from './project-analysis-queue.processor';
import { ContentGenerationQueueProcessor } from './content-generation-queue.processor';
import { PromptAnalysisQueueProcessor } from './prompt-analysis-queue.processor';
import { ProjectModule } from '../project/project.module';
import { TaskModule } from '../task/task.module';
import { CreateProjectQueueProcessor } from './create-project-queue.processor';
import { ContentModule } from 'src/content/content.module';
import { ContentAgentModule } from 'src/content-agent/content-agent.module';
import { PromptModule } from 'src/prompt/prompt.module';
import { AgentModule } from 'src/agent/agent.module';
import { SocialModule } from 'src/social/social.module';
import { SocialPublishProcessor } from 'src/social/social-publish.processor';

@Module({})
export class ProcessorsModule {
  static register(): DynamicModule {
    const workerType = process.env.WORKER_TYPE || 'all';

    const imports: any[] = [];
    const providers: any[] = [];

    // Register queues and processors based on worker type
    if (workerType === 'projectAnalysis' || workerType === 'all') {
      imports.push(
        BullModule.registerQueue({
          name: 'projectAnalysisQueue',
        }),
        BullModule.registerQueue({
          name: 'promptAnalysisQueue',
        }),
      );
      providers.push(
        ProjectAnalysisQueueProcessor,
        PromptAnalysisQueueProcessor,
      );
    }

    if (workerType === 'contentGeneration' || workerType === 'all') {
      imports.push(
        BullModule.registerQueue({
          name: 'contentGenerationQueue',
        }),
        BullModule.registerQueue({
          name: 'socialPublishQueue',
        }),
      );
      providers.push(ContentGenerationQueueProcessor, SocialPublishProcessor);
    }

    if (workerType === 'createProject' || workerType === 'all') {
      imports.push(
        BullModule.registerQueue({
          name: 'createProjectQueue',
        }),
      );
      providers.push(CreateProjectQueueProcessor);
    }

    if (workerType === 'socialPublish' || workerType === 'all') {
      imports.push(
        BullModule.registerQueue({
          name: 'socialPublishQueue',
        }),
      );
      providers.push(SocialPublishProcessor);
    }

    // Always import required modules
    imports.push(
      ProjectModule,
      TaskModule,
      ContentModule,
      ContentAgentModule,
      PromptModule,
      AgentModule,
      SocialModule,
    );

    return {
      module: ProcessorsModule,
      imports,
      providers,
    };
  }
}
