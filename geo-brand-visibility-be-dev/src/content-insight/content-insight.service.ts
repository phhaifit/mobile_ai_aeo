import {
  Injectable,
  NotFoundException,
  ForbiddenException,
  Logger,
} from '@nestjs/common';
import { ContentInsightRepository } from './content-insight.repository';
import { UpdateContentInsightDto } from './dto/update-content-insight.dto';
import { ContentInsightResponseDto } from './dto/content-insight-response.dto';
import { ContentRepository } from '../content/content.repository';
import { ProjectMemberRepository } from '../project-member/project-member.repository';

@Injectable()
export class ContentInsightService {
  private readonly logger = new Logger(ContentInsightService.name);

  constructor(
    private readonly contentInsightRepository: ContentInsightRepository,
    private readonly contentRepository: ContentRepository,
    private readonly projectMemberRepository: ProjectMemberRepository,
  ) {}

  async findByContentId(
    contentId: string,
    userId: string,
  ): Promise<ContentInsightResponseDto[]> {
    this.logger.log('[findByContentId] Fetching insights for content');

    const content =
      await this.contentRepository.findByIdWithRelations(contentId);
    if (!content) {
      throw new NotFoundException(`Content with ID ${contentId} not found`);
    }

    const membership =
      await this.projectMemberRepository.findOneByProjectIdAndUserId(
        content.topic!.projectId,
        userId,
      );
    if (!membership) {
      throw new ForbiddenException('You are not a member of this project');
    }

    const insights =
      await this.contentInsightRepository.findByContentId(contentId);
    return insights.map((insight) => this.mapToResponseDto(insight));
  }

  async update(
    contentInsightId: string,
    dto: UpdateContentInsightDto,
    userId: string,
  ): Promise<ContentInsightResponseDto> {
    this.logger.log('[update] Updating content insight');

    const existing = await this.contentInsightRepository.findById(
      contentInsightId,
      userId,
    );
    if (!existing) {
      throw new NotFoundException(
        `Content insight with ID ${contentInsightId} not found`,
      );
    }

    const content = await this.contentRepository.findByIdWithRelations(
      existing.contentId,
    );
    if (!content) {
      throw new NotFoundException(
        `Content with ID ${existing.contentId} not found`,
      );
    }

    const updated = await this.contentInsightRepository.updateById(
      contentInsightId,
      dto,
    );
    return this.mapToResponseDto(updated);
  }

  private mapToResponseDto(insight: any): ContentInsightResponseDto {
    return {
      id: insight.id,
      contentId: insight.contentId,
      insightGroup: insight.insightGroup,
      type: insight.type,
      content: insight.content,
      createdAt: insight.createdAt,
    };
  }
}
