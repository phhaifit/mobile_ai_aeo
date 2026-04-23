import { Module } from '@nestjs/common';
import { SupabaseModule } from '../supabase/supabase.module';
import { GoogleModule } from '../google/google.module';
import { GaController } from './google-analytics.controller';
import { GaService } from './google-analytics.service';
import { GaRepository } from './google-analytics.repository';

@Module({
  imports: [SupabaseModule, GoogleModule],
  controllers: [GaController],
  providers: [GaService, GaRepository],
  exports: [GaService],
})
export class GoogleAnalyticsModule {}
