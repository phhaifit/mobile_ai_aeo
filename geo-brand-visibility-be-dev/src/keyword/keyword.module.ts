import { Module, forwardRef } from '@nestjs/common';
import { KeywordController } from './keyword.controller';
import { KeywordService } from './keyword.service';
import { KeywordRepository } from './keyword.repository';
import { AgentModule } from '../agent/agent.module';
import { BrandModule } from '../brand/brand.module';
import { TopicModule } from '../topic/topic.module';
import { SupabaseModule } from '../supabase/supabase.module';
import { TokenModule } from '../token/token.module';
import { UserModule } from 'src/user/user.module';
import { CustomerPersonaModule } from '../customer-persona/customer-persona.module';
import { ProjectModule } from '../project/project.module';

@Module({
  imports: [
    AgentModule,
    forwardRef(() => BrandModule),
    TopicModule,
    SupabaseModule,
    TokenModule,
    UserModule,
    CustomerPersonaModule,
    forwardRef(() => ProjectModule),
  ],
  controllers: [KeywordController],
  providers: [KeywordService, KeywordRepository],
  exports: [KeywordService, KeywordRepository],
})
export class KeywordModule {}
