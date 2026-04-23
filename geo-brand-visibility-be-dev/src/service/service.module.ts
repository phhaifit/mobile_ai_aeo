import { forwardRef, Module } from '@nestjs/common';
import { ServiceController } from './service.controller';
import { ServiceService } from './service.service';
import { ServiceRepository } from './service.repository';
import { SupabaseModule } from '../supabase/supabase.module';
import { BrandModule } from '../brand/brand.module';
import { ServiceCategoryModule } from '../service-category/service-category.module';

@Module({
  imports: [
    SupabaseModule,
    forwardRef(() => BrandModule),
    ServiceCategoryModule,
  ],
  controllers: [ServiceController],
  providers: [ServiceService, ServiceRepository],
  exports: [ServiceService, ServiceRepository],
})
export class ServiceModule {}
