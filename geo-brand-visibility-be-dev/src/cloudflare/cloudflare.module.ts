import { Module } from '@nestjs/common';
import { CloudflareService } from './cloudflare.service';

@Module({
  imports: [],
  controllers: [],
  providers: [CloudflareService],
  exports: [CloudflareService],
})
export class CloudflareModule {}
