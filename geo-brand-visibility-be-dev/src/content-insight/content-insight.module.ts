import { Module, forwardRef } from '@nestjs/common';
import { ContentInsightController } from './content-insight.controller';
import { ContentInsightService } from './content-insight.service';
import { ContentInsightRepository } from './content-insight.repository';
import { SupabaseModule } from '../supabase/supabase.module';
import { ContentModule } from '../content/content.module';
import { ProjectMemberModule } from '../project-member/project-member.module';

@Module({
  imports: [
    SupabaseModule,
    forwardRef(() => ContentModule),
    ProjectMemberModule,
  ],
  controllers: [ContentInsightController],
  providers: [ContentInsightService, ContentInsightRepository],
  exports: [ContentInsightService, ContentInsightRepository],
})
export class ContentInsightModule {}
