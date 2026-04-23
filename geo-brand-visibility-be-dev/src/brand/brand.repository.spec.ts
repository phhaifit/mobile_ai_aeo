import { Test, TestingModule } from '@nestjs/testing';
import { BrandRepository } from './brand.repository';
import { SUPABASE } from '../utils/const';
import { PostgrestError } from '@supabase/supabase-js';
import type { Tables, TablesUpdate } from '../supabase/supabase.types';

type Service = Omit<Tables<'Service'>, 'brandId'>;
type Brand = Tables<'Brand'> & {
  services: Service[];
};
type BrandUpdate = TablesUpdate<'Brand'> & {
  services?: {
    id?: string;
    name: string;
    description?: string;
  }[];
  domainConfigMethod?: 'cname' | 'rewrite';
  cloudflareHostnameId?: string | null;
  logoUrl?: string | null;
  defaultArticleImageUrl?: string | null;
  blogTitle?: string | null;
  blogHotline?: string | null;
  slug?: string;
};

describe('BrandRepository', () => {
  let repository: BrandRepository;

  const mockService: Service = {
    id: 'service-id',
    name: 'Test Service',
    description: 'Test Service Description',
  };

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
    services: [mockService],
    blogHotline: null,
    blogTitle: null,
    cloudflareHostnameId: null,
    customDomain: null,
    defaultArticleImageUrl: null,
    domainConfigMethod: null,
    logoUrl: null,
    slug: 'test-brand-slug',
  };

  const mockSupabaseClient = {
    from: jest.fn().mockReturnThis(),
    select: jest.fn().mockReturnThis(),
    eq: jest.fn().mockReturnThis(),
    maybeSingle: jest.fn(),
    rpc: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        BrandRepository,
        {
          provide: SUPABASE,
          useValue: mockSupabaseClient,
        },
      ],
    }).compile();

    repository = module.get<BrandRepository>(BrandRepository);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(repository).toBeDefined();
  });

  describe('findById', () => {
    const brandId = 'brand-id';
    const userId = 'user-id';

    it('should find brand by id successfully', async () => {
      mockSupabaseClient.maybeSingle.mockResolvedValue({
        data: {
          ...mockBrand,
          project: {
            createdBy: userId,
          },
        },
        error: null,
      });

      const result = await repository.findById(brandId, userId);

      expect(result).toEqual(mockBrand);
      expect(mockSupabaseClient.from).toHaveBeenCalledWith('Brand');
      expect(mockSupabaseClient.select).toHaveBeenCalledWith(
        '*, services:Service(id, name, description), project:Project!inner(projectMembers:Project_Member!inner(userId))',
      );
      expect(mockSupabaseClient.eq).toHaveBeenCalledWith('id', brandId);
      expect(mockSupabaseClient.eq).toHaveBeenCalledWith(
        'project.projectMembers.userId',
        userId,
      );
    });

    it('should return null when brand not found', async () => {
      mockSupabaseClient.maybeSingle.mockResolvedValue({
        data: null,
        error: null,
      });

      const result = await repository.findById(brandId, userId);

      expect(result).toBeNull();
    });

    it('should throw error when database operation fails', async () => {
      const error = new Error('Database error') as PostgrestError;
      mockSupabaseClient.maybeSingle.mockResolvedValue({
        data: null,
        error,
      });

      await expect(repository.findById(brandId, userId)).rejects.toThrow();
    });
  });

  describe('findByProjectId', () => {
    const projectId = 'project-id';
    const userId = 'user-id';

    it('should find brand by project id successfully', async () => {
      mockSupabaseClient.maybeSingle.mockResolvedValue({
        data: {
          ...mockBrand,
          project: {
            createdBy: userId,
          },
        },
        error: null,
      });

      const result = await repository.findByProjectId(projectId, userId);

      expect(result).toEqual(mockBrand);
      expect(mockSupabaseClient.from).toHaveBeenCalledWith('Brand');
      expect(mockSupabaseClient.select).toHaveBeenCalledWith(
        '*, services:Service(id, name, description), project:Project!inner(projectMembers:Project_Member!inner(userId))',
      );
      expect(mockSupabaseClient.eq).toHaveBeenCalledWith(
        'projectId',
        projectId,
      );
      expect(mockSupabaseClient.eq).toHaveBeenCalledWith(
        'project.projectMembers.userId',
        userId,
      );
    });

    it('should return null when brand not found', async () => {
      mockSupabaseClient.maybeSingle.mockResolvedValue({
        data: null,
        error: null,
      });

      const result = await repository.findByProjectId(projectId, userId);

      expect(result).toBeNull();
    });

    it('should throw error when database operation fails', async () => {
      const error = new Error('Database error') as PostgrestError;
      mockSupabaseClient.maybeSingle.mockResolvedValue({
        data: null,
        error,
      });

      await expect(
        repository.findByProjectId(projectId, userId),
      ).rejects.toThrow();
    });
  });

  describe('updateById', () => {
    const brandId = 'brand-id';
    const updateData: BrandUpdate = {
      name: 'Updated Brand',
      domain: 'updated.com',
      description: 'Updated Description',
      targetMarket: 'Updated Market',
      industry: 'Updated Industry',
      mission: 'Updated Mission',
      services: [
        {
          id: 'existing-service-id',
          name: 'Updated Service',
          description: 'Updated',
        },
        { name: 'New Service', description: 'New Description' },
      ],
    };

    it('should update brand successfully', async () => {
      const updatedBrand = {
        ...mockBrand,
        ...updateData,
      };

      mockSupabaseClient.rpc.mockResolvedValue({
        data: updatedBrand,
        error: null,
      });

      const result = await repository.updateById(brandId, updateData);

      expect(result).toEqual(updatedBrand);
      expect(mockSupabaseClient.rpc).toHaveBeenCalledWith('update_brand', {
        _id: brandId,
        _name: updateData.name,
        _domain: updateData.domain,
        _description: updateData.description,
        _target_market: updateData.targetMarket,
        _industry: updateData.industry,
        _mission: updateData.mission,
        _services_to_update: [
          {
            id: 'existing-service-id',
            name: 'Updated Service',
            description: 'Updated',
          },
        ],
        _services_to_insert: [
          { name: 'New Service', description: 'New Description' },
        ],
      });
    });

    it('should throw error when database operation fails', async () => {
      const error = new Error('Database error') as PostgrestError;
      mockSupabaseClient.rpc.mockResolvedValue({
        data: null,
        error,
      });

      await expect(
        repository.updateById(brandId, updateData),
      ).rejects.toThrow();
    });
  });
});
