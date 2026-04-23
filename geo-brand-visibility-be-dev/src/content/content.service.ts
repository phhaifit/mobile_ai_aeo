import {
  Injectable,
  NotFoundException,
  ConflictException,
  ForbiddenException,
  Logger,
  BadRequestException,
} from '@nestjs/common';
import {
  ContentRepository,
  Content,
  ContentWithRelations,
} from './content.repository';
import {
  ContentDto,
  ContentListItemDto,
  ContentTopicListItemDto,
} from './dto/content.dto';
import { PaginationResult } from '../shared/dtos/pagination-result.dto';
import { createPaginatedResponse } from '../utils/common';
import { ContentType, GenerateContentDto } from './dto/generate-content.dto';
import { GeneratedContentDto } from './dto/generated-content.dto';
import {
  ContentInputsDto,
  ArticleAngleDto,
  CustomerPersonaInputDto,
} from './dto/content-inputs.dto';
import { TopicRepository } from '../topic/topic.repository';
import { ProjectRepository } from '../project/project.repository';
import { BrandRepository } from '../brand/brand.repository';
import { PromptRepository } from '../prompt/prompt.repository';
import { ContentProfileRepository } from '../content-profile/content-profile.repository';
import { N8nService } from '../n8n/n8n.service';
import { ContentProfileDto } from 'src/project/dto/content-inputs.dto';
import { WebSearchService } from '../web-search/web-search.service';
import { ConfigService } from '@nestjs/config';
import { R2StorageService } from '../r2-storage/r2-storage.service';
import { ContentImageService } from './content-image.service';
import { ReferencePageContentDto } from 'src/web-search/dtos/web-search-response.dto';
import { ThumbnailDto } from './dto/image-metadata.dto';

import { DEFAULT_CONTENT_PROFILE } from '../utils/const';
import { extractTitle } from '../utils/markdown.util';
import { slugify } from '../utils/slug.util';
import { ContentQueryDto } from './dto/content-query.dto';
import { ContentInsightRepository } from '../content-insight/content-insight.repository';
import { WorkflowResponseDto } from 'src/n8n/dto/workflow-response.dto';
import {
  CompletionStatus,
  ContentFormat,
  SocialPlatform,
} from 'src/content/enums';
import type {
  InsightGroup,
  InsightType,
} from '../content-insight/types/content-insight.types';
import { extractSearchQuery } from 'src/utils/search';
import { LanguageUtil } from 'src/shared/utils/language';
import { CountryUtil } from 'src/shared/utils/country';
import {
  extractImagesFromHtml,
  extractImagesFromMarkdown,
  extractOgImage,
} from 'src/utils/markdown-image-extractor.util';
import { AgentService } from '../agent/agent.service';
import {
  ValidateReferenceDto,
  ValidateReferenceResponseDto,
} from './dto/validate-reference.dto';
import { TaskSkippedException } from '../processors/exceptions/task-skipped.exception';
import { SubscriptionService } from '../subscription/subscription.service';
import { VectorSearchService } from '../vector-search/vector-search.service';
import { CustomerPersonaRepository } from '../customer-persona/customer-persona.repository';

interface ContentProcessResult {
  contentId: string;
  contentInput: ContentInputsDto;
  workflowResponse: WorkflowResponseDto;
  finalRetrievedPages: { url: string; title?: string }[];
}

type GeneratedContentWithThumbnail = GeneratedContentDto & {
  thumbnailKey?: string;
};

const MAX_SLUG_ATTEMPTS = 100;
const CONTENT_RELEVANCE_AGENT = 'content_relevance_validation';
const ANGLE_AGENT = 'angle_generation';
const MAX_REF_CONTENT_LENGTH = 15000;

@Injectable()
export class ContentService {
  private readonly logger = new Logger(ContentService.name);
  private readonly languageUtil = new LanguageUtil();
  private readonly countryUtil = new CountryUtil();

  constructor(
    private readonly contentRepository: ContentRepository,
    private readonly topicRepository: TopicRepository,
    private readonly projectRepository: ProjectRepository,
    private readonly brandRepository: BrandRepository,
    private readonly promptRepository: PromptRepository,
    private readonly contentProfileRepository: ContentProfileRepository,
    private readonly n8nService: N8nService,
    private readonly webSearchService: WebSearchService,
    private readonly contentInsightRepository: ContentInsightRepository,
    private readonly configService: ConfigService,
    private readonly r2StorageService: R2StorageService,
    private readonly contentImageService: ContentImageService,
    private readonly agentService: AgentService,
    private readonly subscriptionService: SubscriptionService,
    private readonly vectorSearchService: VectorSearchService,
    private readonly customerPersonaRepository: CustomerPersonaRepository,
  ) {}

  private toThumbnailDto(
    thumbnailKey?: string | null,
  ): ThumbnailDto | undefined {
    if (!thumbnailKey) return undefined;
    return {
      key: thumbnailKey,
      url: this.r2StorageService.getPublicUrl(thumbnailKey),
    };
  }

  async getContentsByPromptId(
    promptId: string,
  ): Promise<ContentTopicListItemDto[]> {
    const contents = await this.contentRepository.findByPromptId(promptId);

    return contents.map((content) => ({
      id: content.id,
      thumbnail: this.toThumbnailDto(content.thumbnailKey),
      body: content.body,
      publishedBody: content.publishedBody ?? null,
      completionStatus: content.completionStatus as CompletionStatus,
      createdAt: content.createdAt,
      topic: content.topic
        ? {
            id: content.topic.id,
            name: content.topic.name,
            projectId: content.topic.projectId,
          }
        : {
            id: '',
            name: 'Unknown Topic',
            projectId: '',
          },
    }));
  }

  async getPaginatedContentsByProjectId(
    projectId: string,
    params: ContentQueryDto,
  ): Promise<PaginationResult<ContentListItemDto>> {
    const { data, total } =
      await this.contentRepository.findAllByProjectIdPaginated(
        projectId,
        params,
      );

    return createPaginatedResponse(
      data,
      total,
      params,
      (item: ContentWithRelations) => ({
        id: item.id,
        title: item.title || undefined,
        slug: item.slug || undefined,
        thumbnail: this.toThumbnailDto(item.thumbnailKey),
        body: item.body,
        publishedBody: item.publishedBody,
        completionStatus: item.completionStatus as CompletionStatus,
        createdAt: item.createdAt,
        publishedAt: item.publishedAt,
        featuredImageUrl: (item as any).featuredImageUrl ?? null,
        targetKeywords: Array.isArray(item.targetKeywords)
          ? (item.targetKeywords as string[])
          : [],
        retrievedPages: Array.isArray(item.retrievedPages)
          ? (item.retrievedPages as Array<{ url: string; title?: string }>)
          : [],
        topic: item.topic
          ? {
              id: item.topic.id,
              name: item.topic.name,
              projectId: item.topic.projectId,
            }
          : {
              id: '',
              name: 'Unknown Topic',
              projectId: '',
            },
        profile: item.profile
          ? {
              id: item.profile.id,
              name: item.profile.name,
            }
          : {
              id: '',
              name: 'Unknown Profile',
            },
        prompt: item.prompt,
        contentType: (item.contentType as ContentType) || ContentType.BLOG_POST,
        platform: (item.platform as SocialPlatform | null) || null,
      }),
    );
  }

  async getContentById(
    id: string,
    userId?: string,
  ): Promise<ContentDto | null> {
    if (userId) {
      const hasAccess = await this.contentRepository.findByIdWithAccess(
        id,
        userId,
      );
      if (!hasAccess) {
        throw new ForbiddenException('You do not have access to this content');
      }
    }

    const content = await this.contentRepository.findByIdWithRelations(id);

    if (!content) {
      return null;
    }

    // Handle null checks for relations
    if (!content.topic) {
      throw new Error('Content missing required relations');
    }

    const targetKeywords = Array.isArray(content.targetKeywords)
      ? (content.targetKeywords as string[])
      : [];

    return {
      id: content.id,
      title: content.title || undefined,
      slug: content.slug || undefined,
      thumbnail: this.toThumbnailDto(content.thumbnailKey),
      publishedBody: content.publishedBody,
      body: content.body,
      completionStatus: content.completionStatus as CompletionStatus,
      contentFormat: content.contentFormat as ContentFormat,
      createdAt: content.createdAt,
      publishedAt: content.publishedAt,
      featuredImageUrl: (content as any).featuredImageUrl ?? null,
      targetKeywords,
      retrievedPages: this.normalizeRetrievedPages(content.retrievedPages),
      topic: {
        id: content.topic.id,
        name: content.topic.name,
        projectId: content.topic.projectId,
      },
      profile: {
        id: content.profile?.id || DEFAULT_CONTENT_PROFILE.ID,
        name: content.profile?.name || DEFAULT_CONTENT_PROFILE.NAME,
        voiceAndTone:
          content.profile?.voiceAndTone ||
          DEFAULT_CONTENT_PROFILE.VOICE_AND_TONE,
        audience: content.profile?.audience || DEFAULT_CONTENT_PROFILE.AUDIENCE,
        description: content.profile?.description || null,
      },
      prompt: {
        id: content.prompt?.id || '',
        content: content.prompt?.content || '',
        type: content.prompt?.type || 'Informational',
      },
      contentType:
        (content.contentType as ContentType) || ContentType.BLOG_POST,
      platform: (content.platform as SocialPlatform) || null,
    } as unknown as ContentDto;
  }

  async verifyContentAccess(id: string, userId: string): Promise<Content> {
    const content = await this.contentRepository.findByIdWithAccess(id, userId);
    if (!content) {
      throw new ForbiddenException('You do not have access to this content');
    }
    return content;
  }

  async deleteContents(ids: string[], userId: string): Promise<void> {
    const contents = await this.contentRepository.findManyByIdsWithAccess(
      ids,
      userId,
    );

    if (contents.length !== ids.length) {
      throw new ForbiddenException(
        'You do not have access to one or more contents',
      );
    }

    const publishedIds = contents
      .filter(
        (c) =>
          (c.completionStatus as CompletionStatus) ===
          CompletionStatus.Published,
      )
      .map((c) => c.id);

    if (publishedIds.length > 0) {
      throw new ConflictException(
        'Cannot delete PUBLISHED content. Unpublish first.',
      );
    }

    for (const contentId of ids) {
      try {
        const deletedCount =
          await this.contentImageService.deleteContentImages(contentId);
        this.logger.log(
          `Deleted ${deletedCount} images for content: ${contentId}`,
        );
      } catch (error) {
        this.logger.error(
          `Failed to delete images for content ${contentId}: ${error instanceof Error ? error.message : 'Unknown'}`,
        );
        // Continue with deletion even if image cleanup fails
      }
    }

    await this.contentRepository.deleteMany(ids);
  }

  async updateContent(
    id: string,
    userId: string,
    data: {
      body?: string;
      title?: string;
      slug?: string;
      completionStatus?: CompletionStatus;
      thumbnailKey?: string | null;
    },
  ): Promise<void> {
    const content = await this.verifyContentAccess(id, userId);

    if (
      (content.completionStatus as CompletionStatus) ===
      CompletionStatus.Published
    ) {
      if (data.slug !== undefined) {
        throw new ConflictException(
          'Cannot update slug on PUBLISHED content. Unpublish first.',
        );
      }
      if (
        data.completionStatus &&
        data.completionStatus !== CompletionStatus.Published
      ) {
        throw new ConflictException(
          'Cannot unpublish content via update endpoint. Use POST /contents/:id/unpublish instead.',
        );
      }
    }

    if (data.completionStatus === CompletionStatus.Published) {
      throw new ConflictException(
        'Cannot publish content via update endpoint. Use POST /contents/:id/publish instead.',
      );
    }

    await this.contentRepository.update(id, {
      body: data.body,
      title: data.title,
      slug: data.slug,
      completionStatus: data.completionStatus,
      thumbnailKey: data.thumbnailKey,
    });
  }

  async publishContent(id: string, userId: string): Promise<void> {
    const content = await this.verifyContentAccess(id, userId);

    if (
      (content.completionStatus as CompletionStatus) !==
      CompletionStatus.Complete
    ) {
      throw new ConflictException(
        'Only COMPLETE content can be published. Current status: ' +
          content.completionStatus,
      );
    }

    const publishedAt = new Date().toISOString();
    const updated: boolean = await this.contentRepository.publishContent(
      id,
      publishedAt,
      content.body,
    );

    if (!updated) {
      throw new ConflictException(
        'Content was modified by another request. Please try again.',
      );
    }

    this.embedContentAsync(id).catch((err) =>
      this.logger.warn(`Failed to embed content ${id} on publish`, err),
    );
  }

  async unpublishContent(id: string, userId: string): Promise<void> {
    const content = await this.verifyContentAccess(id, userId);

    if (
      (content.completionStatus as CompletionStatus) !==
      CompletionStatus.Published
    ) {
      throw new ConflictException(
        'Only PUBLISHED content can be unpublished. Current status: ' +
          content.completionStatus,
      );
    }

    const updated: boolean = await this.contentRepository.unpublishContent(id);

    if (!updated) {
      throw new ConflictException(
        'Content was modified by another request. Please try again.',
      );
    }

    const fullContent = await this.contentRepository.findByIdWithRelations(id);
    if (fullContent?.topic) {
      this.vectorSearchService
        .deleteContent(fullContent.topic.projectId, id)
        .catch((err) =>
          this.logger.warn(
            `Failed to remove content ${id} from Qdrant on unpublish`,
            err,
          ),
        );
    }
  }

  async republishContent(id: string, userId: string): Promise<void> {
    const content = await this.verifyContentAccess(id, userId);

    if (
      (content.completionStatus as CompletionStatus) !==
      CompletionStatus.Published
    ) {
      throw new ConflictException(
        'Only PUBLISHED content can be republished. Current status: ' +
          content.completionStatus,
      );
    }

    const updated: boolean = await this.contentRepository.republishContent(
      id,
      content.body,
    );

    if (!updated) {
      throw new ConflictException(
        'Content was modified by another request. Please try again.',
      );
    }

    this.embedContentAsync(id).catch((err) =>
      this.logger.warn(`Failed to embed content ${id} on republish`, err),
    );
  }

  async getContentInputsForTopic(
    topicId: string,
    promptId: string,
    contentId?: string,
    dto?: GenerateContentDto,
    jobId?: string,
  ): Promise<ContentInputsDto> {
    const { keywords, contentProfileId, referencePageUrl, customerPersonaId } =
      dto || {};
    const topic = await this.topicRepository.findById(topicId);
    if (!topic) {
      throw new NotFoundException('Topic not found');
    }

    const projectId = topic.projectId;
    const project = await this.projectRepository.findById(projectId);
    if (!project) {
      throw new NotFoundException('Project not found or access denied');
    }

    const brand = await this.brandRepository.findByProjectId(projectId);
    if (!brand) {
      throw new NotFoundException('Brand not found for project');
    }

    const prompt = await this.promptRepository.getPromptById(promptId);
    if (!prompt) {
      throw new NotFoundException('Prompt not found');
    }

    let contentProfile: ContentProfileDto;
    if (contentProfileId) {
      const profile =
        await this.contentProfileRepository.findById(contentProfileId);
      if (!profile) {
        throw new NotFoundException('Content profile not found');
      }
      contentProfile = {
        id: profile.id,
        description: profile.description || '',
        voiceAndTone: profile.voiceAndTone,
        audience: profile.audience,
      } as ContentProfileDto;
    } else {
      // Default from brand
      contentProfile = {
        voiceAndTone: brand.mission || DEFAULT_CONTENT_PROFILE.VOICE_AND_TONE,
        audience: brand.targetMarket || DEFAULT_CONTENT_PROFILE.AUDIENCE,
      } as ContentProfileDto;
    }

    // Keywords from provided or topic name
    const finalKeywords =
      keywords && keywords.length > 0 ? keywords : [topic.name];

    const referencePageContent = referencePageUrl
      ? await this.processReferencePageContent(referencePageUrl)
      : null;

    // Fetch customer persona (explicit selection or primary fallback)
    let customerPersona: CustomerPersonaInputDto | undefined;
    const persona = customerPersonaId
      ? await this.customerPersonaRepository.findById(customerPersonaId)
      : await this.customerPersonaRepository.findPrimaryByBrandId(brand.id);
    if (persona) {
      customerPersona = {
        name: persona.name,
        description: persona.description ?? undefined,
        demographics:
          (persona.demographics as Record<string, string>) ?? undefined,
        professional:
          (persona.professional as Record<string, string>) ?? undefined,
        goalsAndMotivations: persona.goalsAndMotivations ?? undefined,
        painPoints: persona.painPoints ?? undefined,
        contentPreferences:
          (persona.contentPreferences as Record<string, unknown>) ?? undefined,
        buyingBehavior:
          (persona.buyingBehavior as Record<string, unknown>) ?? undefined,
      };
    }

    // Convert language and location codes to full names with fallback
    const language = this.languageUtil.getLanguageName(project.language);
    const location = this.countryUtil.getCountryName(project.location);

    return {
      jobId,
      callbackUrl: this.configService.get<string>('N8N_CALLBACK_URL'),
      contentId: contentId || '',
      projectId,
      language,
      location,
      brandIdentity: {
        id: brand.id,
        name: brand.name,
        description: brand.description,
        mission: brand.mission,
        targetMarket: brand.targetMarket,
        industry: brand.industry,
        services:
          brand.services?.map((s) => ({
            id: s.id,
            name: s.name,
            description: s.description || '',
          })) || [],
      },
      specificTopic: {
        id: topic.id,
        name: topic.name,
      },
      prompt: {
        id: prompt.id,
        content: prompt.content,
        type: prompt.type,
      },
      contentProfile,
      keywords: finalKeywords,
      referencePageContent: referencePageContent ?? undefined,
      customerPersona,
    };
  }

  async validateReference(
    promptId: string,
    userId: string,
    dto: ValidateReferenceDto,
  ): Promise<ValidateReferenceResponseDto> {
    const prompt = await this.promptRepository.getPromptById(promptId);
    if (!prompt) {
      throw new NotFoundException('Prompt not found');
    }

    // Crawl and validate the URL
    let crawlContent: string;
    try {
      const crawlResult = await this.webSearchService.crawl(
        dto.referencePageUrl,
      );
      crawlContent = crawlResult.content;
    } catch {
      return { isRelevant: false, reason: 'Failed to crawl the URL' };
    }

    if (!crawlContent || crawlContent.trim().length === 0) {
      return { isRelevant: false, reason: 'Page has no readable content' };
    }

    const validation = await this.validateContentRelevance(
      prompt.content,
      crawlContent,
      userId,
    );

    if (validation.isRelevant) {
      return { isRelevant: true };
    }

    // Not relevant — blacklist it and tell the user to pick another
    await this.promptRepository.addBlacklistedUrl(
      promptId,
      dto.referencePageUrl,
      validation.reason,
    );

    return { isRelevant: false, reason: validation.reason };
  }

  private async processReferencePageContent(
    url: string,
  ): Promise<ReferencePageContentDto> {
    this.logger.log(`Processing reference page content from: ${url}`);

    const crawlResult = await this.webSearchService.crawl(url);
    const ogImage = extractOgImage(crawlResult.html, url);
    const allImages = extractImagesFromHtml(crawlResult.html, url);

    const contentImages = this.contentImageService.filterContentImages(
      allImages,
      crawlResult.content,
    );

    this.logger.log(
      `Extracted ${contentImages.length} content images out of ${allImages.length} total images, og:image: ${ogImage || 'none'}`,
    );

    return {
      content: this.stripAllLinks(crawlResult.content),
      url: crawlResult.url,
      title: crawlResult.title,
      ogImage,
      images: contentImages,
    };
  }

  private stripAllLinks(content: string): string {
    return content.replace(
      /!?\[([^\]]*)\]\([^)]*\)/g,
      (_match: string, text: string) => text,
    );
  }

  async generateContent(
    promptId: string,
    dto: GenerateContentDto,
    userId: string,
    jobId?: string,
  ): Promise<GeneratedContentDto> {
    this.logger.log('Start generating content (user-initiated)');
    const prompt = await this.promptRepository.getPromptById(promptId);
    if (!prompt || !prompt.topicId) {
      throw new NotFoundException(
        'Prompt not found or does not belong to project',
      );
    }

    const result = await this.executeContentGeneration(
      dto,
      userId,
      prompt,
      promptId,
      dto.referencePageUrl,
      jobId,
    );
    return this.processGenerationResult(result, dto, userId);
  }

  async generateContentForScheduler(
    promptId: string,
    dto: GenerateContentDto,
    jobId?: string,
  ): Promise<GeneratedContentDto> {
    this.logger.log('Start generating content (scheduler)');
    const prompt = await this.promptRepository.getPromptById(promptId);
    if (!prompt || !prompt.topicId) {
      throw new NotFoundException('Prompt not found');
    }

    const promptLabel = `"${prompt.content.substring(0, 80)}"`;

    const referenceResult = await this.resolveReferenceUrlForScheduler(
      dto.referencePageUrl,
      promptId,
      prompt.content,
      dto.projectId,
    );

    if ('reason' in referenceResult) {
      if (referenceResult.exhausted) {
        await this.markPromptExhausted(promptId);
      }
      throw new TaskSkippedException(
        `We skipped prompt ${promptLabel}: ${referenceResult.reason}`,
      );
    }

    try {
      const result = await this.executeContentGeneration(
        dto,
        undefined,
        prompt,
        promptId,
        referenceResult.url,
        jobId,
      );
      return this.processGenerationResult(result, dto, undefined);
    } catch (error) {
      if (error instanceof ConflictException) {
        await this.markPromptExhausted(promptId);
        throw new TaskSkippedException(
          `We couldn't find a new angle for prompt ${promptLabel} based on source page "${referenceResult.url}". This page has been blacklisted and will not be used for this prompt again.`,
        );
      }
      throw error;
    }
  }

  private async processGenerationResult(
    result: ContentProcessResult,
    dto: GenerateContentDto,
    userId: string | undefined,
  ): Promise<GeneratedContentDto> {
    const { contentId, contentInput, workflowResponse, finalRetrievedPages } =
      result;

    // Fail-fast: mark draft as FAILED without allocating a slug
    if (!workflowResponse.success) {
      await this.contentRepository.update(contentId, {
        completionStatus: CompletionStatus.Failed,
        body: workflowResponse.body || '',
      });
      throw new Error(`Content generation failed: ${workflowResponse.body}`);
    }

    const processedBody = await this.contentImageService.processMarkdownImages(
      workflowResponse.body || '',
      contentId,
      contentInput.referencePageContent?.url || '',
    );

    // Determine featured image: og:image > body image > filtered reference image
    const bodyImages = extractImagesFromMarkdown(
      processedBody.updatedBody || '',
      '',
    );
    const featuredImageUrl =
      contentInput.referencePageContent?.ogImage ||
      bodyImages[0]?.sourceUrl ||
      contentInput.referencePageContent?.images?.[0]?.sourceUrl ||
      null;

    const generatedContentDto: GeneratedContentDto = {
      id: contentId,
      topicId: contentInput.specificTopic.id,
      profileId: contentInput.contentProfile.id || '',
      promptId: contentInput.prompt.id,
      targetKeywords: workflowResponse.targetKeywords || contentInput.keywords,
      retrievedPages: finalRetrievedPages,
      contentInsight: workflowResponse.contentInsight || [],
      completionStatus: CompletionStatus.Published,
      contentType: dto.contentType || ContentType.BLOG_POST,
      contentFormat:
        dto.contentType === ContentType.SOCIAL_MEDIA_POST
          ? ContentFormat.PlainText
          : ContentFormat.Markdown,
      body: processedBody.updatedBody || '',
      title: workflowResponse.title || '',
      createdAt: new Date().toISOString(),
    };

    const savedData = await this.saveGeneratedContent(
      contentId,
      { ...generatedContentDto, thumbnailKey: processedBody.thumbnail?.key },
      userId,
      featuredImageUrl,
    );

    const contentInsight = generatedContentDto.contentInsight.map(
      (insight) => ({
        insightGroup: insight.insightGroup,
        type: insight.type,
        content: insight.content,
      }),
    );

    // Send metered event to Stripe — triggers per-content charge ($0.10/content) on the user's subscription
    try {
      await this.subscriptionService.reportUsage(dto.projectId);
    } catch (e) {
      this.logger.warn(
        `Failed to report usage for project ${dto.projectId}: ${e instanceof Error ? e.message : 'Unknown'}`,
      );
    }

    return {
      id: contentId,
      topicId: generatedContentDto.topicId,
      profileId: generatedContentDto.profileId,
      promptId: generatedContentDto.promptId,
      targetKeywords: generatedContentDto.targetKeywords,
      retrievedPages: generatedContentDto.retrievedPages,
      contentInsight,
      completionStatus: generatedContentDto.completionStatus,
      contentType: dto.contentType || ContentType.BLOG_POST,
      contentFormat: generatedContentDto.contentFormat,
      body: savedData.body,
      title: savedData.title,
      slug: savedData.slug,
      thumbnail: processedBody.thumbnail,
      createdAt: generatedContentDto.createdAt,
    } as GeneratedContentDto;
  }

  /**
   * Regenerate content based on an existing content record.
   * - Blog: Uses Rewrite mode (sends previousContent to n8n, searches for new reference pages)
   * - Social: Uses Generate mode (creates fresh content â€” shorter, cheaper, more diverse results)
   */
  async regenerateContent(
    contentId: string,
    userId: string,
    jobId?: string,
    improvement?: string,
  ): Promise<GeneratedContentDto> {
    const content =
      await this.contentRepository.findByIdWithRelations(contentId);

    if (!content) {
      throw new NotFoundException(`Content with ID ${contentId} not found`);
    }

    if (!content.topic) {
      throw new BadRequestException('Content is missing topic relation');
    }

    const promptId = content.promptId;
    if (!promptId) {
      throw new BadRequestException(
        'Content does not have an associated prompt. Cannot regenerate.',
      );
    }

    const contentType =
      (content.contentType as ContentType) || ContentType.BLOG_POST;

    const targetKeywords = Array.isArray(content.targetKeywords)
      ? (content.targetKeywords as string[])
      : [];

    const currentStatus = content.completionStatus as CompletionStatus;

    let newContentId: string;

    if (
      currentStatus === CompletionStatus.Failed ||
      currentStatus === CompletionStatus.Drafting
    ) {
      // Retry in place — reset the existing record instead of creating a new one
      newContentId = contentId;
      await this.contentRepository.update(contentId, {
        completionStatus: CompletionStatus.Drafting,
        body: '',
        title: '',
        slug: null,
        publishedAt: null,
        jobId: jobId || null,
      });
      this.logger.log(
        `Reusing existing content ${contentId} for regeneration (was ${currentStatus})`,
      );
    } else {
      // Content was successful — create a new version to preserve the original
      const contentRecord = await this.createDraftContentRecord({
        topicId: content.topic.id,
        promptId,
        profileId: content.profile?.id,
        targetKeywords,
        contentType,
        platform: (content.platform as SocialPlatform) || undefined,
        jobId,
      });
      newContentId = contentRecord.id;
      this.logger.log(
        `Created new content ${newContentId} for regeneration (original ${contentId} is ${currentStatus})`,
      );
    }

    const dto: GenerateContentDto = {
      projectId: content.topic.projectId,
      contentType,
      contentProfileId: content.profile?.id,
      keywords: targetKeywords,
      platform: (content.platform as SocialPlatform) || undefined,
      improvement,
    };

    const contentInput = await this.getContentInputsForTopic(
      content.topic.id,
      promptId,
      newContentId,
      dto,
      jobId,
    );

    // Call the dedicated regenerate n8n flow (not generate/rewrite)
    const workflowResponse =
      await this.n8nService.regenerateContentWithImprovement(
        contentInput,
        content.body || '',
        contentType,
        jobId,
        improvement,
      );

    // Fail-fast: mark draft as FAILED without allocating a slug
    if (!workflowResponse.success) {
      await this.contentRepository.update(newContentId, {
        completionStatus: CompletionStatus.Failed,
        body: workflowResponse.body || '',
      });
      throw new Error(`Content regeneration failed: ${workflowResponse.body}`);
    }

    const processedBody = await this.contentImageService.processMarkdownImages(
      workflowResponse.body || '',
      newContentId,
      contentInput.referencePageContent?.url || '',
    );

    // Determine featured image: first image from body, or first reference image
    const regenBodyImages = extractImagesFromMarkdown(
      processedBody.updatedBody || '',
      '',
    );
    const regenFeaturedImageUrl =
      regenBodyImages[0]?.sourceUrl ||
      contentInput.referencePageContent?.images?.[0]?.sourceUrl ||
      null;

    const contentFormat =
      contentType === ContentType.SOCIAL_MEDIA_POST
        ? ContentFormat.PlainText
        : ContentFormat.Markdown;

    const generatedContentDto: GeneratedContentDto = {
      id: newContentId,
      topicId: content.topic.id,
      profileId: contentInput.contentProfile.id || '',
      promptId,
      targetKeywords: workflowResponse.targetKeywords || targetKeywords,
      retrievedPages: [],
      contentInsight: workflowResponse.contentInsight || [],
      completionStatus: CompletionStatus.Published,
      contentFormat,
      contentType,
      body: processedBody.updatedBody || '',
      title: workflowResponse.title || '',
      createdAt: new Date().toISOString(),
    };

    const savedData = await this.saveGeneratedContent(
      newContentId,
      { ...generatedContentDto, thumbnailKey: processedBody.thumbnail?.key },
      userId,
      regenFeaturedImageUrl,
    );

    // Send metered event to Stripe — triggers per-content charge ($0.10/content) on the user's subscription
    try {
      await this.subscriptionService.reportUsage(content.topic.projectId);
    } catch (e) {
      this.logger.warn(
        `Failed to report usage for project ${content.topic.projectId}: ${e instanceof Error ? e.message : 'Unknown'}`,
      );
    }

    return {
      ...generatedContentDto,
      body: savedData.body,
      title: savedData.title,
      slug: savedData.slug,
      thumbnail: processedBody.thumbnail,
    } as GeneratedContentDto;
  }

  private async createDraftContentRecord(params: {
    topicId: string;
    promptId: string;
    profileId?: string;
    targetKeywords: string[];
    contentType?: string;
    platform?: string;
    jobId?: string;
  }) {
    return this.contentRepository.create({
      topicId: params.topicId,
      promptId: params.promptId,
      profileId: params.profileId,
      targetKeywords: params.targetKeywords,
      retrievedPages: [],
      body: '',
      title: '',
      contentType: params.contentType || ContentType.BLOG_POST,
      platform: params.platform || null,
      contentFormat:
        params.contentType === ContentType.SOCIAL_MEDIA_POST
          ? 'PLAIN_TEXT'
          : 'MARKDOWN',
      completionStatus: 'DRAFTING',
      jobId: params.jobId,
    });
  }

  private async executeContentGeneration(
    dto: GenerateContentDto,
    userId: string | undefined,
    prompt: {
      topicId: string;
      topicName: string;
      content: string;
      type?: string;
    },
    promptId: string,
    referencePageUrl: string | undefined,
    jobId?: string,
  ): Promise<ContentProcessResult> {
    const targetKeywords =
      dto.keywords && dto.keywords.length > 0
        ? dto.keywords
        : [prompt.topicName];

    // Angle resolution BEFORE creating draft — lightweight crawl, no image extraction
    let angle: ArticleAngleDto | null = null;
    if (dto.contentType !== ContentType.SOCIAL_MEDIA_POST) {
      let refContent: ReferencePageContentDto | undefined;
      if (referencePageUrl) {
        try {
          const crawlResult =
            await this.webSearchService.crawl(referencePageUrl);
          refContent = {
            content: crawlResult.content,
            url: crawlResult.url,
            title: crawlResult.title,
          };
        } catch (err) {
          this.logger.warn(
            `[AngleResolution] Failed to crawl reference: ${referencePageUrl}`,
            err,
          );
        }
      }

      angle = await this.resolveUniqueAngle(
        dto.projectId,
        prompt.topicName,
        targetKeywords,
        {
          content: prompt.content,
          type: prompt.type ?? 'AWARENESS',
        },
        refContent,
        userId,
        promptId,
        referencePageUrl,
      );
    }

    const contentRecord = await this.createDraftContentRecord({
      topicId: prompt.topicId,
      promptId,
      profileId: dto.contentProfileId,
      targetKeywords,
      contentType: dto.contentType,
      platform: dto.platform,
      jobId,
    });

    const contentId = contentRecord.id;

    try {
      const dtoWithReference = { ...dto, referencePageUrl };

      const contentInput = await this.getContentInputsForTopic(
        prompt.topicId,
        promptId,
        contentId,
        dtoWithReference,
        jobId,
      );

      let finalRetrievedPages: { url: string; title?: string }[] = [];
      if (referencePageUrl) {
        finalRetrievedPages = [
          {
            url: referencePageUrl,
            title: contentInput.referencePageContent?.title || 'Unknown Title',
          },
        ];
      }

      await this.contentRepository.update(contentId, {
        retrievedPages: finalRetrievedPages,
      });

      if (angle) {
        contentInput.prompt = {
          ...contentInput.prompt,
          content: [
            contentInput.prompt.content,
            '',
            '## Article Angle',
            `Title: ${angle.title}`,
            `Angle: ${angle.angle}`,
            `Differentiators: ${angle.differentiators.join(', ')}`,
          ].join('\n'),
        };
      }

      const workflowResponse = await this.n8nService.generateContentFromPrompt(
        contentInput,
        dto.contentType || 'blog_post',
        contentRecord.contentFormat as ContentFormat,
        dto.platform,
        jobId,
        dto.improvement,
      );

      return {
        contentId,
        contentInput,
        workflowResponse,
        finalRetrievedPages,
      };
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Unknown error';
      this.logger.error(
        `[Generate] Failed for content ${contentId}: ${message}`,
      );
      await this.contentRepository.update(contentId, {
        completionStatus: CompletionStatus.Failed,
        body: `Generation failed: ${message}`,
      });
      throw error;
    }
  }

  async saveGeneratedContent(
    contentId: string,
    generatedContent: GeneratedContentWithThumbnail,
    userId: string | undefined,
    featuredImageUrl?: string | null,
  ): Promise<{ title: string; slug: string; body: string }> {
    // Find the content record
    const contentRecord = await this.contentRepository.findById(contentId);
    if (!contentRecord) {
      throw new NotFoundException('Content record not found');
    }

    const topic = await this.topicRepository.findById(contentRecord.topicId);
    if (!topic) {
      throw new NotFoundException('Topic not found');
    }

    const project = await this.projectRepository.findById(topic.projectId);
    if (!project) {
      throw new NotFoundException('Project not found or access denied');
    }

    const title = generatedContent.title || extractTitle(generatedContent.body);

    const baseSlug = slugify(title);
    const safeBaseSlug = baseSlug || `content-${contentId.slice(0, 8)}`;
    const slug = await this.getUniqueSlug(safeBaseSlug, contentId);

    let cleanBody = generatedContent.body;
    const h1Regex = /^#\s+(.+)$/m;
    const match = cleanBody.match(h1Regex);
    if (match && match[1].trim() === title.trim()) {
      cleanBody = cleanBody.replace(h1Regex, '').trim();
    }

    const finalStatus =
      generatedContent.completionStatus || CompletionStatus.Published;
    const publishedAt =
      finalStatus === CompletionStatus.Published
        ? new Date().toISOString()
        : null;

    await this.contentRepository.update(contentId, {
      title,
      slug,
      completionStatus: finalStatus,
      body: cleanBody,
      publishedBody:
        finalStatus === CompletionStatus.Published ? cleanBody : null,
      targetKeywords: generatedContent.targetKeywords,
      retrievedPages: generatedContent.retrievedPages,
      thumbnailKey: generatedContent.thumbnailKey,
      publishedAt,
      ...(featuredImageUrl !== undefined && { featuredImageUrl }),
    });

    if (generatedContent.contentInsight?.length > 0) {
      await this.saveContentInsights(
        contentId,
        generatedContent.contentInsight,
      );
    }

    // Post-publish: embed into Qdrant + insert internal links (blog posts only)
    if (
      finalStatus === CompletionStatus.Published &&
      topic &&
      contentRecord.contentType === 'blog_post'
    ) {
      this.vectorSearchService
        .upsertContent(topic.projectId, {
          contentId,
          title,
          body: cleanBody,
          slug,
          targetKeywords: generatedContent.targetKeywords ?? [],
          topicId: topic.id,
          topicName: topic.name,
        })
        .catch((err) =>
          this.logger.warn(`Failed to embed content ${contentId} on save`, err),
        );
    }

    this.logger.log(`Saving generated content for content ${contentId}`);

    return { title, slug, body: cleanBody };
  }

  private async saveContentInsights(
    contentId: string,
    insights: Array<{
      insightGroup: string;
      type: string;
      content: string | string[];
    }>,
  ): Promise<void> {
    await this.contentInsightRepository.deleteByContentId(contentId);

    // Filter out insights with missing required fields
    const validInsights = insights.filter(
      (insight) => insight.insightGroup && insight.type && insight.content,
    );

    // Group insights by (insightGroup, type)
    const groupedInsights = new Map<string, string[]>();

    for (const insight of validInsights) {
      const key = `${insight.insightGroup}|${insight.type}`;
      const content = Array.isArray(insight.content)
        ? insight.content
        : [insight.content];

      if (groupedInsights.has(key)) {
        groupedInsights.get(key)!.push(...content);
      } else {
        groupedInsights.set(key, content);
      }
    }

    // Convert grouped insights to insert records
    const insightRecords = Array.from(groupedInsights.entries()).map(
      ([key, contents]) => {
        const [insightGroup, type] = key.split('|');
        return {
          contentId,
          insightGroup: insightGroup as InsightGroup,
          type: type as InsightType,
          content: contents.length === 1 ? contents[0] : contents,
        };
      },
    );

    if (insightRecords.length > 0) {
      const insertedInsights =
        await this.contentInsightRepository.insertMany(insightRecords);
      this.logger.log(
        `Inserted ${insertedInsights.length} insights for content ${contentId}`,
      );
    }
  }

  async getUniqueSlug(baseSlug: string, currentId?: string): Promise<string> {
    let slug = baseSlug;
    let counter = 1;

    while (counter <= MAX_SLUG_ATTEMPTS) {
      const existing = await this.contentRepository.findBySlug(slug);

      if (!existing || (currentId && existing.id === currentId)) {
        return slug;
      }

      slug = `${baseSlug}-${counter}`;
      counter++;
    }

    throw new ConflictException(
      `Could not generate a unique slug for "${baseSlug}" after ${MAX_SLUG_ATTEMPTS} attempts`,
    );
  }

  private normalizeRetrievedPages(
    raw: unknown,
  ): Array<{ url: string; title?: string }> {
    if (!raw) return [];

    if (Array.isArray(raw))
      return raw as Array<{ url: string; title?: string }>;

    if (typeof raw === 'object') {
      return Object.values(raw).filter(
        (p): p is { url: string; title?: string } =>
          p != null && typeof p === 'object',
      );
    }

    return [];
  }

  async updateContentJobProgress(
    jobId: string,
    newStep: string,
  ): Promise<void> {
    const content = await this.contentRepository.findByJobId(jobId);
    if (!content) {
      this.logger.warn(`[JobProgress] No content found for jobId: ${jobId}`);
      return;
    }
    await this.contentRepository.updateJobProgress(content.id, newStep);
  }

  async getContentByJobId(
    jobId: string,
    _userId?: string,
  ): Promise<ContentDto | null> {
    const content = await this.contentRepository.findByJobId(jobId);

    if (!content) {
      return null;
    }

    const targetKeywords = Array.isArray(content.targetKeywords)
      ? (content.targetKeywords as string[])
      : [];

    return {
      id: content.id,
      title: content.title || undefined,
      slug: content.slug || undefined,
      thumbnail: this.toThumbnailDto(content.thumbnailKey),
      body: content.body,
      publishedBody: content.publishedBody ?? null,
      completionStatus: content.completionStatus as CompletionStatus,
      contentFormat: content.contentFormat as ContentFormat,
      createdAt: content.createdAt,
      publishedAt: content.publishedAt,
      featuredImageUrl: (content as any).featuredImageUrl ?? null,
      targetKeywords,
      retrievedPages: this.normalizeRetrievedPages(content.retrievedPages),
      topic: {
        id: content.topic?.id || '',
        name: content.topic?.name || '',
        projectId: content.topic?.projectId || '',
      },
      profile: {
        id: content.profile?.id || DEFAULT_CONTENT_PROFILE.ID,
        name: content.profile?.name || DEFAULT_CONTENT_PROFILE.NAME,
        voiceAndTone:
          content.profile?.voiceAndTone ||
          DEFAULT_CONTENT_PROFILE.VOICE_AND_TONE,
        audience: content.profile?.audience || DEFAULT_CONTENT_PROFILE.AUDIENCE,
        description: content.profile?.description || null,
      },
      prompt: {
        id: content.prompt?.id || '',
        content: content.prompt?.content || '',
        type: content.prompt?.type || 'Informational',
      },
      contentType:
        (content.contentType as ContentType) || ContentType.BLOG_POST,
      platform: (content.platform as SocialPlatform) || null,
      stepHistory: (content.stepHistory as string[]) || [],
    } as unknown as ContentDto & { stepHistory: string[] };
  }

  private async validateContentRelevance(
    promptText: string,
    pageContent: string,
    userId: string, // userId or projectId when called from scheduler
  ): Promise<{ isRelevant: boolean; reason: string }> {
    try {
      const truncatedContent = pageContent;

      const validationPrompt = [
        `**Prompt:** ${promptText}`,
        '',
        `**Page Content:**`,
        truncatedContent,
      ].join('\n');

      const result = await this.agentService.execute<{
        is_relevant: boolean;
        reason: string;
      }>(userId, CONTENT_RELEVANCE_AGENT, validationPrompt);

      this.logger.log(
        `Content relevance validation: is_relevant=${result.is_relevant}, reason=${result.reason}`,
      );

      return { isRelevant: result.is_relevant, reason: result.reason };
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Unknown';
      this.logger.warn(
        `Content relevance validation failed, treating as relevant: ${message}`,
      );
      // On validation failure, treat as irrelevant to prioritize content quality
      return { isRelevant: false, reason: `Validation failed: ${message}` };
    }
  }

  private async resolveReferenceUrlForScheduler(
    url: string | undefined,
    promptId: string,
    promptText: string,
    projectId: string,
  ): Promise<
    { url: string } | { url: null; reason: string; exhausted: boolean }
  > {
    const project = await this.projectRepository.findById(projectId);
    if (!project)
      return { url: null, reason: 'Project not found', exhausted: false };

    // Collect candidate URLs: provided URL first, then Google search
    const candidates: string[] = [];
    if (url) candidates.push(url);

    try {
      const googleResults = await this.webSearchService.search(
        extractSearchQuery(promptText),
        { lang: project.language, loc: project.location },
      );
      candidates.push(...googleResults.map((r) => r.url));
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Unknown';
      this.logger.warn(`[Scheduler] Search for reference failed: ${message}`);
    }

    if (candidates.length === 0)
      return {
        url: null,
        reason:
          "We couldn't find any information on the web for this topic. Please try adding more detail or keywords to your prompt.",
        exhausted: true,
      };

    // Filter out used and blacklisted URLs
    const usedUrls =
      await this.contentRepository.getUsedReferenceUrls(promptId);
    const blacklistedUrls =
      await this.promptRepository.getBlacklistedUrls(promptId);
    const excludedSet = new Set([...usedUrls, ...blacklistedUrls]);

    const firstEligible = candidates.find((c) => !excludedSet.has(c));
    if (!firstEligible)
      return {
        url: null,
        reason:
          'All available sources for this topic have already been used. Please try a different topic.',
        exhausted: true,
      };

    // Crawl
    const crawlResult = await this.webSearchService.crawl(firstEligible);
    if (!crawlResult.content || crawlResult.content.trim().length === 0) {
      await this.promptRepository.addBlacklistedUrl(
        promptId,
        firstEligible,
        'Empty content after crawl',
      );
      return {
        url: null,
        reason:
          "The source website we found couldn't be read at this time. We will try another source in the next run.",
        exhausted: false,
      };
    }

    // Validate relevance
    const validation = await this.validateContentRelevance(
      promptText,
      crawlResult.content,
      'system',
    );

    if (!validation.isRelevant) {
      await this.promptRepository.addBlacklistedUrl(
        promptId,
        firstEligible,
        validation.reason,
      );
      return {
        url: null,
        reason: `The content of reference page "${firstEligible}" is not related to the prompt: "${promptText}"`,
        exhausted: false,
      };
    }

    return { url: firstEligible };
  }

  private async markPromptExhausted(promptId: string): Promise<void> {
    try {
      await this.promptRepository.setExhausted(promptId, true);
      this.logger.log(
        `[Scheduler] Marked prompt ${promptId} as exhausted — no valid reference pages remain`,
      );
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Unknown';
      this.logger.warn(
        `[Scheduler] Failed to mark prompt ${promptId} as exhausted: ${message}`,
      );
    }
  }

  private async embedContentAsync(contentId: string): Promise<void> {
    const content =
      await this.contentRepository.findByIdWithRelations(contentId);
    if (!content?.topic) return;

    await this.vectorSearchService.upsertContent(content.topic.projectId, {
      contentId: content.id,
      title: content.title ?? '',
      body: content.publishedBody ?? content.body ?? '',
      slug: content.slug ?? '',
      targetKeywords: (content.targetKeywords as string[]) ?? [],
      topicId: content.topic.id,
      topicName: content.topic.name,
    });
  }

  async backfillEmbeddings(limit?: number): Promise<{
    projectsProcessed: number;
    totalEmbedded: number;
  }> {
    const published = await this.contentRepository.findAllPublishedBlogs(limit);

    // Group by projectId for batch upsert
    const byProject = new Map<string, typeof published>();
    for (const content of published) {
      const projectId = content.topic?.projectId;
      if (!projectId) continue;
      const group = byProject.get(projectId) ?? [];
      group.push(content);
      byProject.set(projectId, group);
    }

    let totalEmbedded = 0;
    const BATCH_SIZE = 20;

    for (const [projectId, contents] of byProject) {
      const payloads = contents.map((c) => ({
        contentId: c.id,
        title: c.title ?? '',
        body: c.publishedBody ?? c.body ?? '',
        slug: c.slug ?? '',
        targetKeywords: (c.targetKeywords as string[]) ?? [],
        topicId: c.topic?.id ?? '',
        topicName: c.topic?.name ?? '',
      }));

      this.logger.log(
        `[BackfillEmbeddings] Project ${projectId} payloads=${payloads.length} batches=${Math.ceil(payloads.length / BATCH_SIZE)}`,
      );

      for (let i = 0; i < payloads.length; i += BATCH_SIZE) {
        const batch = payloads.slice(i, i + BATCH_SIZE);
        try {
          await this.vectorSearchService.backfill(projectId, batch);
          totalEmbedded += batch.length;
          this.logger.log(
            `[BackfillEmbeddings] Project ${projectId}: batch ${i / BATCH_SIZE + 1}, embedded ${batch.length} contents`,
          );
        } catch (err) {
          this.logger.warn(
            `[BackfillEmbeddings] Project ${projectId}: batch ${i / BATCH_SIZE + 1} failed`,
            err,
          );
        }
      }
    }

    return { projectsProcessed: byProject.size, totalEmbedded };
  }

  private async resolveUniqueAngle(
    projectId: string,
    topicName: string,
    targetKeywords: string[],
    prompt: { content: string; type: string },
    referencePageContent: ReferencePageContentDto | undefined,
    userId: string | undefined,
    promptId?: string,
    referencePageUrl?: string,
  ): Promise<ArticleAngleDto | null> {
    try {
      const refContent = referencePageContent?.content?.substring(
        0,
        MAX_REF_CONTENT_LENGTH,
      );

      const sections: string[] = [
        `## Project ID\n${projectId}`,
        `## Topic\n${topicName}`,
        `## Target Keywords\n${targetKeywords.join(', ')}`,
        `## Prompt Content\n${prompt.content}`,
        `## Prompt Type (User Intent)\n${prompt.type}`,
      ];

      if (referencePageContent?.title || refContent) {
        let refSection = '## Reference Page\n';
        if (referencePageContent?.title) {
          refSection += `Title: ${referencePageContent.title}\n\n`;
        }
        if (refContent) {
          refSection += `Content:\n${refContent}`;
        }
        sections.push(refSection);
      }

      const agentResult = await this.agentService.execute<{
        title: string;
        angle: string;
        differentiators: string[];
        similarity_score: number;
        is_unique: boolean;
        overlapping_content_id: string | null;
      } | null>(userId || 'system', ANGLE_AGENT, sections.join('\n\n'));

      if (!agentResult?.title || !agentResult?.angle) {
        this.logger.log('[AngleResolution] Agent returned no viable angle');
        return null;
      }

      this.logger.log(
        `[AngleResolution] Agent resolved angle (score: ${agentResult.similarity_score}, unique: ${agentResult.is_unique})`,
      );

      // Threshold calibrated via pairwise benchmark (agents/scripts/analyze_similarity_scores.py).
      // In our niche, scores 0.86+ are duplicates. 0.85 adds safety margin.
      // Do NOT lower without re-running the benchmark.
      if (!agentResult.is_unique && agentResult.similarity_score >= 0.85) {
        if (
          promptId &&
          referencePageUrl &&
          agentResult.overlapping_content_id
        ) {
          const overlapping = await this.contentRepository.findById(
            agentResult.overlapping_content_id,
          );
          const overlappingLabel =
            overlapping?.title || agentResult.overlapping_content_id;
          await this.promptRepository.addBlacklistedUrl(
            promptId,
            referencePageUrl,
            `Angle conflict (score: ${agentResult.similarity_score}) with existing article "${overlappingLabel}"`,
          );
        }
        throw new ConflictException({
          message: 'A similar article already exists for this topic',
          overlappingContentId: agentResult.overlapping_content_id,
          similarityScore: agentResult.similarity_score,
        });
      }

      return {
        title: agentResult.title,
        angle: agentResult.angle,
        differentiators: agentResult.differentiators,
      };
    } catch (error) {
      if (error instanceof ConflictException) throw error;
      const message = error instanceof Error ? error.message : 'Unknown';
      this.logger.warn(`[AngleResolution] Agent call failed: ${message}`);
      return null;
    }
  }
}
