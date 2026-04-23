import { Test, TestingModule } from '@nestjs/testing';
import { PromptRepository } from './prompt.repository';
import { SUPABASE } from '../utils/const';
import { PostgrestError } from '@supabase/supabase-js';
import type { Tables } from '../supabase/supabase.types';

type Prompt = Tables<'Prompt'> & { topicName: string };
type SupabaseMock = {
  from: jest.Mock;
  select: jest.Mock;
  insert: jest.Mock;
  update: jest.Mock;
  eq: jest.Mock;
  order: jest.Mock;
  maybeSingle: jest.Mock;
  single: jest.Mock;
  limit: jest.Mock;
  range: jest.Mock;
};

const PROMPT_TYPES = [
  'AWARENESS',
  'INTEREST',
  'CONSIDERATION',
  'PURCHASE',
  'LOYALTY',
] as const;

describe('PromptRepository', () => {
  let repository: PromptRepository;
  const mockPrompt: Prompt = {
    id: 'prompt-id',
    topicId: 'topic-id',
    topicName: 'Sample Topic',
    status: 'active',
    content: 'Test prompt content',
    type: PROMPT_TYPES[0],
    isMonitored: true,
    isDeleted: false,
    isExhausted: false,
    lastRun: null,
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  };

  let mockSupabaseClient: SupabaseMock;

  beforeEach(async () => {
    mockSupabaseClient = {
      from: jest.fn().mockReturnThis(),
      select: jest.fn().mockReturnThis(),
      insert: jest.fn().mockReturnThis(),
      update: jest.fn().mockReturnThis(),
      eq: jest.fn().mockReturnThis(),
      order: jest.fn().mockReturnThis(),
      maybeSingle: jest.fn(),
      single: jest.fn(),
      limit: jest.fn().mockReturnThis(),
      range: jest.fn().mockReturnThis(),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        PromptRepository,
        {
          provide: SUPABASE,
          useValue: mockSupabaseClient,
        },
      ],
    }).compile();

    repository = module.get<PromptRepository>(PromptRepository);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(repository).toBeDefined();
  });

  describe('findAllByProjectId', () => {
    const projectId = 'project-id';
    const userId = 'user-id';
    it('should find all prompts successfully', async () => {
      const prompts = [
        {
          ...mockPrompt,
          Prompt_Keyword: [
            { Keyword: { keyword: 'test-keyword-1' } },
            { Keyword: { keyword: 'test-keyword-2' } },
          ],
          topic: {
            id: 'topic-id',
            projectId: 'project-id',
            name: 'Sample Topic',
            project: {
              createdBy: userId,
            },
          },
        },
        {
          ...mockPrompt,
          id: 'prompt-2',
          type: PROMPT_TYPES[1],
          Prompt_Keyword: [{ Keyword: { keyword: 'test-keyword-3' } }],
          topic: {
            id: 'topic-id',
            projectId: 'project-id',
            name: 'Sample Topic',
            project: {
              createdBy: userId,
            },
          },
        },
      ];

      mockSupabaseClient.order.mockResolvedValue({
        data: prompts,
        error: null,
      });

      const result = await repository.findAllByProjectId(projectId, userId);

      expect(result).toEqual([
        {
          ...mockPrompt,
          keywords: ['test-keyword-1', 'test-keyword-2'],
        },
        {
          ...mockPrompt,
          id: 'prompt-2',
          type: PROMPT_TYPES[1],
          keywords: ['test-keyword-3'],
        },
      ]);
      expect(mockSupabaseClient.from).toHaveBeenCalledWith('Prompt');
      expect(mockSupabaseClient.select).toHaveBeenCalled();
      expect(mockSupabaseClient.eq).toHaveBeenCalledWith(
        'topic.project.projectMembers.userId',
        userId,
      );
      expect(mockSupabaseClient.eq).toHaveBeenCalledWith(
        'topic.projectId',
        projectId,
      );
      expect(mockSupabaseClient.order).toHaveBeenCalledWith('createdAt', {
        ascending: true,
      });
    });

    it('should throw error when database operation fails', async () => {
      const error = new Error('Database error') as PostgrestError;
      mockSupabaseClient.order.mockResolvedValue({
        data: null,
        error,
      });

      await expect(
        repository.findAllByProjectId(projectId, userId),
      ).rejects.toThrow();
    });

    it('should return empty array when no prompts found', async () => {
      mockSupabaseClient.order.mockResolvedValue({
        data: [],
        error: null,
      });

      const result = await repository.findAllByProjectId(projectId, userId);

      expect(result).toEqual([]);
      expect(mockSupabaseClient.from).toHaveBeenCalledWith('Prompt');
      expect(mockSupabaseClient.eq).toHaveBeenCalledWith('isDeleted', false);
    });
  });
  describe('findAllByTopicId', () => {
    const topicId = 'topic-id';
    const userId = 'user-id';
    it('should return prompts for a topic', async () => {
      const promptsWithTopic = [
        {
          ...mockPrompt,
          Prompt_Keyword: [{ Keyword: { keyword: 'test-keyword-1' } }],
          topic: { id: 'topic-id', name: 'Sample Topic' },
        },
      ];

      // Create a mock query object that properly chains and resolves
      const mockQuery = {
        eq: jest.fn().mockReturnThis(),
        order: jest.fn().mockReturnThis(),
        then: jest.fn((resolve) =>
          // eslint-disable-next-line @typescript-eslint/no-unsafe-call,@typescript-eslint/no-unsafe-return
          resolve({ data: promptsWithTopic, error: null }),
        ),
      };

      // Setup select to return the mockQuery
      mockSupabaseClient.select.mockReturnValue(mockQuery);

      const result = await repository.findAllByTopicId(topicId, userId);

      expect(result).toEqual([
        {
          ...mockPrompt,
          keywords: ['test-keyword-1'],
        },
      ]);
      expect(mockSupabaseClient.from).toHaveBeenCalledWith('Prompt');
      expect(mockSupabaseClient.select).toHaveBeenCalledWith(
        `
        *, 
        topic:Topic!inner(
          name,
          project:Project!inner(
            id,
            projectMembers:Project_Member!inner(userId)
          )
        ), 
        Prompt_Keyword(Keyword(keyword))
       `,
      );
      expect(mockQuery.eq).toHaveBeenCalledWith('topicId', topicId);
      expect(mockQuery.eq).toHaveBeenCalledWith(
        'topic.project.projectMembers.userId',
        userId,
      );
      expect(mockQuery.eq).toHaveBeenCalledWith('status', 'active');
      expect(mockQuery.eq).toHaveBeenCalledWith('isDeleted', false);
      expect(mockQuery.order).toHaveBeenCalledWith('createdAt', {
        ascending: true,
      });
    });

    it('should throw error if supabase returns error', async () => {
      const error = new Error('DB error') as PostgrestError;
      mockSupabaseClient.order.mockResolvedValue({ data: null, error });
      mockSupabaseClient.eq.mockResolvedValue({ data: null, error });
      await expect(
        repository.findAllByTopicId(topicId, userId),
      ).rejects.toThrow();
    });
  });

  describe('delete', () => {
    const promptId = 'prompt-id';

    it('should soft delete prompt successfully', async () => {
      mockSupabaseClient.eq.mockResolvedValue({
        data: null,
        error: null,
      });

      await repository.delete(promptId);

      expect(mockSupabaseClient.from).toHaveBeenCalledWith('Prompt');
      expect(mockSupabaseClient.update).toHaveBeenCalledWith({
        isDeleted: true,
      });
      expect(mockSupabaseClient.eq).toHaveBeenCalledWith('id', promptId);
    });

    it('should throw error when database operation fails', async () => {
      const error = new Error('Database error') as PostgrestError;
      mockSupabaseClient.eq.mockResolvedValue({
        data: null,
        error,
      });

      await expect(repository.delete(promptId)).rejects.toThrow();
    });
  });
  describe('update', () => {
    const promptId = 'prompt-id';
    const updateData = {
      isMonitored: false,
    };

    it('should update prompt successfully', async () => {
      const updatedPrompt = {
        ...mockPrompt,
        ...updateData,
        Prompt_Keyword: [{ Keyword: { keyword: 'test-keyword-1' } }],
        topic: { id: 'topic-id', name: 'Sample Topic' },
        updatedAt: new Date().toISOString(),
      };

      mockSupabaseClient.maybeSingle.mockResolvedValue({
        data: updatedPrompt,
        error: null,
      });

      const result = await repository.update(promptId, updateData);

      // eslint-disable-next-line @typescript-eslint/no-unused-vars
      const { topic, Prompt_Keyword, ...expectedPrompt } = updatedPrompt;
      expect(result).toEqual({
        ...expectedPrompt,
        topicName: 'Sample Topic',
        keywords: ['test-keyword-1'],
      });
      expect(mockSupabaseClient.from).toHaveBeenCalledWith('Prompt');
      expect(mockSupabaseClient.update).toHaveBeenCalledWith(updateData);
      expect(mockSupabaseClient.eq).toHaveBeenCalledWith('id', promptId);
      expect(mockSupabaseClient.select).toHaveBeenCalledWith(
        '*, topic:Topic!inner(name), Prompt_Keyword(Keyword(keyword))',
      );
      expect(mockSupabaseClient.maybeSingle).toHaveBeenCalled();
    });

    it('should throw error when database operation fails', async () => {
      const error = new Error('Database error') as PostgrestError;
      mockSupabaseClient.maybeSingle.mockResolvedValue({
        data: null,
        error,
      });

      await expect(repository.update(promptId, updateData)).rejects.toThrow();
    });
  });

  describe('createOne', () => {
    const promptInsert = {
      topicId: 'topic-id',
      content: 'Top 10 software development companies in Ho Chi Minh City',
      type: PROMPT_TYPES[0],
      status: 'active' as const,
    };

    it('should create a single prompt successfully', async () => {
      const createdPrompt = {
        ...mockPrompt,
        ...promptInsert,
        id: 'new-prompt-id',
        isMonitored: false,
        isDeleted: false,
        lastRun: null,
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
        topic: {
          id: 'topic-id',
          name: 'Sample Topic',
        },
      };

      mockSupabaseClient.single.mockResolvedValue({
        data: createdPrompt,
        error: null,
      });

      const result = await repository.createOne(promptInsert);

      // eslint-disable-next-line @typescript-eslint/no-unused-vars
      const { topic, ...expectedPrompt } = createdPrompt;
      expect(result).toEqual({
        ...expectedPrompt,
        topicName: 'Sample Topic',
      });
      expect(mockSupabaseClient.from).toHaveBeenCalledWith('Prompt');
      expect(mockSupabaseClient.insert).toHaveBeenCalledWith(promptInsert);
      expect(mockSupabaseClient.select).toHaveBeenCalledWith(
        '*, topic:Topic!inner(name)',
      );
      expect(mockSupabaseClient.single).toHaveBeenCalled();
    });

    it('should throw error when database operation fails', async () => {
      const error = new Error('Database error') as PostgrestError;
      mockSupabaseClient.single.mockResolvedValue({
        data: null,
        error,
      });

      await expect(repository.createOne(promptInsert)).rejects.toThrow();
    });
    describe('getPromptsForGenerateContentBatch', () => {
      const projectId = 'project-id';
      const limit = 10;
      const offset = 0;

      it('should fetch a batch of prompts successfully', async () => {
        const prompts = [
          { id: '1', topic: { project: { id: projectId } } },
          { id: '2', topic: { project: { id: projectId } } },
        ];

        mockSupabaseClient.order
          .mockImplementationOnce(() => mockSupabaseClient)
          .mockImplementationOnce(() =>
            Promise.resolve({
              data: prompts,
              error: null,
            }),
          );

        const result = await repository.getPromptsForGenerateContentBatch(
          projectId,
          limit,
          offset,
        );

        expect(result).toEqual(prompts);
        expect(mockSupabaseClient.from).toHaveBeenCalledWith('Prompt');
        expect(mockSupabaseClient.select).toHaveBeenCalled();
        expect(mockSupabaseClient.eq).toHaveBeenCalledWith(
          'topic.projectId',
          projectId,
        );
        expect(mockSupabaseClient.range).toHaveBeenCalledWith(
          offset,
          offset + limit - 1,
        );
        expect(mockSupabaseClient.order).toHaveBeenCalledWith('content_count', {
          ascending: true,
        });
        expect(mockSupabaseClient.order).toHaveBeenCalledWith('createdAt', {
          ascending: true,
        });
      });

      it('should throw error if query fails', async () => {
        mockSupabaseClient.order
          .mockImplementationOnce(() => mockSupabaseClient)
          .mockImplementationOnce(() =>
            Promise.resolve({
              data: null,
              error: { message: 'Query failed' } as PostgrestError,
            }),
          );

        await expect(
          repository.getPromptsForGenerateContentBatch(
            projectId,
            limit,
            offset,
          ),
        ).rejects.toThrow();
      });
    });
  });
});
