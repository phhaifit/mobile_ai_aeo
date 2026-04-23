import {
  Injectable,
  CanActivate,
  ExecutionContext,
  ForbiddenException,
  Logger,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import {
  PROJECT_MEMBERSHIP_KEY,
  ProjectMembershipOptions,
} from '../decorators/require-project-membership.decorator';
import { ProjectMemberRepository } from '../../project-member/project-member.repository';
import { ProjectMemberRole } from '../../project-member/enum/member-role.enum';
import { AuthenticatedRequest } from './jwt-auth.guard';

export interface RequestWithProjectMembership extends AuthenticatedRequest {
  params: Record<string, string>;
  projectMembership?: {
    projectId: string;
    role: ProjectMemberRole;
  };
}

@Injectable()
export class ProjectMembershipGuard implements CanActivate {
  private readonly logger = new Logger(ProjectMembershipGuard.name);

  constructor(
    private readonly reflector: Reflector,
    private readonly projectMemberRepository: ProjectMemberRepository,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const options = this.reflector.getAllAndOverride<ProjectMembershipOptions>(
      PROJECT_MEMBERSHIP_KEY,
      [context.getHandler(), context.getClass()],
    );

    // If no decorator is applied, allow access (guard is not required for this route)
    if (!options) {
      return true;
    }

    const request = context
      .switchToHttp()
      .getRequest<RequestWithProjectMembership>();
    const userId = request.user?.id;

    if (!userId) {
      this.logger.warn('No user ID found in request');
      throw new ForbiddenException('User not authenticated');
    }

    const projectIdParam = options.projectIdParam ?? 'projectId';
    const projectId = request.params[projectIdParam];

    if (!projectId) {
      this.logger.warn(
        `No projectId found in params with key: ${projectIdParam}`,
      );
      throw new ForbiddenException('Project ID is required');
    }

    const membership =
      await this.projectMemberRepository.findOneByProjectIdAndUserId(
        projectId,
        userId,
      );

    if (!membership) {
      this.logger.warn(
        `User ${userId} is not a member of project ${projectId}`,
      );
      throw new ForbiddenException('You are not a member of this project');
    }

    // Check if user's role is in the allowed roles
    const userRole = membership.role as ProjectMemberRole;
    if (!options.roles?.includes(userRole)) {
      this.logger.warn(
        `User ${userId} has role ${userRole} but requires one of: ${options.roles?.join(', ')}`,
      );
      throw new ForbiddenException(
        'You do not have permission to perform this action',
      );
    }

    // Attach membership info to request for downstream use
    request.projectMembership = {
      projectId,
      role: userRole,
    };

    return true;
  }
}
