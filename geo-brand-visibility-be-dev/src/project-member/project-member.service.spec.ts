import { Test, TestingModule } from '@nestjs/testing';
import { ProjectMemberService } from './project-member.service';
import { ProjectMemberRepository } from './project-member.repository';

describe('ProjectMemberService', () => {
  let service: ProjectMemberService;

  const mockProjectMemberRepository = {
    findAllByProjectId: jest.fn(),
    removeMember: jest.fn(),
    updateMemberRole: jest.fn(),
    findOneByProjectIdAndUserId: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ProjectMemberService,
        {
          provide: ProjectMemberRepository,
          useValue: mockProjectMemberRepository,
        },
      ],
    }).compile();

    service = module.get<ProjectMemberService>(ProjectMemberService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
