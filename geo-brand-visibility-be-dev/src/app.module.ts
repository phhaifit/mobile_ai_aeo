import { MiddlewareConsumer, Module, NestModule } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { SwaggerModule } from '@nestjs/swagger';
import { AuthModule } from './auth/auth.module';
import { UserModule } from './user/user.module';
import { BrandModule } from './brand/brand.module';
import { PromptModule } from './prompt/prompt.module';
import { ProjectModule } from './project/project.module';
import { SupabaseModule } from './supabase/supabase.module';
import { AgentModule } from './agent/agent.module';
import { ModelModule } from './model/model.module';
import { TopicModule } from './topic/topic.module';
import { KeywordModule } from './keyword/keyword.module';
import { N8nModule } from './n8n/n8n.module';
import { BullModule } from '@nestjs/bullmq';
import { ContentProfileModule } from './content-profile/content-profile.module';
import { ScheduleModule } from '@nestjs/schedule';
import { SchedulerModule } from './scheduler/scheduler.module';
import { ProjectMemberModule } from './project-member/project-member.module';
import { ProjectInvitationModule } from './project-invitation/project-invitation.module';
import { PublicBlogModule } from './public-blog/public-blog.module';
import { QueryParserMiddleware } from './shared/middlewares/query-parse.middleware';
import { WebSearchModule } from './web-search/web-search.module';
import { ContentModule } from './content/content.module';
import { ContentInsightModule } from './content-insight/content-insight.module';
import { R2StorageModule } from './r2-storage/r2-storage.module';
import { ExternalPhotosModule } from './external-photos/external-photos.module';
import { ContentClusterModule } from './content-cluster/content-cluster.module';
import { ContentAgentModule } from './content-agent/content-agent.module';
import { SubscriptionModule } from './subscription/subscription.module';
import { SocialModule } from './social/social.module';
import { CustomerPersonaModule } from './customer-persona/customer-persona.module';
import { ServiceModule } from './service/service.module';
import { ServiceCategoryModule } from './service-category/service-category.module';
import { HealthController } from './health.controller';
import { DefaultContentProfileModule } from './default-content-profile/default-content-profile.module';
import { GoogleSearchConsoleModule } from './google-search-console/google-search-console.module';
import { GoogleAnalyticsModule } from './google-analytics/google-analytics.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
    }),
    ScheduleModule.forRoot(),
    SwaggerModule,
    AuthModule,
    UserModule,
    BrandModule,
    PromptModule,
    ProjectModule,
    SupabaseModule,
    AgentModule,
    ModelModule,
    TopicModule,
    KeywordModule,
    N8nModule,
    ContentModule,
    ContentInsightModule,
    BullModule.forRoot({
      connection: {
        url: process.env.REDIS_URL || 'redis://127.0.0.1:6379',
      },
    }),
    ContentProfileModule,
    SchedulerModule,
    ProjectMemberModule,
    ProjectInvitationModule,
    PublicBlogModule,
    WebSearchModule,
    R2StorageModule,
    ExternalPhotosModule,
    ContentClusterModule,
    ContentAgentModule,
    SubscriptionModule,
    DefaultContentProfileModule,
    SocialModule,
    GoogleSearchConsoleModule,
    GoogleAnalyticsModule,
    CustomerPersonaModule,
    ServiceModule,
    ServiceCategoryModule,
  ],
  controllers: [HealthController],
})
export class AppModule implements NestModule {
  configure(consumer: MiddlewareConsumer) {
    consumer.apply(QueryParserMiddleware).forRoutes('*');
  }
}
