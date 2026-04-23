import { Module } from '@nestjs/common';
import { N8nService } from './n8n.service';

@Module({
  imports: [],
  controllers: [],
  providers: [N8nService],
  exports: [N8nService],
})
export class N8nModule {}
