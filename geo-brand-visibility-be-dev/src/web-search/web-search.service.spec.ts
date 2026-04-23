import { Test, TestingModule } from '@nestjs/testing';
import { WebSearchService } from './web-search.service';
import { AbstractWebSearchProvider } from './providers/base-search.provider';

describe('WebSearchService', () => {
  let service: WebSearchService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        WebSearchService,
        {
          provide: AbstractWebSearchProvider,
          useValue: {
            search: jest.fn(),
            crawl: jest.fn(),
          },
        },
      ],
    }).compile();

    service = module.get<WebSearchService>(WebSearchService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
