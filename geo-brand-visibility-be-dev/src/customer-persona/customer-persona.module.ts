import { forwardRef, Module } from '@nestjs/common';
import { CustomerPersonaController } from './customer-persona.controller';
import { CustomerPersonaService } from './customer-persona.service';
import { CustomerPersonaRepository } from './customer-persona.repository';
import { SupabaseModule } from '../supabase/supabase.module';
import { BrandModule } from '../brand/brand.module';
import { AgentModule } from '../agent/agent.module';

@Module({
  imports: [SupabaseModule, forwardRef(() => BrandModule), AgentModule],
  controllers: [CustomerPersonaController],
  providers: [CustomerPersonaService, CustomerPersonaRepository],
  exports: [CustomerPersonaService, CustomerPersonaRepository],
})
export class CustomerPersonaModule {}
