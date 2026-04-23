import { Module } from '@nestjs/common';
import { SupabaseModule } from '../supabase/supabase.module';
import { ModelRepository } from './model.repository';
import { ModelService } from './model.service';
import { ModelController } from './model.controller';

@Module({
  imports: [SupabaseModule],
  controllers: [ModelController],
  providers: [ModelRepository, ModelService],
  exports: [ModelService],
})
export class ModelModule {}
