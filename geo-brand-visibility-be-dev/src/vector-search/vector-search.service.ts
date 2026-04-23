import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

export interface ContentEmbeddingPayload {
  contentId: string;
  title: string;
  body: string;
  slug: string;
  targetKeywords: string[];
  topicId: string;
  topicName: string;
}

export interface SimilarContentResult {
  contentId: string;
  title: string;
  slug: string;
  targetKeywords: string[];
  topicId: string;
  topicName: string;
  score: number;
}

@Injectable()
export class VectorSearchService {
  private readonly logger = new Logger(VectorSearchService.name);
  private readonly baseUrl: string;

  constructor(private readonly configService: ConfigService) {
    this.baseUrl = this.configService.get<string>('AGENT_BASE_URL')!;
  }

  async ensureCollection(projectId: string): Promise<void> {
    try {
      await this.post('/embeddings/collections', {
        project_id: projectId,
      });
    } catch (error) {
      this.logger.warn(
        `Failed to ensure collection for project ${projectId}`,
        error,
      );
    }
  }

  async upsertContent(
    projectId: string,
    payload: ContentEmbeddingPayload,
  ): Promise<void> {
    try {
      await this.ensureCollection(projectId);
      await this.post('/embeddings/upsert', {
        project_id: projectId,
        content: {
          content_id: payload.contentId,
          title: payload.title,
          body: payload.body,
          slug: payload.slug,
          target_keywords: payload.targetKeywords,
          topic_id: payload.topicId,
          topic_name: payload.topicName,
        },
      });
    } catch (error) {
      this.logger.warn(`Failed to upsert content ${payload.contentId}`, error);
    }
  }

  async upsertBatch(
    projectId: string,
    payloads: ContentEmbeddingPayload[],
  ): Promise<void> {
    try {
      await this.ensureCollection(projectId);
      await this.post('/embeddings/upsert-batch', {
        project_id: projectId,
        contents: payloads.map((p) => ({
          content_id: p.contentId,
          title: p.title,
          body: p.body,
          slug: p.slug,
          target_keywords: p.targetKeywords,
          topic_id: p.topicId,
          topic_name: p.topicName,
        })),
      });
    } catch (error) {
      this.logger.warn(
        `Failed to batch upsert ${payloads.length} contents for project ${projectId}`,
        error,
      );
    }
  }

  async searchSimilar(
    projectId: string,
    queryText: string,
    limit = 10,
    scoreThreshold?: number,
  ): Promise<SimilarContentResult[]> {
    try {
      const body: Record<string, unknown> = {
        project_id: projectId,
        query_text: queryText,
        limit,
      };
      if (scoreThreshold !== undefined) {
        body.score_threshold = scoreThreshold;
      }

      const results = await this.post<SimilarContentResult[]>(
        '/embeddings/search',
        body,
      );
      return results ?? [];
    } catch (error) {
      this.logger.warn(
        `Failed to search similar content for project ${projectId}`,
        error,
      );
      return [];
    }
  }

  async deleteContent(projectId: string, contentId: string): Promise<void> {
    try {
      await this.request('/embeddings/delete', {
        method: 'DELETE',
        body: {
          project_id: projectId,
          content_id: contentId,
        },
      });
    } catch (error) {
      this.logger.warn(
        `Failed to delete content ${contentId} from Qdrant`,
        error,
      );
    }
  }

  async deleteCollection(projectId: string): Promise<void> {
    try {
      await this.request(`/embeddings/collections/${projectId}`, {
        method: 'DELETE',
      });
    } catch (error) {
      this.logger.warn(
        `Failed to delete collection for project ${projectId}`,
        error,
      );
    }
  }

  async backfill(
    projectId: string,
    payloads: ContentEmbeddingPayload[],
  ): Promise<void> {
    this.logger.log(
      `[VectorSearch.backfill] START project=${projectId} count=${payloads.length}`,
    );
    try {
      await this.ensureCollection(projectId);
      const result = await this.post<{
        status: string;
        count: number;
        processed_docs: number;
        skipped_docs: number;
      }>('/embeddings/backfill', {
        project_id: projectId,
        contents: payloads.map((p) => ({
          content_id: p.contentId,
          title: p.title,
          body: p.body,
          slug: p.slug,
          target_keywords: p.targetKeywords,
          topic_id: p.topicId,
          topic_name: p.topicName,
        })),
      });
      this.logger.log(
        `[VectorSearch.backfill] OK project=${projectId} processed=${result.processed_docs} skipped=${result.skipped_docs} chunks=${result.count}`,
      );
    } catch (error) {
      this.logger.warn(
        `[VectorSearch.backfill] FAILED project=${projectId} error=${(error as Error).message}`,
      );
    }
  }

  private async post<T>(path: string, body: unknown): Promise<T> {
    return this.request<T>(path, { method: 'POST', body });
  }

  private async request<T>(
    path: string,
    options: { method: string; body?: unknown },
  ): Promise<T> {
    const url = `${this.baseUrl}${path}`;
    const fetchOptions: RequestInit = {
      method: options.method,
      headers: { 'Content-Type': 'application/json' },
    };
    if (options.body) {
      fetchOptions.body = JSON.stringify(options.body);
    }

    const response = await fetch(url, fetchOptions);

    if (!response.ok) {
      const text = await response.text();
      throw new Error(
        `Vector search request failed: ${response.status} ${text}`,
      );
    }

    return response.json() as Promise<T>;
  }
}
