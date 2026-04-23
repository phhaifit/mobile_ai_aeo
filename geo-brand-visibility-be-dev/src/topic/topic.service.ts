import {
  Injectable,
  NotFoundException,
  ForbiddenException,
} from '@nestjs/common';
import { TopicRepository } from './topic.repository';
import { TopicDTO } from './dto/topic.dto';
import { CreateTopicRequestDTO, AddedTopicDTO } from './dto/create-topics.dto';
import { UpdateTopicRequestDTO } from './dto/update-topic.dto';
import { DeleteTopicsDto } from './dto/delete-topics.dto';
import { Logger } from '@nestjs/common';
import { TablesInsert } from '../supabase/supabase.types';
import { ProjectRepository } from '../project/project.repository';
import { ProjectMemberRepository } from '../project-member/project-member.repository';
import { AgentService } from '../agent/agent.service';
import { BrandRepository } from '../brand/brand.repository';
import { CustomerPersonaRepository } from '../customer-persona/customer-persona.repository';

type GeneratedTopic = {
  name: string;
  description: string;
};

@Injectable()
export class TopicService {
  private readonly logger = new Logger(TopicService.name);
  constructor(
    private readonly topicRepository: TopicRepository,
    private readonly projectRepository: ProjectRepository,
    private readonly projectMemberRepository: ProjectMemberRepository,
    private readonly brandRepository: BrandRepository,
    private readonly agentService: AgentService,
    private readonly customerPersonaRepository: CustomerPersonaRepository,
  ) {}

  async getTopicsByProject(
    projectId: string,
    userId: string,
  ): Promise<TopicDTO[]> {
    return this.topicRepository.getTopicsByProjectId(projectId, userId);
  }

  async createTopics(
    data: CreateTopicRequestDTO,
    userId: string,
  ): Promise<TopicDTO[]> {
    this.logger.log('[createTopics] Start create topics process');
    const { projectId, topicData } = data;

    const membership =
      await this.projectMemberRepository.findOneByProjectIdAndUserId(
        projectId,
        userId,
      );
    if (!membership) {
      throw new ForbiddenException('You are not a member of this project');
    }

    const topicsToInsert: TablesInsert<'Topic'>[] = topicData.map(
      (topic: AddedTopicDTO) => ({
        name: topic.name,
        alias: topic.alias,
        description: topic.description ?? null,
        projectId,
        searchVolume: null,
      }),
    );

    return this.topicRepository.insertMany(topicsToInsert);
  }

  async generateTopics(
    projectId: string,
    userId: string,
  ): Promise<GeneratedTopic[]> {
    const membership =
      await this.projectMemberRepository.findOneByProjectIdAndUserId(
        projectId,
        userId,
      );
    if (!membership) {
      throw new ForbiddenException('You are not a member of this project');
    }

    const project = await this.projectRepository.findById(projectId);
    if (!project) {
      throw new NotFoundException(`Project with ID ${projectId} not found`);
    }

    const brand = await this.brandRepository.findByProjectId(projectId);
    if (!brand) {
      throw new NotFoundException(
        `Brand for project with ID ${projectId} not found`,
      );
    }

    const personas = await this.customerPersonaRepository.findByBrandId(
      brand.id,
      userId,
    );

    const personasText =
      personas.length > 0
        ? personas
            .map((p, i) => {
              const persona = p as Record<string, any>;
              const pro = (persona.professional ?? {}) as Record<
                string,
                string
              >;
              return (
                `  ${i + 1}. ${p.name}${persona.isPrimary ? ' [Primary]' : ''}\n` +
                `     Role: ${pro.jobTitle || 'N/A'} · ${pro.industry || 'N/A'}\n` +
                `     Goals: ${persona.goalsAndMotivations || 'N/A'}\n` +
                `     Pain Points: ${persona.painPoints || 'N/A'}`
              );
            })
            .join('\n')
        : '  N/A';

    const brandInfo = `
    - Brand Name: ${brand.name}
    - Industry: ${brand.industry}
    - Revenue Models: ${(brand as any).revenueModel || 'N/A'}
    - Customer Types: ${(brand as any).customerType || 'N/A'}
    - Products/Services: ${brand.services.map((s) => `${s.name}: ${s.description}`).join(', ')}
    - Mission: ${brand.mission}
    - Target Market: ${brand.targetMarket}
    - Customer Personas (${personas.length}):\n${personasText}
    `;

    const promptContext =
      `Generate topics for brand visibility analysis using the following information:` +
      `\n- Location: ${project.location}` +
      `\n- Language: ${project.language}` +
      `\n- Brand information: ${brandInfo}`;

    const generatedTopics = await this.agentService.execute<GeneratedTopic[]>(
      userId,
      'topic_generation',
      promptContext,
    );

    return generatedTopics;
  }

  async updateTopic(
    topicId: string,
    dto: UpdateTopicRequestDTO,
    userId: string,
  ): Promise<TopicDTO> {
    this.logger.log('[updateTopic] Starting update topic process');
    const topic = await this.topicRepository.getTopic(topicId, userId);
    if (!topic) {
      throw new NotFoundException(`Topic with ID ${topicId} not found`);
    }

    const updatedTopic = this.topicRepository.update(topicId, dto);
    this.logger.log('[updateTopic] Finish updating topic process');
    return updatedTopic;
  }

  async deleteMany(dto: DeleteTopicsDto, userId: string): Promise<void> {
    this.logger.log('[deleteMany] Start deleting topics process');
    const topics = await this.topicRepository.getTopics(dto.ids, userId);
    if (topics.length !== dto.ids.length) {
      throw new NotFoundException(`One or more topics not found`);
    }

    await this.topicRepository.deleteMany(dto.ids);
    this.logger.log('[deleteMany] Finish deleting topics process');
  }
}
