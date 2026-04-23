import { BadRequestException, Injectable, Logger } from '@nestjs/common';
import { v4 as uuidv4 } from 'uuid';
import * as path from 'path';
import { R2StorageService } from './r2-storage.service';
import { StoragePathStrategy } from './interfaces/storage-path.strategy';
import { UploadResult } from './interfaces/storage.types';

@Injectable()
export class FileStorageHelper {
  private readonly logger = new Logger(FileStorageHelper.name);

  constructor(private readonly r2StorageService: R2StorageService) {}

  /**
   * Download an image from a URL and upload to storage
   *
   * @param sourceUrl URL to download from
   * @param pathStrategy Strategy for generating storage path
   * @param context Optional context (e.g., contentId, userId)
   * @returns Upload result
   */
  async downloadAndUpload(
    sourceUrl: string,
    pathStrategy: StoragePathStrategy,
    context: string,
  ): Promise<UploadResult> {
    this.logger.log(`Downloading image from: ${sourceUrl}`);

    try {
      const response = await fetch(new URL(sourceUrl).toString());
      if (!response.ok) {
        throw new BadRequestException(
          `Failed to download image from ${sourceUrl}`,
        );
      }

      const arrayBuffer = await response.arrayBuffer();
      const buffer = Buffer.from(arrayBuffer);

      const contentType = response.headers.get('content-type') || 'image/jpeg';
      if (!contentType?.startsWith('image/')) {
        throw new BadRequestException(`Not an image`);
      }

      const extension = this.getExtensionFromContentType(contentType);
      const filename = `${uuidv4()}${extension}`;
      const key = pathStrategy.generatePath(filename, context);

      return await this.r2StorageService.upload({
        buffer,
        key,
        contentType,
      });
    } catch (error) {
      this.logger.error(
        `Error downloading and uploading image: ${error.message}`,
      );
      throw new BadRequestException(
        `Failed to process image: ${error.message}`,
      );
    }
  }

  /**
   * Generate a presigned URL with path strategy
   *
   * @param filename Original filename
   * @param pathStrategy Strategy for generating storage path
   * @param contentType MIME type
   * @param context Optional context
   * @param expiresIn Expiration in seconds
   * @returns Presigned URL result
   */
  async generatePresignedUrl(
    filename: string,
    pathStrategy: StoragePathStrategy,
    contentType: string,
    context: string,
    expiresIn: number = 600,
  ) {
    const extension =
      path.extname(filename) || this.getExtensionFromContentType(contentType);
    const uniqueFilename = `${uuidv4()}${extension}`;
    const key = pathStrategy.generatePath(uniqueFilename, context);

    return await this.r2StorageService.generatePresignedUrl({
      key,
      contentType,
      expiresIn,
    });
  }

  getExtensionFromContentType(contentType: string): string {
    const mimeMap: Record<string, string> = {
      'image/jpeg': '.jpg',
      'image/jpg': '.jpg',
      'image/png': '.png',
      'image/gif': '.gif',
      'image/webp': '.webp',
      'image/svg+xml': '.svg',
    };

    return mimeMap[contentType.toLowerCase()] || '.jpg';
  }
}
