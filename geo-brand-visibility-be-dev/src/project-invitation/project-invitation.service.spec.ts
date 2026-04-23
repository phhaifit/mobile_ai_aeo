import { Test, TestingModule } from '@nestjs/testing';
import { ProjectInvitationService } from './project-invitation.service';
import { ProjectInvitationRepository } from './project-invitation.repository';
import { ProjectMemberRepository } from '../project-member/project-member.repository';
import { UserRepository } from '../user/user.repository';

describe('ProjectInvitationService', () => {
  let service: ProjectInvitationService;

  const mockProjectInvitationRepository = {
    create: jest.fn(),
    findById: jest.fn(),
    findOneByProjectIdAndInviteeId: jest.fn(),
    findAllByInviteeId: jest.fn(),
    update: jest.fn(),
  };

  const mockProjectMemberRepository = {
    create: jest.fn(),
    findOneByProjectIdAndUserId: jest.fn(),
  };

  const mockUserRepository = {
    findByEmail: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ProjectInvitationService,
        {
          provide: ProjectInvitationRepository,
          useValue: mockProjectInvitationRepository,
        },
        {
          provide: ProjectMemberRepository,
          useValue: mockProjectMemberRepository,
        },
        {
          provide: UserRepository,
          useValue: mockUserRepository,
        },
      ],
    }).compile();

    service = module.get<ProjectInvitationService>(ProjectInvitationService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
