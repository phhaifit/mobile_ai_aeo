import { Module } from '@nestjs/common';
import {
  ContentAgentController,
  ProjectContentAgentController,
} from './content-agent.controller';
import { ContentAgentService } from './content-agent.service';
import { ContentAgentRepository } from './content-agent.repository';
import { SupabaseModule } from '../supabase/supabase.module';
import { ProjectMemberModule } from '../project-member/project-member.module';

@Module({
  imports: [SupabaseModule, ProjectMemberModule],
  controllers: [ContentAgentController, ProjectContentAgentController],
  providers: [ContentAgentService, ContentAgentRepository],
  exports: [ContentAgentService, ContentAgentRepository],
})
export class ContentAgentModule {}
