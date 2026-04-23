import { Module, OnModuleInit } from '@nestjs/common';
import { BullModule } from '@nestjs/bullmq';
import { SupabaseModule } from '../supabase/supabase.module';
import { ProjectMemberModule } from '../project-member/project-member.module';
import { SocialController } from './social.controller';
import { SocialService } from './social.service';
import { SocialAccountRepository } from './social-account.repository';
import { SocialPostRepository } from './social-post.repository';
import { SocialPostTargetRepository } from './social-post-target.repository';
import { PlatformProviderRegistry } from './platforms/platform-provider.registry';
import { FacebookProvider } from './platforms/facebook/facebook.provider';
import { LinkedInProvider } from './platforms/linkedin/linkedin.provider';
import { ThreadsProvider } from './platforms/threads/threads.provider';
import { ZaloOAProvider } from './platforms/zalo-oa/zalo-oa.provider';
import { InstagramProvider } from './platforms/instagram/instagram.provider';
import { SafePublishService } from './safe-publish.service';
import { SafePublishSchedulerService } from './safe-publish-scheduler.service';
import { QueueNames } from '../processors/contants/queue';

@Module({
  imports: [
    SupabaseModule,
    ProjectMemberModule,
    BullModule.registerQueue({
      name: QueueNames.SocialPublish,
    }),
  ],
  controllers: [SocialController],
  providers: [
    SocialService,
    SafePublishService,
    SafePublishSchedulerService,
    SocialAccountRepository,
    SocialPostRepository,
    SocialPostTargetRepository,
    PlatformProviderRegistry,
    FacebookProvider,
    LinkedInProvider,
    ThreadsProvider,
    ZaloOAProvider,
    InstagramProvider,
  ],
  exports: [
    SocialService,
    SafePublishService,
    SocialAccountRepository,
    SocialPostRepository,
    SocialPostTargetRepository,
    PlatformProviderRegistry,
  ],
})
export class SocialModule implements OnModuleInit {
  constructor(
    private readonly registry: PlatformProviderRegistry,
    private readonly facebookProvider: FacebookProvider,
    private readonly linkedInProvider: LinkedInProvider,
    private readonly threadsProvider: ThreadsProvider,
    private readonly zaloOAProvider: ZaloOAProvider,
    private readonly instagramProvider: InstagramProvider,
  ) {}

  onModuleInit() {
    this.registry.register(this.facebookProvider);
    this.registry.register(this.linkedInProvider);
    this.registry.register(this.threadsProvider);
    this.registry.register(this.zaloOAProvider);
    this.registry.register(this.instagramProvider);
  }
}
