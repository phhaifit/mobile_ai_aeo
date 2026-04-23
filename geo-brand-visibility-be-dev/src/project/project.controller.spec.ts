import { Test, TestingModule } from '@nestjs/testing';
import { ProjectController } from './project.controller';
import { ProjectService } from './project.service';
import { ProjectStatus } from './enum/project-status.enum';
import { BadRequestException } from '@nestjs/common';
import { type AuthenticatedRequest } from '../auth/guards/jwt-auth.guard';
import { ProjectMemberRepository } from '../project-member/project-member.repository';
import { Reflector } from '@nestjs/core';
import { PromptService } from '../prompt/prompt.service';
import { TopicService } from '../topic/topic.service';
import { TaskOrchestratorService } from '../scheduler/scheduler.service';

jest.mock('uuid', () => ({
  v4: jest.fn(() => 'mock-uuid'),
}));

describe('ProjectController', () => {
  let controller: ProjectController;

  const mockProjectService = {
    findProjectsByUser: jest.fn(),
  };

  const mockProjectMemberRepository = {
    findMember: jest.fn(),
  };

  const mockPromptService = {};
  const mockTopicService = {};
  const mockTaskOrchestratorService = {};

  const mockRequest = {
    user: {
      id: 'user-id',
    },
  } as AuthenticatedRequest;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [ProjectController],
      providers: [
        {
          provide: ProjectService,
          useValue: mockProjectService,
        },
        {
          provide: ProjectMemberRepository,
          useValue: mockProjectMemberRepository,
        },
        {
          provide: PromptService,
          useValue: mockPromptService,
        },
        {
          provide: TopicService,
          useValue: mockTopicService,
        },
        {
          provide: TaskOrchestratorService,
          useValue: mockTaskOrchestratorService,
        },
        Reflector,
      ],
    }).compile();

    controller = module.get<ProjectController>(ProjectController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  describe('getProjects', () => {
    it('should call service with correct params when status is valid', async () => {
      await controller.getProjects(mockRequest, ProjectStatus.ACTIVE);
      expect(mockProjectService.findProjectsByUser).toHaveBeenCalledWith(
        'user-id',
        ProjectStatus.ACTIVE,
      );
    });

    it('should call service with undefined status when status is not provided', async () => {
      await controller.getProjects(mockRequest, undefined);
      expect(mockProjectService.findProjectsByUser).toHaveBeenCalledWith(
        'user-id',
        undefined,
      );
    });

    // Cast 'INVALID_STATUS' to any to bypass type check for test
    it('should throw BadRequestException when status is invalid', async () => {
      await expect(
        controller.getProjects(mockRequest, 'INVALID_STATUS' as any),
      ).rejects.toThrow(BadRequestException);
    });
  });
});
