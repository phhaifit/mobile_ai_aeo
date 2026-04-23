import { Module } from '@nestjs/common';
import { SupabaseModule } from '../supabase/supabase.module';
import { GoogleModule } from '../google/google.module';
import { GscController } from './google-search-console.controller';
import { GscService } from './google-search-console.service';
import { GscRepository } from './google-search-console.repository';

@Module({
  imports: [SupabaseModule, GoogleModule],
  controllers: [GscController],
  providers: [GscService, GscRepository],
  exports: [GscService],
})
export class GoogleSearchConsoleModule {}
