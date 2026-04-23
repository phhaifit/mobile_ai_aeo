import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

export interface CloudflareCustomHostnameResponse {
  success: boolean;
  result?: {
    id: string;
    hostname: string;
    status: string;
    ssl?: {
      status: string;
      method: string;
      type: string;
    };
    ownership_verification?: {
      name: string;
      type: string;
      value: string;
    };
    created_at?: string;
  };
  errors?: Array<{
    code: number;
    message: string;
  }>;
}

export interface CloudflareHostnameStatusResponse {
  success: boolean;
  result?: {
    id: string;
    hostname: string;
    status: 'active' | 'pending' | 'moved' | 'deleted';
    ssl?: {
      status: string;
    };
  };
  errors?: Array<{
    code: number;
    message: string;
  }>;
}

export interface CloudflareDeleteResponse {
  success: boolean;
  result?: {
    id: string;
  };
  errors?: Array<{
    code: number;
    message: string;
  }>;
}

@Injectable()
export class CloudflareService {
  private readonly logger = new Logger(CloudflareService.name);
  private readonly baseUrl = 'https://api.cloudflare.com/client/v4';

  constructor(private readonly configService: ConfigService) {}

  private getZoneId(): string {
    return (
      this.configService.get<string>('CLOUDFLARE_ZONE_ID') ||
      'mock_zone_id_12345'
    );
  }

  private getApiToken(): string {
    return (
      this.configService.get<string>('CLOUDFLARE_API_TOKEN') ||
      'mock_api_token_67890'
    );
  }

  private getHeaders(): Record<string, string> {
    return {
      Authorization: `Bearer ${this.getApiToken()}`,
      'Content-Type': 'application/json',
    };
  }

  async createCustomHostname(
    hostname: string,
  ): Promise<CloudflareCustomHostnameResponse> {
    const zoneId = this.getZoneId();
    const url = `${this.baseUrl}/zones/${zoneId}/custom_hostnames`;

    this.logger.log(`Creating custom hostname: ${hostname}`);

    try {
      const response = await fetch(url, {
        method: 'POST',
        headers: this.getHeaders(),
        body: JSON.stringify({
          hostname,
          ssl: {
            method: 'http',
            type: 'dv',
          },
        }),
      });

      const data = (await response.json()) as CloudflareCustomHostnameResponse;

      if (!response.ok || !data.success) {
        this.logger.error(
          `Failed to create custom hostname: ${JSON.stringify(data.errors)}`,
        );
      } else {
        this.logger.log(
          `Custom hostname created successfully: ${data.result?.id}`,
        );
      }

      return data;
    } catch (error) {
      this.logger.error(`Error creating custom hostname: ${error}`);
      return {
        success: false,
        errors: [{ code: 0, message: String(error) }],
      };
    }
  }

  async getCustomHostnameStatus(
    customHostnameId: string,
  ): Promise<CloudflareHostnameStatusResponse> {
    const zoneId = this.getZoneId();
    const url = `${this.baseUrl}/zones/${zoneId}/custom_hostnames/${customHostnameId}`;

    try {
      const response = await fetch(url, {
        method: 'GET',
        headers: this.getHeaders(),
      });

      return (await response.json()) as CloudflareHostnameStatusResponse;
    } catch (error) {
      this.logger.error(`Error fetching custom hostname status: ${error}`);
      return {
        success: false,
        errors: [{ code: 0, message: String(error) }],
      };
    }
  }

  async deleteCustomHostname(
    customHostnameId: string,
  ): Promise<CloudflareDeleteResponse> {
    const zoneId = this.getZoneId();
    const url = `${this.baseUrl}/zones/${zoneId}/custom_hostnames/${customHostnameId}`;

    this.logger.log(`Deleting custom hostname: ${customHostnameId}`);

    try {
      const response = await fetch(url, {
        method: 'DELETE',
        headers: this.getHeaders(),
      });

      const data = (await response.json()) as CloudflareDeleteResponse;

      if (!response.ok || !data.success) {
        this.logger.error(
          `Failed to delete custom hostname: ${JSON.stringify(data.errors)}`,
        );
      } else {
        this.logger.log(
          `Custom hostname deleted successfully: ${customHostnameId}`,
        );
      }

      return data;
    } catch (error) {
      this.logger.error(`Error deleting custom hostname: ${error}`);
      return {
        success: false,
        errors: [{ code: 0, message: String(error) }],
      };
    }
  }
}
