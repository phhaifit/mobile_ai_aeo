import { forwardRef, Module } from '@nestjs/common';
import { BrandController } from './brand.controller';
import { BrandService } from './brand.service';
import { SupabaseModule } from '../supabase/supabase.module';
import { BrandRepository } from './brand.repository';
import { AgentModule } from '../agent/agent.module';
import { CompetitorModule } from '../competitor/competitor.module';
import { ProjectModule } from '../project/project.module';
import { CloudflareModule } from '../cloudflare/cloudflare.module';

@Module({
  imports: [
    SupabaseModule,
    AgentModule,
    CompetitorModule,
    forwardRef(() => ProjectModule),
    CloudflareModule,
  ],
  controllers: [BrandController],
  providers: [BrandService, BrandRepository],
  exports: [BrandService, BrandRepository],
})
export class BrandModule {}
