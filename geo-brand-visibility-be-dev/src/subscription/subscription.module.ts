import { Module } from '@nestjs/common';
import { SubscriptionController } from './subscription.controller';
import { WebhookController } from './webhook.controller';
import { SubscriptionService } from './subscription.service';
import { SubscriptionRepository } from './subscription.repository';
import { SupabaseModule } from '../supabase/supabase.module';
import { ProjectMemberModule } from '../project-member/project-member.module';
import { MailModule } from '../mail/mail.module';

@Module({
  imports: [SupabaseModule, ProjectMemberModule, MailModule],
  controllers: [SubscriptionController, WebhookController],
  providers: [SubscriptionRepository, SubscriptionService],
  exports: [SubscriptionRepository, SubscriptionService],
})
export class SubscriptionModule {}
