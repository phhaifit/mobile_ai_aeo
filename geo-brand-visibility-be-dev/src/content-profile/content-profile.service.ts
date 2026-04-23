import {
  Injectable,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common';
import { ContentProfileRepository } from './content-profile.repository';
import { ContentProfileResponseDto } from './dto/content-profile-response.dto';
import { CreateContentProfileDto } from './dto/create-content-profile.dto';
import { UpdateContentProfileDto } from './dto/update-content-profile.dto';
import { ProjectRepository } from '../project/project.repository';

@Injectable()
export class ContentProfileService {
  constructor(
    private readonly contentProfileRepository: ContentProfileRepository,
    private readonly projectRepository: ProjectRepository,
  ) {}

  async findById(
    id: string,
    projectId: string,
    userId: string,
  ): Promise<ContentProfileResponseDto> {
    const contentProfile = await this.contentProfileRepository.findById(id);

    if (!contentProfile || contentProfile.projectId !== projectId) {
      throw new NotFoundException('Content profile not found');
    }

    return contentProfile;
  }

  async findByProjectId(
    projectId: string,
    userId: string,
  ): Promise<ContentProfileResponseDto[]> {
    return this.contentProfileRepository.findByProjectId(projectId, userId);
  }

  async create(
    projectId: string,
    contentProfile: CreateContentProfileDto,
  ): Promise<ContentProfileResponseDto> {
    const project = await this.projectRepository.findById(projectId);
    if (!project) {
      throw new NotFoundException('Project not found');
    }

    return this.contentProfileRepository.create({
      projectId,
      ...contentProfile,
    });
  }

  async update(
    projectId: string,
    id: string,
    contentProfile: UpdateContentProfileDto,
  ): Promise<ContentProfileResponseDto> {
    const project = await this.projectRepository.findById(projectId);
    if (!project) {
      throw new NotFoundException('Project not found');
    }

    if (Object.keys(contentProfile).length === 0) {
      throw new BadRequestException('No fields to update');
    }

    const updatedProfile = await this.contentProfileRepository.update(
      id,
      contentProfile,
    );

    if (!updatedProfile) {
      throw new NotFoundException('Content profile not found');
    }

    return updatedProfile;
  }

  async seedDefaults(projectId: string, language?: string): Promise<void> {
    return this.contentProfileRepository.seedDefaults(projectId, language);
  }

  async delete(id: string, userId: string): Promise<void> {
    const existingProfile = await this.contentProfileRepository.findById(id);

    if (!existingProfile) {
      throw new NotFoundException('Content profile not found');
    }

    await this.contentProfileRepository.delete(id);
  }
}
