import { Module } from '@nestjs/common';
import { TaskRepository } from './task.repository';
import { SupabaseModule } from '../supabase/supabase.module';

@Module({
  imports: [SupabaseModule],
  providers: [TaskRepository],
  exports: [TaskRepository],
})
export class TaskModule {}
