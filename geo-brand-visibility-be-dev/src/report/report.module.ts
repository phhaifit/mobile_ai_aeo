import { forwardRef, Module } from '@nestjs/common';
import { ReportService } from './report.service';
import { MailModule } from '../mail/mail.module';
import { PromptModule } from '../prompt/prompt.module';
import { ProjectMemberModule } from '../project-member/project-member.module';
import { ProjectModule } from '../project/project.module';
import { ContentModule } from '../content/content.module';

@Module({
  imports: [
    MailModule,
    forwardRef(() => PromptModule),
    forwardRef(() => ContentModule),
    forwardRef(() => ProjectMemberModule),
    forwardRef(() => ProjectModule),
  ],
  providers: [ReportService],
  exports: [ReportService],
})
export class ReportModule {}
