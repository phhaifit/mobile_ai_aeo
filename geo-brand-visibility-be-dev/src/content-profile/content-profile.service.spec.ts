import { Test, TestingModule } from '@nestjs/testing';
import { ContentProfileService } from './content-profile.service';
import { ContentProfileRepository } from './content-profile.repository';
import { ProjectRepository } from '../project/project.repository';
import { NotFoundException, BadRequestException } from '@nestjs/common';
import type { Tables } from '../supabase/supabase.types';

type ContentProfile = Tables<'ContentProfile'>;

describe('ContentProfileService', () => {
  let service: ContentProfileService;

  const mockContentProfile: ContentProfile = {
    id: 'content-profile-id',
    projectId: 'project-id',
    name: 'Blog Posts',
    description: 'Content profile for blog posts and articles',
    voiceAndTone: 'Professional yet friendly, informative and engaging',
    audience: 'Tech-savvy professionals aged 25-45',
  };

  const mockContentProfileRepository = {
    findById: jest.fn(),
    findByProjectId: jest.fn(),
    create: jest.fn(),
    update: jest.fn(),
    delete: jest.fn(),
  };

  const mockProjectRepository = {
    findById: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ContentProfileService,
        {
          provide: ContentProfileRepository,
          useValue: mockContentProfileRepository,
        },
        {
          provide: ProjectRepository,
          useValue: mockProjectRepository,
        },
      ],
    }).compile();

    service = module.get<ContentProfileService>(ContentProfileService);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('findById', () => {
    const contentProfileId = 'content-profile-id';
    const projectId = 'project-id';
    const userId = 'user-id';

    it('should find content profile by id successfully', async () => {
      mockContentProfileRepository.findById.mockResolvedValue(
        mockContentProfile,
      );

      const result = await service.findById(
        contentProfileId,
        projectId,
        userId,
      );

      expect(result).toEqual(mockContentProfile);
      expect(mockContentProfileRepository.findById).toHaveBeenCalledWith(
        contentProfileId,
        userId,
      );
    });

    it('should throw NotFoundException when content profile not found', async () => {
      mockContentProfileRepository.findById.mockResolvedValue(null);

      await expect(
        service.findById(contentProfileId, projectId, userId),
      ).rejects.toThrow(new NotFoundException('Content profile not found'));
    });

    it('should throw NotFoundException when content profile belongs to different project', async () => {
      mockContentProfileRepository.findById.mockResolvedValue({
        ...mockContentProfile,
        projectId: 'different-project-id',
      });

      await expect(
        service.findById(contentProfileId, projectId, userId),
      ).rejects.toThrow(new NotFoundException('Content profile not found'));
    });
  });

  describe('findByProjectId', () => {
    const projectId = 'project-id';
    const userId = 'user-id';

    it('should find all content profiles for a project successfully', async () => {
      const mockProfiles = [
        mockContentProfile,
        {
          ...mockContentProfile,
          id: 'content-profile-id-2',
          name: 'Social Media Posts',
        },
      ];
      mockContentProfileRepository.findByProjectId.mockResolvedValue(
        mockProfiles,
      );
      mockProjectRepository.findById.mockResolvedValue({ id: projectId });

      const result = await service.findByProjectId(projectId, userId);

      expect(result).toEqual(mockProfiles);
      expect(mockContentProfileRepository.findByProjectId).toHaveBeenCalledWith(
        projectId,
        userId,
      );
    });

    it('should return empty array when no content profiles found', async () => {
      mockContentProfileRepository.findByProjectId.mockResolvedValue([]);

      const result = await service.findByProjectId(projectId, userId);

      expect(result).toEqual([]);
    });
  });

  describe('create', () => {
    const projectId = 'project-id';
    const userId = 'user-id';
    const createDto = {
      name: 'Blog Posts',
      description: 'Content profile for blog posts and articles',
      voiceAndTone: 'Professional yet friendly, informative and engaging',
      audience: 'Tech-savvy professionals aged 25-45',
    };

    it('should create content profile successfully', async () => {
      mockProjectRepository.findById.mockResolvedValue({ id: projectId });
      mockContentProfileRepository.create.mockResolvedValue(mockContentProfile);

      const result = await service.create(projectId, createDto);

      expect(result).toEqual(mockContentProfile);
      expect(mockProjectRepository.findById).toHaveBeenCalledWith(projectId);
      expect(mockContentProfileRepository.create).toHaveBeenCalledWith({
        projectId,
        ...createDto,
      });
    });

    it('should create content profile with null description', async () => {
      const createDtoWithoutDescription = {
        name: 'Blog Posts',
        voiceAndTone: 'Professional yet friendly',
        audience: 'Tech-savvy professionals',
      };
      const profileWithoutDescription = {
        ...mockContentProfile,
        description: null,
      };
      mockProjectRepository.findById.mockResolvedValue({ id: projectId });
      mockContentProfileRepository.create.mockResolvedValue(
        profileWithoutDescription,
      );

      const result = await service.create(
        projectId,
        createDtoWithoutDescription,
      );

      expect(result).toEqual(profileWithoutDescription);
      expect(mockContentProfileRepository.create).toHaveBeenCalledWith({
        projectId,
        ...createDtoWithoutDescription,
      });
    });

    it('should throw NotFoundException when project not found', async () => {
      mockProjectRepository.findById.mockResolvedValue(null);

      await expect(service.create(projectId, createDto)).rejects.toThrow(
        new NotFoundException('Project not found'),
      );

      expect(mockProjectRepository.findById).toHaveBeenCalledWith(projectId);
      expect(mockContentProfileRepository.create).not.toHaveBeenCalled();
    });
  });

  describe('update', () => {
    const projectId = 'project-id';
    const contentProfileId = 'content-profile-id';
    const userId = 'user-id';
    const updateDto = {
      name: 'Updated Blog Posts',
      description: 'Updated description',
      voiceAndTone: 'Updated tone',
      audience: 'Updated audience',
    };

    it('should update content profile successfully', async () => {
      const updatedProfile = {
        ...mockContentProfile,
        ...updateDto,
      };
      mockProjectRepository.findById.mockResolvedValue({ id: projectId });
      mockContentProfileRepository.update.mockResolvedValue(updatedProfile);

      const result = await service.update(
        projectId,
        contentProfileId,
        updateDto,
      );

      expect(result).toEqual(updatedProfile);
      expect(mockProjectRepository.findById).toHaveBeenCalledWith(projectId);
      expect(mockContentProfileRepository.update).toHaveBeenCalledWith(
        contentProfileId,
        updateDto,
      );
    });

    it('should update only specific fields', async () => {
      const partialUpdate = {
        name: 'Updated Name Only',
      };
      const updatedProfile = {
        ...mockContentProfile,
        name: 'Updated Name Only',
      };
      mockProjectRepository.findById.mockResolvedValue({ id: projectId });
      mockContentProfileRepository.update.mockResolvedValue(updatedProfile);

      const result = await service.update(
        projectId,
        contentProfileId,
        partialUpdate,
      );

      expect(result).toEqual(updatedProfile);
      expect(mockContentProfileRepository.update).toHaveBeenCalledWith(
        contentProfileId,
        partialUpdate,
      );
    });

    it('should throw BadRequestException when no fields to update', async () => {
      const emptyUpdate = {};
      mockProjectRepository.findById.mockResolvedValue({ id: projectId });

      await expect(
        service.update(projectId, contentProfileId, emptyUpdate),
      ).rejects.toThrow(new BadRequestException('No fields to update'));

      expect(mockContentProfileRepository.update).not.toHaveBeenCalled();
    });

    it('should throw NotFoundException when project not found', async () => {
      mockProjectRepository.findById.mockResolvedValue(null);

      await expect(
        service.update(projectId, contentProfileId, updateDto),
      ).rejects.toThrow(new NotFoundException('Project not found'));

      expect(mockProjectRepository.findById).toHaveBeenCalledWith(projectId);
      expect(mockContentProfileRepository.update).not.toHaveBeenCalled();
    });

    it('should throw NotFoundException when content profile not found', async () => {
      mockProjectRepository.findById.mockResolvedValue({ id: projectId });
      mockContentProfileRepository.update.mockResolvedValue(null);

      await expect(
        service.update(projectId, contentProfileId, updateDto),
      ).rejects.toThrow(new NotFoundException('Content profile not found'));
    });
  });

  describe('delete', () => {
    const contentProfileId = 'content-profile-id';
    const userId = 'user-id';

    it('should delete content profile successfully', async () => {
      mockContentProfileRepository.findById.mockResolvedValue(
        mockContentProfile,
      );
      mockContentProfileRepository.delete.mockResolvedValue(undefined);

      await service.delete(contentProfileId, userId);

      expect(mockContentProfileRepository.findById).toHaveBeenCalledWith(
        contentProfileId,
        userId,
      );
      expect(mockContentProfileRepository.delete).toHaveBeenCalledWith(
        contentProfileId,
      );
    });

    it('should throw NotFoundException when content profile not found', async () => {
      mockContentProfileRepository.findById.mockResolvedValue(null);

      await expect(service.delete(contentProfileId, userId)).rejects.toThrow(
        new NotFoundException('Content profile not found'),
      );
      expect(mockContentProfileRepository.delete).not.toHaveBeenCalled();
    });
  });
});
