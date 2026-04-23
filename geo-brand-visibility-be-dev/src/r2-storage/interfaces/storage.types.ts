export interface UploadOptions {
  buffer: Buffer;
  key: string;
  contentType: string;
  metadata?: Record<string, string>;
}

export interface UploadResult {
  url: string;
  key: string;
}

export interface PresignedUrlOptions {
  key: string;
  contentType: string;
  expiresIn?: number;
}

export interface PresignedUrlResult {
  url: string;
  key: string;
  expiresIn: number;
}

export interface ImageBuffer {
  buffer: Buffer;
  mimeType: string;
}
