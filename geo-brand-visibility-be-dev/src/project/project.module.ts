import { forwardRef, Module } from '@nestjs/common';
import { ProjectController } from './project.controller';
import { ProjectService } from './project.service';
import { SupabaseModule } from '../supabase/supabase.module';
import { ProjectRepository } from './project.repository';
import { AgentModule } from '../agent/agent.module';
import { PromptModule } from '../prompt/prompt.module';
import { BrandModule } from '../brand/brand.module';
import { TopicModule } from 'src/topic/topic.module';
import { ProjectMemberModule } from '../project-member/project-member.module';
import { TaskEnqueueModule } from 'src/task-enqueue/task-enqueue.module';
import { ReportModule } from '../report/report.module';
import { UserModule } from '../user/user.module';
import { ContentAgentModule } from '../content-agent/content-agent.module';
import { ContentProfileModule } from '../content-profile/content-profile.module';
import { SubscriptionModule } from '../subscription/subscription.module';

@Module({
  imports: [
    SupabaseModule,
    AgentModule,
    TaskEnqueueModule,
    UserModule,
    forwardRef(() => ReportModule),
    ContentAgentModule,
    SubscriptionModule,
    forwardRef(() => ContentProfileModule),
    forwardRef(() => PromptModule),
    forwardRef(() => TopicModule),
    forwardRef(() => BrandModule),
    forwardRef(() => ProjectMemberModule),
  ],
  controllers: [ProjectController],
  providers: [ProjectRepository, ProjectService],
  exports: [
    ProjectRepository,
    ProjectService,
    TaskEnqueueModule,
    forwardRef(() => PromptModule),
    forwardRef(() => TopicModule),
    forwardRef(() => BrandModule),
    forwardRef(() => ProjectMemberModule),
  ],
})
export class ProjectModule {}
