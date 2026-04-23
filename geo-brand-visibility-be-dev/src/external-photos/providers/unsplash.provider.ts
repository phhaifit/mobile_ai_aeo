import { Inject, Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import {
  AbstractExternalPhotoProvider,
  PhotoSearchOptions,
} from './photo-provider';
import { ExternalPhotoDto } from '../dtos/external-photo.dto';
import Redis from 'ioredis';
import { REDIS_CACHE_CLIENT } from 'src/shared/constant';

interface UnsplashImage {
  id: string;
  urls: {
    small: string;
    regular: string;
    full: string;
  };
  alt_description: string | null;
  user: {
    name: string;
    username: string;
  };
  description: string | null;
}

interface UnsplashSearchResponse {
  results: UnsplashImage[];
  total: number;
  total_pages: number;
}

@Injectable()
export class UnsplashPhotoProvider extends AbstractExternalPhotoProvider {
  protected readonly logger = new Logger(UnsplashPhotoProvider.name);
  private readonly accessKey: string;
  private readonly apiBaseUrl = 'https://api.unsplash.com';

  constructor(
    @Inject(REDIS_CACHE_CLIENT) redisClient: Redis,
    private readonly configService: ConfigService,
  ) {
    super(redisClient);
    this.accessKey =
      this.configService.get<string>('UNSPLASH_ACCESS_KEY') || '';
    if (!this.accessKey) {
      this.logger.warn('UNSPLASH_ACCESS_KEY not configured');
    }
  }

  private async get<T>(
    apiKey: string,
    apiUrl: string = `${this.apiBaseUrl}/search/photos`,
  ): Promise<T> {
    try {
      const response = await fetch(apiUrl, {
        method: 'GET',
        headers: {
          Authorization: `Client-ID ${apiKey}`,
          'Accept-Version': 'v1',
        },
      });
      this.logger.debug('Unsplash response received', response);

      if (!response.ok) {
        throw new Error(`Fetch failed with status: ${response.status}`);
      }
      const data = (await response.json()) as T;
      return data;
    } catch (error) {
      this.logger.error('Error fetching data from Unsplash:', error);
      throw error;
    }
  }

  protected async executeSearchPhotos(
    query: string,
    options: PhotoSearchOptions,
  ): Promise<ExternalPhotoDto[]> {
    const { page, perPage } = options;

    try {
      const url = `${this.apiBaseUrl}/search/photos?query=${encodeURIComponent(query)}&page=${page}&per_page=${perPage}`;

      const data = await this.get<UnsplashSearchResponse>(this.accessKey, url);

      const uniquePhotos = Array.from(
        new Map(
          data.results.map((img) => [img.id, this.mapToExternalPhoto(img)]),
        ).values(),
      );

      return uniquePhotos;
    } catch (error) {
      this.logger.error(
        `Failed to search photos from Unsplash: ${error.message}`,
        error.stack,
      );
      throw new Error('Failed to fetch images from Unsplash');
    }
  }

  private mapToExternalPhoto(image: UnsplashImage): ExternalPhotoDto {
    return {
      id: image.id,
      smallUrl: image.urls.small,
      regularUrl: image.urls.regular,
      fullUrl: image.urls.full,
      altDescription: image.alt_description,
      photographer: {
        name: image.user.name,
        username: image.user.username,
      },
      description: image.description,
    };
  }
}
