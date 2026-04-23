import { Controller, Get, Query, UseGuards } from '@nestjs/common';
import { ExternalPhotosService } from './external-photos.service';
import { SearchPhotosDto } from './dtos/search-photos.dto';
import { ExternalPhotoDto } from './dtos/external-photo.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('external-photos')
@UseGuards(JwtAuthGuard)
export class ExternalPhotosController {
  constructor(private readonly externalPhotosService: ExternalPhotosService) {}

  @Get('search')
  async searchPhotos(
    @Query() searchDto: SearchPhotosDto,
  ): Promise<ExternalPhotoDto[]> {
    return this.externalPhotosService.searchPhotos(searchDto);
  }
}
