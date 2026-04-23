// Allows different modules to define their own folder structures
export interface StoragePathStrategy {
  /**
   * Generate a storage key/path for a file
   * @param filename The filename to store
   * @param context Optional context (e.g., entityId, userId, contentId) for path generation
   * @returns The full storage path/key
   */
  generatePath(filename: string, context: string): string;
}

/**
 * Content-specific path strategy
 * Pattern: contents/{contentId}/{filename}
 */
export class ContentPathStrategy implements StoragePathStrategy {
  generatePath(filename: string, contentId: string): string {
    if (!contentId || contentId.trim() === '') {
      throw new Error('contentId is required for ContentPathStrategy');
    }
    return `contents/${contentId}/${filename}`;
  }
}

export class ThumbnailPathStrategy implements StoragePathStrategy {
  generatePath(filename: string, contentId: string): string {
    if (!contentId || contentId.trim() === '') {
      throw new Error('contentId is required for ThumbnailPathStrategy');
    }

    return `thumbnails/${contentId}/${filename}`;
  }
}
