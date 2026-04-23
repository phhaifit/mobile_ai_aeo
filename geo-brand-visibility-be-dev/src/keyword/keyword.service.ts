import {
  Injectable,
  Logger,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common';
import { KeywordRepository } from './keyword.repository';
import { KeywordDTO } from './dto/keyword.dto';
import { AgentService } from '../agent/agent.service';
import { BrandRepository } from '../brand/brand.repository';
import { TopicRepository } from '../topic/topic.repository';
import { ProjectRepository } from '../project/project.repository';
import { TablesInsert } from '../supabase/supabase.types';
import { GenerateKeywordRequestDTO } from './dto/generate-keyword-request.dto';
import { CustomerPersonaRepository } from '../customer-persona/customer-persona.repository';

interface SuggestedKeyword {
  keyword: string;
}

@Injectable()
export class KeywordService {
  private readonly logger = new Logger(KeywordService.name);

  constructor(
    private readonly keywordRepository: KeywordRepository,
    private readonly agentService: AgentService,
    private readonly brandRepository: BrandRepository,
    private readonly topicRepository: TopicRepository,
    private readonly customerPersonaRepository: CustomerPersonaRepository,
    private readonly projectRepository: ProjectRepository,
  ) {}

  async getKeywordsByTopic(topicId: string): Promise<KeywordDTO[]> {
    return this.keywordRepository.findByTopicId(topicId);
  }

  async getKeywordsByProject(projectId: string): Promise<KeywordDTO[]> {
    const keywords = await this.keywordRepository.findByProjectId(projectId);
    return keywords.map((k) => ({
      ...k,
      topicName: k.topic.name,
    }));
  }

  async createKeywords(
    topicId: string,
    keywords: string[],
  ): Promise<KeywordDTO[]> {
    const keywordsToInsert: TablesInsert<'Keyword'>[] = keywords.map(
      (keyword) => ({
        topicId,
        keyword,
      }),
    );

    return this.keywordRepository.insertMany(keywordsToInsert);
  }

  async deleteKeyword(keywordId: string): Promise<void> {
    await this.keywordRepository.delete(keywordId);
  }

  async updateKeyword(keywordId: string, keyword: string): Promise<KeywordDTO> {
    return this.keywordRepository.update(keywordId, { keyword });
  }

  async getOrGenerateKeywords(
    projectId: string,
    userId: string,
  ): Promise<
    {
      topicId: string;
      topicName: string;
      keywords: { id: string; keyword: string }[];
    }[]
  > {
    const keywords = await this.keywordRepository.findByProjectId(projectId);

    if (!keywords || keywords.length == 0) {
      return this.generateKeywords(projectId, userId);
    }

    const grouped = keywords.reduce(
      (acc, k) => {
        const existingTopic = acc.find((item) => item.topicId === k.topicId);

        if (existingTopic) {
          existingTopic.keywords.push({ id: k.id, keyword: k.keyword });
        } else {
          acc.push({
            topicId: k.topicId,
            topicName: k.topic.name,
            keywords: [{ id: k.id, keyword: k.keyword }],
          });
        }
        return acc;
      },
      [] as {
        topicId: string;
        topicName: string;
        keywords: { id: string; keyword: string }[];
      }[],
    );

    return grouped;
  }

  async generateKeywords(
    projectId: string,
    userId: string,
  ): Promise<
    {
      topicId: string;
      topicName: string;
      keywords: { id: string; keyword: string }[];
    }[]
  > {
    const topics = await this.topicRepository.getTopicsByProjectId(
      projectId,
      userId,
    );
    if (!topics || topics.length === 0) {
      throw new BadRequestException(
        `No topics found for project with ID ${projectId}`,
      );
    }

    const brand = await this.brandRepository.findByProjectId(projectId);

    if (!brand) {
      throw new NotFoundException(
        `Brand for project with ID ${projectId} not found`,
      );
    }

    const project = await this.projectRepository.findById(projectId);
    if (!project) {
      throw new NotFoundException(`Project with ID ${projectId} not found`);
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

    const topicList = topics
      .map((t) => `- topicId: ${t.id}, topicName: ${t.name}`)
      .join('\n');

    const generatedData = await this.agentService.execute<
      GenerateKeywordRequestDTO[]
    >(
      userId,
      'keyword_agent',
      `Generate keywords in "${project.language}" language for the provided topics using the following information:\n${brandInfo}\n\nTopics:\n${topicList}`,
    );

    const flattenedKeywords = generatedData.flatMap((item) =>
      item.keywords.map((kw) => ({
        topicId: item.topicId,
        keyword: kw,
      })),
    );

    const insertedKeywords =
      await this.keywordRepository.insertMany(flattenedKeywords);

    this.logger.log(`Generated keywords: ${JSON.stringify(generatedData)}`);

    const topicMp: Record<string, string> = {};
    for (const topic of topics) {
      topicMp[topic.id] = topic.name;
    }

    // Group inserted keywords by topicId
    const grouped = insertedKeywords.reduce(
      (acc, k) => {
        const existingTopic = acc.find((item) => item.topicId === k.topicId);
        if (existingTopic) {
          existingTopic.keywords.push({ id: k.id, keyword: k.keyword });
        } else {
          acc.push({
            topicId: k.topicId,
            topicName: topicMp[k.topicId],
            keywords: [{ id: k.id, keyword: k.keyword }],
          });
        }
        return acc;
      },
      [] as {
        topicId: string;
        topicName: string;
        keywords: { id: string; keyword: string }[];
      }[],
    );

    return grouped;
  }

  async suggestKeywords(
    userId: string,
    keywords: string[],
    projectId?: string,
    topicId?: string,
  ): Promise<SuggestedKeyword[]> {
    const seedKeywords = keywords.join(', ');
    let prompt = `Suggest related keywords for: ${seedKeywords}`;

    // If projectId is provided, fetch sibling topics to avoid overlap
    if (projectId) {
      const topics = await this.topicRepository.getTopicsByProjectId(
        projectId,
        userId,
      );

      if (topics && topics.length > 0) {
        let currentTopicName: string | undefined;
        if (topicId) {
          currentTopicName = topics.find((t) => t.id === topicId)?.name;
          if (currentTopicName) {
            prompt += `\n\nThis is for the topic: "${currentTopicName}"`;
          }
        }

        // Build list of other topics (siblings)
        const siblingTopics = topics
          .filter((t) => !topicId || t.id !== topicId)
          .map((t) => t.name);

        if (siblingTopics.length > 0) {
          prompt += `\n\nOther topics already covered in this project (do NOT generate keywords that fit these better than the current topic):\n${siblingTopics.map((name) => `- ${name}`).join('\n')}`;
        }
      }
    }

    const data = await this.agentService.execute<SuggestedKeyword[]>(
      userId,
      'keyword_agent',
      prompt,
    );

    this.logger.log(`Suggested keywords: ${JSON.stringify(data)}`);
    return data;
  }

  async savePromptKeywordMappings(
    mappings: { promptId: string; keywordId: string }[],
  ): Promise<void> {
    await this.keywordRepository.insertPromptKeywords(mappings);
  }
}
