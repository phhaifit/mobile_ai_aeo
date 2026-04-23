import { Module, forwardRef } from '@nestjs/common';
import { TopicController } from './topic.controller';
import { TopicService } from './topic.service';
import { TopicRepository } from './topic.repository';
import { SupabaseModule } from 'src/supabase/supabase.module';
import { PromptModule } from 'src/prompt/prompt.module';
import { ProjectModule } from 'src/project/project.module';
import { ProjectMemberModule } from 'src/project-member/project-member.module';
import { AgentModule } from 'src/agent/agent.module';
import { BrandModule } from 'src/brand/brand.module';
import { CustomerPersonaModule } from 'src/customer-persona/customer-persona.module';

@Module({
  imports: [
    SupabaseModule,
    AgentModule,
    forwardRef(() => PromptModule),
    forwardRef(() => ProjectModule),
    forwardRef(() => ProjectMemberModule),
    forwardRef(() => BrandModule),
    CustomerPersonaModule,
  ],
  controllers: [TopicController],
  providers: [TopicService, TopicRepository],
  exports: [TopicService, TopicRepository],
})
export class TopicModule {}
