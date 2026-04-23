import { forwardRef, Module } from '@nestjs/common';
import { BullModule } from '@nestjs/bullmq';
import { SchedulerService } from './scheduler.service';
import { SchedulerRepository } from './scheduler.repository';
import { ProjectModule } from '../project/project.module';
import { TaskModule } from '../task/task.module';
import { QueueNames } from '../processors/contants/queue';
import { ContentModule } from '../content/content.module';
import { SupabaseModule } from '../supabase/supabase.module';
import { SubscriptionModule } from '../subscription/subscription.module';
import { MailModule } from '../mail/mail.module';

@Module({
  imports: [
    BullModule.registerQueue({
      name: QueueNames.ProjectAnalysis,
    }),
    BullModule.registerQueue({
      name: QueueNames.ContentGeneration,
    }),
    SupabaseModule,
    TaskModule,
    SubscriptionModule,
    MailModule,
    forwardRef(() => ContentModule),
    forwardRef(() => ProjectModule),
  ],
  providers: [SchedulerService, SchedulerRepository],
  exports: [SchedulerService],
})
export class SchedulerModule {}
