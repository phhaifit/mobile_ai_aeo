import { forwardRef, Module } from '@nestjs/common';
import { ServiceCategoryController } from './service-category.controller';
import { ServiceCategoryService } from './service-category.service';
import { ServiceCategoryRepository } from './service-category.repository';
import { SupabaseModule } from '../supabase/supabase.module';
import { BrandModule } from '../brand/brand.module';

@Module({
  imports: [SupabaseModule, forwardRef(() => BrandModule)],
  controllers: [ServiceCategoryController],
  providers: [ServiceCategoryService, ServiceCategoryRepository],
  exports: [ServiceCategoryService, ServiceCategoryRepository],
})
export class ServiceCategoryModule {}
