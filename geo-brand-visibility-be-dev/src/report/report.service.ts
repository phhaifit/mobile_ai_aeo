import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { render } from '@react-email/render';
import { MailService } from '../mail/mail.service';
import { ReportData } from './types/report-data.type';
import { VisibilityReportEmail } from './templates/visibility-report';
import { PromptRepository } from '../prompt/prompt.repository';
import { ProjectMemberRepository } from '../project-member/project-member.repository';
import { ProjectRepository } from '../project/project.repository';
import { ContentRepository } from '../content/content.repository';
import {
  calcMentionRate,
  calcReferenceRate,
  calcVisibilityScore,
} from '../utils/metrics.util';

@Injectable()
export class ReportService {
  private readonly logger = new Logger(ReportService.name);
  private readonly appUrl: string;

  constructor(
    private readonly mailService: MailService,
    private readonly configService: ConfigService,
    private readonly promptRepository: PromptRepository,
    private readonly contentRepository: ContentRepository,
    private readonly projectMemberRepository: ProjectMemberRepository,
    private readonly projectRepository: ProjectRepository,
  ) {
    this.appUrl =
      this.configService.get<string>('APP_URL') || 'https://app.aeo.how';
  }

  async generateAndSendAnalysisReport(
    projectId: string,
    brand: string,
  ): Promise<void> {
    this.logger.log('Start generating brand visibility report');
    const [models, receivers] = await Promise.all([
      this.projectRepository.getModelsByProjectId(projectId),
      this.projectMemberRepository.findAllMemberEmails(projectId),
    ]);

    if (receivers.length === 0) {
      this.logger.log('Finish generating report: No recipients found');
      return;
    }

    const modelNames = models.map((m) => m.name);

    const now = new Date();
    const currentMonthStart = new Date(now.getFullYear(), now.getMonth(), 1);
    const previousMonthStart = new Date(
      now.getFullYear(),
      now.getMonth() - 1,
      1,
    );

    this.logger.log(
      'Start fetching analysis results for current and previous month',
    );
    const [currentResults, previousResults, newPromptStats, newContentStats] =
      await Promise.all([
        this.promptRepository.getAnalysisResultByProjectId(
          projectId,
          currentMonthStart.toISOString(),
          now.toISOString(),
        ),
        this.promptRepository.getAnalysisResultByProjectId(
          projectId,
          previousMonthStart.toISOString(),
          currentMonthStart.toISOString(),
        ),
        this.promptRepository.getNewPromptStats(
          projectId,
          currentMonthStart.toISOString(),
          now.toISOString(),
        ),
        this.contentRepository.getNewContentStats(
          projectId,
          currentMonthStart.toISOString(),
          now.toISOString(),
        ),
      ]);
    this.logger.log(
      'Finished fetching analysis results for current and previous month',
    );

    const total = currentResults.length;

    if (total === 0) {
      this.logger.log(
        `Skipping report — no analysis results for project ${projectId}`,
      );
      return;
    }

    let brandMentions = 0;
    let linkReferences = 0;
    const competitorCounts: Record<string, number> = {};
    const modelBrandMentions: Record<string, number> = {};
    const domainFrequency: Record<string, number> = {};
    const promptBestRanking: Record<
      string,
      { content: string; position: number }
    > = {};

    for (const result of currentResults) {
      const modelName = result.model.name;

      if (result.position != null) {
        brandMentions++;
        modelBrandMentions[modelName] =
          (modelBrandMentions[modelName] || 0) + 1;

        const existing = promptBestRanking[result.promptId];
        if (!existing || result.position < existing.position) {
          promptBestRanking[result.promptId] = {
            content: result.prompt,
            position: result.position,
          };
        }
      }

      if (result.isCited) {
        linkReferences++;
      }

      for (const comp of result.competitors) {
        competitorCounts[comp.name] = (competitorCounts[comp.name] || 0) + 1;
      }

      for (const citation of result.citations) {
        domainFrequency[citation.domain] =
          (domainFrequency[citation.domain] || 0) + 1;
      }
    }

    const brandMentionsRate = calcMentionRate(brandMentions, total);
    const linkReferencesRate = calcReferenceRate(linkReferences, total);
    const brandVisibilityScore = calcVisibilityScore(
      brandMentions,
      linkReferences,
      total,
    );

    // Compute deltas compared to previous period
    let brandMentionsRateDelta: number | null = null;
    let linkReferencesRateDelta: number | null = null;

    if (previousResults.length > 0) {
      const prevTotal = previousResults.length;
      let prevBrandMentions = 0;
      let prevLinkReferences = 0;

      for (const r of previousResults) {
        if (r.position != null) prevBrandMentions++;
        if (r.isCited) prevLinkReferences++;
      }

      const prevBrandMentionsRate = calcMentionRate(
        prevBrandMentions,
        prevTotal,
      );
      const prevLinkReferencesRate = calcReferenceRate(
        prevLinkReferences,
        prevTotal,
      );

      brandMentionsRateDelta = brandMentionsRate - prevBrandMentionsRate;
      linkReferencesRateDelta = linkReferencesRate - prevLinkReferencesRate;
    }

    // Compute competitor ranks (top 5)
    const competitorRanks = Object.entries(competitorCounts)
      .map(([name, count]) => ({
        name,
        mentionRate: (count / total) * 100,
      }))
      .sort((a, b) => b.mentionRate - a.mentionRate)
      .slice(0, 5);

    // Compute platform breakdown
    const totalBrandMentions = brandMentions || 1;
    const platformBreakdown = modelNames
      .map((name) => ({
        name,
        mentionRate:
          ((modelBrandMentions[name] || 0) / totalBrandMentions) * 100,
      }))
      .sort((a, b) => b.mentionRate - a.mentionRate);

    // Compute prompts mentioning brand with best ranking
    const promptsMentioningBrand = Object.entries(promptBestRanking)
      .map(([id, { content, position }]) => ({
        content,
        ranking: position,
        url: `${this.appUrl}/prompts/${id}?context=project&project_id=${projectId}`,
      }))
      .sort((a, b) => a.ranking - b.ranking);

    // Compute top referenced domains
    const topReferencedDomains = Object.entries(domainFrequency)
      .map(([domain, frequency]) => ({ domain, frequency }))
      .sort((a, b) => b.frequency - a.frequency)
      .slice(0, 5);

    // Construct report data
    const executionDate = new Date().toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'long',
      day: '2-digit',
    });

    const reportData: ReportData = {
      projectName: brand,
      brandName: brand,
      executionDate,
      summary: {
        brandVisibilityScore,
        brandMentionsRate,
        brandMentionsRateDelta,
        linkReferencesRate,
        linkReferencesRateDelta,
        promptGeneration: newPromptStats,
        contentGeneration: newContentStats,
      },
      competitorRanks,
      platformBreakdown,
      promptsMentioningBrand,
      topReferencedDomains,
      overviewUrl: `${this.appUrl}/overview?project_id=${projectId}`,
    };

    // Render email template and send to all project members
    const html = await render(VisibilityReportEmail(reportData));
    const subject = `Brand Visibility Report — ${reportData.projectName} (${executionDate})`;

    await Promise.allSettled(
      receivers.map((email) => this.mailService.sendMail(email, subject, html)),
    );

    this.logger.log(
      `Report sent to ${receivers.length} members for project ${projectId}`,
    );
  }
}
