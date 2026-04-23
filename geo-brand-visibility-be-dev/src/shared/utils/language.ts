import { Logger } from '@nestjs/common';
import ISO6391 from 'iso-639-1';

export class LanguageUtil {
  private readonly logger = new Logger(LanguageUtil.name);

  /**
   * Convert ISO 639-1 language code to full language name
   * @param code - Two-letter language code (e.g., 'en', 'vi')
   * @returns Full language name (e.g., 'English', 'Vietnamese') or the original code if conversion fails
   */
  getLanguageName(code: string): string {
    try {
      const name = ISO6391.getName(code);
      return name || code;
    } catch (error) {
      this.logger.warn(
        `Failed to convert language code '${code}' to name: ${error}`,
      );
      return code;
    }
  }
}
