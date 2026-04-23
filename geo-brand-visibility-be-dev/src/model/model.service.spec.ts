import { Test, TestingModule } from '@nestjs/testing';
import { ModelService } from './model.service';
import { ModelRepository } from './model.repository';

describe('ModelService', () => {
  let service: ModelService;

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

  const mockModelRepository = {
    findAll: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ModelService,
        {
          provide: ModelRepository,
          useValue: mockModelRepository,
        },
      ],
    }).compile();

    service = module.get<ModelService>(ModelService);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('getAllModels', () => {
    it('should return all models', async () => {
      mockModelRepository.findAll.mockResolvedValue(mockModels);

      const result = await service.getAllModels();

      expect(mockModelRepository.findAll).toHaveBeenCalledTimes(1);
      expect(result).toHaveLength(2);
      expect(result[0].id).toBe('model-1');
      expect(result[0].name).toBe('GPT-4');
      expect(result[0].description).toBe('Large language model by OpenAI');
      expect(result[1].id).toBe('model-2');
      expect(result[1].name).toBe('Claude');
      expect(result[1].description).toBe('AI assistant by Anthropic');
    });

    it('should return empty array when no models found', async () => {
      mockModelRepository.findAll.mockResolvedValue([]);

      const result = await service.getAllModels();

      expect(mockModelRepository.findAll).toHaveBeenCalledTimes(1);
      expect(result).toEqual([]);
    });

    it('should propagate repository errors', async () => {
      const error = new Error('Repository error');
      mockModelRepository.findAll.mockRejectedValue(error);

      await expect(service.getAllModels()).rejects.toThrow('Repository error');
      expect(mockModelRepository.findAll).toHaveBeenCalledTimes(1);
    });
  });
});
