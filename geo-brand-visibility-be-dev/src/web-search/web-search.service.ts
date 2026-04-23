import { Injectable, Logger } from '@nestjs/common';
import { AbstractWebSearchProvider } from './providers/base-search.provider';
import {
  WebSearchResponseDto,
  WebCrawlResponseDto,
} from './dtos/web-search-response.dto';
import { SearchOptionDto } from './dtos/search-option.dto';

@Injectable()
export class WebSearchService {
  private readonly logger = new Logger(WebSearchService.name);

  constructor(private readonly provider: AbstractWebSearchProvider) {}

  async search(
    query: string,
    option?: SearchOptionDto,
  ): Promise<WebSearchResponseDto[]> {
    this.logger.log(`Searching with query: ${query}`);
    return await this.provider.search(query, option);
  }

  async crawl(url: string): Promise<WebCrawlResponseDto> {
    this.logger.log(`Crawling URL: ${url}`);
    return await this.provider.crawl(url);
  }
}
