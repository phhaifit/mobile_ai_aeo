import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { OcrResponseDto } from './dtos/ocr-response.dto';
import { OcrStatus } from './enums';

const OCR_API_ENDPOINT = 'https://api.ocr.space/parse/image';
const OCR_ENGINE = 2;
const FALLBACK_OCR_ENGINE = 1;
type OcrResult = {
  status: OcrStatus;
  text?: string;
};

@Injectable()
export class OcrService {
  private readonly logger = new Logger(OcrService.name);
  private readonly apiKey: string;

  constructor(private readonly configService: ConfigService) {
    this.apiKey = this.configService.get<string>('OCR_SPACE_API_KEY') || '';

    if (!this.apiKey) {
      this.logger.warn(
        'OCR_SPACE_API_KEY is not configured. OCR features will not function properly.',
      );
    }
  }

  async ocrImageFromUrl(imageUrl: string): Promise<OcrResult> {
    this.logger.log(`OCR image from URL: ${imageUrl}`);
    return this.parse({ url: imageUrl, filetype: undefined });
  }

  // Planned-feature: read user's input document for generating content
  async ocrPdfFromUrl(pdfUrl: string): Promise<OcrResult> {
    this.logger.log(`OCR PDF from URL: ${pdfUrl}`);
    return this.parse({ url: pdfUrl, filetype: 'PDF' });
  }

  private async parse(options: {
    url: string;
    filetype?: string;
  }): Promise<OcrResult> {
    const result = await this.parseWithEngine(options, OCR_ENGINE);

    if (result.status !== OcrStatus.ERROR) {
      return result;
    }

    this.logger.warn(
      `OCR engine ${OCR_ENGINE} failed for ${options.url}, retrying with fallback engine ${FALLBACK_OCR_ENGINE}`,
    );

    const fallbackResult = await this.parseWithEngine(
      options,
      FALLBACK_OCR_ENGINE,
    );
    return fallbackResult;
  }

  private async parseWithEngine(
    options: { url: string; filetype?: string },
    engine: number,
  ): Promise<OcrResult> {
    const body = new URLSearchParams();
    body.set('url', options.url);
    body.set('OCREngine', String(engine));
    body.set('isOverlayRequired', 'false');
    body.set('detectOrientation', 'true');
    body.set('scale', 'true');

    if (engine === OCR_ENGINE) {
      body.set('language', 'auto');
    } else {
      body.set('language', 'eng');
    }

    if (options.filetype) {
      body.set('filetype', options.filetype);
    }

    try {
      const response = await fetch(OCR_API_ENDPOINT, {
        method: 'POST',
        headers: {
          apikey: this.apiKey,
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body.toString(),
        signal: AbortSignal.timeout(60_000),
      });

      if (!response.ok) {
        this.logger.warn(
          `OCR HTTP error (engine ${engine}) for ${options.url}: ${response.status} ${response.statusText}`,
        );
        return { status: OcrStatus.ERROR };
      }

      const data = (await response.json()) as OcrResponseDto;

      if (data.IsErroredOnProcessing) {
        this.logger.warn(
          `OCR processing error (engine ${engine}) for ${options.url}: ${data.ErrorMessage}`,
        );
        return { status: OcrStatus.ERROR };
      }

      if (!data.ParsedResults?.length) {
        this.logger.warn(
          `OCR returned no parsed results (engine ${engine}) for ${options.url}`,
        );
        return { status: OcrStatus.NO_TEXT };
      }

      const text = data.ParsedResults.map((r) => r.ParsedText ?? '')
        .join('\n')
        .trim();

      this.logger.log(
        `OCR completed (engine ${engine}) for ${options.url} in ${data.ProcessingTimeInMilliseconds}ms`,
      );

      return text
        ? { status: OcrStatus.TEXT, text }
        : { status: OcrStatus.NO_TEXT };
    } catch (error) {
      this.logger.error(
        `OCR request failed (engine ${engine}) for ${options.url}: ${(error as Error)?.message}`,
      );
      return { status: OcrStatus.ERROR };
    }
  }
}
