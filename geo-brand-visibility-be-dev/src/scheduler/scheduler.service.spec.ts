import { Test, TestingModule } from '@nestjs/testing';
import { SchedulerService } from './scheduler.service';
import { TaskRepository } from '../task/task.repository';
import { ProjectRepository } from '../project/project.repository';
import { ContentRepository } from '../content/content.repository';
import { SchedulerRepository } from './scheduler.repository';
import { getQueueToken } from '@nestjs/bullmq';
import { QueueNames } from '../processors/contants/queue';
import { Logger } from '@nestjs/common';
import { ScheduleModule } from '@nestjs/schedule';

describe('SchedulerService', () => {
  let service: SchedulerService;
  let projectRepository: jest.Mocked<ProjectRepository>;
  let schedulerRepository: jest.Mocked<SchedulerRepository>;
  let taskRepository: jest.Mocked<TaskRepository>;
  let contentGenerationQueue: jest.Mocked<{ add: jest.Mock }>;

  const mockProject = {
    id: 'project-1',
    createdBy: 'user-1',
    contentProfile: [{ id: 'cp-1' }],
  };

  beforeEach(async () => {
    const mockQueue = {
      add: jest.fn().mockResolvedValue(undefined),
    };

    const module: TestingModule = await Test.createTestingModule({
      imports: [ScheduleModule.forRoot()],
      providers: [
        SchedulerService,
        {
          provide: ProjectRepository,
          useValue: {
            findProjectsWithAutoGenerateEnabled: jest.fn(),
            findProjectsWithAutoAnalysisEnabled: jest.fn(),
            findAll: jest.fn(),
            deleteStaleDrafts: jest.fn(),
          },
        },
        {
          provide: SchedulerRepository,
          useValue: {
            findActiveAgents: jest.fn().mockResolvedValue([]),
            getPromptsForBlogScheduler: jest.fn().mockResolvedValue([]),
            getPromptsForSocialMediaScheduler: jest.fn().mockResolvedValue([]),
          },
        },
        {
          provide: ContentRepository,
          useValue: {
            deleteFailedContentOlderThan: jest.fn(),
          },
        },
        {
          provide: TaskRepository,
          useValue: {
            create: jest.fn(),
          },
        },
        {
          provide: getQueueToken(QueueNames.ProjectAnalysis),
          useValue: mockQueue,
        },
        {
          provide: getQueueToken(QueueNames.ContentGeneration),
          useValue: mockQueue,
        },
      ],
    }).compile();

    service = module.get<SchedulerService>(SchedulerService);
    projectRepository = module.get(ProjectRepository);
    schedulerRepository = module.get(SchedulerRepository);
    taskRepository = module.get(TaskRepository);
    contentGenerationQueue = module.get(
      getQueueToken(QueueNames.ContentGeneration),
    );

    // Silence logger during tests
    jest.spyOn(Logger.prototype, 'log').mockImplementation(() => {});
    jest.spyOn(Logger.prototype, 'error').mockImplementation(() => {});
    jest.spyOn(console, 'log').mockImplementation(() => {});
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('scheduleDailyContentGeneration', () => {
    it('should skip if no auto-generate projects found', async () => {
      projectRepository.findProjectsWithAutoGenerateEnabled.mockResolvedValue(
        [],
      );

      await service.scheduleDailyContentGeneration();

      expect(
        schedulerRepository.getPromptsForBlogScheduler,
      ).not.toHaveBeenCalled();
    });

    it('should skip queuing if RPCs return empty results', async () => {
      projectRepository.findProjectsWithAutoGenerateEnabled.mockResolvedValue([
        mockProject,
      ] as any);

      await service.scheduleDailyContentGeneration();

      expect(taskRepository.create).not.toHaveBeenCalled();
    });

    it('should queue blog tasks when blog items are returned', async () => {
      const blogItem = {
        promptId: 'p1',
        referenceUrl: null,
        contentProfileId: 'cp-1',
        contentAgentId: 'agent-1',
        userId: 'user-1',
      };

      projectRepository.findProjectsWithAutoGenerateEnabled.mockResolvedValue([
        mockProject,
      ] as any);
      schedulerRepository.findActiveAgents.mockResolvedValue([
        { agentType: 'BLOG_GENERATOR', postsPerDay: 5 },
      ]);
      schedulerRepository.getPromptsForBlogScheduler.mockResolvedValue([
        blogItem,
      ]);
      taskRepository.create.mockResolvedValue({ id: 'task-1' } as any);

      await service.scheduleDailyContentGeneration();

      expect(taskRepository.create).toHaveBeenCalledTimes(1);
      expect(contentGenerationQueue.add).toHaveBeenCalledTimes(1);
    });

    it('should queue social media tasks when media items are returned', async () => {
      const mediaItem = {
        promptId: 'p1',
        referenceUrl: null,
        platform: 'facebook',
        contentProfileId: 'cp-1',
        contentAgentId: 'agent-1',
        userId: 'user-1',
      };

      projectRepository.findProjectsWithAutoGenerateEnabled.mockResolvedValue([
        mockProject,
      ] as any);
      schedulerRepository.findActiveAgents.mockResolvedValue([
        { agentType: 'SOCIAL_MEDIA_GENERATOR', postsPerDay: 3 },
      ]);
      schedulerRepository.getPromptsForSocialMediaScheduler.mockResolvedValue([
        mediaItem,
      ]);
      taskRepository.create.mockResolvedValue({ id: 'task-1' } as any);

      await service.scheduleDailyContentGeneration();

      expect(taskRepository.create).toHaveBeenCalledTimes(1);
      expect(contentGenerationQueue.add).toHaveBeenCalledTimes(1);
    });

    it('should process multiple projects independently', async () => {
      const projectA = { ...mockProject, id: 'A' };
      const projectB = { ...mockProject, id: 'B' };

      const makeBlogItem = (userId: string) => ({
        promptId: 'p1',
        referenceUrl: null,
        contentProfileId: 'cp-1',
        contentAgentId: 'agent-1',
        userId,
      });

      projectRepository.findProjectsWithAutoGenerateEnabled.mockResolvedValue([
        projectA,
        projectB,
      ] as any);

      schedulerRepository.findActiveAgents.mockResolvedValue([
        { agentType: 'BLOG_GENERATOR', postsPerDay: 5 },
      ]);
      schedulerRepository.getPromptsForBlogScheduler.mockResolvedValue([
        makeBlogItem('user-1'),
      ]);
      taskRepository.create.mockResolvedValue({ id: 'task-1' } as any);

      await service.scheduleDailyContentGeneration();

      // Called once per project
      expect(
        schedulerRepository.getPromptsForBlogScheduler,
      ).toHaveBeenCalledTimes(2);
      // 2 projects × 1 blog item each = 2 tasks
      expect(taskRepository.create).toHaveBeenCalledTimes(2);
    });
  });

  describe('scheduleAnalysis', () => {
    it('should only process projects with autoAnalysis enabled', async () => {
      const activeProjects = [
        {
          id: 'project-1',
          createdBy: 'user-1',
          status: 'ACTIVE',
          autoAnalysis: true,
        },
        {
          id: 'project-2',
          createdBy: 'user-2',
          status: 'ACTIVE',
          autoAnalysis: true,
        },
      ];

      projectRepository.findProjectsWithAutoAnalysisEnabled.mockResolvedValue(
        activeProjects as any,
      );
      taskRepository.create.mockResolvedValue({ id: 'task-1' } as any);

      await service.scheduleAnalysis();

      expect(
        projectRepository.findProjectsWithAutoAnalysisEnabled,
      ).toHaveBeenCalled();

      // Should create one task per project
      expect(taskRepository.create).toHaveBeenCalledTimes(2);
    });

    it('should handle empty project list gracefully', async () => {
      projectRepository.findProjectsWithAutoAnalysisEnabled.mockResolvedValue(
        [],
      );

      await service.scheduleAnalysis();

      expect(taskRepository.create).not.toHaveBeenCalled();
    });
  });
});
