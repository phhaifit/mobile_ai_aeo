import { Module, Logger, Global } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import Redis from 'ioredis';
import { WebSearchService } from './web-search.service';
import { BrightdataProvider } from './providers/brightdata.provider';
import { AbstractWebSearchProvider } from './providers/base-search.provider';
import { REDIS_CACHE_CLIENT } from 'src/shared/constant';

const logger = new Logger('WebSearchModule');

@Global()
@Module({
  imports: [ConfigModule],
  providers: [
    {
      provide: REDIS_CACHE_CLIENT,
      useFactory: (configService: ConfigService) => {
        const redisUrl =
          configService.get<string>('REDIS_URL') || 'redis://localhost:6379';
        logger.log(`Connecting WebSearch cache to Redis at: ${redisUrl}`);

        const client = new Redis(redisUrl);

        client.on('connect', () => {
          logger.log('WebSearch Redis cache connected successfully');
        });

        client.on('error', (err) => {
          logger.error('WebSearch Redis cache connection error', err);
        });

        return client;
      },
      inject: [ConfigService],
    },
    WebSearchService,
    {
      provide: AbstractWebSearchProvider,
      useClass: BrightdataProvider,
    },
  ],
  exports: [WebSearchService, AbstractWebSearchProvider, REDIS_CACHE_CLIENT],
})
export class WebSearchModule {}
