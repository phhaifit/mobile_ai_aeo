import { Module } from '@nestjs/common';
import { PublicBlogController } from './public-blog.controller';
import { PublicBlogService } from './public-blog.service';
import { PublicBlogRepository } from './public-blog.repository';
import { BrandModule } from '../brand/brand.module';
import { SupabaseModule } from '../supabase/supabase.module';
import { R2StorageModule } from '../r2-storage/r2-storage.module';

@Module({
  imports: [BrandModule, SupabaseModule, R2StorageModule],
  controllers: [PublicBlogController],
  providers: [PublicBlogService, PublicBlogRepository],
  exports: [PublicBlogService],
})
export class PublicBlogModule {}
