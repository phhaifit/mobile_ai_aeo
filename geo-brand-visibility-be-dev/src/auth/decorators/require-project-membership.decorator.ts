import { SetMetadata } from '@nestjs/common';
import { ProjectMemberRole } from '../../project-member/enum/member-role.enum';

export const PROJECT_MEMBERSHIP_KEY = 'projectMembership';

export type ProjectMembershipOptions = {
  roles?: ProjectMemberRole[];
  projectIdParam?: string; // defaults to 'projectId'
};

/**
 * Decorator to require project membership for a route.
 *
 * @example
 * // Any member (Admin or Member) can access
 * @RequireProjectMembership()
 *
 * @example
 * // Only Admin can access
 * @RequireProjectMembership({ roles: [ProjectMemberRole.Admin] })
 *
 * @example
 * // Custom projectId param name
 * @RequireProjectMembership({ projectIdParam: 'id' })
 */
export const RequireProjectMembership = (
  options?: ProjectMembershipOptions,
) => {
  return SetMetadata(PROJECT_MEMBERSHIP_KEY, {
    roles: options?.roles ?? Object.values(ProjectMemberRole),
    projectIdParam: options?.projectIdParam ?? 'projectId',
  });
};
