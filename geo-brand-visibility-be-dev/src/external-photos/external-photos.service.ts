import { Injectable } from '@nestjs/common';
import { AbstractExternalPhotoProvider } from './providers/photo-provider';
import { ExternalPhotoDto } from './dtos/external-photo.dto';
import { SearchPhotosDto } from './dtos/search-photos.dto';

@Injectable()
export class ExternalPhotosService {
  constructor(
    private readonly externalPhotoProvider: AbstractExternalPhotoProvider,
  ) {}

  async searchPhotos(searchDto: SearchPhotosDto): Promise<ExternalPhotoDto[]> {
    return this.externalPhotoProvider.searchPhotos(searchDto.query, {
      page: searchDto.page,
      perPage: searchDto.perPage,
    });
  }
}
