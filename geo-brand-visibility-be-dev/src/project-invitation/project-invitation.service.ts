import { Injectable, BadRequestException, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { ProjectInvitationRepository } from './project-invitation.repository';
import { ProjectMemberRepository } from '../project-member/project-member.repository';
import { UserRepository } from '../user/user.repository';
import { MailService } from '../mail/mail.service';
import { InvitationStatus } from './enum/invitation-status.enum';
import { ProjectMemberRole } from 'src/project-member/enum/member-role.enum';
import { PaginationQueryDto } from 'src/shared/dtos/pagination-query.dto';
import { createPaginatedResponse } from 'src/utils/common';
import { buildInvitationEmailHtml } from './templates/invitation-email.template';

@Injectable()
export class ProjectInvitationService {
  private readonly logger = new Logger(ProjectInvitationService.name);

  constructor(
    private readonly projectInvitationRepository: ProjectInvitationRepository,
    private readonly projectMemberRepository: ProjectMemberRepository,
    private readonly userRepository: UserRepository,
    private readonly mailService: MailService,
    private readonly configService: ConfigService,
  ) {}

  async inviteMember(
    projectId: string,
    inviterId: string,
    email: string,
    role: ProjectMemberRole,
  ) {
    email = email.toLowerCase().trim();
    const user = await this.userRepository.findByEmail(email);

    if (user) {
      const existingMember =
        await this.projectMemberRepository.findOneByProjectIdAndUserId(
          projectId,
          user.id,
        );

      if (existingMember) {
        throw new BadRequestException(
          'User is already a member of this project',
        );
      }

      const existingInvitation =
        await this.projectInvitationRepository.findOneByProjectIdAndInviteeId(
          projectId,
          user.id,
        );

      if (existingInvitation) {
        throw new BadRequestException(
          'User is already invited to this project',
        );
      }
    } else {
      const existingInvitation =
        await this.projectInvitationRepository.findOneByProjectIdAndEmail(
          projectId,
          email,
        );

      if (existingInvitation) {
        throw new BadRequestException(
          'This email is already invited to this project',
        );
      }
    }

    const invitation = await this.projectInvitationRepository.create({
      projectId,
      inviterId,
      inviteeId: user?.id || null,
      inviteeEmail: email,
      role,
      status: InvitationStatus.Pending,
    });

    // Re-fetch with joins to get inviter name and project name for the email
    const fullInvitation = await this.projectInvitationRepository.findByToken(
      invitation.token!,
    );
    const inviterName =
      (fullInvitation as any)?.user?.fullname || 'A team member';
    const projectName =
      (fullInvitation as any)?.project?.brand?.name || 'a project';

    let emailSent = true;
    try {
      await this.sendInvitationEmail({
        token: invitation.token!,
        inviterName,
        projectName,
        inviteeEmail: email,
        role,
      });
    } catch (err) {
      emailSent = false;
      this.logger.error(
        `Failed to send invitation email to ${email}: ${err.message}`,
      );
    }

    return { ...invitation, emailSent };
  }

  private async sendInvitationEmail(params: {
    token: string;
    inviterName: string;
    projectName: string;
    inviteeEmail: string;
    role: ProjectMemberRole;
  }) {
    const { token, inviterName, projectName, inviteeEmail, role } = params;
    const frontendUrl = this.configService.get<string>('FRONTEND_URL');
    if (!frontendUrl) {
      throw new Error('FRONTEND_URL environment variable is not configured');
    }
    const acceptUrl = `${frontendUrl}/invitations/accept?token=${token}`;

    const html = buildInvitationEmailHtml({
      inviterName,
      projectName,
      role,
      acceptUrl,
    });

    await this.mailService.sendMail(
      inviteeEmail,
      `You've been invited to ${projectName} on AEO`,
      html,
    );
  }

  async getInvitationsByInviteeId(
    inviteeId: string,
    params: PaginationQueryDto,
  ) {
    const { data, total } =
      await this.projectInvitationRepository.findAllByInviteeId(
        inviteeId,
        params,
      );

    return createPaginatedResponse(data, total, params, (item: any) => ({
      id: item.id,
      role: item.role,
      projectName: item.project?.brand?.name,
      inviterName: item.user?.fullname,
      status: item.status,
      createdAt: item.createdAt,
      expiresAt: item.expiresAt,
    }));
  }

  async getInvitationByToken(token: string) {
    const invitation =
      await this.projectInvitationRepository.findByToken(token);

    if (!invitation) {
      throw new BadRequestException('Invitation not found');
    }

    return {
      id: invitation.id,
      projectId: invitation.projectId,
      projectName: (invitation as any).project?.brand?.name,
      inviterName: (invitation as any).user?.fullname,
      inviteeEmail: invitation.inviteeEmail
        ? this.maskEmail(invitation.inviteeEmail)
        : null,
      role: invitation.role,
      status: invitation.status,
      expiresAt: invitation.expiresAt,
    };
  }

  private maskEmail(email: string): string {
    const [local, domain] = email.split('@');
    if (!domain) return '***';
    const visible = local.slice(0, 2);
    return `${visible}${'*'.repeat(Math.max(local.length - 2, 1))}@${domain}`;
  }

  async acceptByToken(token: string, userId: string, userEmail: string) {
    const invitation =
      await this.projectInvitationRepository.findByToken(token);

    if (!invitation) {
      throw new BadRequestException('Invitation not found');
    }

    if (invitation.status !== InvitationStatus.Pending) {
      throw new BadRequestException('Invitation has already been answered');
    }

    if (invitation.expiresAt && new Date(invitation.expiresAt) < new Date()) {
      throw new BadRequestException('Invitation has expired');
    }

    if (
      invitation.inviteeEmail &&
      invitation.inviteeEmail.toLowerCase() !== userEmail.toLowerCase()
    ) {
      throw new BadRequestException(
        'This invitation was sent to a different email address',
      );
    }

    if (!invitation.projectId) {
      throw new BadRequestException('Invalid invitation data');
    }

    const existingMember =
      await this.projectMemberRepository.findOneByProjectIdAndUserId(
        invitation.projectId,
        userId,
      );

    if (existingMember) {
      throw new BadRequestException('You are already a member of this project');
    }

    const result = await this.projectInvitationRepository.update(
      invitation.id,
      {
        inviteeId: userId,
        status: InvitationStatus.Accepted,
      },
    );

    await this.projectMemberRepository.create({
      projectId: invitation.projectId,
      userId,
      role: invitation.role,
    });

    return { projectId: invitation.projectId };
  }

  async answerInvitation(invitationId: string, answer: boolean) {
    const invitation =
      await this.projectInvitationRepository.findById(invitationId);
    if (!invitation) {
      throw new BadRequestException('Invitation not found');
    }

    if (!invitation.projectId || !invitation.inviteeId) {
      throw new BadRequestException('Invalid invitation data');
    }

    const result = await this.projectInvitationRepository.update(invitationId, {
      status: answer ? InvitationStatus.Accepted : InvitationStatus.Rejected,
    });

    if (answer && result) {
      await this.projectMemberRepository.create({
        projectId: invitation.projectId,
        userId: invitation.inviteeId,
        role: invitation.role,
      });
    }

    return result;
  }
}
