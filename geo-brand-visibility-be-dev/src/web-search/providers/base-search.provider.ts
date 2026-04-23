import { Logger, Inject, Injectable } from '@nestjs/common';
import Redis from 'ioredis';
import {
  WebSearchResponseDto,
  WebCrawlResponseDto,
} from '../dtos/web-search-response.dto';
import { REDIS_CACHE_TTL } from '../contants';
import { REDIS_CACHE_CLIENT } from 'src/shared/constant';
import { SearchOptionDto } from '../dtos/search-option.dto';

@Injectable()
export abstract class AbstractWebSearchProvider {
  protected abstract readonly logger: Logger;

  constructor(
    @Inject(REDIS_CACHE_CLIENT) protected readonly redisClient: Redis,
  ) {}

  async search(
    query: string,
    option?: SearchOptionDto,
  ): Promise<WebSearchResponseDto[]> {
    let cacheKey = `websearch`;

    if (option) {
      cacheKey += `:${option.lang}:${option.loc}`;
    }

    cacheKey += `:search:${query}`.replaceAll(' ', '-');

    try {
      const cachedData = await this.redisClient.get(cacheKey);
      if (cachedData) {
        this.logger.log(`Cache HIT for query: ${query}`);
        return JSON.parse(cachedData) as WebSearchResponseDto[];
      }
    } catch (error) {
      this.logger.error(`Cache GET failed for key: ${cacheKey}`, error);
    }

    this.logger.log(`Cache MISS for query: ${query}. Executing search.`);
    const result = await this.executeSearch(query, option);

    try {
      await this.redisClient.setex(
        cacheKey,
        REDIS_CACHE_TTL, // TTL in seconds
        JSON.stringify(result),
      );
      this.logger.log(`Cache SET successful for key: ${cacheKey}`);
    } catch (error) {
      this.logger.error(`Cache SET failed for key: ${cacheKey}`, error);
    }

    return result;
  }

  async crawl(url: string): Promise<WebCrawlResponseDto> {
    const cacheKey = `websearch:crawl:${url}`.replaceAll(' ', '-');

    try {
      const cachedData = await this.redisClient.get(cacheKey);
      if (cachedData) {
        this.logger.log(`Cache HIT for URL: ${url}`);
        return JSON.parse(cachedData) as WebCrawlResponseDto;
      }
    } catch (error) {
      this.logger.error(`Cache GET failed for key: ${cacheKey}`, error);
    }

    this.logger.log(`Cache MISS for URL: ${url}. Executing crawl.`);
    const result = await this.executeCrawl(url);

    try {
      await this.redisClient.setex(
        cacheKey,
        REDIS_CACHE_TTL, // TTL in seconds
        JSON.stringify(result),
      );
      this.logger.log(`Cache SET successful for key: ${cacheKey}`);
    } catch (error) {
      this.logger.error(`Cache SET failed for key: ${cacheKey}`, error);
    }

    return result;
  }

  protected abstract executeSearch(
    query: string,
    option?: SearchOptionDto,
  ): Promise<WebSearchResponseDto[]>;

  protected abstract executeCrawl(url: string): Promise<WebCrawlResponseDto>;
}
