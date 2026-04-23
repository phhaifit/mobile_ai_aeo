import { Injectable, Logger, NotFoundException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { AgentService } from 'src/agent/agent.service';
import { BrandRepository } from 'src/brand/brand.repository';
import { TopicRepository } from 'src/topic/topic.repository';
import { ContentProfileRepository } from 'src/content-profile/content-profile.repository';
import { ContentRepository } from 'src/content/content.repository';
import { ContentService } from 'src/content/content.service';
import { N8nService } from 'src/n8n/n8n.service';
import { ProjectRepository } from 'src/project/project.repository';
import { SseService } from 'src/sse/sse.service';
import {
  GenerateClusterPlanDto,
  GenerateClusterArticlesDto,
  ClusterPlanArticleDto,
} from './dto/cluster.dto';
import { LanguageUtil } from 'src/shared/utils/language';
import { CountryUtil } from 'src/shared/utils/country';
import {
  CompletionStatus,
  ContentFormat,
  ContentStrategy,
} from 'src/content/enums';
import { ContentType } from 'src/content/dto/generate-content.dto';

export interface ClusterPlanResponse {
  articles: ClusterPlanArticleDto[];
}

interface GeneratedArticleResult {
  contentId: string;
  title: string;
  slug?: string;
  role: string;
}

@Injectable()
export class ContentClusterService {
  private readonly logger = new Logger(ContentClusterService.name);
  private readonly languageUtil = new LanguageUtil();
  private readonly countryUtil = new CountryUtil();

  constructor(
    private readonly agentService: AgentService,
    private readonly brandRepository: BrandRepository,
    private readonly topicRepository: TopicRepository,
    private readonly contentProfileRepository: ContentProfileRepository,
    private readonly contentRepository: ContentRepository,
    private readonly contentService: ContentService,
    private readonly n8nService: N8nService,
    private readonly projectRepository: ProjectRepository,
    private readonly configService: ConfigService,
    private readonly sseService: SseService,
  ) {}

  async generateClusterPlan(
    dto: GenerateClusterPlanDto,
    userId: string,
  ): Promise<ClusterPlanResponse> {
    const topic = await this.topicRepository.findById(dto.topicId);
    if (!topic) {
      throw new NotFoundException('Topic not found');
    }

    const project = await this.projectRepository.findById(topic.projectId);
    if (!project) {
      throw new NotFoundException('Project not found');
    }

    const brand = await this.brandRepository.findByProjectId(topic.projectId);
    if (!brand) {
      throw new NotFoundException('Brand not found');
    }

    const language = this.languageUtil.getLanguageName(project.language);
    const location = this.countryUtil.getCountryName(project.location);

    const promptContext = [
      `Plan a topic cluster for the following topic: "${topic.name}"`,
      topic.description ? `Description: ${topic.description}` : '',
      `Language: ${language}`,
      `Location: ${location}`,
      '',
      'Brand information:',
      `- Brand Name: ${brand.name}`,
      `- Industry: ${brand.industry}`,
      `- Products/Services: ${brand.services?.map((s: any) => `${s.name}: ${s.description || ''}`).join(', ') || 'N/A'}`,
      `- Mission: ${brand.mission}`,
      `- Target Market: ${brand.targetMarket}`,
    ]
      .filter(Boolean)
      .join('\n');

    const result = await this.agentService.execute<ClusterPlanResponse>(
      userId,
      'cluster_planning',
      promptContext,
    );

    return result;
  }

  async generateClusterArticles(
    dto: GenerateClusterArticlesDto,
    userId: string,
    jobId: string,
  ): Promise<GeneratedArticleResult[]> {
    const topic = await this.topicRepository.findById(dto.topicId);
    if (!topic) {
      throw new NotFoundException('Topic not found');
    }

    const project = await this.projectRepository.findById(topic.projectId);
    if (!project) {
      throw new NotFoundException('Project not found');
    }

    const brand = await this.brandRepository.findByProjectId(topic.projectId);
    if (!brand) {
      throw new NotFoundException('Brand not found');
    }

    let contentProfile:
      | { voiceAndTone: string; audience: string; description?: string }
      | undefined;
    if (dto.profileId) {
      const profile = await this.contentProfileRepository.findById(
        dto.profileId,
      );
      if (profile) {
        contentProfile = {
          voiceAndTone: profile.voiceAndTone,
          audience: profile.audience,
          description: profile.description || '',
        };
      }
    }

    if (!contentProfile) {
      contentProfile = {
        voiceAndTone: brand.mission || 'Professional',
        audience: brand.targetMarket || 'General audience',
      };
    }

    const language = this.languageUtil.getLanguageName(project.language);
    const location = this.countryUtil.getCountryName(project.location);
    const blogBaseUrl = `/${brand.slug}/blog`;

    // Sort: pillar first, then satellites
    const sortedArticles = [...dto.articles].sort((a, b) => {
      if (a.role === 'PILLAR' && b.role !== 'PILLAR') return -1;
      if (a.role !== 'PILLAR' && b.role === 'PILLAR') return 1;
      return 0;
    });

    const pillarArticle = sortedArticles.find((a) => a.role === 'PILLAR');
    const results: GeneratedArticleResult[] = [];
    let pillarSlug = '';

    for (let i = 0; i < sortedArticles.length; i++) {
      const article = sortedArticles[i];
      const articleIndex = i + 1;
      const totalArticles = sortedArticles.length;

      const stepLabel =
        article.role === 'PILLAR'
          ? `Generating pillar article: ${article.title}`
          : `Generating satellite ${articleIndex - 1}/${totalArticles - 1}: ${article.title}`;

      this.sseService.send(jobId, 'step', {
        step: stepLabel,
        articleIndex: i,
      });

      // Create draft content record before try so catch can reference it
      let contentRecord: { id: string } | null = null;
      try {
        contentRecord = await this.contentRepository.create({
          topicId: dto.topicId,
          promptId: null,
          profileId: dto.profileId || null,
          targetKeywords: article.targetKeywords,
          retrievedPages: [],
          body: '',
          title: '',
          contentFormat: ContentFormat.Markdown,
          completionStatus: CompletionStatus.Drafting,
          contentStrategy: ContentStrategy.Cluster,
          jobId,
        });

        // Build cluster context for N8N
        const siblingArticles = sortedArticles
          .filter((_, idx) => idx !== i)
          .map((a) => ({
            title: a.title,
            slug: a.suggestedSlug || '',
            role: a.role,
          }));

        // For satellites, use actual pillar slug if already generated
        const effectivePillarSlug =
          article.role === 'SATELLITE' && pillarSlug
            ? pillarSlug
            : pillarArticle?.suggestedSlug || '';

        const clusterPayload = {
          brandIdentity: {
            name: brand.name,
            description: brand.description,
            mission: brand.mission,
            targetMarket: brand.targetMarket,
            industry: brand.industry,
            services:
              brand.services?.map((s: any) => ({
                name: s.name,
                description: s.description || '',
              })) || [],
          },
          specificTopic: { name: topic.name },
          contentProfile: {
            voiceAndTone: contentProfile.voiceAndTone,
            audience: contentProfile.audience,
            description: contentProfile.description || '',
          },
          keywords: article.targetKeywords,
          language,
          location,
          clusterContext: {
            articleTitle: article.title,
            articleRole: article.role,
            articleOutline: article.outline,
            pillarTitle: pillarArticle?.title || article.title,
            pillarSlug: effectivePillarSlug,
            siblingArticles,
            blogBaseUrl,
          },
          jobId,
          callbackUrl: this.configService.get<string>('N8N_CALLBACK_URL') || '',
        };

        const workflowResponse =
          await this.n8nService.generateClusterContent(clusterPayload);

        if (!workflowResponse.success) {
          this.logger.error(`Failed to generate article: ${article.title}`);
          await this.contentRepository.update(contentRecord.id, {
            completionStatus: CompletionStatus.Failed,
          });
          const failedResult: GeneratedArticleResult = {
            contentId: contentRecord.id,
            title: article.title,
            role: article.role,
          };
          results.push(failedResult);
          this.sseService.send(jobId, 'article-complete', failedResult);
          continue;
        }

        // Save generated content using existing pattern
        const savedData = await this.contentService.saveGeneratedContent(
          contentRecord.id,
          {
            id: contentRecord.id,
            topicId: dto.topicId,
            profileId: dto.profileId || '',
            targetKeywords:
              workflowResponse.targetKeywords || article.targetKeywords,
            retrievedPages: [],
            contentInsight: workflowResponse.contentInsight || [],
            completionStatus: workflowResponse.success
              ? CompletionStatus.Complete
              : CompletionStatus.Failed,
            contentFormat: ContentFormat.Markdown,
            contentType: ContentType.BLOG_POST,
            body: workflowResponse.body || '',
            title: workflowResponse.title || article.title,
            createdAt: new Date().toISOString(),
          },
          userId,
        );

        // Track pillar slug for satellite internal links
        if (article.role === 'PILLAR' && savedData.slug) {
          pillarSlug = savedData.slug;
        }

        const articleResult: GeneratedArticleResult = {
          contentId: contentRecord.id,
          title: savedData.title || article.title,
          slug: savedData.slug,
          role: article.role,
        };
        results.push(articleResult);

        this.sseService.send(jobId, 'step', {
          step: `Completed: ${article.title}`,
          articleIndex: i,
        });
        this.sseService.send(jobId, 'article-complete', articleResult);
      } catch (error) {
        this.logger.error(
          `Error generating article "${article.title}":`,
          error,
        );

        // Mark the orphaned draft as failed so it doesn't stay stuck in DRAFTING
        if (contentRecord) {
          try {
            await this.contentRepository.update(contentRecord.id, {
              completionStatus: CompletionStatus.Failed,
            });
          } catch (updateError) {
            this.logger.error(
              `Failed to mark content ${contentRecord.id} as FAILED:`,
              updateError,
            );
          }
        }

        const errorResult: GeneratedArticleResult = {
          contentId: contentRecord?.id || '',
          title: article.title,
          role: article.role,
        };
        results.push(errorResult);
        this.sseService.send(jobId, 'article-complete', errorResult);
      }
    }

    return results;
  }
}
