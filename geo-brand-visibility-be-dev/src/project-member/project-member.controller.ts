import { Controller, Get, Body, Patch, Delete, Query } from '@nestjs/common';
import { ProjectMemberService } from './project-member.service';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
} from '@nestjs/swagger';
import {
  ProjectMemberResponseDto,
  UpdateMemberRoleDto,
} from './dto/project-member.dto';
import { PaginationResult } from '../shared/dtos/pagination-result.dto';
import { PaginationQueryDto } from '../shared/dtos/pagination-query.dto';
import { UUIDParam } from '../shared/decorators/uuid-param.decorator';
import { ProjectMembershipGuard } from '../auth/guards/project-membership.guard';
import { UseGuards } from '@nestjs/common';
import { RequireProjectMembership } from 'src/auth/decorators/require-project-membership.decorator';
import { ProjectMemberRole } from './enum/member-role.enum';

@ApiTags('project-members')
@Controller('projects/:projectId/project-members')
@UseGuards(ProjectMembershipGuard)
@ApiBearerAuth('JWT-auth')
export class ProjectMemberController {
  constructor(private readonly projectMemberService: ProjectMemberService) {}

  @Get()
  @ApiOperation({ summary: 'Get all members of a project' })
  @ApiResponse({
    status: 200,
    description: 'Project members retrieved successfully',
    type: [ProjectMemberResponseDto],
  })
  async getMembers(
    @UUIDParam('projectId') projectId: string,
    @Query() query: PaginationQueryDto,
  ): Promise<PaginationResult<ProjectMemberResponseDto>> {
    return this.projectMemberService.getProjectMembersByProjectId(
      projectId,
      query,
    );
  }

  @Delete(':userId')
  @ApiOperation({ summary: 'Remove a member from a project' })
  @ApiResponse({
    status: 200,
    description: 'Member removed successfully',
  })
  async removeMember(
    @UUIDParam('projectId') projectId: string,
    @UUIDParam('userId') userId: string,
  ) {
    return this.projectMemberService.removeProjectMember(projectId, userId);
  }

  @Patch(':userId/role')
  @RequireProjectMembership({ roles: [ProjectMemberRole.Admin] })
  @ApiOperation({ summary: 'Update a project member role' })
  @ApiResponse({
    status: 200,
    description: 'Member role updated successfully',
  })
  async updateMemberRole(
    @UUIDParam('projectId') projectId: string,
    @UUIDParam('userId') userId: string,
    @Body() updateMemberRoleDto: UpdateMemberRoleDto,
  ) {
    return this.projectMemberService.updateProjectMemberRole(
      projectId,
      userId,
      updateMemberRoleDto,
    );
  }
}
