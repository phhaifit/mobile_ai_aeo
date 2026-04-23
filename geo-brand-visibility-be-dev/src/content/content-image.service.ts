import { Injectable, Logger, Inject, forwardRef } from '@nestjs/common';
import { FileStorageHelper } from '../r2-storage/file-storage.helper';
import { R2StorageService } from '../r2-storage/r2-storage.service';
import {
  ContentPathStrategy,
  StoragePathStrategy,
} from '../r2-storage/interfaces/storage-path.strategy';
import { extractImagesFromMarkdown } from '../utils/markdown-image-extractor.util';
import { ImageMetadata } from './dto/image-metadata.dto';
import { ContentService } from './content.service';
import { OcrService } from '../ocr/ocr.service';
import { Response } from 'express';
import { distance } from 'fastest-levenshtein';
import { parse } from 'tldts';
import { OcrStatus } from 'src/ocr/enums';
import { ThumbnailPathStrategy } from '../r2-storage/interfaces/storage-path.strategy';
import { ContentAssetType } from './enums';
import { UploadResult } from 'src/r2-storage/interfaces/storage.types';

type Action =
  | { type: 'replace'; urls: string[]; r2Url: string; sourceUrl: string }
  | { type: 'remove'; urls: string[] };

@Injectable()
export class ContentImageService {
  private readonly logger = new Logger(ContentImageService.name);
  private readonly pathStrategy = new ContentPathStrategy();
  private readonly thumbnailPathStrategy = new ThumbnailPathStrategy();
  private static readonly WATERMARK_DOMAINS = new Set([
    'shutterstock',
    'gettyimages',
    'alamy',
    'dreamstime',
    'depositphotos',
    '123rf',
    'istockphoto',
    'adobestock',
  ]);
  private static readonly WATERMARK_KEYWORDS = [
    'watermark',
    'shutterstock',
    'getty images',
    'istock',
    'dreamstime',
    '123rf',
    'depositphotos',
    'alamy',
    'adobe stock',
  ];

  constructor(
    private readonly fileStorageHelper: FileStorageHelper,
    private readonly r2StorageService: R2StorageService,
    @Inject(forwardRef(() => ContentService))
    private readonly contentService: ContentService,
    private readonly ocrService: OcrService,
  ) {}

  // Internal method to delete all images for a content item
  async deleteContentImages(contentId: string): Promise<number> {
    const prefix = this.pathStrategy.generatePath('', contentId);
    return await this.r2StorageService.deleteByPrefix(prefix);
  }

  private getPathStrategy(type: ContentAssetType): StoragePathStrategy {
    switch (type) {
      case ContentAssetType.THUMBNAIL:
        return this.thumbnailPathStrategy;
      case ContentAssetType.IMAGE:
      default:
        return this.pathStrategy;
    }
  }

  async uploadImageFromUrl(
    contentId: string,
    userId: string,
    sourceUrl: string,
    type: ContentAssetType = ContentAssetType.IMAGE,
  ): Promise<any> {
    const content = await this.contentService.verifyContentAccess(
      contentId,
      userId,
    );

    const pathStrategy = this.getPathStrategy(type);

    return await this.fileStorageHelper.downloadAndUpload(
      sourceUrl,
      pathStrategy,
      content.id,
    );
  }

  async generatePresignedUrlForContent(
    contentId: string,
    userId: string,
    filename: string,
    contentType: string = 'image/jpeg',
    expiresIn: number = 600,
    type: ContentAssetType = ContentAssetType.IMAGE,
  ): Promise<any> {
    const content = await this.contentService.verifyContentAccess(
      contentId,
      userId,
    );

    const pathStrategy = this.getPathStrategy(type);

    return await this.fileStorageHelper.generatePresignedUrl(
      filename,
      pathStrategy,
      contentType,
      content.id,
      expiresIn,
    );
  }

  async deleteContentImage(
    contentId: string,
    userId: string,
    key: string,
  ): Promise<void> {
    await this.contentService.verifyContentAccess(contentId, userId);

    await this.r2StorageService.deleteObject(key);
  }

  async streamImageForDownload(
    contentId: string,
    userId: string,
    key: string,
    res: Response,
  ): Promise<void> {
    await this.contentService.verifyContentAccess(contentId, userId);

    await this.r2StorageService.streamObject(key, res);
  }

  private escapeRegex(text: string): string {
    return text.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  }

  private removeMarkdownImages(body: string, urls: string[]): string {
    if (!urls || urls.length === 0) return body;

    const escapedUrls = urls
      .filter(Boolean)
      .map((url) => this.escapeRegex(url));

    const pattern = new RegExp(
      `!\\[[^\\]]*\\]\\((?:${escapedUrls.join('|')})(?:\\s+"[^"]*")?\\)`,
      'g',
    );

    return body.replace(pattern, '');
  }

  private async processImage(image: ImageMetadata, contentId: string) {
    const urlCandidates = Array.from(
      new Set([image.originalUrl, image.sourceUrl].filter(Boolean)),
    ) as string[];

    try {
      const ocrResult = await this.ocrService.ocrImageFromUrl(image.sourceUrl);

      if (
        ocrResult.status === OcrStatus.ERROR ||
        (ocrResult.text &&
          this.hasBrandedWatermark(ocrResult.text, image.sourceUrl))
      ) {
        return { type: 'remove', urls: urlCandidates } as Action;
      }

      this.logger.log(`Uploading image: ${image.sourceUrl}`);

      const result = await this.fileStorageHelper.downloadAndUpload(
        image.sourceUrl,
        this.pathStrategy,
        contentId,
      );

      return {
        type: 'replace',
        urls: urlCandidates,
        r2Url: result.url,
        sourceUrl: image.sourceUrl,
      } as Action;
    } catch (error) {
      this.logger.error(
        `Unexpected error processing image ${image.sourceUrl}: ${(error as Error)?.message}`,
      );

      return { type: 'remove', urls: urlCandidates } as Action;
    }
  }

  private applyActionsToBody(body: string, actions: Action[]): string {
    const replaceMap: Record<string, string> = {};
    const removeUrls: string[] = [];

    for (const action of actions) {
      if (action.type === 'replace') {
        for (const url of action.urls) {
          replaceMap[url] = action.r2Url;
        }
      }

      if (action.type === 'remove') {
        removeUrls.push(...action.urls);
      }
    }

    let updatedBody = body;

    if (removeUrls.length > 0) {
      const uniqueRemoveUrls = Array.from(new Set(removeUrls));
      updatedBody = this.removeMarkdownImages(updatedBody, uniqueRemoveUrls);
    }

    const replaceUrls = Object.keys(replaceMap);

    if (replaceUrls.length > 0) {
      const pattern = new RegExp(
        replaceUrls.map((u) => this.escapeRegex(u)).join('|'),
        'g',
      );

      updatedBody = updatedBody.replace(pattern, (match) => {
        return replaceMap[match] ?? match;
      });
    }
    return updatedBody;
  }

  async processMarkdownImages(
    body: string,
    contentId: string,
    pageUrl: string,
  ): Promise<{ updatedBody: string; thumbnail?: UploadResult }> {
    const images = extractImagesFromMarkdown(body, pageUrl);

    if (!images?.length) {
      this.logger.log(`No images found in content body`);
      return { updatedBody: body };
    }

    this.logger.log(`Found ${images.length} images to process`);

    const actions = await Promise.all(
      images.map((image) => this.processImage(image, contentId)),
    );

    const firstValid = actions.find((a) => a.type === 'replace');

    let thumbnailResult: UploadResult | undefined;

    if (firstValid) {
      try {
        thumbnailResult = await this.fileStorageHelper.downloadAndUpload(
          firstValid.sourceUrl,
          this.thumbnailPathStrategy,
          contentId,
        );
      } catch (error) {
        this.logger.error(
          `Failed to upload thumbnail: ${(error as Error).message}`,
        );
      }
    }

    const updatedBody = this.applyActionsToBody(body, actions);

    return { updatedBody, thumbnail: thumbnailResult };
  }

  filterContentImages(
    images: ImageMetadata[],
    markdownContent: string,
  ): ImageMetadata[] {
    if (!images || images.length === 0) return [];
    const contentLength = markdownContent.length;

    // Exclude images in first 15% (likely header/navigation)
    // and last 10% (likely footer) of content
    const startThreshold = contentLength * 0.15;
    const endThreshold = contentLength * 0.9;

    // Patterns that match both path segments (/logo/) and filenames (logo_black.webp)
    const excludePatterns = [
      /[\/._-]logo[s]?[\/._-]/i,
      /[\/._-]icon[s]?[\/._-]/i,
      /[\/._-]nav[igation]?[\/._-]/i,
      /[\/._-]menu[s]?[\/._-]/i,
      /[\/._-]header[s]?[\/._-]/i,
      /[\/._-]footer[s]?[\/._-]/i,
      /[\/._-]sidebar[s]?[\/._-]/i,
      /[\/._-]widget[s]?[\/._-]/i,
      /[\/._-]banner[s]?[\/._-]/i,
      /[\/._-]ad[s]?[\/._-]/i,
      /favicon/i,
      /[\/._-]avatar[s]?[\/._-]/i,
      /[\/._-]profile[s]?[\/._-]/i,
      /[\/._-]thumb[s]?[\/._-]/i,
      /[\/._-]thumbnail[s]?[\/._-]/i,
      /[\/._-]social[s]?[\/._-]/i,
      /[\/._-]brand[ing]?[\/._-]/i,
      /[\/._-]ui[s]?[\/._-]/i,
      /[\/._-]button[s]?[\/._-]/i,
      /[\/._-]sprite[s]?[\/._-]/i,
      /\/author[s]?\//i,
      /\.svg$/i,
    ];

    return images.filter((image) => {
      if (excludePatterns.some((pattern) => pattern.test(image.sourceUrl))) {
        console.warn('[Image Filtered][UI]', image.sourceUrl);
        return false;
      }

      // Check if image appears in main content area
      const imagePattern = new RegExp(
        `!\\[[^\\]]*\\]\\(${image.sourceUrl.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')}\\)`,
      );
      const match = markdownContent.match(imagePattern);

      if (!match) {
        // Position unknown — only keep if alt text suggests content image
        if (
          image.altText &&
          image.altText.length > 10 &&
          !/logo|icon|avatar|author|profile/i.test(image.altText)
        ) {
          console.info(
            '[Image Kept][Position Unknown - has alt]',
            image.sourceUrl,
          );
          return true;
        }
        console.warn(
          '[Image Filtered][Position Unknown - no useful alt]',
          image.sourceUrl,
        );
        return false;
      }

      const imagePosition = match.index || 0;

      if (imagePosition < startThreshold || imagePosition > endThreshold) {
        return false;
      }

      console.info('[Image Kept][Content]', {
        url: image.sourceUrl,
        altText: image.altText,
      });

      return true;
    });
  }

  private normalizeText(text: string): string {
    return text
      .toLowerCase()
      .replace(/đ/g, 'd')
      .normalize('NFD')
      .replace(/[\u0300-\u036f]/g, '')
      .replace(/[^a-z0-9\s]/g, '')
      .trim();
  }

  private matchSubstringOrFuzzy(text: string, target: string): boolean {
    if (text.includes(target)) return true;

    let chunk = '',
      _distance = 0,
      similarity = 1;
    const windowSize = target.length;
    for (let i = 0; i <= text.length - windowSize; i++) {
      chunk = text.slice(i, i + windowSize);
      _distance = distance(chunk, target);
      similarity = 1 - _distance / windowSize;

      if (similarity >= 0.7) {
        console.log(
          `[Fuzzy Match] - Text: ${text}, Target: ${target}, Similarity: ${similarity}`,
        );
        return true;
      }
    }

    return false;
  }

  private hasBrandedWatermark(ocrText: string, imageUrl: string): boolean {
    const normalizedOCR = this.normalizeText(ocrText);
    const normalizedOCRNoSpace = normalizedOCR.replace(/\s+/g, '');
    console.log(
      `Normalized OCR Text: ${normalizedOCRNoSpace} and with space: ${normalizedOCR}`,
    );

    let brand = '';

    try {
      const parsed = parse(imageUrl);
      brand = parsed.domainWithoutSuffix ?? '';
    } catch {
      return false;
    }

    brand = this.normalizeText(brand);

    if (!brand || brand.length <= 2) return false;

    if (ContentImageService.WATERMARK_DOMAINS.has(brand)) {
      console.debug(`[Branded Watermark Detected][Layer 0] - Domain: ${brand}`);
      return true;
    }

    for (const keyword of ContentImageService.WATERMARK_KEYWORDS) {
      if (
        normalizedOCRNoSpace.includes(
          this.normalizeText(keyword).replace(/\s+/g, ''),
        )
      ) {
        console.debug(
          `[Branded Watermark Detected][Layer 1] - Keyword: ${keyword}`,
        );
        return true;
      }
    }

    return this.matchSubstringOrFuzzy(normalizedOCRNoSpace, brand);
  }
}
