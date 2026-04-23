import { forwardRef, Module } from '@nestjs/common';
import { ContentClusterController } from './content-cluster.controller';
import { ContentClusterService } from './content-cluster.service';
import { SupabaseModule } from '../supabase/supabase.module';
import { ProjectModule } from 'src/project/project.module';
import { BrandModule } from 'src/brand/brand.module';
import { ContentProfileModule } from 'src/content-profile/content-profile.module';
import { N8nModule } from 'src/n8n/n8n.module';
import { TopicModule } from 'src/topic/topic.module';
import { AgentModule } from 'src/agent/agent.module';
import { ContentModule } from 'src/content/content.module';
import { ProjectMemberModule } from 'src/project-member/project-member.module';
import { SseModule } from 'src/sse/sse.module';

@Module({
  imports: [
    SupabaseModule,
    N8nModule,
    forwardRef(() => ProjectModule),
    forwardRef(() => BrandModule),
    ContentProfileModule,
    TopicModule,
    AgentModule,
    forwardRef(() => ContentModule),
    ProjectMemberModule,
    SseModule,
  ],
  controllers: [ContentClusterController],
  providers: [ContentClusterService],
  exports: [ContentClusterService],
})
export class ContentClusterModule {}
