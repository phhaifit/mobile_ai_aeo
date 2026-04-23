import { Inject, Injectable, Logger } from '@nestjs/common';
import Redis from 'ioredis';
import { ConfigService } from '@nestjs/config';
import { AbstractWebSearchProvider } from './base-search.provider';
import {
  WebCrawlResponseDto,
  WebSearchResponseDto,
} from 'src/web-search/dtos/web-search-response.dto';
import { SearchOptionDto } from 'src/web-search/dtos/search-option.dto';
import { BrightdataCrawlResponseDto } from 'src/web-search/dtos/brightdata-web-crawl-response.dto';
import { BrightdataSearchResponseDto } from 'src/web-search/dtos/brightdata-web-search-response.dto';
import { REDIS_CACHE_CLIENT } from 'src/shared/constant';
import { DEFAULT_LOCATION } from 'src/shared/constant';

@Injectable()
export class BrightdataProvider extends AbstractWebSearchProvider {
  protected readonly logger = new Logger(BrightdataProvider.name);

  constructor(
    @Inject(REDIS_CACHE_CLIENT) redisClient: Redis,
    private readonly configService: ConfigService,
  ) {
    super(redisClient);
  }

  private readonly MAX_RETRIES = 2;
  private readonly RETRY_DELAY_MS = 2000;

  private async post<T>(
    body: string,
    apiKey: string,
    apiUrl: string = 'https://api.brightdata.com/request',
  ): Promise<T> {
    let lastError!: Error;

    for (let attempt = 0; attempt <= this.MAX_RETRIES; attempt++) {
      try {
        if (attempt > 0) {
          const delay = this.RETRY_DELAY_MS * Math.pow(2, attempt - 1);
          this.logger.warn(
            `Retrying BrightData request (attempt ${attempt + 1}/${this.MAX_RETRIES + 1}) after ${delay}ms`,
          );
          await new Promise((resolve) => setTimeout(resolve, delay));
        }

        const response = await fetch(apiUrl, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            Authorization: `Bearer ${apiKey}`,
          },
          body: body,
        });

        this.logger.debug('DataBright response received', response);

        // Retry on rate limit (429) or server errors (5xx)
        if (response.status === 429 || response.status >= 500) {
          const errorBody = await response.text();
          this.logger.error(
            `BrightData responded with ${response.status}: ${errorBody}`,
          );
          throw new Error(
            `BrightData returned status ${response.status} (retryable)`,
          );
        }

        if (!response.ok) {
          const errorBody = await response.text();
          this.logger.error(
            `BrightData responded with ${response.status}: ${errorBody}`,
          );
          throw new Error(
            `BrightData fetch failed with status: ${response.status} (non-retryable)`,
          );
        }
        const data = (await response.json()) as T;
        return data;
      } catch (error) {
        lastError = error instanceof Error ? error : new Error('Unknown error');
        this.logger.error(
          `BrightData attempt ${attempt + 1} failed: ${lastError.message}`,
        );

        const isRetryable =
          lastError.message.includes('retryable') ||
          lastError.message.includes('ECONNRESET') ||
          lastError.message.includes('ETIMEDOUT') ||
          lastError.message.includes('fetch failed');

        if (!isRetryable || attempt === this.MAX_RETRIES) {
          break;
        }
      }
    }

    this.logger.error(`All BrightData attempts failed: ${lastError?.message}`);
    throw lastError;
  }

  protected async executeSearch(
    query: string,
    option?: SearchOptionDto,
  ): Promise<WebSearchResponseDto[]> {
    this.logger.log(`Searching with query: ${query}`);
    let url = `https://www.google.com/search?&q=${encodeURIComponent(query)}`;

    if (option?.loc && option?.loc != DEFAULT_LOCATION) {
      url += `&gl=${option?.loc}`;
    }
    // if (option?.lang) {
    //   url += `&hl=${option?.lang}`;
    // }

    this.logger.log(`option: ${JSON.stringify(option)}`);
    this.logger.log(`Searching with URL: ${url}`);
    const data = await this.post<BrightdataSearchResponseDto>(
      JSON.stringify({
        url: url,
        format: 'raw',
        zone: 'serp_api',
      }),
      this.configService.get<string>('BRIGHTDATA_API_KEY') || '',
      this.configService.get<string>('BRIGHTDATA_SERP_ENDPOINT'),
    );

    const result = (data.organic || []).map((item) => ({
      title: item.title,
      url: item.link,
      description: item.description,
    }));

    return result;
  }

  protected async executeCrawl(url: string): Promise<WebCrawlResponseDto> {
    this.logger.log(`Crawling URL: ${url}`);
    const data = await this.post<BrightdataCrawlResponseDto>(
      JSON.stringify({
        input: [{ url }],
      }),
      this.configService.get<string>('BRIGHTDATA_API_KEY') || '',
      this.configService.get<string>('BRIGHTDATA_CRAWL_ENDPOINT') || '',
    );

    const response = {
      content: data.markdown || data.html2text || '',
      url: data.url,
      title: data.page_title,
      html: data.page_html,
    };

    return response;
  }
}
