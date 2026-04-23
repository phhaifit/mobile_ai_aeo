import { Test, TestingModule } from '@nestjs/testing';
import { ProjectMemberController } from './project-member.controller';
import { ProjectMemberService } from './project-member.service';

import { ProjectMembershipGuard } from '../auth/guards/project-membership.guard';

describe('ProjectMemberController', () => {
  let controller: ProjectMemberController;

  const mockProjectMemberService = {
    getProjectMembersByProjectId: jest.fn(),
    removeProjectMember: jest.fn(),
    updateProjectMemberRole: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [ProjectMemberController],
      providers: [
        {
          provide: ProjectMemberService,
          useValue: mockProjectMemberService,
        },
      ],
    })
      .overrideGuard(ProjectMembershipGuard)
      .useValue({ canActivate: () => true })
      .compile();

    controller = module.get<ProjectMemberController>(ProjectMemberController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
