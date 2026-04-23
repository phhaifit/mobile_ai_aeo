import { Module } from '@nestjs/common';
import { CompetitorService } from './competitor.service';
import { SupabaseModule } from '../supabase/supabase.module';
import { CompetitorRepository } from './competitor.repository';

@Module({
  imports: [SupabaseModule],
  providers: [CompetitorService, CompetitorRepository],
  exports: [CompetitorService, CompetitorRepository],
})
export class CompetitorModule {}
