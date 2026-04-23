import { Test, TestingModule } from '@nestjs/testing';
import { ContentProfileRepository } from './content-profile.repository';
import { SUPABASE } from '../utils/const';
import { PostgrestError } from '@supabase/supabase-js';
import type {
  Tables,
  TablesInsert,
  TablesUpdate,
} from '../supabase/supabase.types';

type ContentProfile = Tables<'ContentProfile'>;
type ContentProfileInsert = TablesInsert<'ContentProfile'>;
type ContentProfileUpdate = TablesUpdate<'ContentProfile'>;

describe('ContentProfileRepository', () => {
  let repository: ContentProfileRepository;

  const mockContentProfile: ContentProfile = {
    id: 'content-profile-id',
    projectId: 'project-id',
    name: 'Blog Posts',
    description: 'Content profile for blog posts and articles',
    voiceAndTone: 'Professional yet friendly, informative and engaging',
    audience: 'Tech-savvy professionals aged 25-45',
  };

  const mockSupabaseClient = {
    from: jest.fn().mockReturnThis(),
    select: jest.fn().mockReturnThis(),
    insert: jest.fn().mockReturnThis(),
    update: jest.fn().mockReturnThis(),
    delete: jest.fn().mockReturnThis(),
    eq: jest.fn().mockReturnThis(),
    order: jest.fn().mockReturnThis(),
    single: jest.fn(),
    maybeSingle: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ContentProfileRepository,
        {
          provide: SUPABASE,
          useValue: mockSupabaseClient,
        },
      ],
    }).compile();

    repository = module.get<ContentProfileRepository>(ContentProfileRepository);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(repository).toBeDefined();
  });

  describe('findById', () => {
    const contentProfileId = 'content-profile-id';
    const userId = 'user-id';

    it('should find content profile by id successfully', async () => {
      mockSupabaseClient.maybeSingle.mockResolvedValue({
        data: {
          ...mockContentProfile,
          project: { createdBy: userId },
        },
        error: null,
      });

      const result = await repository.findById(contentProfileId, userId);

      expect(result).toEqual(mockContentProfile);
      expect(mockSupabaseClient.from).toHaveBeenCalledWith('ContentProfile');
      expect(mockSupabaseClient.select).toHaveBeenCalledWith(
        '*, project:Project(createdBy)',
      );
      expect(mockSupabaseClient.eq).toHaveBeenCalledWith(
        'id',
        contentProfileId,
      );
      expect(mockSupabaseClient.eq).toHaveBeenCalledWith(
        'project.createdBy',
        userId,
      );
      expect(mockSupabaseClient.maybeSingle).toHaveBeenCalled();
    });

    it('should return null when content profile not found', async () => {
      mockSupabaseClient.maybeSingle.mockResolvedValue({
        data: null,
        error: null,
      });

      const result = await repository.findById(contentProfileId, userId);

      expect(result).toBeNull();
      expect(mockSupabaseClient.from).toHaveBeenCalledWith('ContentProfile');
    });

    it('should throw error when database operation fails', async () => {
      const error = new Error('Database error') as PostgrestError;
      mockSupabaseClient.maybeSingle.mockResolvedValue({
        data: null,
        error,
      });

      await expect(
        repository.findById(contentProfileId, userId),
      ).rejects.toThrow();
    });
  });

  describe('findByProjectId', () => {
    const projectId = 'project-id';
    const userId = 'user-id';

    it('should find all content profiles by project id successfully', async () => {
      const mockProfiles = [
        {
          ...mockContentProfile,
          project: { createdBy: userId },
        },
        {
          ...mockContentProfile,
          id: 'content-profile-id-2',
          name: 'Social Media Posts',
          project: { createdBy: userId },
        },
      ];

      mockSupabaseClient.order.mockResolvedValue({
        data: mockProfiles,
        error: null,
      });

      const result = await repository.findByProjectId(projectId, userId);

      expect(result).toEqual(mockProfiles);
      expect(mockSupabaseClient.from).toHaveBeenCalledWith('ContentProfile');
      expect(mockSupabaseClient.select).toHaveBeenCalledWith(
        '*, project:Project(createdBy)',
      );
      expect(mockSupabaseClient.eq).toHaveBeenCalledWith(
        'project.createdBy',
        userId,
      );
      expect(mockSupabaseClient.eq).toHaveBeenCalledWith(
        'projectId',
        projectId,
      );
      expect(mockSupabaseClient.order).toHaveBeenCalledWith('name', {
        ascending: true,
      });
    });

    it('should return empty array when no content profiles found', async () => {
      mockSupabaseClient.order.mockResolvedValue({
        data: null,
        error: null,
      });

      const result = await repository.findByProjectId(projectId, userId);

      expect(result).toEqual([]);
      expect(mockSupabaseClient.from).toHaveBeenCalledWith('ContentProfile');
    });

    it('should throw error when database operation fails', async () => {
      const error = new Error('Database error') as PostgrestError;
      mockSupabaseClient.order.mockResolvedValue({
        data: null,
        error,
      });

      await expect(
        repository.findByProjectId(projectId, userId),
      ).rejects.toThrow();
    });
  });

  describe('create', () => {
    const createData: ContentProfileInsert = {
      projectId: 'project-id',
      name: 'Blog Posts',
      description: 'Content profile for blog posts and articles',
      voiceAndTone: 'Professional yet friendly, informative and engaging',
      audience: 'Tech-savvy professionals aged 25-45',
    };

    it('should create content profile successfully', async () => {
      mockSupabaseClient.single.mockResolvedValue({
        data: mockContentProfile,
        error: null,
      });

      const result = await repository.create(createData);

      expect(result).toEqual(mockContentProfile);
      expect(mockSupabaseClient.from).toHaveBeenCalledWith('ContentProfile');
      expect(mockSupabaseClient.insert).toHaveBeenCalledWith(createData);
      expect(mockSupabaseClient.select).toHaveBeenCalled();
      expect(mockSupabaseClient.single).toHaveBeenCalled();
    });

    it('should create content profile with null description', async () => {
      const createDataWithNullDescription = {
        ...createData,
        description: null,
      };
      const profileWithNullDescription = {
        ...mockContentProfile,
        description: null,
      };

      mockSupabaseClient.single.mockResolvedValue({
        data: profileWithNullDescription,
        error: null,
      });

      const result = await repository.create(createDataWithNullDescription);

      expect(result).toEqual(profileWithNullDescription);
      expect(mockSupabaseClient.insert).toHaveBeenCalledWith(
        createDataWithNullDescription,
      );
    });

    it('should throw error when database operation fails', async () => {
      const error = new Error('Database error') as PostgrestError;
      mockSupabaseClient.single.mockResolvedValue({
        data: null,
        error,
      });

      await expect(repository.create(createData)).rejects.toThrow();
    });
  });

  describe('update', () => {
    const contentProfileId = 'content-profile-id';
    const updateData: ContentProfileUpdate = {
      name: 'Updated Blog Posts',
      description: 'Updated description',
      voiceAndTone: 'Updated tone',
      audience: 'Updated audience',
    };

    it('should update content profile successfully', async () => {
      const updatedProfile = {
        ...mockContentProfile,
        ...updateData,
      };

      mockSupabaseClient.maybeSingle.mockResolvedValue({
        data: updatedProfile,
        error: null,
      });

      const result = await repository.update(contentProfileId, updateData);

      expect(result).toEqual(updatedProfile);
      expect(mockSupabaseClient.from).toHaveBeenCalledWith('ContentProfile');
      expect(mockSupabaseClient.update).toHaveBeenCalledWith(updateData);
      expect(mockSupabaseClient.eq).toHaveBeenCalledWith(
        'id',
        contentProfileId,
      );
      expect(mockSupabaseClient.select).toHaveBeenCalled();
      expect(mockSupabaseClient.maybeSingle).toHaveBeenCalled();
    });

    it('should update only specific fields', async () => {
      const partialUpdate: ContentProfileUpdate = {
        name: 'Updated Name Only',
      };
      const updatedProfile = {
        ...mockContentProfile,
        name: 'Updated Name Only',
      };

      mockSupabaseClient.maybeSingle.mockResolvedValue({
        data: updatedProfile,
        error: null,
      });

      const result = await repository.update(contentProfileId, partialUpdate);

      expect(result).toEqual(updatedProfile);
      expect(mockSupabaseClient.update).toHaveBeenCalledWith(partialUpdate);
    });

    it('should return null when content profile not found', async () => {
      mockSupabaseClient.maybeSingle.mockResolvedValue({
        data: null,
        error: null,
      });

      const result = await repository.update(contentProfileId, updateData);

      expect(result).toBeNull();
    });

    it('should throw error when database operation fails', async () => {
      const error = new Error('Database error') as PostgrestError;
      mockSupabaseClient.maybeSingle.mockResolvedValue({
        data: null,
        error,
      });

      await expect(
        repository.update(contentProfileId, updateData),
      ).rejects.toThrow();
    });
  });

  describe('delete', () => {
    const contentProfileId = 'content-profile-id';

    it('should delete content profile successfully', async () => {
      mockSupabaseClient.eq.mockResolvedValue({
        data: null,
        error: null,
      });

      await repository.delete(contentProfileId);

      expect(mockSupabaseClient.from).toHaveBeenCalledWith('ContentProfile');
      expect(mockSupabaseClient.delete).toHaveBeenCalled();
      expect(mockSupabaseClient.eq).toHaveBeenCalledWith(
        'id',
        contentProfileId,
      );
    });

    it('should throw error when database operation fails', async () => {
      const error = new Error('Database error') as PostgrestError;
      mockSupabaseClient.eq.mockResolvedValue({
        data: null,
        error,
      });

      await expect(repository.delete(contentProfileId)).rejects.toThrow();
    });
  });
});
