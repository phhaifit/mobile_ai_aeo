import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsOptional, IsEnum, IsNumber } from 'class-validator';
import { ContentAssetType } from '../enums';
import { Type } from 'class-transformer';

export class ImageMetadata {
  @ApiProperty({
    description: 'Original image URL from reference content',
    example: 'https://example.com/image.jpg',
  })
  @IsString()
  sourceUrl: string;

  @ApiProperty({
    description:
      'Original URL string as it appeared in the source (e.g., markdown). Useful when the source used relative URLs.',
    example: '/images/hero.jpg',
    required: false,
  })
  @IsString()
  @IsOptional()
  originalUrl?: string;

  @ApiProperty({
    description: 'Alt text for the image',
    example: 'Person using AI technology',
    required: false,
  })
  @IsString()
  @IsOptional()
  altText?: string;

  @ApiProperty({
    description: 'Caption for the image',
    example: 'AI technology in action',
    required: false,
  })
  @IsString()
  @IsOptional()
  caption?: string;

  @ApiProperty({
    description: 'Context/section where image appears',
    example: 'Introduction section',
    required: false,
  })
  @IsString()
  @IsOptional()
  context?: string;
}

export class UploadImageDto {
  @ApiProperty({
    description: 'Original image URL to download and upload',
    example: 'https://example.com/image.jpg',
  })
  @IsString()
  sourceUrl: string;

  @ApiProperty({
    description: 'Type of content asset (e.g., IMAGE, THUMBNAIL)',
    example: 'IMAGE',
    required: false,
  })
  @IsEnum(ContentAssetType)
  @IsOptional()
  type?: ContentAssetType;
}

export class GetPresignedUrlDto {
  @IsString()
  filename: string;

  @IsOptional()
  @IsString()
  contentType?: string = 'image/jpeg';

  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  expiresIn?: number = 600;

  @IsOptional()
  @IsEnum(ContentAssetType)
  type?: ContentAssetType;
}

export class PresignedUrlResponseDto {
  @ApiProperty({
    description: 'Presigned URL for uploading image',
    example: 'https://app.aeo.how/upload/...',
  })
  url: string;

  @ApiProperty({
    description: 'Key/path for the uploaded file',
    example: 'images/2026/02/image-uuid.jpg',
  })
  key: string;

  @ApiProperty({
    description: 'Expiration time in seconds',
    example: 600,
  })
  expiresIn: number;
}

export class ImageUploadResponseDto {
  @ApiProperty({
    description: 'Public URL of the uploaded image',
    example: 'https://app.aeo.how/images/2026/02/image-uuid.jpg',
  })
  url: string;

  @ApiProperty({
    description: 'Key/path of the uploaded file',
    example: 'images/2026/02/image-uuid.jpg',
  })
  key: string;
}

export class ThumbnailDto extends ImageUploadResponseDto {}
