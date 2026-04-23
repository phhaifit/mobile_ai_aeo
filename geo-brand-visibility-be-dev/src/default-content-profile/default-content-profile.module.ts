import { Module } from '@nestjs/common';
import { DefaultContentProfileController } from './default-content-profile.controller';
import { DefaultContentProfileService } from './default-content-profile.service';
import { SupabaseModule } from '../supabase/supabase.module';
import { DefaultContentProfileRepository } from './default-content-profile.repository';

@Module({
  imports: [SupabaseModule],
  controllers: [DefaultContentProfileController],
  providers: [DefaultContentProfileService, DefaultContentProfileRepository],
  exports: [DefaultContentProfileService, DefaultContentProfileRepository],
})
export class DefaultContentProfileModule {}
