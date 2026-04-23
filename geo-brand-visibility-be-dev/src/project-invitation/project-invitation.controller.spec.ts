import { Test, TestingModule } from '@nestjs/testing';
import { ProjectInvitationController } from './project-invitation.controller';
import { ProjectInvitationService } from './project-invitation.service';

describe('ProjectInvitationController', () => {
  let controller: ProjectInvitationController;

  const mockProjectInvitationService = {
    inviteMember: jest.fn(),
    getInvitationsByInviteeId: jest.fn(),
    answerInvitation: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [ProjectInvitationController],
      providers: [
        {
          provide: ProjectInvitationService,
          useValue: mockProjectInvitationService,
        },
      ],
    }).compile();

    controller = module.get<ProjectInvitationController>(
      ProjectInvitationController,
    );
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
