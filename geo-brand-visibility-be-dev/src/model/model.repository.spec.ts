import { Test, TestingModule } from '@nestjs/testing';
import { ModelRepository } from './model.repository';
import { SUPABASE } from '../utils/const';
import { mapSqlError } from '../utils/map-sql-error.util';

jest.mock('../utils/map-sql-error.util');

describe('ModelRepository', () => {
  let repository: ModelRepository;
  let mockSupabase: {
    from: jest.Mock;
    select: jest.Mock;
  };

  const mockModels = [
    {
      id: 'model-1',
      name: 'GPT-4',
      description: 'Large language model by OpenAI',
    },
    {
      id: 'model-2',
      name: 'Claude',
      description: 'AI assistant by Anthropic',
    },
  ];

  beforeEach(async () => {
    mockSupabase = {
      from: jest.fn().mockReturnThis(),
      select: jest.fn().mockReturnThis(),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ModelRepository,
        {
          provide: SUPABASE,
          useValue: mockSupabase,
        },
      ],
    }).compile();

    repository = module.get<ModelRepository>(ModelRepository);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('findAll', () => {
    it('should return all models when successful', async () => {
      mockSupabase.select.mockResolvedValue({
        data: mockModels,
        error: null,
      });

      const result = await repository.findAll();

      expect(mockSupabase.from).toHaveBeenCalledWith('Model');
      expect(mockSupabase.select).toHaveBeenCalledWith('*');
      expect(result).toEqual(mockModels);
    });

    it('should return empty array when no models found', async () => {
      mockSupabase.select.mockResolvedValue({
        data: null,
        error: null,
      });

      const result = await repository.findAll();

      expect(result).toEqual([]);
    });

    it('should throw mapped error when database error occurs', async () => {
      const dbError = { message: 'Database connection failed' };
      const mappedError = new Error('Mapped database error');
      mockSupabase.select.mockResolvedValue({
        data: null,
        error: dbError,
      });

      (mapSqlError as jest.Mock).mockReturnValue(mappedError);

      await expect(repository.findAll()).rejects.toThrow(mappedError);
      expect(mapSqlError).toHaveBeenCalledWith(dbError);
    });
  });
});
