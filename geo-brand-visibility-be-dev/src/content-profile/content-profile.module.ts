import { forwardRef, Module } from '@nestjs/common';
import { ContentProfileController } from './content-profile.controller';
import { ContentProfileService } from './content-profile.service';
import { ContentProfileRepository } from './content-profile.repository';
import { SupabaseModule } from '../supabase/supabase.module';
import { ProjectModule } from '../project/project.module';

@Module({
  imports: [SupabaseModule, forwardRef(() => ProjectModule)],
  controllers: [ContentProfileController],
  providers: [ContentProfileService, ContentProfileRepository],
  exports: [ContentProfileService, ContentProfileRepository],
})
export class ContentProfileModule {}
