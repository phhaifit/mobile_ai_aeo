import { Inject, Logger } from '@nestjs/common';
import { ExternalPhotoDto } from '../dtos/external-photo.dto';
import { PHOTO_SEARCH_REDIS_CACHE_TTL } from '../constant';
import { REDIS_CACHE_CLIENT } from 'src/shared/constant';
import Redis from 'ioredis/built/Redis';

export interface PhotoSearchOptions {
  page: number;
  perPage: number;
}

export abstract class AbstractExternalPhotoProvider {
  protected abstract readonly logger: Logger;

  constructor(
    @Inject(REDIS_CACHE_CLIENT) protected readonly redisClient: Redis,
  ) {}

  async searchPhotos(
    query: string,
    options: PhotoSearchOptions,
  ): Promise<ExternalPhotoDto[]> {
    let cacheKey = `external_photos`;

    if (options) {
      cacheKey += `:page:${options.page || 1}:perPage:${options.perPage || 30}`;
    }

    cacheKey += `:query:${query}`.replaceAll(' ', '-');

    try {
      const cachedResult = await this.redisClient.get(cacheKey);
      if (cachedResult) {
        this.logger.log(`Cache HIT for query: ${query}`);
        return JSON.parse(cachedResult) as ExternalPhotoDto[];
      }
    } catch (error) {
      this.logger.error(`Cache GET failed for key: ${cacheKey}`, error);
    }

    this.logger.log(`Cache MISS for query: ${query}. Executing search.`);
    const photos = await this.executeSearchPhotos(query, options);

    try {
      await this.redisClient.setex(
        cacheKey,
        PHOTO_SEARCH_REDIS_CACHE_TTL,
        JSON.stringify(photos),
      );
      this.logger.log(`Cache SET successful for key: ${cacheKey}`);
    } catch (error) {
      this.logger.error(`Cache SET failed for key: ${cacheKey}`, error);
    }

    return photos;
  }

  protected abstract executeSearchPhotos(
    query: string,
    options: PhotoSearchOptions,
  ): Promise<ExternalPhotoDto[]>;
}
