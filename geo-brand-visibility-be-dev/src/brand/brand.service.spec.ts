import { Test, TestingModule } from '@nestjs/testing';
import { BrandService } from './brand.service';
import { BrandRepository } from './brand.repository';
import { AgentService } from '../agent/agent.service';
import { NotFoundException } from '@nestjs/common';
import { AGENTS, SUPABASE } from '../utils/const';
import type { Tables } from '../supabase/supabase.types';
import { ProjectService } from '../project/project.service';
import { CloudflareService } from '../cloudflare/cloudflare.service';
import { ConfigService } from '@nestjs/config';
import { DEFAULT_LANGUAGE, DEFAULT_LOCATION } from 'src/shared/constant';

jest.mock('uuid', () => ({
  v4: jest.fn(() => 'mock-uuid'),
}));

type Service = Omit<Tables<'Service'>, 'brandId'>;
type Brand = Tables<'Brand'> & {
  services: Service[];
};

describe('BrandService', () => {
  let service: BrandService;

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
  };

  const mockBrandRepository = {
    findById: jest.fn(),
    findByProjectId: jest.fn(),
    updateById: jest.fn(),
  };

  const mockAgentService = {
    execute: jest.fn(),
  };

  const mockProjectService = {
    updateProject: jest.fn(),
  };

  const mockCloudflareService = {
    createCustomHostname: jest.fn(),
    deleteCustomHostname: jest.fn(),
  };
  const mockSupabaseClient = {};
  const mockConfigService = {
    get: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        BrandService,
        {
          provide: BrandRepository,
          useValue: mockBrandRepository,
        },
        {
          provide: AgentService,
          useValue: mockAgentService,
        },
        {
          provide: ProjectService,
          useValue: mockProjectService,
        },
        {
          provide: CloudflareService,
          useValue: mockCloudflareService,
        },
        {
          provide: SUPABASE,
          useValue: mockSupabaseClient,
        },
        {
          provide: ConfigService,
          useValue: mockConfigService,
        },
      ],
    }).compile();

    service = module.get<BrandService>(BrandService);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('createBrand', () => {
    const projectId = 'project-id';
    const domain = 'test.com';
    const userId = 'user-id';
    const language = DEFAULT_LANGUAGE;
    const location = DEFAULT_LOCATION;

    it('should create brand successfully', async () => {
      mockProjectService.updateProject.mockResolvedValue({});
      mockAgentService.execute.mockResolvedValue(mockBrand);

      const result = await service.createBrand({
        projectId,
        domain,
        userId,
        location,
        language,
      });

      expect(result).toEqual(mockBrand);
      expect(mockProjectService.updateProject).toHaveBeenCalledWith(projectId, {
        language,
        location,
      });
      expect(mockAgentService.execute).toHaveBeenCalledWith(
        userId,
        AGENTS.BRAND_CONTEXT_INITIALIZATION,
        `Init brand context for project using given information:\n` +
          `- Project ID: "${projectId}"\n` +
          `- Domain: "${domain}"\n` +
          `- Language: "${language}"\n` +
          `- Location: "${location.length ? location : DEFAULT_LOCATION}".`,
      );
    });

    it('should allow any language value at service layer', async () => {
      const unsupportedLanguage = 'UnsupportedLanguage';

      mockProjectService.updateProject.mockResolvedValue({});
      mockAgentService.execute.mockResolvedValue(mockBrand);

      const result = await service.createBrand({
        projectId,
        domain,
        userId,
        location,
        language: unsupportedLanguage,
      });

      expect(result).toEqual(mockBrand);
      expect(mockProjectService.updateProject).toHaveBeenCalledWith(projectId, {
        language: unsupportedLanguage,
        location,
      });
      expect(mockAgentService.execute).toHaveBeenCalledWith(
        userId,
        AGENTS.BRAND_CONTEXT_INITIALIZATION,
        `Init brand context for project using given information:\n` +
          `- Project ID: "${projectId}"\n` +
          `- Domain: "${domain}"\n` +
          `- Language: "${unsupportedLanguage}"\n` +
          `- Location: "${location.length ? location : DEFAULT_LOCATION}".`,
      );
    });
  });

  describe('findBrandById', () => {
    const brandId = 'brand-id';
    const userId = 'user-id';

    it('should find brand successfully', async () => {
      mockBrandRepository.findById.mockResolvedValue(mockBrand);

      const result = await service.findBrandById(brandId, userId);

      expect(result).toEqual(mockBrand);
      expect(mockBrandRepository.findById).toHaveBeenCalledWith(
        brandId,
        userId,
      );
    });

    it('should throw NotFoundException when brand not found', async () => {
      mockBrandRepository.findById.mockResolvedValue(null);

      await expect(service.findBrandById(brandId, userId)).rejects.toThrow(
        new NotFoundException(`Brand ${brandId} not found`),
      );
    });
  });

  describe('updateBrand', () => {
    const brandId = 'brand-id';
    const userId = 'user-id';
    const updateData = {
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
      mockBrandRepository.findById.mockResolvedValue(mockBrand);
      mockBrandRepository.updateById.mockResolvedValue(updatedBrand);

      const result = await service.updateBrand(brandId, updateData, userId);

      expect(result).toEqual(updatedBrand);
      expect(mockBrandRepository.findById).toHaveBeenCalledWith(
        brandId,
        userId,
      );
      expect(mockBrandRepository.updateById).toHaveBeenCalledWith(
        brandId,
        updateData,
      );
    });

    it('should throw NotFoundException when brand not found', async () => {
      mockBrandRepository.findById.mockResolvedValue(null);

      await expect(
        service.updateBrand(brandId, updateData, userId),
      ).rejects.toThrow(new NotFoundException(`Brand ${brandId} not found`));

      expect(mockBrandRepository.findById).toHaveBeenCalledWith(
        brandId,
        userId,
      );
      expect(mockBrandRepository.updateById).not.toHaveBeenCalled();
    });
  });

  describe('findBrandByProjectId', () => {
    const projectId = 'project-id';
    const userId = 'user-id';

    it('should find brand successfully', async () => {
      mockBrandRepository.findByProjectId.mockResolvedValue(mockBrand);

      const result = await service.findBrandByProjectId(projectId, userId);

      expect(result).toEqual(mockBrand);
      expect(mockBrandRepository.findByProjectId).toHaveBeenCalledWith(
        projectId,
        userId,
      );
    });

    it('should throw NotFoundException when brand not found', async () => {
      mockBrandRepository.findByProjectId.mockResolvedValue(null);

      await expect(
        service.findBrandByProjectId(projectId, userId),
      ).rejects.toThrow(new NotFoundException('Brand not found'));
    });
  });
});
