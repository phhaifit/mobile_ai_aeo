import { Test, TestingModule } from '@nestjs/testing';
import { PromptService } from './prompt.service';
import { PromptRepository } from './prompt.repository';
import { ProjectRepository } from '../project/project.repository';
import { AgentService } from '../agent/agent.service';
import { BrandRepository } from '../brand/brand.repository';
import { TopicRepository } from '../topic/topic.repository';
import { NotFoundException } from '@nestjs/common';
import type { Tables } from '../supabase/supabase.types';
import { UpdatePromptRequestDTO } from './dto/update-prompt.dto';
import { KeywordRepository } from '../keyword/keyword.repository';
import { WebSearchService } from '../web-search/web-search.service';
import { DEFAULT_LANGUAGE } from 'src/shared/constant';

jest.mock('uuid', () => ({
  v4: jest.fn(() => 'mock-uuid'),
}));

type Prompt = Tables<'Prompt'>;

describe('PromptService', () => {
  let service: PromptService;

  const mockPrompt: Prompt = {
    id: 'prompt-id',
    topicId: 'topic-id',
    content: 'Top 10 software development companies in Ho Chi Minh City',
    type: 'AWARENESS',
    status: 'active',
    isDeleted: false,
    isExhausted: false,
    isMonitored: false,
    lastRun: null,
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  };

  const mockPrompts: Prompt[] = [
    mockPrompt,
    {
      id: 'prompt-id-2',
      topicId: 'topic-id',
      content: 'Best digital marketing agencies in Vietnam',
      type: 'INTEREST',
      status: 'active',
      isDeleted: false,
      isExhausted: false,
      isMonitored: true,
      lastRun: null,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    },
  ];

  const mockPromptRepository = {
    createMany: jest.fn(),
    createOne: jest.fn(),
    findAllByProjectId: jest.fn(),
    findAllByTopicId: jest.fn(),
    delete: jest.fn(),
    update: jest.fn(),
    insert: jest.fn(),
    insertResponse: jest.fn(),
    getResponses: jest.fn(),
    getPromptById: jest.fn(),
    getAnalysisResultById: jest.fn(),
  };

  const mockProjectRepository = {
    findById: jest.fn(),
  };

  const mockAgentService = {
    execute: jest.fn(),
  };

  const mockBrandRepository = {
    findByProjectId: jest.fn(),
  };

  const mockTopicRepository = {
    create: jest.fn(),
    findAllByProjectId: jest.fn(),
    findById: jest.fn(),
    getTopic: jest.fn(),
    update: jest.fn(),
    delete: jest.fn(),
  };

  const mockKeywordRepository = {
    findAll: jest.fn(),
    findById: jest.fn(),
    create: jest.fn(),
    update: jest.fn(),
    delete: jest.fn(),
  };
  const mockWebSearchService = {
    search: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        PromptService,
        {
          provide: PromptRepository,
          useValue: mockPromptRepository,
        },
        {
          provide: ProjectRepository,
          useValue: mockProjectRepository,
        },
        {
          provide: AgentService,
          useValue: mockAgentService,
        },
        {
          provide: BrandRepository,
          useValue: mockBrandRepository,
        },
        {
          provide: TopicRepository,
          useValue: mockTopicRepository,
        },
        {
          provide: KeywordRepository,
          useValue: mockKeywordRepository,
        },
        {
          provide: WebSearchService,
          useValue: mockWebSearchService,
        },
      ],
    }).compile();

    service = module.get<PromptService>(PromptService);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('createPrompt', () => {
    const userId = 'user-id';
    const createPromptDto = {
      topicId: 'topic-id',
      content: 'Top 10 software development companies in Ho Chi Minh City',
      type: 'AWARENESS' as const,
    };

    const mockTopic = {
      id: 'topic-id',
      name: 'Software Development',
      projectId: 'project-id',
      isMonitored: true,
      isDeleted: false,
      searchVolume: 1000,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    };

    it('should create a single prompt successfully', async () => {
      const expectedPrompt = {
        ...mockPrompt,
        topicName: mockTopic.name,
      };

      mockTopicRepository.getTopic.mockResolvedValue(mockTopic);
      mockPromptRepository.createOne.mockResolvedValue(expectedPrompt);

      const result = await service.createPrompt(createPromptDto, userId);

      expect(result).toEqual(expectedPrompt);
      expect(mockTopicRepository.getTopic).toHaveBeenCalledWith(
        createPromptDto.topicId,
        userId,
      );
      expect(mockPromptRepository.createOne).toHaveBeenCalledWith({
        status: 'active',
        ...createPromptDto,
      });
    });

    it('should throw NotFoundException when topic not found', async () => {
      mockTopicRepository.getTopic.mockResolvedValue(null);

      await expect(
        service.createPrompt(createPromptDto, userId),
      ).rejects.toThrow(
        new NotFoundException(`Topic ${createPromptDto.topicId} not found`),
      );

      expect(mockTopicRepository.getTopic).toHaveBeenCalledWith(
        createPromptDto.topicId,
        userId,
      );
      expect(mockPromptRepository.createOne).not.toHaveBeenCalled();
    });
  });

  describe('getPromptsByProject', () => {
    const projectId = 'project-id';
    const userId = 'user-id';

    it('should get prompts by project successfully', async () => {
      mockPromptRepository.findAllByProjectId.mockResolvedValue(mockPrompts);

      const result = await service.getPromptsByProject(projectId, userId);

      expect(result).toEqual(mockPrompts);
      expect(mockPromptRepository.findAllByProjectId).toHaveBeenCalledWith(
        projectId,
        userId,
      );
    });
  });

  describe('getPromptsByTopic', () => {
    const topicId = 'topic-id';
    const userId = 'user-id';
    it('should get prompts by topic successfully', async () => {
      mockPromptRepository.findAllByTopicId.mockResolvedValue(mockPrompts);
      const result = await service.getPromptsByTopic(topicId, userId);
      expect(result).toEqual(mockPrompts);
      expect(mockPromptRepository.findAllByTopicId).toHaveBeenCalledWith(
        topicId,
        userId,
      );
    });
  });

  describe('deletePrompt', () => {
    const promptId = 'prompt-id';
    const userId = 'user-id';

    it('should delete prompt successfully', async () => {
      mockPromptRepository.getPromptById.mockResolvedValue(mockPrompt);
      mockPromptRepository.delete.mockResolvedValue(undefined);

      await service.deletePrompt(promptId, userId);

      expect(mockPromptRepository.getPromptById).toHaveBeenCalledWith(
        promptId,
        userId,
      );
      expect(mockPromptRepository.delete).toHaveBeenCalledWith(promptId);
    });

    it('should throw NotFoundException when prompt not found', async () => {
      mockPromptRepository.getPromptById.mockResolvedValue(null);

      await expect(service.deletePrompt(promptId, userId)).rejects.toThrow(
        new NotFoundException(`Prompt ${promptId} not found`),
      );
    });
  });

  describe('updatePrompt', () => {
    const promptId = 'prompt-id';
    const userId = 'user-id';
    const updateData: UpdatePromptRequestDTO = {
      isMonitored: true,
    };

    it('should update prompt successfully', async () => {
      const updatedPrompt = {
        ...mockPrompt,
        isMonitored: true,
      };
      mockPromptRepository.getPromptById.mockResolvedValue(mockPrompt);
      mockPromptRepository.update.mockResolvedValue(updatedPrompt);

      const result = await service.updatePrompt(promptId, updateData, userId);

      expect(result).toEqual(updatedPrompt);
      expect(mockPromptRepository.getPromptById).toHaveBeenCalledWith(
        promptId,
        userId,
      );
      expect(mockPromptRepository.update).toHaveBeenCalledWith(
        promptId,
        updateData,
      );
    });

    it('should throw NotFoundException when prompt not found', async () => {
      mockPromptRepository.getPromptById.mockResolvedValue(null);

      await expect(
        service.updatePrompt(promptId, updateData, userId),
      ).rejects.toThrow(new NotFoundException('Prompt not found'));
    });
  });

  describe('generatePrompts', () => {
    const projectId = 'project-id';
    const userId = 'user-id';

    it('should generate prompts successfully', async () => {
      const mockProject = {
        id: projectId,
        location: 'Ho Chi Minh City',
        language: DEFAULT_LANGUAGE,
        createdBy: userId,
      };

      const mockBrand = {
        id: 'brand-id',
        name: 'TechCorp',
        industry: 'Technology',
        services: [
          { name: 'Web Development', description: 'Custom web solutions' },
        ],
        mission: 'Innovate for better tomorrow',
        targetMarket: 'SMEs in Vietnam',
      };

      const mockGeneratedData = [
        {
          topic: 'Software Development',
          prompts: [
            {
              content: 'Top 10 software development companies',
              type: 'AWARENESS',
            },
          ],
        },
      ];

      mockProjectRepository.findById.mockResolvedValue(mockProject);
      mockBrandRepository.findByProjectId.mockResolvedValue(mockBrand);
      mockAgentService.execute.mockResolvedValue(mockGeneratedData);

      const result = await service.generatePrompts(projectId, userId);

      expect(result).toEqual({ data: mockGeneratedData });
      expect(mockProjectRepository.findById).toHaveBeenCalledWith(projectId);
      expect(mockBrandRepository.findByProjectId).toHaveBeenCalledWith(
        projectId,
        userId,
      );
      expect(mockAgentService.execute).toHaveBeenCalled();
    });

    it('should throw NotFoundException when project not found', async () => {
      mockProjectRepository.findById.mockResolvedValue(null);

      await expect(service.generatePrompts(projectId, userId)).rejects.toThrow(
        new NotFoundException(`Project with ID ${projectId} not found`),
      );
    });

    it('should throw NotFoundException when brand not found', async () => {
      const mockProject = {
        id: projectId,
        location: 'Ho Chi Minh City',
        language: DEFAULT_LANGUAGE,
      };

      mockProjectRepository.findById.mockResolvedValue(mockProject);
      mockBrandRepository.findByProjectId.mockResolvedValue(null);

      await expect(service.generatePrompts(projectId, userId)).rejects.toThrow(
        new NotFoundException(
          `Brand for project with ID ${projectId} not found`,
        ),
      );
    });
  });

  describe('savePrompts', () => {
    const projectId = 'project-id';
    const userId = 'user-id';
    const topicsData = [
      {
        topic: 'Software Development',
        prompts: [
          {
            content: 'Top 10 software development companies',
            type: 'AWARENESS' as const,
          },
        ],
      },
    ];

    it('should save prompts successfully', async () => {
      const mockProject = {
        id: projectId,
        createdBy: userId,
      };

      mockProjectRepository.findById.mockResolvedValue(mockProject);
      mockPromptRepository.insert.mockResolvedValue(undefined);

      await service.savePrompts(projectId, topicsData);

      expect(mockProjectRepository.findById).toHaveBeenCalledWith(projectId);
      expect(mockPromptRepository.insert).toHaveBeenCalledWith({
        projectId,
        data: JSON.parse(JSON.stringify(topicsData)),
      });
    });

    it('should throw NotFoundException when project not found', async () => {
      mockProjectRepository.findById.mockResolvedValue(null);

      await expect(service.savePrompts(projectId, topicsData)).rejects.toThrow(
        new NotFoundException(`Project with ID ${projectId} not found`),
      );
    });
  });

  describe('getResponses', () => {
    const promptId = 'prompt-id';
    const userId = 'user-id';
    const startDate = '2026-01-01';
    const endDate = '2026-01-10';

    it('should get responses successfully', async () => {
      const mockResponses = [
        {
          id: 'response-id',
          response: 'Test response content',
          relatedQuestions: ['Question 1', 'Question 2'],
          model: { id: 'model-id', name: 'GPT-4' },
          citations: [
            {
              url: 'https://example.com',
              title: 'Example',
              domain: 'example.com',
            },
          ],
        },
      ];

      mockPromptRepository.getResponses.mockResolvedValue(mockResponses);

      const result = await service.getResponses(
        promptId,
        startDate,
        endDate,
        userId,
      );

      expect(result).toEqual(mockResponses);
      expect(mockPromptRepository.getResponses).toHaveBeenCalledWith(
        promptId,
        startDate,
        endDate,
        userId,
      );
    });
  });

  describe('getPrompt', () => {
    const promptId = 'prompt-id';
    const userId = 'user-id';

    it('should get prompt by id successfully', async () => {
      mockPromptRepository.getPromptById.mockResolvedValue(mockPrompt);

      const result = await service.getPrompt(promptId, userId);

      expect(result).toEqual(mockPrompt);
      expect(mockPromptRepository.getPromptById).toHaveBeenCalledWith(
        promptId,
        userId,
      );
    });

    it('should throw NotFoundException when prompt not found', async () => {
      mockPromptRepository.getPromptById.mockResolvedValue(null);

      await expect(service.getPrompt(promptId, userId)).rejects.toThrow(
        new NotFoundException('Prompt not found'),
      );
    });
  });

  describe('getAnalysisResult', () => {
    const promptId = 'prompt-id';
    const userId = 'user-id';
    const startDate = '2026-01-01';
    const endDate = '2026-01-10';

    it('should return empty result when no analysis data found', async () => {
      mockPromptRepository.getPromptById.mockResolvedValue(mockPrompt);
      mockPromptRepository.getAnalysisResultById.mockResolvedValue([]);

      const result = await service.getAnalysisResult(
        promptId,
        startDate,
        endDate,
        userId,
      );

      expect(result).toEqual({
        competitors: [],
        domains: [],
        positionOverTime: [],
        shareOfVoice: [],
      });
    });

    it('should return analysis result successfully', async () => {
      const mockBrand = {
        id: 'brand-id',
        name: 'TechCorp',
      };

      const mockAnalysisResult = [
        {
          id: 'response-id',
          position: 3,
          createdAt: '2026-01-05T10:00:00Z',
          model: { id: 'model-id', name: 'GPT-4' },
          citations: [
            { url: 'https://example.com', domain: 'example.com' },
            { url: 'https://test.com', domain: 'test.com' },
          ],
          competitors: [
            {
              competitor: { id: 'comp-1', name: 'CompetitorA' },
              position: 1,
            },
            {
              competitor: { id: 'comp-2', name: 'CompetitorB' },
              position: 2,
            },
          ],
          prompt: {
            topic: {
              projectId: 'project-id',
            },
          },
        },
      ];

      mockPromptRepository.getPromptById.mockResolvedValue(mockPrompt);
      mockPromptRepository.getAnalysisResultById.mockResolvedValue(
        mockAnalysisResult,
      );
      mockBrandRepository.findByProjectId.mockResolvedValue(mockBrand);

      const result = await service.getAnalysisResult(
        promptId,
        startDate,
        endDate,
        userId,
      );

      expect(result).toHaveProperty('competitors');
      expect(result).toHaveProperty('domains');
      expect(result).toHaveProperty('positionOverTime');
      expect(result).toHaveProperty('shareOfVoice');
      expect(result.competitors.length).toBeGreaterThan(0);
      expect(result.domains.length).toBeGreaterThan(0);
    });

    it('should throw NotFoundException when prompt not found', async () => {
      mockPromptRepository.getPromptById.mockResolvedValue(null);

      await expect(
        service.getAnalysisResult(promptId, startDate, endDate, userId),
      ).rejects.toThrow(new NotFoundException(`Prompt ${promptId} not found`));
    });
  });
});
