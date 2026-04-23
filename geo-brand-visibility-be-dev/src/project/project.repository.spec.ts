import { Test, TestingModule } from '@nestjs/testing';
import { ProjectRepository } from './project.repository';
import { ProjectStatus } from './enum/project-status.enum';
import { SUPABASE } from '../utils/const';
import { PostgrestError } from '@supabase/supabase-js';
import type {
  Enums,
  Tables,
  TablesInsert,
  TablesUpdate,
} from '../supabase/supabase.types';
import { DEFAULT_LANGUAGE, DEFAULT_LOCATION } from 'src/shared/constant';

type Project = Tables<'Project'> & { status: ProjectStatus };
type Brand = Tables<'Brand'>;
type Model = Tables<'Model'>;
type ProjectDetail = Project & {
  brand?: Brand;
  models: string[];
};
type ProjectInsert = TablesInsert<'Project'>;
type ProjectUpdate = TablesUpdate<'Project'> & {
  models?: string[];
  status?: ProjectStatus;
  brandName?: string;
};
type PromptType = Enums<'PromptType'>;

interface MockSupabaseClient {
  from: jest.Mock;
  select: jest.Mock;
  insert: jest.Mock;
  update: jest.Mock;
  delete: jest.Mock;
  eq: jest.Mock;
  neq: jest.Mock;
  not: jest.Mock;
  order: jest.Mock;
  limit: jest.Mock;
  single: jest.Mock;
  maybeSingle: jest.Mock;
  rpc: jest.Mock;
}

describe('ProjectRepository', () => {
  let repository: ProjectRepository;
  let mockSupabaseClient: MockSupabaseClient;

  const mockBrand = {
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
    articleDefaultImageUrl: null,
    defaultArticleImageUrl: null,
    domainConfigMethod: null,
    logoUrl: null,
    slug: 'test-brand-slug',
  } as unknown as Brand;

  const mockModel: Model = {
    id: 'model-id',
    name: 'Test Model',
    description: 'Test Model Description',
  };

  const mockProject: Project = {
    id: 'project-id',
    createdBy: 'user-id',
    name: 'Test Project',
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

  beforeEach(async () => {
    mockSupabaseClient = {
      from: jest.fn().mockReturnThis(),
      select: jest.fn().mockReturnThis(),
      insert: jest.fn().mockReturnThis(),
      update: jest.fn().mockReturnThis(),
      delete: jest.fn().mockReturnThis(),
      eq: jest.fn().mockReturnThis(),
      neq: jest.fn().mockReturnThis(),
      not: jest.fn().mockReturnThis(),
      order: jest.fn().mockReturnThis(),
      limit: jest.fn().mockReturnThis(),
      single: jest.fn(),
      maybeSingle: jest.fn(),
      rpc: jest.fn(),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ProjectRepository,
        {
          provide: SUPABASE,
          useValue: mockSupabaseClient,
        },
      ],
    }).compile();

    repository = module.get<ProjectRepository>(ProjectRepository);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(repository).toBeDefined();
  });

  describe('findById', () => {
    const projectId = 'project-id';
    const userId = 'user-id';

    it('should find project by id successfully', async () => {
      const rawData = {
        ...mockProject,
        brand: mockBrand,
        models: [mockModel],
      };

      mockSupabaseClient.maybeSingle.mockResolvedValue({
        data: rawData,
        error: null,
      });

      const result = await repository.findById(projectId);

      expect(result).toEqual(mockProjectDetail);
      expect(mockSupabaseClient.from).toHaveBeenCalledWith('Project');
      expect(mockSupabaseClient.select).toHaveBeenCalledWith(
        '*, brand:Brand(*), models:Model(*)',
      );
      expect(mockSupabaseClient.eq).toHaveBeenCalledWith('id', projectId);
    });

    it('should return null when project not found', async () => {
      mockSupabaseClient.maybeSingle.mockResolvedValue({
        data: null,
        error: null,
      });

      const result = await repository.findById(projectId);

      expect(result).toBeNull();
    });

    it('should throw error when database operation fails', async () => {
      const error = new Error('Database error') as PostgrestError;
      mockSupabaseClient.maybeSingle.mockResolvedValue({
        data: null,
        error,
      });

      await expect(repository.findById(projectId)).rejects.toThrow();
    });
  });

  describe('findAllByUserId', () => {
    const userId = 'user-id';

    it('should find all projects successfully', async () => {
      const rawProjects = [
        {
          ...mockProject,
          brand: mockBrand,
          models: [mockModel],
        },
      ];

      mockSupabaseClient.order.mockResolvedValue({
        data: rawProjects,
        error: null,
      });

      const result = await repository.findAllByUserId(userId);

      expect(result).toEqual([mockProjectDetail]);
      expect(mockSupabaseClient.from).toHaveBeenCalledWith('Project');
      expect(mockSupabaseClient.select).toHaveBeenCalledWith(
        '*, projectMembers:Project_Member!inner(*), brand:Brand(*), models:Model(*)',
      );
      expect(mockSupabaseClient.eq).toHaveBeenCalledWith(
        'Project_Member.userId',
        userId,
      );
      expect(mockSupabaseClient.not).toHaveBeenCalledWith('brand', 'is', null);
      expect(mockSupabaseClient.order).toHaveBeenCalledWith('createdAt', {
        ascending: false,
      });
    });

    it('should return empty array when no projects found', async () => {
      mockSupabaseClient.order.mockResolvedValue({
        data: [],
        error: null,
      });

      const result = await repository.findAllByUserId(userId);

      expect(result).toEqual([]);
    });

    it('should throw error when database operation fails', async () => {
      const error = new Error('Database error') as PostgrestError;
      mockSupabaseClient.order.mockResolvedValue({
        data: null,
        error,
      });

      await expect(repository.findAllByUserId(userId)).rejects.toThrow();
    });
  });

  describe('create', () => {
    const newProject: ProjectInsert = {
      createdBy: 'user-id',
      monitoringFrequency: 'weekly',
      location: DEFAULT_LOCATION,
      language: DEFAULT_LANGUAGE,
    };

    it('should create project successfully', async () => {
      const createdProject = {
        ...mockProject,
        ...newProject,
        id: 'new-project-id',
      };

      mockSupabaseClient.single.mockResolvedValue({
        data: createdProject,
        error: null,
      });

      const result = await repository.create(newProject);

      expect(result).toEqual(createdProject);
      expect(mockSupabaseClient.from).toHaveBeenCalledWith('Project');
      expect(mockSupabaseClient.insert).toHaveBeenCalledWith(newProject);
      expect(mockSupabaseClient.select).toHaveBeenCalled();
    });

    it('should throw error when database operation fails', async () => {
      const error = new Error('Database error') as PostgrestError;
      mockSupabaseClient.single.mockResolvedValue({
        data: null,
        error,
      });

      await expect(repository.create(newProject)).rejects.toThrow();
    });
  });

  describe('update', () => {
    const projectId = 'project-id';
    const updateData: ProjectUpdate = {
      name: 'Updated Project',
      brandName: 'Updated Brand',
      monitoringFrequency: 'daily',
      location: 'US',
      language: DEFAULT_LANGUAGE,
      models: ['model-1', 'model-2'],
    };

    it('should update project successfully', async () => {
      const updatedProject = {
        ...mockProjectDetail,
        ...updateData,
      };

      mockSupabaseClient.rpc.mockResolvedValue({
        data: updatedProject,
        error: null,
      });

      const result = await repository.update(projectId, updateData);

      expect(result).toEqual(updatedProject);
      expect(mockSupabaseClient.rpc).toHaveBeenCalledWith('update_project', {
        _id: projectId,
        _language: updateData.language,
        _location: updateData.location,
        _monitoring_frequency: updateData.monitoringFrequency,
        _project_name: updateData.name,
        _brand_name: updateData.brandName,
        _models: updateData.models,
      });
    });

    it('should handle update without models', async () => {
      const updateWithoutModels: ProjectUpdate = {
        monitoringFrequency: 'daily',
      };

      const updatedProject = {
        ...mockProjectDetail,
        ...updateWithoutModels,
      };

      mockSupabaseClient.rpc.mockResolvedValue({
        data: updatedProject,
        error: null,
      });

      const result = await repository.update(projectId, updateWithoutModels);

      expect(result).toEqual(updatedProject);
      expect(mockSupabaseClient.rpc).toHaveBeenCalledWith('update_project', {
        _id: projectId,
        _language: undefined,
        _location: undefined,
        _monitoring_frequency: updateWithoutModels.monitoringFrequency,
        _project_name: undefined,
        _brand_name: undefined,
        _models: undefined,
      });
    });

    it('should update project status if provided', async () => {
      const updateDataWithStatus: ProjectUpdate = {
        status: ProjectStatus.ACTIVE,
      };

      const updatedProject = {
        ...mockProjectDetail,
        status: ProjectStatus.ACTIVE,
      };

      mockSupabaseClient.rpc.mockResolvedValue({
        data: updatedProject,
        error: null,
      });

      const result = await repository.update(projectId, updateDataWithStatus);

      expect(result).toEqual(updatedProject);
      expect(mockSupabaseClient.from).toHaveBeenCalledWith('Project');
      expect(mockSupabaseClient.update).toHaveBeenCalledWith({
        status: ProjectStatus.ACTIVE,
      });
      expect(mockSupabaseClient.eq).toHaveBeenCalledWith('id', projectId);
      expect(mockSupabaseClient.rpc).toHaveBeenCalledWith('update_project', {
        _id: projectId,
        _language: undefined,
        _location: undefined,
        _monitoring_frequency: undefined,
        _project_name: undefined,
        _brand_name: undefined,
        _models: undefined,
      });
    });

    it('should throw error when database operation fails', async () => {
      const error = new Error('Database error') as PostgrestError;
      mockSupabaseClient.rpc.mockResolvedValue({
        data: null,
        error,
      });

      await expect(repository.update(projectId, updateData)).rejects.toThrow();
    });
  });

  describe('delete', () => {
    const projectId = 'project-id';
    const userId = 'user-id';

    it('should delete project successfully', async () => {
      mockSupabaseClient.maybeSingle.mockResolvedValue({
        data: mockProject,
        error: null,
      });

      const result = await repository.delete(projectId);

      expect(result).toEqual(mockProject);
      expect(mockSupabaseClient.from).toHaveBeenCalledWith('Project');
      expect(mockSupabaseClient.delete).toHaveBeenCalled();
      expect(mockSupabaseClient.eq).toHaveBeenCalledWith('id', projectId);
      expect(mockSupabaseClient.select).toHaveBeenCalled();
    });

    it('should return null when project not found', async () => {
      mockSupabaseClient.maybeSingle.mockResolvedValue({
        data: null,
        error: null,
      });

      const result = await repository.delete(projectId);

      expect(result).toBeNull();
    });

    it('should throw error when database operation fails', async () => {
      const error = new Error('Database error') as PostgrestError;
      mockSupabaseClient.maybeSingle.mockResolvedValue({
        data: null,
        error,
      });

      await expect(repository.delete(projectId)).rejects.toThrow();
    });
  });

  describe('getModelsByProjectId', () => {
    const projectId = 'project-id';

    it('should get models by project id successfully', async () => {
      const mockModel2: Model = {
        id: 'model-id-2',
        name: 'Test Model 2',
        description: 'Test Model 2 Description',
      };

      const rawData = [{ Model: mockModel }, { Model: mockModel2 }];

      mockSupabaseClient.eq.mockResolvedValueOnce({
        data: rawData,
        error: null,
      });

      const result = await repository.getModelsByProjectId(projectId);

      expect(result).toEqual([mockModel, mockModel2]);
      expect(mockSupabaseClient.from).toHaveBeenCalledWith('Project_Model');
      expect(mockSupabaseClient.select).toHaveBeenCalledWith('Model!inner(*)');
      expect(mockSupabaseClient.eq).toHaveBeenCalledWith(
        'projectId',
        projectId,
      );
    });

    it('should return empty array when no models found', async () => {
      mockSupabaseClient.eq.mockResolvedValueOnce({
        data: [],
        error: null,
      });

      const result = await repository.getModelsByProjectId(projectId);

      expect(result).toEqual([]);
      expect(mockSupabaseClient.from).toHaveBeenCalledWith('Project_Model');
      expect(mockSupabaseClient.select).toHaveBeenCalledWith('Model!inner(*)');
      expect(mockSupabaseClient.eq).toHaveBeenCalledWith(
        'projectId',
        projectId,
      );
    });

    it('should throw error when database operation fails', async () => {
      const error = new Error('Database error') as PostgrestError;
      mockSupabaseClient.eq.mockResolvedValueOnce({
        data: null,
        error,
      });

      await expect(
        repository.getModelsByProjectId(projectId),
      ).rejects.toThrow();
      expect(mockSupabaseClient.from).toHaveBeenCalledWith('Project_Model');
      expect(mockSupabaseClient.select).toHaveBeenCalledWith('Model!inner(*)');
      expect(mockSupabaseClient.eq).toHaveBeenCalledWith(
        'projectId',
        projectId,
      );
    });
  });

  describe('getAnalytics', () => {
    const projectId = 'project-id';
    const start = '2026-01-01';
    const end = '2026-01-31';

    const mockAnalytics = {
      brandMentions: 10,
      brandMentionsRate: 0.5,
      linkReferences: 5,
      linkReferencesRate: 0.25,
      totalResponses: 20,
      AIOverviewsCount: 15,
      AIOverviewsRate: 0.75,
      sentimentStats: {
        positive: 8,
        neutral: 10,
        negative: 2,
      },
      analyticsByDate: [
        {
          date: '2026-01-01',
          totalResponses: 5,
          brandMentions: 2,
          linkReferences: 1,
          positiveCount: 2,
          neutralCount: 2,
          negativeCount: 1,
        },
      ],
      analyticsByModel: [
        {
          modelName: 'Test Model',
          totalMentions: 10,
          brandMentions: 5,
          competitorMentions: { 'Competitor A': 3, 'Competitor B': 2 },
        },
      ],
    };

    it('should get analytics successfully', async () => {
      mockSupabaseClient.rpc.mockResolvedValue({
        data: mockAnalytics,
        error: null,
      });

      const result = await repository.getAnalytics(projectId, start, end);

      expect(result).toEqual(mockAnalytics);
      expect(mockSupabaseClient.rpc).toHaveBeenCalledWith('get_analytics', {
        p_project_id: projectId,
        p_start: start,
        p_end: end,
        p_models: undefined,
        p_prompt_types: undefined,
      });
    });

    it('should get analytics with models filter', async () => {
      const models = ['model-1', 'model-2'];
      mockSupabaseClient.rpc.mockResolvedValue({
        data: mockAnalytics,
        error: null,
      });

      const result = await repository.getAnalytics(
        projectId,
        start,
        end,
        models,
      );

      expect(result).toEqual(mockAnalytics);
      expect(mockSupabaseClient.rpc).toHaveBeenCalledWith('get_analytics', {
        p_project_id: projectId,
        p_start: start,
        p_end: end,
        p_models: models,
        p_prompt_types: undefined,
      });
    });

    it('should get analytics with prompt types filter', async () => {
      const promptTypes = ['AWARENESS', 'CONSIDERATION'] as PromptType[];
      mockSupabaseClient.rpc.mockResolvedValue({
        data: mockAnalytics,
        error: null,
      });

      const result = await repository.getAnalytics(
        projectId,
        start,
        end,
        undefined,
        promptTypes,
      );

      expect(result).toEqual(mockAnalytics);
      expect(mockSupabaseClient.rpc).toHaveBeenCalledWith('get_analytics', {
        p_project_id: projectId,
        p_start: start,
        p_end: end,
        p_models: undefined,
        p_prompt_types: promptTypes,
      });
    });

    it('should get analytics with both models and prompt types filters', async () => {
      const models = ['model-1'];
      const promptTypes = ['AWARENESS'] as PromptType[];
      mockSupabaseClient.rpc.mockResolvedValue({
        data: mockAnalytics,
        error: null,
      });

      const result = await repository.getAnalytics(
        projectId,
        start,
        end,
        models,
        promptTypes,
      );

      expect(result).toEqual(mockAnalytics);
      expect(mockSupabaseClient.rpc).toHaveBeenCalledWith('get_analytics', {
        p_project_id: projectId,
        p_start: start,
        p_end: end,
        p_models: models,
        p_prompt_types: promptTypes,
      });
    });

    it('should throw error when database operation fails', async () => {
      const error = new Error('Database error') as PostgrestError;
      mockSupabaseClient.rpc.mockResolvedValue({
        data: null,
        error,
      });

      await expect(
        repository.getAnalytics(projectId, start, end),
      ).rejects.toThrow();
    });
  });

  describe('findAll', () => {
    it('should exclude DRAFT projects from results', async () => {
      const activeProjects = [
        { ...mockProject, status: ProjectStatus.ACTIVE },
        { ...mockProject, id: 'project-2', status: ProjectStatus.ACTIVE },
      ];

      mockSupabaseClient.neq.mockResolvedValue({
        data: activeProjects,
        error: null,
      });

      const result = await repository.findAll();

      expect(result).toEqual(activeProjects);
      expect(mockSupabaseClient.from).toHaveBeenCalledWith('Project');
      expect(mockSupabaseClient.select).toHaveBeenCalledWith('*');
      expect(mockSupabaseClient.neq).toHaveBeenCalledWith('status', 'DRAFT');
    });
  });

  describe('findDraftByUserId', () => {
    const userId = 'user-id';

    it('should not join Brand and Model tables', async () => {
      const draftProject = {
        ...mockProject,
        status: ProjectStatus.DRAFT,
      };

      mockSupabaseClient.maybeSingle.mockResolvedValue({
        data: draftProject,
        error: null,
      });

      const result = await repository.findDraftByUserId(userId);

      expect(result).toEqual({
        ...draftProject,
        brand: undefined,
        models: [],
      });
      expect(mockSupabaseClient.select).toHaveBeenCalledWith('*');
      expect(mockSupabaseClient.select).not.toHaveBeenCalledWith(
        expect.stringContaining('brand:Brand'),
      );
    });
  });
});
