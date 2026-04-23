import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { ContentInputsDto } from 'src/content/dto/content-inputs.dto';
import { WorkflowResponseDto } from './dto/workflow-response.dto';
import * as http from 'http';
import { useIPApproachForN8n } from 'src/utils/environment.util';
import { ContentFormat } from '../content/enums';

export interface ClusterContentPayload {
  brandIdentity: {
    name: string;
    description: string;
    mission: string;
    targetMarket: string;
    industry: string;
    services: Array<{ name: string; description: string }>;
  };
  specificTopic: { name: string };
  contentProfile: {
    voiceAndTone: string;
    audience: string;
    description: string;
  };
  keywords: string[];
  language: string;
  location: string;
  clusterContext: {
    articleTitle: string;
    articleRole: 'PILLAR' | 'SATELLITE';
    articleOutline: string[];
    pillarTitle: string;
    pillarSlug: string;
    siblingArticles: Array<{ title: string; slug: string; role: string }>;
    blogBaseUrl: string;
  };
  jobId: string;
  callbackUrl: string;
}

@Injectable()
export class N8nService {
  private readonly logger = new Logger(N8nService.name);

  constructor(private readonly configService: ConfigService) {}

  async generateContentFromPrompt(
    contentInput: ContentInputsDto,
    contentType: string,
    contentFormat?: ContentFormat,
    platform?: string,
    jobId?: string,
    improvement?: string,
  ): Promise<WorkflowResponseDto> {
    const callbackUrl = this.configService.get<string>('N8N_CALLBACK_URL');
    const finalJobId = jobId || contentInput.contentId;
    const postData = JSON.stringify({
      ...contentInput,
      contentType,
      contentFormat,
      ...(platform && { platform }),
      ...(improvement && { improvement }),
      jobId: finalJobId,
      callbackUrl,
    });
    return this.postToWebhook(
      this.configService.get<string>('N8N_GENERETE_WEBHOOK_PATH') || '',
      postData,
    );
  }

  async regenerateContentWithImprovement(
    contentInput: ContentInputsDto,
    previousContent: string,
    contentType: string,
    jobId?: string,
    improvement?: string | null,
  ): Promise<WorkflowResponseDto> {
    const postData = JSON.stringify({
      ...contentInput,
      previousContent,
      contentType,
      improvement: improvement || null,
      mode: improvement ? 'SURGICAL_EDIT' : 'FULL_REGENERATE',
      jobId,
      callbackUrl: this.configService.get<string>('N8N_CALLBACK_URL'),
    });

    return this.postToWebhook(
      this.configService.get<string>('N8N_REGENERATE_WEBHOOK_PATH') || '',
      postData,
    );
  }

  async rewriteContentFromPrompt(
    contentInput: ContentInputsDto,
    previousContent: string,
    contentType: string,
    platform?: string,
    jobId?: string,
    improvement?: string,
  ): Promise<WorkflowResponseDto> {
    const callbackUrl =
      this.configService.get<string>('N8N_CALLBACK_URL') || '';
    const finalJobId = jobId || contentInput.contentId;
    const postData = JSON.stringify({
      ...contentInput,
      previousContent,
      contentType,
      ...(platform && { platform }),
      ...(improvement && { improvement }),
      jobId: finalJobId,
      callbackUrl,
    });

    const path =
      this.configService.get<string>('N8N_REWRITE_WEBHOOK_PATH') || '';
    return this.postToWebhook(path, postData);
  }

  async generateClusterContent(
    payload: ClusterContentPayload,
  ): Promise<WorkflowResponseDto> {
    const postData = JSON.stringify(payload);
    return this.postToWebhook(
      this.configService.get<string>('N8N_CLUSTER_GENERATE_WEBHOOK_PATH') || '',
      postData,
    );
  }

  private async postToWebhook(
    path: string,
    postData: string,
    maxRetries = 2,
  ): Promise<WorkflowResponseDto> {
    let lastError: Error | null = null;

    for (let attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        if (attempt > 0) {
          const delay = Math.min(1000 * Math.pow(2, attempt), 10000);
          this.logger.warn(
            `Retrying N8n webhook (attempt ${attempt + 1}/${maxRetries + 1}) after ${delay}ms`,
          );
          await new Promise((r) => setTimeout(r, delay));
        }

        const startTime = Date.now();

        const responseText = useIPApproachForN8n()
          ? await this.postByHttpModule(path, postData)
          : await this.postByFetch(path, postData);

        const endTime = Date.now();
        this.logger.log(
          `N8n webhook triggered in ${(endTime - startTime) / 1000}s`,
        );

        if (!responseText || responseText.trim() === '') {
          throw new Error('Empty response from webhook');
        }

        const responseData = JSON.parse(responseText) as WorkflowResponseDto;
        const hasContent = !!(
          responseData.body && responseData.body.trim().length > 0
        );
        if (!hasContent) {
          this.logger.warn(
            'N8n webhook returned response without body content',
          );
        }
        return {
          ...responseData,
          success: hasContent,
        };
      } catch (error) {
        lastError = error instanceof Error ? error : new Error('Unknown error');
        this.logger.error(
          `N8n webhook attempt ${attempt + 1} failed: ${lastError.message}`,
        );

        // Retry on transient errors (timeout, connection issues, empty response from n8n)
        const isRetryable =
          lastError.message.includes('timed out') ||
          lastError.message.includes('ECONNRESET') ||
          lastError.message.includes('ECONNREFUSED') ||
          lastError.message.includes('socket hang up') ||
          lastError.message.includes('Empty response from webhook');

        if (!isRetryable || attempt === maxRetries) {
          break;
        }
      }
    }

    const errorMessage = lastError?.message || 'Unknown error';
    this.logger.error('All N8n webhook attempts failed:', errorMessage);

    return {
      targetKeywords: [],
      contentInsight: [],
      title: '# Mock Generated Content',
      body: `Error connecting to generation service: ${errorMessage}`,
      success: false,
    };
  }

  private getAuthHeader(): string {
    const username = this.configService.get<string>('N8N_USERNAME');
    const password = this.configService.get<string>('N8N_PASSWORD');
    const cleanUser = username?.replace(/['"]/g, '');
    const cleanPass = password?.replace(/['"]/g, '');
    return (
      'Basic ' + Buffer.from(`${cleanUser}:${cleanPass}`).toString('base64')
    );
  }

  private async postByHttpModule(path: string, body: string): Promise<string> {
    const ip = this.configService.get<string>('N8N_IP');
    const host = this.configService.get<string>('N8N_HOST');

    // We use the 'http' module instead of 'fetch' because we need to connect to the n8n server
    // using its direct IP address (N8N_IP) while providing a custom 'Host' header (N8N_HOST).
    // Native 'fetch' (and many libraries) often restrict or override the 'Host' header based on the URL,
    // which causes issues when the N8N server/proxy relies on the Host header for routing.
    const options: http.RequestOptions = {
      hostname: ip,
      path: path,
      method: 'POST',
      headers: {
        Host: host,
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(body),
        Authorization: this.getAuthHeader(),
        Connection: 'close',
        'User-Agent': 'Node.js/http-module',
      },
      timeout: 1000 * 60 * 10,
    };

    return new Promise<string>((resolve, reject) => {
      const req = http.request(options, (res) => {
        let data = '';

        if (res.statusCode && (res.statusCode < 200 || res.statusCode >= 300)) {
          this.logger.warn(`Webhook failed with status code ${res.statusCode}`);
          reject(
            new Error(`Webhook failed with status code ${res.statusCode}`),
          );
          return;
        }

        res.on('data', (chunk) => {
          data += chunk;
        });

        res.on('end', () => {
          if (
            res.statusCode &&
            (res.statusCode < 200 || res.statusCode >= 300)
          ) {
            reject(
              new Error(
                `N8n webhook returned status ${res.statusCode}: ${data.substring(0, 200)}`,
              ),
            );
            return;
          }
          resolve(data);
        });
      });

      req.on('timeout', () => {
        this.logger.error(
          `N8n webhook timed out after ${options.timeout}ms for path: ${path}`,
        );
        req.destroy(
          new Error(`N8n webhook timed out after ${options.timeout}ms`),
        );
      });

      req.on('error', (err) => {
        reject(err);
      });

      req.write(body);
      req.end();
    });
  }

  private async postByFetch(path: string, body: string): Promise<string> {
    const host = this.configService.get<string>('N8N_HOST');
    const url = `https://${host}${path}`;

    const response = await fetch(url, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: this.getAuthHeader(),
      },
      body: body,
    });

    if (!response.ok) {
      throw new Error(`Fetch failed with status: ${response.status}`);
    }

    return await response.text();
  }
}
