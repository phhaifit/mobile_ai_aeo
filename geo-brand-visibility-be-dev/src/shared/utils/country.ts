import { Logger } from '@nestjs/common';
import iso3166 from 'iso-3166-1';
import { DEFAULT_LOCATION } from '../constant';

export class CountryUtil {
  private readonly logger = new Logger(CountryUtil.name);
  /**
   * Convert ISO 3166-1 country code to full country name
   * @param code - Two-letter country code (e.g., 'US', 'VN')
   * @returns Full country name (e.g., 'United States', 'Vietnam') or the original code if conversion fails
   */
  getCountryName(code: string): string {
    try {
      if (code.toLowerCase() === DEFAULT_LOCATION.toLowerCase()) {
        return DEFAULT_LOCATION;
      }
      const country = iso3166.whereAlpha2(code.toUpperCase());
      return country?.country || code;
    } catch (error) {
      this.logger.warn(
        `Failed to convert country code '${code}' to name: ${error}`,
      );
      return code;
    }
  }
}
