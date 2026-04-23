import { Test, TestingModule } from '@nestjs/testing';
import { TopicService } from './topic.service';
import { TopicRepository } from './topic.repository';
import { ProjectRepository } from '../project/project.repository';
import { NotFoundException } from '@nestjs/common';
import { ProjectMemberRepository } from '../project-member/project-member.repository';
import { AgentService } from '../agent/agent.service';
import { BrandRepository } from '../brand/brand.repository';

jest.mock('uuid', () => ({
  v4: jest.fn(() => 'mock-uuid'),
}));

const mockTopic = {
  id: 'topic-id',
  projectId: 'project-id',
  name: 'Test Topic',
  searchVolume: 1000,
  isMonitored: true,
  isDeleted: false,
  createdAt: new Date().toISOString(),
  updatedAt: new Date().toISOString(),
};

const mockTopicRepository = {
  insertMany: jest.fn(),
  update: jest.fn(),
  deleteMany: jest.fn(),
  getTopicsByProjectId: jest.fn(),
  getTopic: jest.fn(),
  getTopics: jest.fn(),
};

const mockProject = {
  id: 'project-id',
  name: 'Test Project',
  createdBy: 'user-id',
  createdAt: new Date().toISOString(),
  updatedAt: new Date().toISOString(),
};

const mockProjectRepository = {
  findById: jest.fn(),
};

const mockProjectMemberRepository = {
  findOneByProjectIdAndUserId: jest.fn(),
};
const mockAgentService = {
  execute: jest.fn(),
};
const mockBrandRepository = {
  findByProjectId: jest.fn(),
};

describe('TopicService', () => {
  let service: TopicService;
  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        TopicService,
        { provide: TopicRepository, useValue: mockTopicRepository },
        { provide: ProjectRepository, useValue: mockProjectRepository },
        {
          provide: ProjectMemberRepository,
          useValue: mockProjectMemberRepository,
        },
        {
          provide: BrandRepository,
          useValue: mockBrandRepository,
        },
        {
          provide: AgentService,
          useValue: mockAgentService,
        },
      ],
    }).compile();

    service = module.get<TopicService>(TopicService);
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('getTopicsByProject', () => {
    it('should return topics for a project', async () => {
      mockTopicRepository.getTopicsByProjectId.mockResolvedValue([mockTopic]);
      const result = await service.getTopicsByProject('project-id', 'user-id');
      expect(result).toEqual([mockTopic]);
      expect(mockTopicRepository.getTopicsByProjectId).toHaveBeenCalledWith(
        'project-id',
        'user-id',
      );
    });
  });

  describe('createTopics', () => {
    it('should create multiple topics', async () => {
      const createData = {
        projectId: 'project-id',
        topicData: [{ name: 'Topic 1' }, { name: 'Topic 2' }],
      };
      const expectedTopics = [
        { ...mockTopic, name: 'Topic 1' },
        { ...mockTopic, name: 'Topic 2' },
      ];
      const expectedInsertData = [
        {
          name: 'Topic 1',
          alias: undefined,
          description: null,
          projectId: 'project-id',
          searchVolume: null,
        },
        {
          name: 'Topic 2',
          alias: undefined,
          description: null,
          projectId: 'project-id',
          searchVolume: null,
        },
      ];

      mockProjectMemberRepository.findOneByProjectIdAndUserId.mockResolvedValue(
        { id: 'membership-id' },
      );
      mockTopicRepository.insertMany.mockResolvedValue(expectedTopics);
      const result = await service.createTopics(createData, 'user-id');
      expect(result).toEqual(expectedTopics);
      expect(
        mockProjectMemberRepository.findOneByProjectIdAndUserId,
      ).toHaveBeenCalledWith('project-id', 'user-id');
      expect(mockTopicRepository.insertMany).toHaveBeenCalledWith(
        expectedInsertData,
      );
    });

    it('should throw ForbiddenException if user is not a member of the project', async () => {
      const createData = {
        projectId: 'project-id',
        topicData: [{ name: 'Topic 1' }],
      };

      mockProjectMemberRepository.findOneByProjectIdAndUserId.mockResolvedValue(
        null,
      );
      await expect(service.createTopics(createData, 'user-id')).rejects.toThrow(
        'You are not a member of this project',
      );
      expect(mockTopicRepository.insertMany).not.toHaveBeenCalled();
    });
  });

  describe('updateTopic', () => {
    it('should update a topic name', async () => {
      const dto = { name: 'Updated Topic Name' };
      const updatedTopic = { ...mockTopic, name: dto.name };
      mockTopicRepository.getTopic.mockResolvedValue(mockTopic);
      mockTopicRepository.update.mockResolvedValue(updatedTopic);
      const result = await service.updateTopic('topic-id', dto, 'user-id');
      expect(result).toEqual(updatedTopic);
      expect(mockTopicRepository.getTopic).toHaveBeenCalledWith(
        'topic-id',
        'user-id',
      );
      expect(mockTopicRepository.update).toHaveBeenCalledWith('topic-id', dto);
    });

    it('should update topic monitoring status', async () => {
      const dto = { isMonitored: false };
      const updatedTopic = { ...mockTopic, isMonitored: false };
      mockTopicRepository.getTopic.mockResolvedValue(mockTopic);
      mockTopicRepository.update.mockResolvedValue(updatedTopic);
      const result = await service.updateTopic('topic-id', dto, 'user-id');
      expect(result).toEqual(updatedTopic);
      expect(mockTopicRepository.getTopic).toHaveBeenCalledWith(
        'topic-id',
        'user-id',
      );
      expect(mockTopicRepository.update).toHaveBeenCalledWith('topic-id', dto);
    });

    it('should update both name and monitoring status', async () => {
      const dto = { name: 'New Name', isMonitored: false };
      const updatedTopic = { ...mockTopic, name: dto.name, isMonitored: false };
      mockTopicRepository.getTopic.mockResolvedValue(mockTopic);
      mockTopicRepository.update.mockResolvedValue(updatedTopic);
      const result = await service.updateTopic('topic-id', dto, 'user-id');
      expect(result).toEqual(updatedTopic);
      expect(mockTopicRepository.getTopic).toHaveBeenCalledWith(
        'topic-id',
        'user-id',
      );
      expect(mockTopicRepository.update).toHaveBeenCalledWith('topic-id', dto);
    });

    it('should throw NotFoundException if topic not found', async () => {
      const dto = { name: 'New Name' };
      mockTopicRepository.getTopic.mockResolvedValue(null);
      await expect(
        service.updateTopic('topic-id', dto, 'user-id'),
      ).rejects.toThrow(NotFoundException);
      await expect(
        service.updateTopic('topic-id', dto, 'user-id'),
      ).rejects.toThrow('Topic with ID topic-id not found');
      expect(mockTopicRepository.update).not.toHaveBeenCalled();
    });
  });

  describe('deleteMany', () => {
    it('should soft delete multiple topics', async () => {
      const dto = { ids: ['topic-id-1', 'topic-id-2'] };
      const mockTopics = [
        { ...mockTopic, id: 'topic-id-1' },
        { ...mockTopic, id: 'topic-id-2' },
      ];
      mockTopicRepository.getTopics.mockResolvedValue(mockTopics);
      mockTopicRepository.deleteMany.mockResolvedValue(undefined);
      await service.deleteMany(dto, 'user-id');
      expect(mockTopicRepository.getTopics).toHaveBeenCalledWith(
        dto.ids,
        'user-id',
      );
      expect(mockTopicRepository.deleteMany).toHaveBeenCalledWith(dto.ids);
    });

    it('should throw NotFoundException if some topics not found', async () => {
      const dto = { ids: ['topic-id-1', 'topic-id-2', 'topic-id-3'] };
      const mockTopics = [
        { ...mockTopic, id: 'topic-id-1' },
        { ...mockTopic, id: 'topic-id-2' },
      ];
      mockTopicRepository.getTopics.mockResolvedValue(mockTopics);
      await expect(service.deleteMany(dto, 'user-id')).rejects.toThrow(
        NotFoundException,
      );
      await expect(service.deleteMany(dto, 'user-id')).rejects.toThrow(
        'One or more topics not found',
      );
      expect(mockTopicRepository.deleteMany).not.toHaveBeenCalled();
    });

    it('should throw NotFoundException if no topics found', async () => {
      const dto = { ids: ['topic-id-1'] };
      mockTopicRepository.getTopics.mockResolvedValue([]);
      await expect(service.deleteMany(dto, 'user-id')).rejects.toThrow(
        NotFoundException,
      );
      expect(mockTopicRepository.deleteMany).not.toHaveBeenCalled();
    });
  });
});
