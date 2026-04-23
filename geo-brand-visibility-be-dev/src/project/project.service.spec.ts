import { Test, TestingModule } from '@nestjs/testing';
import { ProjectService } from './project.service';
import { ProjectRepository } from './project.repository';
import { PromptRepository } from '../prompt/prompt.repository';
import { NotFoundException, ConflictException } from '@nestjs/common';
import type { Tables } from '../supabase/supabase.types';
import { AgentService } from '../agent/agent.service';
import { BrandRepository } from '../brand/brand.repository';
import { ProjectMemberRepository } from '../project-member/project-member.repository';
import { ProjectStatus } from './enum/project-status.enum';
import { DEFAULT_LANGUAGE, DEFAULT_LOCATION } from 'src/shared/constant';

jest.mock('uuid', () => ({
  v4: jest.fn(() => 'mock-uuid'),
}));

type Project = Tables<'Project'> & { status: ProjectStatus };
type Brand = Tables<'Brand'>;
type ProjectDetail = Project & {
  brand?: Brand;
  models: string[];
};

describe('ProjectService', () => {
  let service: ProjectService;

  const mockBrand: Brand = {
    id: 'brand-id',
    projectId: 'project-id',
    name: 'Test Brand',
    description: 'Test Description',
    domain: 'test.com',
    targetMarket: 'Test Market',
    industry: 'Test Industry',
    mission: 'Test Mission',
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
    blogHotline: null,
    blogTitle: null,
    cloudflareHostnameId: null,
    customDomain: null,
    defaultArticleImageUrl: null,
    domainConfigMethod: null,
    logoUrl: null,
    slug: 'test-brand',
  };

  const mockProject: Project = {
    id: 'project-id',
    createdBy: 'user-id',
    monitoringFrequency: 'weekly',
    location: DEFAULT_LOCATION,
    language: DEFAULT_LANGUAGE,
    status: ProjectStatus.ACTIVE,
    autoGenerate: false,
    autoAnalysis: false,
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  };

  const mockProjectDetail: ProjectDetail = {
    ...mockProject,
    brand: mockBrand,
    models: ['model-id'],
  };

  const mockProjectRepository = {
    create: jest.fn(),
    findById: jest.fn(),
    findAllByUserId: jest.fn(),
    findDraftByUserId: jest.fn(),
    update: jest.fn(),
    delete: jest.fn(),
    getAnalytics: jest.fn(),
  };

  const mockAgentService = {
    execute: jest.fn(),
  };

  const mockPromptRepository = {
    createMany: jest.fn(),
    findAllByProjectId: jest.fn(),
    findAllResponsesByProjectId: jest.fn(),
    delete: jest.fn(),
    update: jest.fn(),
  };

  const mockBrandRepository = {
    findByProjectId: jest.fn(),
  };

  const mockProjectMemberRepository = {
    create: jest.fn(),
  };

  beforeEach(async () => {
    jest.clearAllMocks();

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ProjectService,
        {
          provide: ProjectRepository,
          useValue: mockProjectRepository,
        },
        {
          provide: ProjectMemberRepository,
          useValue: mockProjectMemberRepository,
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
          provide: PromptRepository,
          useValue: mockPromptRepository,
        },
      ],
    }).compile();

    service = module.get<ProjectService>(ProjectService);

    // Set default behavior for findDraftByUserId
    mockProjectRepository.findDraftByUserId.mockResolvedValue(null);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('createProject', () => {
    const userId = 'user-id';

    it('should create project with default values successfully', async () => {
      mockProjectRepository.create.mockResolvedValue(mockProject);

      const result = await service.createProject(userId);

      expect(result).toEqual({
        project: {
          ...mockProject,
          models: [],
        },
        isExisting: false,
      });
      expect(mockProjectRepository.create).toHaveBeenCalledWith({
        createdBy: userId,
        location: DEFAULT_LOCATION,
        language: DEFAULT_LANGUAGE,
        monitoringFrequency: 'weekly',
        status: ProjectStatus.DRAFT,
      });
      expect(mockProjectMemberRepository.create).toHaveBeenCalled();
    });

    it('should create project with custom values successfully', async () => {
      const customProject = {
        ...mockProject,
        location: 'US',
        language: 'es',
        monitoringFrequency: 'daily' as
          | 'hourly'
          | 'daily'
          | 'weekly'
          | 'monthly',
      };

      mockProjectRepository.create.mockResolvedValue(customProject);

      const result = await service.createProject(userId, 'US', 'es', 'daily');

      expect(result).toEqual({
        project: {
          ...customProject,
          models: [],
        },
        isExisting: false,
      });
      expect(mockProjectRepository.create).toHaveBeenCalledWith({
        createdBy: userId,
        location: 'US',
        language: 'es',
        monitoringFrequency: 'daily',
        status: ProjectStatus.DRAFT,
      });
      expect(mockProjectMemberRepository.create).toHaveBeenCalled();
    });

    it('should return existing draft when ConflictException occurs during creation', async () => {
      const draftProject = {
        ...mockProject,
        status: ProjectStatus.DRAFT,
      };

      // First check returns null (race condition window)
      mockProjectRepository.findDraftByUserId.mockResolvedValueOnce(null);

      // Create throws ConflictException (unique constraint violated)
      mockProjectRepository.create.mockRejectedValue(
        new ConflictException('Duplicate key violation'),
      );

      // Second check returns the draft created by concurrent request
      mockProjectRepository.findDraftByUserId.mockResolvedValueOnce(
        draftProject,
      );

      const result = await service.createProject(userId);

      expect(result).toEqual({
        project: draftProject,
        isExisting: true,
      });
      expect(mockProjectRepository.findDraftByUserId).toHaveBeenCalledTimes(2);
      expect(mockProjectRepository.create).toHaveBeenCalledTimes(1);
      expect(mockProjectMemberRepository.create).not.toHaveBeenCalled();
    });

    it('should throw error when ConflictException occurs but no draft found on retry', async () => {
      mockProjectRepository.findDraftByUserId.mockResolvedValue(null);

      mockProjectRepository.create.mockRejectedValue(
        new ConflictException('Duplicate key violation'),
      );

      await expect(service.createProject(userId)).rejects.toThrow(
        ConflictException,
      );
    });

    it('should throw error when non-ConflictException error occurs', async () => {
      mockProjectRepository.findDraftByUserId.mockResolvedValue(null);
      mockProjectRepository.create.mockRejectedValue(
        new Error('Database connection failed'),
      );

      await expect(service.createProject(userId)).rejects.toThrow(
        'Database connection failed',
      );
    });
  });

  describe('findProjectById', () => {
    const projectId = 'project-id';
    const userId = 'user-id';

    it('should find project successfully', async () => {
      mockProjectRepository.findById.mockResolvedValue(mockProjectDetail);

      const result = await service.findProjectById(projectId);

      expect(result).toEqual(mockProjectDetail);
      expect(mockProjectRepository.findById).toHaveBeenCalledWith(projectId);
    });

    it('should throw NotFoundException when project not found', async () => {
      mockProjectRepository.findById.mockResolvedValue(null);

      await expect(service.findProjectById(projectId)).rejects.toThrow(
        new NotFoundException('Project not found'),
      );
    });
  });

  describe('findProjectsByUser', () => {
    const userId = 'user-id';

    it('should find all projects successfully', async () => {
      const projects = [mockProjectDetail];
      mockProjectRepository.findAllByUserId.mockResolvedValue(projects);

      const result = await service.findProjectsByUser(userId);

      expect(result).toEqual(projects);
      expect(mockProjectRepository.findAllByUserId).toHaveBeenCalledWith(
        userId,
        undefined,
      );
    });

    it('should return empty array when no projects found', async () => {
      mockProjectRepository.findAllByUserId.mockResolvedValue([]);

      const result = await service.findProjectsByUser(userId);

      expect(result).toEqual([]);
    });
  });

  describe('updateProject', () => {
    const projectId = 'project-id';
    const userId = 'user-id';
    const updateData = {
      monitoringFrequency: 'daily' as 'hourly' | 'daily' | 'weekly' | 'monthly',
      location: 'US',
      language: 'es',
      models: ['model-1', 'model-2'],
    };

    it('should update project successfully', async () => {
      const updatedProject = {
        ...mockProjectDetail,
        ...updateData,
      };
      mockProjectRepository.update.mockResolvedValue(updatedProject);

      const result = await service.updateProject(projectId, updateData);

      expect(result).toEqual(updatedProject);
      expect(mockProjectRepository.update).toHaveBeenCalledWith(
        projectId,
        updateData,
      );
    });

    it('should throw NotFoundException when project not found', async () => {
      mockProjectRepository.update.mockResolvedValue(null);

      await expect(
        service.updateProject(projectId, updateData),
      ).rejects.toThrow(new NotFoundException('Project not found'));

      expect(mockProjectRepository.update).toHaveBeenCalledWith(
        projectId,
        updateData,
      );
    });
  });

  describe('deleteProject', () => {
    const projectId = 'project-id';
    const userId = 'user-id';

    it('should delete project successfully', async () => {
      mockProjectRepository.delete.mockResolvedValue(mockProject);

      await service.deleteProject(projectId);

      expect(mockProjectRepository.delete).toHaveBeenCalledWith(projectId);
    });

    it('should throw NotFoundException when project not found', async () => {
      mockProjectRepository.delete.mockResolvedValue(null);

      await expect(service.deleteProject(projectId)).rejects.toThrow(
        new NotFoundException('Project not found'),
      );
    });
  });

  describe('getMetricsOverview', () => {
    const projectId = 'project-id';
    const userId = 'user-id';
    const start = '2025-01-01T00:00:00.000Z';
    const end = '2025-01-31T23:59:59.999Z';

    type ResponseForMetrics = {
      id: string;
      position: number | null;
      isCited: boolean;
      model: {
        id: string;
        name: string;
      };
      citations: {
        url: string;
        title: string | null;
        domain: string;
      }[];
      competitors: {
        name: string;
        position: number;
      }[];
    };

    it('should calculate metrics overview with domain distribution correctly', async () => {
      const mockResponsesWithCitations: ResponseForMetrics[] = [
        {
          id: 'response-1',
          position: 1,
          isCited: true,
          model: { id: 'model-1', name: 'chatgpt' },
          citations: [
            {
              url: 'https://github.com/test1',
              title: 'Test 1',
              domain: 'github.com',
            },
            {
              url: 'https://docs.com/test2',
              title: 'Test 2',
              domain: 'docs.com',
            },
          ],
          competitors: [
            { name: 'Competitor A', position: 2 },
            { name: 'Competitor B', position: 5 },
          ],
        },
        {
          id: 'response-2',
          position: 2,
          isCited: true,
          model: { id: 'model-2', name: 'perplexity' },
          citations: [
            {
              url: 'https://github.com/test3',
              title: 'Test 3',
              domain: 'github.com',
            },
          ],
          competitors: [{ name: 'Competitor A', position: 1 }],
        },
        {
          id: 'response-3',
          position: 3,
          isCited: false,
          model: { id: 'model-1', name: 'chatgpt' },
          citations: [],
          competitors: [],
        },
        {
          id: 'response-4',
          position: null,
          isCited: true,
          model: { id: 'model-3', name: 'gemini' },
          citations: [
            {
              url: 'https://github.com/test4',
              title: 'Test 4',
              domain: 'github.com',
            },
          ],
          competitors: [{ name: 'Competitor B', position: 3 }],
        },
      ];

      mockPromptRepository.findAllResponsesByProjectId.mockResolvedValue(
        mockResponsesWithCitations,
      );

      const result = await service.getMetricsOverview(
        projectId,
        start,
        end,
        userId,
      );

      expect(result).toEqual({
        brandVisibilityScore: 75,
        brandMentions: 3,
        brandMentionsRate: 75,
        linkReferences: 3,
        linkReferencesRate: 75,
        // eslint-disable-next-line @typescript-eslint/no-unsafe-assignment
        domainDistribution: expect.arrayContaining([
          {
            domain: 'github.com',
            count: 3,
            distribution: {
              // eslint-disable-next-line @typescript-eslint/no-unsafe-assignment
              chatgpt: expect.closeTo(33.33, 2),
              // eslint-disable-next-line @typescript-eslint/no-unsafe-assignment
              perplexity: expect.closeTo(33.33, 2),
              // eslint-disable-next-line @typescript-eslint/no-unsafe-assignment
              gemini: expect.closeTo(33.33, 2),
            },
          },
          {
            domain: 'docs.com',
            count: 1,
            distribution: {
              chatgpt: 100,
            },
          },
        ]),
        competitors: {
          'Competitor A': 2,
          'Competitor B': 2,
        },
      });

      expect(
        mockPromptRepository.findAllResponsesByProjectId,
      ).toHaveBeenCalledWith(projectId, start, end, userId);
    });

    it('should return zero metrics when no responses exist', async () => {
      mockPromptRepository.findAllResponsesByProjectId.mockResolvedValue([]);

      const result = await service.getMetricsOverview(
        projectId,
        start,
        end,
        userId,
      );
      expect(result).toEqual({
        brandVisibilityScore: 0,
        brandMentions: 0,
        brandMentionsRate: 0,
        linkReferences: 0,
        linkReferencesRate: 0,
        domainDistribution: [],
        competitors: {},
      });
    });

    it('should handle responses with no citations correctly', async () => {
      const mockResponsesNoCitations: ResponseForMetrics[] = [
        {
          id: 'response-1',
          position: 1,
          isCited: false,
          model: { id: 'model-1', name: 'chatgpt' },
          citations: [],
          competitors: [],
        },
        {
          id: 'response-2',
          position: 2,
          isCited: false,
          model: { id: 'model-2', name: 'perplexity' },
          citations: [],
          competitors: [],
        },
      ];

      mockPromptRepository.findAllResponsesByProjectId.mockResolvedValue(
        mockResponsesNoCitations,
      );
      const result = await service.getMetricsOverview(
        projectId,
        start,
        end,
        userId,
      );

      expect(result).toEqual({
        brandVisibilityScore: 60,
        brandMentions: 2,
        brandMentionsRate: 100,
        linkReferences: 0,
        linkReferencesRate: 0,
        domainDistribution: [],
        competitors: {},
      });
    });

    it('should group multiple citations from same model to same domain correctly', async () => {
      const mockResponsesSameModelDomain: ResponseForMetrics[] = [
        {
          id: 'response-1',
          position: 1,
          isCited: true,
          model: { id: 'model-1', name: 'chatgpt' },
          citations: [
            {
              url: 'https://github.com/repo1',
              title: 'Repo 1',
              domain: 'github.com',
            },
            {
              url: 'https://github.com/repo2',
              title: 'Repo 2',
              domain: 'github.com',
            },
            {
              url: 'https://github.com/repo3',
              title: 'Repo 3',
              domain: 'github.com',
            },
          ],
          competitors: [],
        },
      ];

      mockPromptRepository.findAllResponsesByProjectId.mockResolvedValue(
        mockResponsesSameModelDomain,
      );
      const result = await service.getMetricsOverview(
        projectId,
        start,
        end,
        userId,
      );

      expect(result).toEqual({
        brandVisibilityScore: 100,
        brandMentions: 1,
        brandMentionsRate: 100,
        linkReferences: 1,
        linkReferencesRate: 100,
        domainDistribution: [
          {
            domain: 'github.com',
            count: 3,
            distribution: {
              chatgpt: 100,
            },
          },
        ],
        competitors: {},
      });
    });

    it('should calculate distribution percentages correctly for multiple models', async () => {
      const mockResponsesMultipleModels: ResponseForMetrics[] = [
        {
          id: 'response-1',
          position: 1,
          isCited: true,
          model: { id: 'model-1', name: 'chatgpt' },
          citations: [
            {
              url: 'https://example.com/1',
              title: 'Example 1',
              domain: 'example.com',
            },
            {
              url: 'https://example.com/2',
              title: 'Example 2',
              domain: 'example.com',
            },
          ],
          competitors: [],
        },
        {
          id: 'response-2',
          position: 2,
          isCited: true,
          model: { id: 'model-1', name: 'chatgpt' },
          citations: [
            {
              url: 'https://example.com/3',
              title: 'Example 3',
              domain: 'example.com',
            },
          ],
          competitors: [],
        },
        {
          id: 'response-3',
          position: 3,
          isCited: true,
          model: { id: 'model-2', name: 'perplexity' },
          citations: [
            {
              url: 'https://example.com/4',
              title: 'Example 4',
              domain: 'example.com',
            },
            {
              url: 'https://example.com/5',
              title: 'Example 5',
              domain: 'example.com',
            },
          ],
          competitors: [],
        },
      ];

      mockPromptRepository.findAllResponsesByProjectId.mockResolvedValue(
        mockResponsesMultipleModels,
      );
      const result = await service.getMetricsOverview(
        projectId,
        start,
        end,
        userId,
      );

      expect(result).toEqual({
        brandVisibilityScore: 100,
        brandMentions: 3,
        brandMentionsRate: 100,
        linkReferences: 3,
        linkReferencesRate: 100,
        domainDistribution: [
          {
            domain: 'example.com',
            count: 5,
            distribution: {
              chatgpt: 60,
              perplexity: 40,
            },
          },
        ],
        competitors: {},
      });
    });

    it('should handle mixed null and non-null positions correctly', async () => {
      const mockResponsesMixedPositions: ResponseForMetrics[] = [
        {
          id: 'response-1',
          position: null,
          isCited: true,
          model: { id: 'model-1', name: 'chatgpt' },
          citations: [
            { url: 'https://test.com/1', title: 'Test 1', domain: 'test.com' },
          ],
          competitors: [],
        },
        {
          id: 'response-2',
          position: 5,
          isCited: true,
          model: { id: 'model-2', name: 'perplexity' },
          citations: [
            { url: 'https://test.com/2', title: 'Test 2', domain: 'test.com' },
          ],
          competitors: [],
        },
        {
          id: 'response-3',
          position: null,
          isCited: false,
          model: { id: 'model-3', name: 'gemini' },
          citations: [],
          competitors: [],
        },
      ];

      mockPromptRepository.findAllResponsesByProjectId.mockResolvedValue(
        mockResponsesMixedPositions,
      );
      const result = await service.getMetricsOverview(
        projectId,
        start,
        end,
        userId,
      );

      expect(result).toEqual({
        // eslint-disable-next-line @typescript-eslint/no-unsafe-assignment
        brandVisibilityScore: expect.closeTo(46.67, 2),
        brandMentions: 1,
        // eslint-disable-next-line @typescript-eslint/no-unsafe-assignment
        brandMentionsRate: expect.closeTo(33.33, 2),
        linkReferences: 2,
        // eslint-disable-next-line @typescript-eslint/no-unsafe-assignment
        linkReferencesRate: expect.closeTo(66.67, 2),
        domainDistribution: [
          {
            domain: 'test.com',
            count: 2,
            distribution: {
              chatgpt: 50,
              perplexity: 50,
            },
          },
        ],
        competitors: {},
      });
    });
  });

  describe('getMetricsAnalytics', () => {
    const projectId = 'project-id';
    const userId = 'user-id';
    const start = '2025-01-01T00:00:00.000Z';
    const end = '2025-01-31T23:59:59.999Z';
    it('should return analytics data with all metrics from database function', async () => {
      const mockAnalyticsData = {
        brandMentions: 85,
        brandMentionsRate: 37.44,
        linkReferences: 42,
        linkReferencesRate: 18.5,
        AIOverviewsCount: 30,
        AIOverviewsRate: 13.22,
        totalResponses: 227,
        sentimentStats: {
          positive: 42,
          neutral: 78,
          negative: 15,
        },
        analyticsByDate: [
          {
            date: '2025-01-01',
            totalResponses: 10,
            brandMentions: 5,
            linkReferences: 3,
            positiveCount: 2,
            neutralCount: 6,
            negativeCount: 2,
          },
        ],
        analyticsByModel: [
          {
            model: 'ChatGPT',
            totalMentions: 100,
            brandMentions: 42,
            competitorMentions: {
              'Acme Corp': 25,
              'TechStart Inc': 18,
            },
          },
        ],
      };

      mockProjectRepository.findById.mockResolvedValue(mockProjectDetail);
      mockProjectRepository.getAnalytics.mockResolvedValue(mockAnalyticsData);

      const result = await service.getMetricsAnalytics(projectId, start, end);

      expect(result).toEqual(mockAnalyticsData);
      expect(mockProjectRepository.findById).toHaveBeenCalledWith(projectId);
      expect(mockProjectRepository.getAnalytics).toHaveBeenCalledWith(
        projectId,
        start,
        end,
        undefined,
        undefined,
      );
    });
    it('should pass filters to repository', async () => {
      const models = ['model-1', 'model-2'];
      const promptTypes: (
        | 'AWARENESS'
        | 'INTEREST'
        | 'PURCHASE'
        | 'LOYALTY'
        | 'CONSIDERATION'
      )[] = ['AWARENESS', 'INTEREST'];

      const mockAnalyticsData = {
        brandMentions: 45,
        brandMentionsRate: 50.0,
        linkReferences: 20,
        linkReferencesRate: 22.22,
        AIOverviewsCount: 10,
        AIOverviewsRate: 11.11,
        totalResponses: 90,
        sentimentStats: {
          positive: 20,
          neutral: 40,
          negative: 30,
        },
        analyticsByDate: [],
        analyticsByModel: [
          {
            model: 'ChatGPT',
            totalMentions: 90,
            brandMentions: 45,
            competitorMentions: {},
          },
        ],
      };

      mockProjectRepository.findById.mockResolvedValue(mockProjectDetail);
      mockProjectRepository.getAnalytics.mockResolvedValue(mockAnalyticsData);

      const result = await service.getMetricsAnalytics(
        projectId,
        start,
        end,
        models,
        promptTypes,
      );

      expect(result).toEqual(mockAnalyticsData);
      expect(mockProjectRepository.getAnalytics).toHaveBeenCalledWith(
        projectId,
        start,
        end,
        models,
        promptTypes,
      );
    });

    it('should return empty analytics when no data exists', async () => {
      const emptyAnalyticsData = {
        brandMentions: 0,
        brandMentionsRate: 0,
        linkReferences: 0,
        linkReferencesRate: 0,
        AIOverviewsCount: 0,
        AIOverviewsRate: 0,
        totalResponses: 0,
        sentimentStats: {
          positive: 0,
          neutral: 0,
          negative: 0,
        },
        analyticsByDate: [],
        analyticsByModel: [],
      };

      mockProjectRepository.findById.mockResolvedValue(mockProjectDetail);
      mockProjectRepository.getAnalytics.mockResolvedValue(emptyAnalyticsData);

      const result = await service.getMetricsAnalytics(projectId, start, end);

      expect(result).toEqual(emptyAnalyticsData);
    });

    it('should throw NotFoundException when project not found', async () => {
      mockProjectRepository.findById.mockResolvedValue(null);

      await expect(
        service.getMetricsAnalytics(projectId, start, end),
      ).rejects.toThrow(new NotFoundException('Project not found'));

      expect(mockProjectRepository.findById).toHaveBeenCalledWith(projectId);
      expect(mockProjectRepository.getAnalytics).not.toHaveBeenCalled();
    });
  });
});
