import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import {
  S3Client,
  PutObjectCommand,
  GetObjectCommand,
  HeadObjectCommand,
  DeleteObjectCommand,
  ListObjectsV2Command,
  DeleteObjectsCommand,
} from '@aws-sdk/client-s3';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';
import {
  UploadOptions,
  UploadResult,
  PresignedUrlOptions,
  PresignedUrlResult,
} from './interfaces/storage.types';
import { Response } from 'express';
import { ImageBuffer } from './interfaces/storage.types';

@Injectable()
export class R2StorageService {
  private readonly logger = new Logger(R2StorageService.name);
  private readonly s3Client: S3Client;
  private readonly bucketName: string;
  private readonly publicDomain: string;

  constructor(private readonly configService: ConfigService) {
    const accountId = this.configService.get<string>('CLOUDFLARE_ACCOUNT_ID');
    const accessKeyId = this.configService.get<string>('R2_ACCESS_KEY_ID');
    const secretAccessKey = this.configService.get<string>(
      'R2_SECRET_ACCESS_KEY',
    );
    this.publicDomain =
      this.configService.get<string>('R2_BUCKET_PUBLIC_URL') ||
      'https://img.aeo.how';
    this.bucketName =
      this.configService.get<string>('R2_BUCKET_NAME') || 'aeo-storage';

    if (!accountId || !accessKeyId || !secretAccessKey) {
      this.logger.warn(
        'R2 credentials not configured. R2 storage will not function properly.',
      );
    }

    this.s3Client = new S3Client({
      region: 'auto',
      endpoint: `https://${accountId}.r2.cloudflarestorage.com`,
      credentials: {
        accessKeyId: accessKeyId || '',
        secretAccessKey: secretAccessKey || '',
      },
      requestChecksumCalculation: 'WHEN_REQUIRED',
      responseChecksumValidation: 'WHEN_REQUIRED',
    });
  }

  async upload(options: UploadOptions): Promise<UploadResult> {
    this.logger.log(`Uploading to R2 with key: ${options.key}`);

    const command = new PutObjectCommand({
      Bucket: this.bucketName,
      Key: options.key,
      Body: options.buffer,
      ContentType: options.contentType,
      Metadata: options.metadata,
    });

    await this.s3Client.send(command);
    const url = this.getPublicUrl(options.key);

    this.logger.log(`Successfully uploaded to: ${url}`);

    return { url, key: options.key };
  }

  async generatePresignedUrl(
    options: PresignedUrlOptions,
  ): Promise<PresignedUrlResult> {
    this.logger.log(`Generating presigned URL for key: ${options.key}`);

    const command = new PutObjectCommand({
      Bucket: this.bucketName,
      Key: options.key,
      ContentType: options.contentType,
    });

    const url = await getSignedUrl(this.s3Client, command, {
      expiresIn: options.expiresIn || 600,
    });

    return {
      url,
      key: options.key,
      expiresIn: options.expiresIn || 600,
    };
  }

  async getObject(key: string): Promise<ImageBuffer> {
    this.logger.log(`Retrieving object from R2: ${key}`);

    const command = new GetObjectCommand({
      Bucket: this.bucketName,
      Key: key,
    });

    const response = await this.s3Client.send(command);
    const chunks: Uint8Array[] = [];

    for await (const chunk of response.Body as any) {
      chunks.push(chunk);
    }

    return {
      buffer: Buffer.concat(chunks),
      mimeType: response.ContentType || 'application/octet-stream',
    };
  }

  async streamObject(key: string, res: Response): Promise<void> {
    this.logger.log(`Streaming object from R2: ${key}`);

    const command = new GetObjectCommand({
      Bucket: this.bucketName,
      Key: key,
    });

    const response = await this.s3Client.send(command);

    if (!response.Body) {
      throw new Error('Empty object body');
    }

    (response.Body as NodeJS.ReadableStream).pipe(res);
  }

  async objectExists(key: string): Promise<boolean> {
    try {
      const command = new HeadObjectCommand({
        Bucket: this.bucketName,
        Key: key,
      });

      await this.s3Client.send(command);
      return true;
    } catch (error) {
      return false;
    }
  }

  async deleteObject(key: string): Promise<void> {
    this.logger.log(`Deleting object from R2: ${key}`);

    const command = new DeleteObjectCommand({
      Bucket: this.bucketName,
      Key: key,
    });

    await this.s3Client.send(command);
    this.logger.log(`Successfully deleted: ${key}`);
  }

  async deleteByPrefix(prefix: string): Promise<number> {
    this.logger.log(`Deleting all objects with prefix: ${prefix}`);

    const listCommand = new ListObjectsV2Command({
      Bucket: this.bucketName,
      Prefix: prefix,
    });

    const listResponse = await this.s3Client.send(listCommand);

    if (!listResponse.Contents || listResponse.Contents.length === 0) {
      this.logger.log(`No objects found with prefix: ${prefix}`);
      return 0;
    }

    const objectsToDelete = listResponse.Contents.map((obj) => ({
      Key: obj.Key,
    }));

    const deleteCommand = new DeleteObjectsCommand({
      Bucket: this.bucketName,
      Delete: {
        Objects: objectsToDelete,
      },
    });

    await this.s3Client.send(deleteCommand);
    this.logger.log(
      `Deleted ${objectsToDelete.length} objects with prefix: ${prefix}`,
    );

    return objectsToDelete.length;
  }

  getPublicUrl(key: string): string {
    return `${this.publicDomain}/${key}`;
  }
}
