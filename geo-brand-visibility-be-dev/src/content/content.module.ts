import { forwardRef, Module } from '@nestjs/common';
import { ContentRepository } from './content.repository';
import { ContentService } from './content.service';
import { ContentImageService } from './content-image.service';
import { ContentController } from './content.controller';
import { SupabaseModule } from '../supabase/supabase.module';
import { ProjectModule } from 'src/project/project.module';
import { BrandModule } from 'src/brand/brand.module';
import { ContentProfileModule } from 'src/content-profile/content-profile.module';
import { N8nModule } from 'src/n8n/n8n.module';
import { WebSearchModule } from 'src/web-search/web-search.module';
import { TopicModule } from 'src/topic/topic.module';
import { PromptModule } from 'src/prompt/prompt.module';
import { ContentInsightModule } from 'src/content-insight/content-insight.module';
import { ProjectMemberModule } from 'src/project-member/project-member.module';
import { SseModule } from 'src/sse/sse.module';
import { R2StorageModule } from 'src/r2-storage/r2-storage.module';
import { OcrModule } from 'src/ocr/ocr.module';
import { AgentModule } from 'src/agent/agent.module';
import { SubscriptionModule } from 'src/subscription/subscription.module';
import { VectorSearchModule } from 'src/vector-search/vector-search.module';
import { CustomerPersonaModule } from 'src/customer-persona/customer-persona.module';

@Module({
  imports: [
    SupabaseModule,
    N8nModule,
    AgentModule,
    VectorSearchModule,
    forwardRef(() => ProjectModule),
    forwardRef(() => BrandModule),
    ContentProfileModule,
    WebSearchModule,
    TopicModule,
    forwardRef(() => PromptModule),
    forwardRef(() => ContentInsightModule),
    ProjectMemberModule,
    SseModule,
    R2StorageModule,
    OcrModule,
    forwardRef(() => SubscriptionModule),
    CustomerPersonaModule,
  ],
  controllers: [ContentController],
  providers: [ContentRepository, ContentService, ContentImageService],
  exports: [ContentRepository, ContentService, ContentImageService],
})
export class ContentModule {}
