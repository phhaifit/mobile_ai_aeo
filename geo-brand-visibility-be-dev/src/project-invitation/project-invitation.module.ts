import { Module } from '@nestjs/common';
import { ProjectInvitationService } from './project-invitation.service';
import { ProjectInvitationController } from './project-invitation.controller';
import { ProjectInvitationRepository } from './project-invitation.repository';
import { SupabaseModule } from '../supabase/supabase.module';
import { ProjectMemberModule } from '../project-member/project-member.module';
import { UserModule } from '../user/user.module';
import { MailModule } from '../mail/mail.module';

@Module({
  imports: [SupabaseModule, ProjectMemberModule, UserModule, MailModule],
  controllers: [ProjectInvitationController],
  providers: [ProjectInvitationService, ProjectInvitationRepository],
  exports: [ProjectInvitationService],
})
export class ProjectInvitationModule {}
