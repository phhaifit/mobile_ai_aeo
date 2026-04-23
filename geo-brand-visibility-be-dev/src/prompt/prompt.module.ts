import { forwardRef, Module } from '@nestjs/common';
import { PromptController } from './prompt.controller';
import { PromptService } from './prompt.service';
import { SupabaseModule } from '../supabase/supabase.module';
import { ProjectModule } from '../project/project.module';
import { PromptRepository } from './prompt.repository';
import { BrandModule } from '../brand/brand.module';
import { AgentModule } from '../agent/agent.module';
import { TopicModule } from '../topic/topic.module';
import { KeywordModule } from '../keyword/keyword.module';
import { ContentModule } from 'src/content/content.module';
import { WebSearchModule } from 'src/web-search/web-search.module';
import { TaskEnqueueModule } from 'src/task-enqueue/task-enqueue.module';
import { SubscriptionModule } from '../subscription/subscription.module';
import { PromptProPlanGuard } from '../auth/guards/prompt-pro-plan.guard';
import { CustomerPersonaModule } from '../customer-persona/customer-persona.module';

@Module({
  imports: [
    SupabaseModule,
    forwardRef(() => ProjectModule),
    AgentModule,
    forwardRef(() => BrandModule),
    TopicModule,
    ContentModule,
    forwardRef(() => KeywordModule),
    WebSearchModule,
    forwardRef(() => TaskEnqueueModule),
    SubscriptionModule,
    CustomerPersonaModule,
  ],
  controllers: [PromptController],
  providers: [PromptService, PromptRepository, PromptProPlanGuard],
  exports: [PromptService, PromptRepository],
})
export class PromptModule {}
