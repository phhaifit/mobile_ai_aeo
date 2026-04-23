import { Test, TestingModule } from '@nestjs/testing';
import { TopicRepository } from './topic.repository';
import { SUPABASE } from '../utils/const';
import type { Tables } from '../supabase/supabase.types';

const mockTopic: Tables<'Topic'> = {
  id: 'topic-id',
  projectId: 'project-id',
  name: 'Test Topic',
  searchVolume: 1000,
  isMonitored: true,
  isDeleted: false,
  createdAt: new Date().toISOString(),
  updatedAt: new Date().toISOString(),
};

type SupabaseMock = {
  from: jest.Mock;
  select: jest.Mock;
  insert: jest.Mock;
  update: jest.Mock;
  eq: jest.Mock;
  in: jest.Mock;
  single: jest.Mock;
  order: jest.Mock;
};

describe('TopicRepository', () => {
  let repository: TopicRepository;
  let mockSupabaseClient: SupabaseMock;

  beforeEach(async () => {
    mockSupabaseClient = {
      from: jest.fn().mockReturnThis(),
      select: jest.fn().mockReturnThis(),
      eq: jest.fn().mockReturnThis(),
      insert: jest.fn().mockReturnThis(),
      update: jest.fn().mockReturnThis(),
      in: jest.fn().mockReturnThis(),
      single: jest.fn().mockReturnThis(),
      order: jest.fn().mockReturnThis(),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        TopicRepository,
        { provide: SUPABASE, useValue: mockSupabaseClient },
      ],
    }).compile();

    repository = module.get<TopicRepository>(TopicRepository);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(repository).toBeDefined();
  });

  describe('getTopic', () => {
    it('should return a topic with user access check', async () => {
      const mockTopicWithProject = {
        ...mockTopic,
        project: { projectMembers: [{ userId: 'user-id' }] },
      };
      mockSupabaseClient.eq
        .mockReturnValueOnce(mockSupabaseClient)
        .mockReturnValueOnce(mockSupabaseClient)
        .mockReturnValueOnce({
          maybeSingle: jest.fn().mockResolvedValue({
            data: mockTopicWithProject,
            error: null,
          }),
        });

      const result = await repository.getTopic('topic-id', 'user-id');

      expect(result).toEqual(mockTopic);
      expect(mockSupabaseClient.from).toHaveBeenCalledWith('Topic');
      expect(mockSupabaseClient.select).toHaveBeenCalledWith(
        '*, project:Project!inner(projectMembers:Project_Member!inner(userId))',
      );
      expect(mockSupabaseClient.eq).toHaveBeenCalledWith('id', 'topic-id');
      expect(mockSupabaseClient.eq).toHaveBeenCalledWith('isDeleted', false);
      expect(mockSupabaseClient.eq).toHaveBeenCalledWith(
        'project.projectMembers.userId',
        'user-id',
      );
    });

    it('should return null if topic not found', async () => {
      mockSupabaseClient.eq
        .mockReturnValueOnce(mockSupabaseClient)
        .mockReturnValueOnce(mockSupabaseClient)
        .mockReturnValueOnce({
          maybeSingle: jest.fn().mockResolvedValue({
            data: null,
            error: null,
          }),
        });

      const result = await repository.getTopic('topic-id', 'user-id');

      expect(result).toBeNull();
    });

    it('should throw error if supabase returns error', async () => {
      const error = new Error('DB error');
      mockSupabaseClient.eq
        .mockReturnValueOnce(mockSupabaseClient)
        .mockReturnValueOnce(mockSupabaseClient)
        .mockReturnValueOnce({
          maybeSingle: jest.fn().mockResolvedValue({
            data: null,
            error,
          }),
        });

      await expect(
        repository.getTopic('topic-id', 'user-id'),
      ).rejects.toThrow();
    });
  });

  describe('getTopics', () => {
    it('should return multiple topics with user access check', async () => {
      const ids = ['topic-id-1', 'topic-id-2'];
      const mockTopicsWithProject = [
        {
          ...mockTopic,
          id: 'topic-id-1',
          project: { projectMembers: [{ userId: 'user-id' }] },
        },
        {
          ...mockTopic,
          id: 'topic-id-2',
          project: { projectMembers: [{ userId: 'user-id' }] },
        },
      ];

      mockSupabaseClient.in.mockReturnValueOnce(mockSupabaseClient);
      mockSupabaseClient.eq
        .mockReturnValueOnce(mockSupabaseClient)
        .mockResolvedValueOnce({
          data: mockTopicsWithProject,
          error: null,
        });

      const result = await repository.getTopics(ids, 'user-id');

      expect(result).toEqual([
        { ...mockTopic, id: 'topic-id-1' },
        { ...mockTopic, id: 'topic-id-2' },
      ]);
      expect(mockSupabaseClient.from).toHaveBeenCalledWith('Topic');
      expect(mockSupabaseClient.select).toHaveBeenCalledWith(
        '*, project:Project!inner(projectMembers:Project_Member!inner(userId))',
      );
      expect(mockSupabaseClient.in).toHaveBeenCalledWith('id', ids);
      expect(mockSupabaseClient.eq).toHaveBeenCalledWith('isDeleted', false);
      expect(mockSupabaseClient.eq).toHaveBeenCalledWith(
        'project.projectMembers.userId',
        'user-id',
      );
    });

    it('should return empty array if no topics found', async () => {
      mockSupabaseClient.in.mockReturnValueOnce(mockSupabaseClient);
      mockSupabaseClient.eq
        .mockReturnValueOnce(mockSupabaseClient)
        .mockResolvedValueOnce({
          data: [],
          error: null,
        });

      const result = await repository.getTopics(['topic-id'], 'user-id');

      expect(result).toEqual([]);
    });

    it('should throw error if supabase returns error', async () => {
      const error = new Error('DB error');
      mockSupabaseClient.in.mockReturnValueOnce(mockSupabaseClient);
      mockSupabaseClient.eq
        .mockReturnValueOnce(mockSupabaseClient)
        .mockResolvedValueOnce({
          data: null,
          error,
        });

      await expect(
        repository.getTopics(['topic-id'], 'user-id'),
      ).rejects.toThrow();
    });
  });

  describe('getTopicsByProjectId', () => {
    it('should return topics for a project', async () => {
      const mockTopicWithProject = {
        ...mockTopic,
        active_prompt_count: 2,
        project: { projectMembers: [{ userId: 'user-id' }] },
      };
      mockSupabaseClient.order.mockResolvedValueOnce({
        data: [mockTopicWithProject],
        error: null,
      });
      const result = await repository.getTopicsByProjectId(
        'project-id',
        'user-id',
      );
      expect(result).toEqual([
        {
          ...mockTopic,
          active_prompt_count: 2,
          promptCount: 2,
        },
      ]);
      expect(mockSupabaseClient.from).toHaveBeenCalledWith('Topic');
      expect(mockSupabaseClient.select).toHaveBeenCalledWith(
        '*, project:Project!inner(projectMembers:Project_Member!inner(userId)), active_prompt_count',
      );
      expect(mockSupabaseClient.eq).toHaveBeenCalledWith(
        'project.projectMembers.userId',
        'user-id',
      );
      expect(mockSupabaseClient.eq).toHaveBeenCalledWith(
        'projectId',
        'project-id',
      );
      expect(mockSupabaseClient.eq).toHaveBeenCalledWith('isDeleted', false);
      expect(mockSupabaseClient.eq).toHaveBeenCalledTimes(3);
    });

    it('should throw error if supabase returns error', async () => {
      const error = new Error('DB error');
      mockSupabaseClient.order.mockResolvedValueOnce({ data: null, error });
      await expect(
        repository.getTopicsByProjectId('project-id', 'user-id'),
      ).rejects.toThrow();
    });
  });

  describe('insertMany', () => {
    it('should create multiple topics', async () => {
      const createData = [
        {
          name: 'Topic 1',
          projectId: 'project-id',
          searchVolume: 500,
        },
        {
          name: 'Topic 2',
          projectId: 'project-id',
          searchVolume: null,
        },
      ];
      const mockTopics = [
        { ...mockTopic, name: 'Topic 1' },
        { ...mockTopic, name: 'Topic 2' },
      ];

      mockSupabaseClient.select.mockResolvedValue({
        data: mockTopics,
        error: null,
      });

      const result = await repository.insertMany(createData);
      expect(result).toEqual(mockTopics);
      expect(mockSupabaseClient.from).toHaveBeenCalledWith('Topic');
      expect(mockSupabaseClient.insert).toHaveBeenCalledWith(createData);
      expect(mockSupabaseClient.select).toHaveBeenCalled();
    });

    it('should throw error if supabase returns error', async () => {
      const error = new Error('DB error');
      const createData = [
        {
          name: 'Topic 1',
          projectId: 'project-id',
        },
      ];
      mockSupabaseClient.select.mockResolvedValue({ data: null, error });
      await expect(repository.insertMany(createData)).rejects.toThrow();
    });
  });

  describe('update', () => {
    it('should update a topic name', async () => {
      const dto = { name: 'Updated Topic Name' };
      mockSupabaseClient.eq
        .mockReturnValueOnce(mockSupabaseClient)
        .mockReturnValueOnce(mockSupabaseClient);
      mockSupabaseClient.single.mockResolvedValue({
        data: { ...mockTopic, name: dto.name },
        error: null,
      });
      const result = await repository.update('topic-id', dto);
      expect(result).toEqual({ ...mockTopic, name: dto.name });
      expect(mockSupabaseClient.from).toHaveBeenCalledWith('Topic');
      expect(mockSupabaseClient.update).toHaveBeenCalledWith(dto);
      expect(mockSupabaseClient.eq).toHaveBeenNthCalledWith(
        1,
        'id',
        'topic-id',
      );
      expect(mockSupabaseClient.eq).toHaveBeenNthCalledWith(
        2,
        'isDeleted',
        false,
      );
      expect(mockSupabaseClient.select).toHaveBeenCalled();
      expect(mockSupabaseClient.single).toHaveBeenCalled();
    });

    it('should update topic monitoring status', async () => {
      const dto = { isMonitored: false };
      mockSupabaseClient.eq
        .mockReturnValueOnce(mockSupabaseClient)
        .mockReturnValueOnce(mockSupabaseClient);
      mockSupabaseClient.single.mockResolvedValue({
        data: { ...mockTopic, isMonitored: false },
        error: null,
      });
      const result = await repository.update('topic-id', dto);
      expect(result).toEqual({ ...mockTopic, isMonitored: false });
      expect(mockSupabaseClient.from).toHaveBeenCalledWith('Topic');
      expect(mockSupabaseClient.update).toHaveBeenCalledWith(dto);
    });

    it('should update both name and monitoring status', async () => {
      const dto = { name: 'New Name', isMonitored: false };
      mockSupabaseClient.eq
        .mockReturnValueOnce(mockSupabaseClient)
        .mockReturnValueOnce(mockSupabaseClient);
      mockSupabaseClient.single.mockResolvedValue({
        data: { ...mockTopic, name: dto.name, isMonitored: false },
        error: null,
      });
      const result = await repository.update('topic-id', dto);
      expect(result).toEqual({
        ...mockTopic,
        name: dto.name,
        isMonitored: false,
      });
      expect(mockSupabaseClient.from).toHaveBeenCalledWith('Topic');
      expect(mockSupabaseClient.update).toHaveBeenCalledWith(dto);
    });

    it('should throw error if supabase returns error', async () => {
      const error = new Error('DB error');
      const dto = { name: 'New Name' };
      mockSupabaseClient.eq
        .mockReturnValueOnce(mockSupabaseClient)
        .mockReturnValueOnce(mockSupabaseClient);
      mockSupabaseClient.single.mockResolvedValue({ data: null, error });
      await expect(repository.update('topic-id', dto)).rejects.toThrow();
    });
  });

  describe('deleteMany', () => {
    it('should soft delete multiple topics', async () => {
      const ids = ['topic-id-1', 'topic-id-2'];
      mockSupabaseClient.in.mockResolvedValue({
        data: null,
        error: null,
      });
      await repository.deleteMany(ids);
      expect(mockSupabaseClient.from).toHaveBeenCalledWith('Topic');
      expect(mockSupabaseClient.update).toHaveBeenCalledWith({
        isDeleted: true,
      });
      expect(mockSupabaseClient.in).toHaveBeenCalledWith('id', ids);
    });

    it('should throw error if supabase returns error', async () => {
      const error = new Error('DB error');
      mockSupabaseClient.in.mockResolvedValue({ data: null, error });
      await expect(repository.deleteMany(['topic-id'])).rejects.toThrow();
    });
  });
});
