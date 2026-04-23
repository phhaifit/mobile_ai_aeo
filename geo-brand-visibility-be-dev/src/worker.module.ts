import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { BrandModule } from './brand/brand.module';
import { PromptModule } from './prompt/prompt.module';
import { ProjectModule } from './project/project.module';
import { SupabaseModule } from './supabase/supabase.module';
import { AgentModule } from './agent/agent.module';
import { BullModule } from '@nestjs/bullmq';
import { ProcessorsModule } from './processors/processors.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
    }),
    ProcessorsModule.register(),
    BrandModule,
    PromptModule,
    ProjectModule,
    SupabaseModule,
    AgentModule,
    BullModule.forRoot({
      connection: {
        url: process.env.REDIS_URL || 'redis://127.0.0.1:6379',
      },
      defaultJobOptions: {
        removeOnComplete: { count: 100 },
        removeOnFail: { count: 200 },
      },
    }),
  ],
})
export class WorkerModule {}
