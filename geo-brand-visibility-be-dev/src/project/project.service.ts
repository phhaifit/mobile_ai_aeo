import {
  Injectable,
  Logger,
  NotFoundException,
  ConflictException,
} from '@nestjs/common';
import { ProjectRepository } from './project.repository';
import { ProjectResponseDto } from './dto/project-response.dto';
import { UpdateProjectDto } from './dto/update-project.dto';
import { MetricsOverviewDto, MetricsAnalyticsDto } from './dto/metrics.dto';
import { Enums, Tables } from '../supabase/supabase.types';
import { PromptRepository } from '../prompt/prompt.repository';
import { AgentService } from '../agent/agent.service';
import { BrandRepository } from '../brand/brand.repository';
import { ProjectMemberRole } from 'src/project-member/enum/member-role.enum';
import { ACTIVE_STATUSES } from '../subscription/subscription.constants';
import { ProjectMemberRepository } from 'src/project-member/project-member.repository';
import { ProjectStatus } from './enum/project-status.enum';
import { DEFAULT_LANGUAGE, DEFAULT_LOCATION } from 'src/shared/constant';
import { TaskEnqueueService } from 'src/task-enqueue/task-enqueue.service';
import { ReportService } from '../report/report.service';
import { ContentAgentService } from '../content-agent/content-agent.service';
import { AnalysisResult } from 'src/shared/types';
import { AGENTS } from 'src/utils/const';
import { SubscriptionRepository } from '../subscription/subscription.repository';
import { ContentProfileService } from 'src/content-profile/content-profile.service';
import { TopicRepository } from '../topic/topic.repository';
import { UserRepository } from '../user/user.repository';
import { StrategyReviewResponseDto } from './dto/strategy-review.dto';
interface DomainDistribution {
  [domain: string]: {
    count: number;
    models: Record<string, number>;
  };
}

import {
  calcMentionRate,
  calcReferenceRate,
  calcVisibilityScore,
} from '../utils/metrics.util';

@Injectable()
export class ProjectService {
  private readonly logger = new Logger(ProjectService.name);

  constructor(
    private readonly projectRepository: ProjectRepository,
    private readonly projectMemberRepository: ProjectMemberRepository,
    private readonly agentService: AgentService,
    private readonly promptRepository: PromptRepository,
    private readonly brandRepository: BrandRepository,
    private readonly taskEnqueueService: TaskEnqueueService,
    private readonly contentAgentService: ContentAgentService,
    private readonly reportService: ReportService,
    private readonly subscriptionRepository: SubscriptionRepository,
    private readonly contentProfileService: ContentProfileService,
    private readonly topicRepository: TopicRepository,
    private readonly userRepository: UserRepository,
  ) {}

  async createProject(
    userId: string,
    location: string = DEFAULT_LOCATION,
    language: string = DEFAULT_LANGUAGE,
    monitoringFrequency: Enums<'monitoring_frequency'> = 'weekly',
  ): Promise<{ project: ProjectResponseDto; isExisting: boolean }> {
    const existingDraft =
      await this.projectRepository.findDraftByUserId(userId);

    if (existingDraft) {
      return { project: existingDraft, isExisting: true };
    }

    try {
      const data = await this.projectRepository.create({
        createdBy: userId,
        location,
        language,
        monitoringFrequency,
        status: ProjectStatus.DRAFT,
      });

      await this.projectMemberRepository.create({
        userId,
        projectId: data.id,
        role: ProjectMemberRole.Admin,
      });

      await this.contentAgentService.seedDefaults(data.id);

      return {
        project: { ...data, models: [] },
        isExisting: false,
      };
    } catch (error) {
      // Handle race condition: if unique constraint is violated,
      // another concurrent request already created the draft
      if (error instanceof ConflictException) {
        const draft = await this.projectRepository.findDraftByUserId(userId);
        if (draft) {
          return { project: draft, isExisting: true };
        }
      }
      throw error;
    }
  }

  async findProjectById(id: string): Promise<ProjectResponseDto> {
    const project = await this.projectRepository.findById(id);

    if (!project) {
      throw new NotFoundException('Project not found');
    }

    return project;
  }

  async getModelsByProjectId(projectId: string): Promise<Tables<'Model'>[]> {
    return this.projectRepository.getModelsByProjectId(projectId);
  }

  async findProjectsByUser(
    userId: string,
    status?: ProjectStatus,
  ): Promise<ProjectResponseDto[]> {
    return this.projectRepository.findAllByUserId(userId, status);
  }

  async getOrCreateUserProject(userId: string): Promise<ProjectResponseDto[]> {
    const projects = await this.projectRepository.findProjectsByUserId(userId);

    if (projects.length === 0) {
      const { project } = await this.createProject(userId);
      return [project];
    }

    return projects;
  }

  async updateProject(
    id: string,
    project: UpdateProjectDto,
  ): Promise<ProjectResponseDto> {
    const updatedProject = await this.projectRepository.update(id, project);

    if (!updatedProject) {
      throw new NotFoundException('Project not found');
    }

    return updatedProject;
  }

  async deleteProject(id: string) {
    const subscription = await this.subscriptionRepository.findByProjectId(id);

    if (
      subscription &&
      ACTIVE_STATUSES.includes(
        subscription.status as (typeof ACTIVE_STATUSES)[number],
      )
    ) {
      throw new ConflictException(
        'Cannot delete a project with an active subscription. Please cancel your subscription first.',
      );
    }

    const data = await this.projectRepository.delete(id);

    if (!data) {
      throw new NotFoundException('Project not found');
    }
  }

  async analyzeProjectHelper(
    projectId: string,
    userId: string,
  ): Promise<any[]> {
    const results: any[] = [];

    const [brand, project, models] = await Promise.all([
      this.brandRepository.findByProjectId(projectId),
      this.projectRepository.findById(projectId),
      this.projectRepository.getModelsByProjectId(projectId),
    ]);

    if (!project || !brand) {
      throw new NotFoundException('Project not found');
    }

    const prompts =
      await this.promptRepository.findAllMonitoredPromptsByProjectId(
        projectId,
        userId,
      );

    for (const prompt of prompts) {
      let changeLastRun = false;

      for (const model of models) {
        try {
          const data = await this.agentService.execute<AnalysisResult>(
            userId,
            AGENTS.VISIBILITY_ANALYSIS_AGENT,
            prompt.content,
            {
              engine_name: model.name,
              brand_id: brand.id,
              brand_name: brand.name,
              brand_domain: brand.domain,
              industry: brand.industry,
            },
          );

          if (data && data.response && data.response.length > 0) {
            await this.promptRepository.insertResponse({
              promptId: prompt.id,
              modelId: model.id,
              ...data,
            });

            changeLastRun = true;
          }
        } catch (error) {
          this.logger.error(error);
        }
      }

      if (changeLastRun) {
        await this.promptRepository.update(prompt.id, {
          lastRun: new Date().toISOString(),
        });
      }
    }

    try {
      await this.reportService.generateAndSendAnalysisReport(
        projectId,
        brand.name,
      );
    } catch (error) {
      this.logger.error(
        `Report generation failed for project ${projectId}: ${error instanceof Error ? error.stack : String(error)}`,
      );
    }

    return results;
  }

  async getMetricsOverview(
    projectId: string,
    start: string,
    end: string,
    userId: string,
  ): Promise<MetricsOverviewDto> {
    const responses = await this.promptRepository.findAllResponsesByProjectId(
      projectId,
      start,
      end,
      userId,
    );
    const totalResponses = responses.length;

    if (totalResponses === 0) {
      return {
        brandVisibilityScore: 0,
        brandMentions: 0,
        brandMentionsRate: 0,
        linkReferences: 0,
        linkReferencesRate: 0,
        domainDistribution: [],
        competitors: {},
      };
    }

    const domainDistributionCompute: DomainDistribution = {};
    const competitorMentions: Record<string, number> = {};
    let brandMentions = 0;
    let linkReferences = 0;

    for (const response of responses) {
      if (response.position != null) brandMentions++;
      if (response.isCited) linkReferences++;

      const citationsLength = response.citations.length;
      if (citationsLength > 0) {
        const modelName = response.model.name;

        for (let i = 0; i < citationsLength; i++) {
          const { domain } = response.citations[i];

          let domainData = domainDistributionCompute[domain];
          if (!domainData) {
            domainData = domainDistributionCompute[domain] = {
              count: 0,
              models: {},
            };
          }

          domainData.count++;
          domainData.models[modelName] =
            (domainData.models[modelName] || 0) + 1;
        }
      }

      const competitorsLength = response.competitors.length;
      if (competitorsLength > 0) {
        for (let i = 0; i < competitorsLength; i++) {
          const name = response.competitors[i].name;
          competitorMentions[name] = (competitorMentions[name] || 0) + 1;
        }
      }
    }

    return {
      brandVisibilityScore: calcVisibilityScore(
        brandMentions,
        linkReferences,
        totalResponses,
      ),
      brandMentions,
      brandMentionsRate: calcMentionRate(brandMentions, totalResponses),
      linkReferences,
      linkReferencesRate: calcReferenceRate(linkReferences, totalResponses),
      domainDistribution: Object.entries(domainDistributionCompute)
        .map(([domain, info]) => {
          const distribution: { [modelName: string]: number } = {};
          for (const [modelName, count] of Object.entries(info.models)) {
            distribution[modelName] = (count / info.count) * 100;
          }

          return {
            domain,
            count: info.count,
            distribution,
          };
        })
        .sort((a, b) => b.count - a.count)
        .slice(0, 30),
      competitors: competitorMentions,
    };
  }

  async getMetricsAnalytics(
    projectId: string,
    start: string,
    end: string,
    models?: string[],
    promptTypes?: Enums<'PromptType'>[],
    granularity?: 'day' | 'month',
  ): Promise<MetricsAnalyticsDto> {
    const project = await this.projectRepository.findById(projectId);
    if (!project) {
      throw new NotFoundException('Project not found');
    }

    const result = await this.projectRepository.getAnalytics(
      projectId,
      start,
      end,
      models,
      promptTypes,
      granularity,
    );

    return result as MetricsAnalyticsDto;
  }

  async cleanupStaleDrafts(): Promise<number> {
    const sevenDaysAgo = new Date();
    sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);
    return this.projectRepository.deleteStaleDrafts(sevenDaysAgo.toISOString());
  }

  async activateAndAnalyzeNewProject(
    projectId: string,
    userId: string,
  ): Promise<void> {
    const project = await this.projectRepository.findById(projectId);
    if (!project) {
      throw new NotFoundException('Project not found');
    }

    await this.projectRepository.update(projectId, {
      status: ProjectStatus.ACTIVE,
    });

    await this.contentProfileService.seedDefaults(projectId, project.language);

    await this.taskEnqueueService.analyzeNewProject(projectId, userId);
  }

  async updateStrategyReview(
    projectId: string,
    userId: string,
    reviewed: boolean,
  ): Promise<StrategyReviewResponseDto> {
    const project = await this.projectRepository.findById(projectId);
    if (!project) {
      throw new NotFoundException('Project not found');
    }

    if (reviewed) {
      // First-reviewer-wins: if already reviewed, return existing state
      if ((project as any).strategyReviewedAt) {
        return {
          strategyReviewedAt: (project as any).strategyReviewedAt,
          strategyReviewedById: (project as any).strategyReviewedById,
          strategyReviewedByName: (project as any).strategyReviewedByName,
        };
      }

      const [user, topics, promptStats, metricsOverview] = await Promise.all([
        this.userRepository.findById(userId),
        this.topicRepository.getTopicsByProjectId(projectId, userId),
        this.promptRepository.getPromptStatsByProjectId(projectId),
        this.getMetricsOverviewLast30Days(projectId, userId),
      ]);

      const reviewerName = user?.fullname || user?.email || 'Unknown';

      const result = await this.projectRepository.updateStrategyReview(
        projectId,
        {
          strategyReviewedAt: new Date().toISOString(),
          strategyReviewedById: userId,
          strategyReviewedByName: reviewerName,
          strategyReviewedTopicCount: topics.length,
          strategyReviewedPromptCount: promptStats.totalCount,
          strategyReviewedScore: metricsOverview.brandVisibilityScore,
        },
      );

      if (!result) {
        throw new NotFoundException('Project not found');
      }

      return result;
    } else {
      const result = await this.projectRepository.updateStrategyReview(
        projectId,
        {
          strategyReviewedAt: null,
          strategyReviewedById: null,
          strategyReviewedByName: null,
          strategyReviewedTopicCount: null,
          strategyReviewedPromptCount: null,
          strategyReviewedScore: null,
        },
      );

      if (!result) {
        throw new NotFoundException('Project not found');
      }

      return result;
    }
  }

  private async getMetricsOverviewLast30Days(
    projectId: string,
    userId: string,
  ): Promise<MetricsOverviewDto> {
    const now = new Date();
    const thirtyDaysAgo = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);
    return this.getMetricsOverview(
      projectId,
      thirtyDaysAgo.toISOString(),
      now.toISOString(),
      userId,
    );
  }
}
