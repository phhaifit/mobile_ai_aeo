import { Module } from '@nestjs/common';
import { ExternalPhotosController } from './external-photos.controller';
import { ExternalPhotosService } from './external-photos.service';
import { UnsplashPhotoProvider } from './providers/unsplash.provider';
import { TokenModule } from 'src/token/token.module';
import { UserModule } from 'src/user/user.module';
import { AbstractExternalPhotoProvider } from './providers/photo-provider';

@Module({
  imports: [TokenModule, UserModule],
  controllers: [ExternalPhotosController],
  providers: [
    ExternalPhotosService,
    {
      provide: AbstractExternalPhotoProvider,
      useClass: UnsplashPhotoProvider,
    },
  ],
  exports: [ExternalPhotosService],
})
export class ExternalPhotosModule {}
