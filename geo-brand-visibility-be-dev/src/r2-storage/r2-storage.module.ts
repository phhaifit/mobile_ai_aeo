import { Module } from '@nestjs/common';
import { R2StorageService } from './r2-storage.service';
import { FileStorageHelper } from './file-storage.helper';
import { TokenModule } from '../token/token.module';
import { UserModule } from '../user/user.module';

@Module({
  imports: [TokenModule, UserModule],
  providers: [R2StorageService, FileStorageHelper],
  exports: [R2StorageService, FileStorageHelper],
})
export class R2StorageModule {}
