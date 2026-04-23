import { Injectable, NotFoundException } from '@nestjs/common';
import { ProjectMemberRepository } from './project-member.repository';
import {
  ProjectMemberResponseDto,
  UpdateMemberRoleDto,
} from './dto/project-member.dto';
import { PaginationResult } from 'src/shared/dtos/pagination-result.dto';
import { PaginationQueryDto } from 'src/shared/dtos/pagination-query.dto';
import { createPaginatedResponse } from 'src/utils/common';

@Injectable()
export class ProjectMemberService {
  constructor(
    private readonly projectMemberRepository: ProjectMemberRepository,
  ) {}

  async getProjectMembersByProjectId(
    projectId: string,
    params: PaginationQueryDto,
  ): Promise<PaginationResult<ProjectMemberResponseDto>> {
    const { data, total } =
      await this.projectMemberRepository.findAllByProjectId(projectId, params);

    return createPaginatedResponse(data, total, params, (item: any) => ({
      id: item.user.id,
      fullname: item.user.fullname,
      email: item.user.email,
      role: item.role,
      createdAt: item.createdAt,
      updatedAt: item.updatedAt,
    }));
  }

  async removeProjectMember(projectId: string, userId: string) {
    const data = await this.projectMemberRepository.removeMember(
      projectId,
      userId,
    );
    if (!data) {
      throw new NotFoundException('Member not found in this project');
    }
    return data;
  }

  async updateProjectMemberRole(
    projectId: string,
    userId: string,
    dto: UpdateMemberRoleDto,
  ) {
    const data = await this.projectMemberRepository.updateMemberRole(
      projectId,
      userId,
      dto.role,
    );
    if (!data) {
      throw new NotFoundException('Member not found in this project');
    }
    return data;
  }
}
