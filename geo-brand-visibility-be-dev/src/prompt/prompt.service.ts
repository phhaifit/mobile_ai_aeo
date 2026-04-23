import {
  BadRequestException,
  Inject,
  Injectable,
  Logger,
  NotFoundException,
  forwardRef,
} from '@nestjs/common';
import { ProjectRepository } from '../project/project.repository';
import { AnalysisResult, PromptRepository } from './prompt.repository';
import { KeywordRepository } from '../keyword/keyword.repository';
import {
  UpdatePromptRequestDTO,
  UpdatePromptResponseDTO,
} from './dto/update-prompt.dto';
import { PromptDTO } from './dto/prompt.dto';
import { GetResponsesResponseDTO } from './dto/get-responses.dto';
import { AgentService } from '../agent/agent.service';
import { BrandRepository } from '../brand/brand.repository';
import { convertPgTimeStampToStrDate } from '../utils/converter';
import {
  GeneratePromptResponseDTO,
  TopicDTO,
} from './dto/generate-prompt-response.dto';
import { TopicRepository } from '../topic/topic.repository';
import { CreatePromptDto } from './dto/create-prompt.dto';
import { WebSearchService } from 'src/web-search/web-search.service';
import { CustomerPersonaRepository } from '../customer-persona/customer-persona.repository';
import { extractSearchQuery } from 'src/utils/search';
import { SearchOptionDto } from 'src/web-search/dtos/search-option.dto';
import { GeneratePromptRequestDTO } from './dto/generate-prompt-request.dto';
import { PaginationResult } from 'src/shared/dtos/pagination-result.dto';
import { Database } from '../supabase/supabase.types';
import { TaskEnqueueService } from 'src/task-enqueue/task-enqueue.service';
import { REDIS_CACHE_CLIENT } from 'src/shared/constant';
import Redis from 'ioredis';

@Injectable()
export class PromptService {
  private readonly logger = new Logger(PromptService.name);

  private static readonly MONITORING_PROMPT_LIMIT = 50;
  private static readonly TOP_PAGES_CACHE_TTL = 11 * 24 * 60 * 60; // 11 days

  constructor(
    private readonly promptRepository: PromptRepository,
    private readonly projectRepository: ProjectRepository,
    private readonly agentService: AgentService,
    private readonly brandRepository: BrandRepository,
    private readonly topicRepository: TopicRepository,
    private readonly keywordRepository: KeywordRepository,
    private readonly webSearchService: WebSearchService,
    private readonly customerPersonaRepository: CustomerPersonaRepository,
    @Inject(forwardRef(() => TaskEnqueueService))
    private readonly taskEnqueueService: TaskEnqueueService,
    @Inject(REDIS_CACHE_CLIENT) private readonly redisClient: Redis,
  ) {}

  async generatePrompts(
    projectId: string,
    userId: string,
    keywords?: GeneratePromptRequestDTO['keywords'],
  ): Promise<GeneratePromptResponseDTO> {
    this.logger.log('[generatePrompts] Start generating prompts process');
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
                `\t  ${i + 1}. ${p.name}${persona.isPrimary ? ' [Primary]' : ''}\n` +
                `\t     Role: ${pro.jobTitle || 'N/A'} · ${pro.industry || 'N/A'}\n` +
                `\t     Goals: ${persona.goalsAndMotivations || 'N/A'}\n` +
                `\t     Pain Points: ${persona.painPoints || 'N/A'}`
              );
            })
            .join('\n')
        : '\t  N/A';

    const brandInfo = `
    \t- Brand Name: ${brand.name}
    \t- Industry: ${brand.industry}
    \t- Revenue Models: ${(brand as any).revenueModel || 'N/A'}
    \t- Customer Types: ${(brand as any).customerType || 'N/A'}
    \t- Products/Services: ${brand.services.map((s) => `\t- ${s.name}:${s.description}`).join('\n')}
    \t- Mission: ${brand.mission}
    \t- Target Market: ${brand.targetMarket}
    \t- Customer Personas (${personas.length}):\n${personasText}
    `;

    let promptContext =
      `Generate prompts in "${project.language}" language using following information:` +
      `\n- Location: ${project.location}` +
      `\n- Language: ${project.language}` +
      `\n- Brand information: ${brandInfo}`;

    if (keywords && keywords.length > 0) {
      promptContext += `\n\nTarget Topics and Keywords:`;
      keywords.forEach((keyword) => {
        promptContext += `\n- Topic: ${keyword.topicName}`;
        promptContext += `\n  Keywords: ${keyword.keywords.join(', ')}`;
      });
    }

    this.logger.log(
      '[generatePrompts] Invoking agent service to generate prompts',
    );
    const data = await this.agentService.execute<TopicDTO[]>(
      userId,
      'prompt_generation',
      promptContext,
    );

    this.logger.log('[generatePrompts] Finish generating prompts process');
    return { data: data };
  }

  async getOrGeneratePrompts(
    projectId: string,
    userId: string,
  ): Promise<
    {
      topicId: string;
      topicName: string;
      prompts: {
        id: string;
        content: string;
        type: string;
        keywords: string[];
      }[];
    }[]
  > {
    const existingPrompts = await this.promptRepository.findAllByProjectId(
      projectId,
      userId,
    );

    if (existingPrompts.length > 0) {
      return this.groupPromptsByTopic(existingPrompts);
    }

    // No prompts exist — generate, save, then return
    const keywords = await this.keywordRepository.findByProjectId(projectId);

    const keywordContext = keywords.reduce(
      (acc, k) => {
        const existing = acc.find((item) => item.topicName === k.topic.name);
        if (existing) {
          existing.keywords.push(k.keyword);
        } else {
          acc.push({ topicName: k.topic.name, keywords: [k.keyword] });
        }
        return acc;
      },
      [] as { topicName: string; keywords: string[] }[],
    );

    const generated = await this.generatePrompts(
      projectId,
      userId,
      keywordContext,
    );

    const keywordMap = new Map<string, string>();
    keywords.forEach((k) => keywordMap.set(k.keyword, k.id));

    const topics = await this.topicRepository.getTopicsByProjectId(
      projectId,
      userId,
    );
    const topicNameToId = new Map<string, string>();
    topics.forEach((t) => topicNameToId.set(t.name.toLowerCase(), t.id));

    for (const topicDto of generated.data) {
      const topicId = topicNameToId.get(topicDto.topic.toLowerCase());
      if (!topicId) {
        this.logger.warn(
          `[getOrGeneratePrompts] Could not find topicId for topic: ${topicDto.topic}`,
        );
        continue;
      }

      const promptsToInsert = topicDto.prompts.map((p) => {
        const keywordIds: string[] = [];
        if (p.keywords) {
          p.keywords.forEach((kw) => {
            const id = keywordMap.get(kw);
            if (id) keywordIds.push(id);
          });
        }
        return {
          content: p.content,
          type: p.type as any,
          keywordIds,
        };
      });

      await this.promptRepository.insertPromptsForTopic(
        topicId,
        promptsToInsert,
        'active',
        true,
      );
    }

    const savedPrompts = await this.promptRepository.findAllByProjectId(
      projectId,
      userId,
    );
    return this.groupPromptsByTopic(savedPrompts);
  }

  private groupPromptsByTopic(
    prompts: {
      id: string;
      topicId: string;
      topicName: string;
      content: string;
      type: string;
      keywords?: string[];
    }[],
  ) {
    const grouped = prompts.reduce(
      (acc, p) => {
        let group = acc.find((g) => g.topicId === p.topicId);
        if (!group) {
          group = { topicId: p.topicId, topicName: p.topicName, prompts: [] };
          acc.push(group);
        }
        group.prompts.push({
          id: p.id,
          content: p.content,
          type: p.type,
          keywords: p.keywords || [],
        });
        return acc;
      },
      [] as {
        topicId: string;
        topicName: string;
        prompts: {
          id: string;
          content: string;
          type: string;
          keywords: string[];
        }[];
      }[],
    );
    return grouped;
  }

  async createPrompt(
    data: CreatePromptDto,
    userId: string,
  ): Promise<PromptDTO> {
    const topic = await this.topicRepository.getTopic(data.topicId, userId);
    if (!topic) {
      throw new NotFoundException(`Topic ${data.topicId} not found`);
    }

    const { keywordIds, ...promptData } = data;
    const prompt = await this.promptRepository.createOne({
      status: 'active',
      isMonitored: false,
      ...promptData,
    });

    if (keywordIds && keywordIds.length > 0) {
      await this.keywordRepository.insertPromptKeywords(
        keywordIds.map((keywordId) => ({
          promptId: prompt.id,
          keywordId,
        })),
      );
    }
    return prompt;
  }

  async getMonitoringCapacity(projectId: string): Promise<{
    monitoredCount: number;
    limit: number;
    exhaustedCount: number;
    totalCount: number;
  }> {
    const { monitoredCount, exhaustedCount, totalCount } =
      await this.promptRepository.getPromptStatsByProjectId(projectId);

    return {
      monitoredCount,
      exhaustedCount,
      totalCount,
      limit: PromptService.MONITORING_PROMPT_LIMIT,
    };
  }

  async getPromptsByProject(
    projectId: string,
    userId: string,
    status?: string,
    page?: number,
    pageSize?: number,
    search?: string,
    type?: Database['public']['Enums']['PromptType'][],
    isMonitored?: boolean,
  ): Promise<PaginationResult<PromptDTO>> {
    if (page && page < 0) {
      throw new BadRequestException('page must be greater than 0');
    }

    if (pageSize && (pageSize < 1 || pageSize > 100)) {
      throw new BadRequestException('pageSize must be between 1 and 100');
    }

    if (status === 'suggested') {
      const { data, total } =
        await this.promptRepository.findSuggestedByProjectId(
          projectId,
          { page, pageSize },
          { type, isMonitored },
          search,
        );
      return new PaginationResult<PromptDTO>(
        data,
        total,
        page || 1,
        pageSize || total,
      );
    } else if (status === 'inactive') {
      const { data, total } =
        await this.promptRepository.findDeletedByProjectId(
          projectId,
          { page, pageSize },
          { type, isMonitored },
          search,
        );
      return new PaginationResult<PromptDTO>(
        data,
        total,
        page || 1,
        pageSize || total,
      );
    }

    // Default to 'active' if no status or status='active'
    const { data, total } =
      await this.promptRepository.findPromptsWithLatestAnalysis(
        projectId,
        userId,
        { page, pageSize },
        { type, isMonitored },
        search,
      );

    return new PaginationResult<PromptDTO>(
      data,
      total,
      page || 1,
      pageSize || total,
    );
  }

  async getPromptsByTopic(
    topicId: string,
    userId: string,
    status?: string,
    page?: number,
    pageSize?: number,
    search?: string,
    type?: Database['public']['Enums']['PromptType'][],
    isMonitored?: boolean,
  ): Promise<PaginationResult<PromptDTO>> {
    if (page && page < 0) {
      throw new BadRequestException('page must be greater than 0');
    }

    if (pageSize && (pageSize < 1 || pageSize > 100)) {
      throw new BadRequestException('pageSize must be between 1 and 100');
    }

    if (status === 'suggested') {
      const { data, total } =
        await this.promptRepository.findSuggestedByTopicId(
          topicId,
          { page, pageSize },
          { type, isMonitored },
          search,
        );
      return new PaginationResult<PromptDTO>(
        data,
        total,
        page || 1,
        pageSize || total,
      );
    } else if (status === 'inactive') {
      const { data, total } = await this.promptRepository.findDeletedByTopicId(
        topicId,
        { page, pageSize },
        { type, isMonitored },
        search,
      );
      return new PaginationResult<PromptDTO>(
        data,
        total,
        page || 1,
        pageSize || total,
      );
    }
    // Default to 'active' if no status or status='active'
    const { data, total } =
      await this.promptRepository.findPromptsWithLatestAnalysisByTopicId(
        topicId,
        userId,
        { page, pageSize },
        { type, isMonitored },
        search,
      );
    return new PaginationResult<PromptDTO>(
      data,
      total,
      page || 1,
      pageSize || total,
    );
  }

  async deletePrompt(promptId: string, userId: string): Promise<void> {
    const prompt = await this.promptRepository.getPromptById(promptId);
    if (!prompt) {
      throw new NotFoundException(`Prompt ${promptId} not found`);
    }

    this.logger.log(`Deleting prompt with ID: ${promptId}`);
    return this.promptRepository.delete(promptId);
  }

  async getDeletedPromptsByProject(projectId: string): Promise<PromptDTO[]> {
    const { data } =
      await this.promptRepository.findDeletedByProjectId(projectId);
    return data;
  }

  async getDeletedPromptsByTopic(topicId: string): Promise<PromptDTO[]> {
    const { data } = await this.promptRepository.findDeletedByTopicId(topicId);
    return data;
  }

  async getSuggestedPromptsByProject(projectId: string): Promise<PromptDTO[]> {
    const { data } =
      await this.promptRepository.findSuggestedByProjectId(projectId);
    return data;
  }

  async getSuggestedPromptsByTopic(topicId: string): Promise<PromptDTO[]> {
    const { data } =
      await this.promptRepository.findSuggestedByTopicId(topicId);
    return data;
  }

  async restorePrompt(promptId: string): Promise<PromptDTO> {
    const restored = await this.promptRepository.update(promptId, {
      status: 'active',
    });
    if (!restored) {
      throw new NotFoundException('Prompt not found');
    }
    return restored;
  }

  async trackPrompt(promptId: string): Promise<PromptDTO> {
    const tracked = await this.promptRepository.update(promptId, {
      status: 'active',
    });
    if (!tracked) {
      throw new NotFoundException('Prompt not found');
    }
    return tracked;
  }

  async rejectPrompt(promptId: string): Promise<PromptDTO> {
    const rejected = await this.promptRepository.update(promptId, {
      status: 'inactive',
    });
    if (!rejected) {
      throw new NotFoundException('Prompt not found');
    }
    return rejected;
  }

  async permanentlyDeletePrompt(promptId: string): Promise<void> {
    await this.promptRepository.update(promptId, {
      isDeleted: true,
    });
  }

  async ensureSuggestedPromptsByTopic(
    topicId: string,
    userId: string,
    minCount: number = 10,
    personaId?: string,
  ): Promise<PromptDTO[]> {
    // 0. Verify topic exists and user has access
    const topic = await this.topicRepository.getTopic(topicId, userId);
    if (!topic) {
      throw new NotFoundException('Topic not found');
    }

    // 1. Get all existing prompts for this topic
    const allPrompts = await this.promptRepository.findAllByTopicId(
      topicId,
      userId,
    );

    const topicName = topic.name;

    // 2. Count existing suggested prompts for this topic
    const { data: suggestedPrompts } =
      await this.promptRepository.findSuggestedByTopicId(topicId);

    if (suggestedPrompts.length >= minCount) {
      return []; // Already have enough
    }

    const needed = minCount - suggestedPrompts.length;

    // 3. Get topic keywords
    const keywords = await this.keywordRepository.findByTopicId(topicId);
    const keywordList = keywords.map((k) => k.keyword).join(', ');
    const keywordMap = new Map(keywords.map((k) => [k.keyword, k.id]));

    // 4. Optionally fetch persona for context enrichment
    let personaContext = '';

    if (personaId) {
      const persona = await this.customerPersonaRepository.findById(personaId);

      if (persona) {
        const professional = persona.professional as Record<
          string,
          string
        > | null;
        const demographics = persona.demographics as Record<
          string,
          string
        > | null;
        const contentPreferences = persona.contentPreferences as Record<
          string,
          any
        > | null;
        const buyingBehavior = persona.buyingBehavior as Record<
          string,
          any
        > | null;

        const fields = [
          { label: 'Name', value: persona.name },
          {
            label: 'Role',
            value: professional?.jobTitle
              ? `${professional.jobTitle}${professional.industry ? ` at ${professional.industry}` : ''}`
              : null,
          },
          { label: 'Seniority', value: professional?.seniorityLevel },
          { label: 'Age', value: demographics?.ageRange },
          { label: 'Location', value: demographics?.location },
          { label: 'Goals', value: persona.goalsAndMotivations },
          { label: 'Pain Points', value: persona.painPoints },
          {
            label: 'Preferred Channels',
            value: Array.isArray(contentPreferences?.channels)
              ? (contentPreferences.channels as string[]).join(', ')
              : null,
          },
          {
            label: 'Buys when',
            value: Array.isArray(buyingBehavior?.triggers)
              ? (buyingBehavior.triggers as string[]).join(', ')
              : null,
          },
        ];

        // Filter out null/undefined/empty values and format strings
        const parts = fields
          .filter(
            (f) => f.value && (!Array.isArray(f.value) || f.value.length > 0),
          )
          .map((f) => `${f.label}: ${f.value}`);

        if (parts.length) {
          const indent = '      ';
          personaContext = `
      Target Persona:
${parts.map((p) => indent + p).join('\n')}

      Generate prompts that this persona would realistically search or ask for.\n`;
        }
      }
    }

    // 5. Build AI prompt with existing prompts as context
    const existingPromptContents = allPrompts.map((p) => p.content);

    const aiPrompt = `
      Topic: "${topicName}"
      Keywords: ${keywordList}
      ${personaContext}
      Existing prompts for this topic (DO NOT generate similar ones):
      ${existingPromptContents.map((content, i) => `${i + 1}. "${content}"`).join('\n')}
      
      Task:
      Generate exactly ${needed} NEW prompts that are:
      - Semantically DIFFERENT from all existing prompts above
      - Cover different aspects, angles, or use cases of the topic
      - Actionable and specific for the topic "${topicName}"
      - Diverse in their approach
      - Incorporate RELEVANT keywords from the provided list where appropriate
      
      Return as JSON with this exact structure:
      {
        "status": "success",
        "data": [
          { 
            "content": "prompt text here", 
            "type": "Informational",
            "keywords": ["keyword1", "keyword2"] 
          },
          { 
            "content": "prompt text here", 
            "type": "Commercial",
            "keywords": ["keyword3"] 
          }
        ]
      }
      
      Valid types: Informational, Navigational, Transactional, Commercial
      Note: The "keywords" field in the response MUST be a subset of the provided Keywords list.
      `;

    // 6. Call AI to generate semantically unique prompts
    let generatedPrompts: Array<{
      content: string;
      type: string;
      keywords?: string[];
    }>;
    try {
      generatedPrompts = await this.agentService.execute<
        Array<{ content: string; type: string; keywords?: string[] }>
      >(userId, 'prompt_generation', aiPrompt);
    } catch (error) {
      this.logger.error('Failed to generate prompts from AI', error);
      return [];
    }

    if (!Array.isArray(generatedPrompts) || generatedPrompts.length === 0) {
      this.logger.warn('No prompts generated by AI');
      return [];
    }

    // 7. Save with status='suggested' for this topic
    const promptsToInsert = generatedPrompts.slice(0, needed).map((prompt) => {
      const keywordIds: string[] = [];
      if (prompt.keywords && Array.isArray(prompt.keywords)) {
        prompt.keywords.forEach((k) => {
          const id = keywordMap.get(k);
          if (id) {
            keywordIds.push(id);
          }
        });
      }
      return {
        content: prompt.content,
        type: prompt.type,
        keywordIds,
      };
    });

    await this.promptRepository.insertPromptsForTopic(
      topicId,
      promptsToInsert as Array<{
        content: string;
        type: any;
        keywordIds?: string[];
      }>,
      'suggested',
    );

    // 8. Fetch and return the newly created prompts
    const { data: newSuggestedPrompts } =
      await this.promptRepository.findSuggestedByTopicId(topicId);
    return newSuggestedPrompts.slice(0, needed);
  }

  async updatePrompt(
    promptId: string,
    data: UpdatePromptRequestDTO,
    userId: string,
  ): Promise<UpdatePromptResponseDTO> {
    this.logger.log('[updatePrompt] Start updating prompt process');
    const prompt = await this.promptRepository.getPromptById(promptId);
    if (!prompt) {
      throw new NotFoundException('Prompt not found');
    }

    if (data.isMonitored === true && !prompt.isMonitored) {
      const projectId = await this.promptRepository.getProjectIdByPromptId(
        promptId,
        userId,
      );
      if (!projectId) {
        throw new NotFoundException('Project not found for this prompt');
      }
      const { monitoredCount, limit } =
        await this.getMonitoringCapacity(projectId);
      if (monitoredCount >= limit) {
        throw new BadRequestException(
          `You have reached the limit of ${limit} monitoring prompts. Please upgrade your plan or disable monitoring for other prompts.`,
        );
      }
    }

    if (data.content && data.content !== prompt.content) {
      await this.promptRepository.setExhausted(promptId, false);
    }

    const updatedPrompt = await this.promptRepository.update(promptId, data);
    this.logger.log('[updatePrompt] Finish updating prompt process');
    return updatedPrompt!;
  }

  async getResponses(
    promptId: string,
    startDate: string,
    endDate: string,
    userId: string,
  ): Promise<GetResponsesResponseDTO[]> {
    return this.promptRepository.getResponses(
      promptId,
      startDate,
      endDate,
      userId,
    );
  }

  async getPrompt(promptId: string, userId: string): Promise<PromptDTO> {
    const prompt = await this.promptRepository.getPromptById(promptId);

    if (!prompt) {
      throw new NotFoundException('Prompt not found');
    }

    return prompt;
  }

  async getAnalysisResult(
    promptId: string,
    startDate: string,
    endDate: string,
    userId: string,
  ) {
    const prompt = await this.promptRepository.getPromptById(promptId);
    if (!prompt) {
      throw new NotFoundException(`Prompt ${promptId} not found`);
    }

    const result = await this.promptRepository.getAnalysisResultById(
      promptId,
      startDate,
      endDate,
    );

    if (!result || result.length === 0) {
      return {
        competitors: [],
        domains: [],
        positionOverTime: [],
        shareOfVoice: [],
      };
    }

    const brand = await this.brandRepository.findByProjectId(
      result[0].prompt.topic.projectId,
    );

    const competitorsSummary = this.getAllBrandsSummary(
      result,
      brand!.id,
      brand!.name,
    );

    const domains = result.map((item) => item.citations).flat();
    const domainsSummary = this.getDomainsSummary(domains);

    const positionSummary = this.getPositionSummary(
      result,
      brand!.id,
      brand!.name,
    );
    const sovSummary = this.getSoVSummary(result, brand!.id, brand!.name);

    return {
      competitors: competitorsSummary,
      domains: domainsSummary,
      positionOverTime: positionSummary,
      shareOfVoice: sovSummary,
    };
  }

  private getDomainsSummary(
    citations: {
      url: string;
      domain: string;
    }[],
  ) {
    const freq: Record<string, number> = {};

    citations.forEach((citation) => {
      freq[citation.domain] = (freq[citation.domain] || 0) + 1;
    });

    const result: { domain: string; frequency: number }[] = [];
    for (const domain in freq) {
      result.push({ domain: domain, frequency: freq[domain] });
    }
    result.sort((a, b) => b.frequency - a.frequency);

    return result;
  }

  private getAllBrandsSummary(
    data: AnalysisResult[],
    brandId: string,
    brandName: string,
  ) {
    const record: Record<
      string,
      { name: string; freq: number; sumOfPos: number }
    > = {};

    const addToRecord = (id: string, name: string, position: number) => {
      if (!record[id]) {
        record[id] = { name: name, freq: 0, sumOfPos: 0 };
      }
      record[id].freq += 1;
      record[id].sumOfPos += position;
    };

    data.forEach((item) => {
      if (item.position) {
        addToRecord(brandId, brandName, item.position);
      }

      item.competitors.forEach((c) => {
        addToRecord(c.competitor.id, c.competitor.name, c.position);
      });
    });

    const result: {
      id: string;
      name: string;
      frequency: number;
      avgPosition: number;
    }[] = [];
    for (const id in record) {
      result.push({
        id: id,
        name: record[id].name,
        frequency: record[id].freq,
        avgPosition: parseFloat(
          (record[id].sumOfPos / record[id].freq).toFixed(2),
        ),
      });
    }
    result.sort((a, b) => b.frequency - a.frequency);

    return result;
  }

  private getPositionSummary(
    data: AnalysisResult[],
    brandId: string,
    brandName: string,
  ) {
    const groupedData = this.groupAnalysisResultByDate(data);
    const result: {
      date: string;
      brands: { id: string; name: string; position: number }[];
    }[] = [];

    groupedData.forEach((items) => {
      const brandsSummary = this.getAllBrandsSummary(items, brandId, brandName);

      result.push({
        date: convertPgTimeStampToStrDate(items[0].createdAt),
        brands: brandsSummary.map((brand) => ({
          id: brand.id,
          name: brand.name,
          position: brand.avgPosition,
        })),
      });
    });

    result.sort(
      (a, b) => new Date(a.date).getTime() - new Date(b.date).getTime(),
    );

    return result;
  }

  private getSoVSummary(
    data: AnalysisResult[],
    brandId: string,
    brandName: string,
  ) {
    const groupedData = this.groupAnalysisResultByModel(data);
    const result: {
      model: string;
      brands: { id: string; name: string; sov: number }[];
    }[] = [];

    groupedData.forEach((item) => {
      const brandsSummary = this.getAllBrandsSummary(item, brandId, brandName);
      const totalFrequencies = brandsSummary.reduce(
        (sum, brand) => sum + brand.frequency,
        0,
      );

      result.push({
        model: item[0].model.name,
        brands: brandsSummary.map((brand) => ({
          id: brand.id,
          name: brand.name,
          sov: parseFloat(
            ((brand.frequency / totalFrequencies) * 100).toFixed(2),
          ),
        })),
      });
    });

    return result;
  }

  private groupAnalysisResultByModel(data: AnalysisResult[]) {
    const record: Record<string, AnalysisResult[]> = {};

    data.forEach((item) => {
      const key = item.model.name;
      if (!record[key]) {
        record[key] = [];
      }

      record[key].push(item);
    });

    const result: AnalysisResult[][] = [];
    for (const key in record) {
      result.push(record[key]);
    }

    return result;
  }

  private groupAnalysisResultByDate(data: AnalysisResult[]) {
    const record: Record<string, AnalysisResult[]> = {};

    data.forEach((item) => {
      const key = convertPgTimeStampToStrDate(item.createdAt);
      if (!record[key]) {
        record[key] = [];
      }

      record[key].push(item);
    });

    const result: AnalysisResult[][] = [];
    for (const key in record) {
      result.push(record[key]);
    }

    return result;
  }

  private getTopPagesCacheKey(
    promptId: string,
    option?: SearchOptionDto,
  ): string {
    let key = `top-pages:${promptId}`;
    if (option?.lang) key += `:${option.lang}`;
    if (option?.loc) key += `:${option.loc}`;
    return key;
  }

  async getTopPages(
    promptId: string,
    userId: string,
    option?: SearchOptionDto,
  ) {
    const cacheKey = this.getTopPagesCacheKey(promptId, option);

    try {
      const cached = await this.redisClient.get(cacheKey);
      if (cached) {
        this.logger.log(`Top pages cache HIT for prompt: ${promptId}`);
        return JSON.parse(cached);
      }
    } catch (error) {
      this.logger.warn(`Top pages cache GET failed for key: ${cacheKey}`);
    }

    const prompt = await this.promptRepository.getPromptById(promptId);

    if (!prompt) {
      throw new NotFoundException(`Prompt ${promptId} not found`);
    }

    const searchResults = await this.webSearchService.search(
      extractSearchQuery(prompt.content),
      option,
    );

    // Score relevance of search results against the prompt
    const relevanceByIndex: Array<{
      relevanceScore: number;
      relevanceLabel: string;
    }> = [];
    try {
      const pages = searchResults.map((r, i) => ({
        index: i,
        url: r.url,
        title: r.title,
        description: r.description,
      }));
      const agentPrompt = `Prompt: ${prompt.content}\n\nPages: ${JSON.stringify(pages)}`;
      const relevanceData = await this.agentService.execute<
        Array<{
          index: number;
          url: string;
          relevance_score: number;
          relevance_label: string;
        }>
      >(userId, 'page_relevance', agentPrompt);

      // Build array indexed by position for reliable matching
      for (const r of relevanceData) {
        relevanceByIndex[r.index] = {
          relevanceScore: r.relevance_score,
          relevanceLabel: r.relevance_label,
        };
      }
    } catch (error) {
      this.logger.warn(
        `Failed to score page relevance: ${error instanceof Error ? error.message : error}`,
      );
    }

    const results = searchResults.map((result, i) => {
      const relevance = relevanceByIndex[i];
      return {
        ...result,
        relevanceScore: relevance?.relevanceScore,
        relevanceLabel: relevance?.relevanceLabel,
      };
    });

    try {
      await this.redisClient.setex(
        cacheKey,
        PromptService.TOP_PAGES_CACHE_TTL,
        JSON.stringify(results),
      );
      this.logger.log(`Top pages cache SET for key: ${cacheKey}`);
    } catch (error) {
      this.logger.warn(`Top pages cache SET failed for key: ${cacheKey}`);
    }

    return results;
  }

  async analyzePrompt(promptId: string, userId: string) {
    return this.taskEnqueueService.triggerPromptAnalysis(promptId, userId);
  }
}
