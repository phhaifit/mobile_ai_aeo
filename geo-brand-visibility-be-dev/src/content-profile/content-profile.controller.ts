import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Body,
  Param,
  ParseUUIDPipe,
  HttpCode,
  HttpStatus,
  Request,
} from '@nestjs/common';
import {
  ApiOperation,
  ApiResponse,
  ApiTags,
  ApiBearerAuth,
  ApiParam,
} from '@nestjs/swagger';
import { ContentProfileService } from './content-profile.service';
import { ContentProfileResponseDto } from './dto/content-profile-response.dto';
import { CreateContentProfileDto } from './dto/create-content-profile.dto';
import { UpdateContentProfileDto } from './dto/update-content-profile.dto';
import { type AuthenticatedRequest } from '../auth/guards/jwt-auth.guard';

@ApiTags('content-profiles')
@Controller('projects/:projectId/content-profiles')
@ApiBearerAuth('JWT-auth')
export class ContentProfileController {
  constructor(private readonly contentProfileService: ContentProfileService) {}

  @Get()
  @ApiOperation({
    summary: 'Get all content profiles for a project',
  })
  @ApiParam({
    name: 'projectId',
    description: 'ID of the project',
    type: String,
  })
  @ApiResponse({
    status: 200,
    description: 'Content profiles retrieved successfully',
    type: [ContentProfileResponseDto],
  })
  @ApiResponse({ status: 404, description: 'Project not found' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getContentProfiles(
    @Param('projectId', ParseUUIDPipe) projectId: string,
    @Request() req: AuthenticatedRequest,
  ): Promise<ContentProfileResponseDto[]> {
    return this.contentProfileService.findByProjectId(projectId, req.user.id);
  }

  @Get(':contentProfileId')
  @ApiOperation({
    summary: 'Get a specific content profile by ID',
  })
  @ApiParam({
    name: 'projectId',
    description: 'ID of the project',
    type: String,
  })
  @ApiParam({
    name: 'contentProfileId',
    description: 'ID of the content profile',
    type: String,
  })
  @ApiResponse({
    status: 200,
    description: 'Content profile retrieved successfully',
    type: ContentProfileResponseDto,
  })
  @ApiResponse({ status: 404, description: 'Content profile not found' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getContentProfile(
    @Param('projectId', ParseUUIDPipe) projectId: string,
    @Param('contentProfileId', ParseUUIDPipe) contentProfileId: string,
    @Request() req: AuthenticatedRequest,
  ): Promise<ContentProfileResponseDto> {
    return this.contentProfileService.findById(
      contentProfileId,
      projectId,
      req.user.id,
    );
  }

  @Post()
  @ApiOperation({
    summary: 'Create a new content profile for a project',
  })
  @ApiParam({
    name: 'projectId',
    description: 'ID of the project',
    type: String,
  })
  @ApiResponse({
    status: 201,
    description: 'Content profile created successfully',
    type: ContentProfileResponseDto,
  })
  @ApiResponse({ status: 400, description: 'Invalid input data' })
  @ApiResponse({ status: 404, description: 'Project not found' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async createContentProfile(
    @Param('projectId', ParseUUIDPipe) projectId: string,
    @Body() contentProfile: CreateContentProfileDto,
  ): Promise<ContentProfileResponseDto> {
    return this.contentProfileService.create(projectId, contentProfile);
  }

  @Patch(':contentProfileId')
  @ApiOperation({
    summary: 'Update a content profile by ID',
  })
  @ApiParam({
    name: 'projectId',
    description: 'ID of the project',
    type: String,
  })
  @ApiParam({
    name: 'contentProfileId',
    description: 'ID of the content profile',
    type: String,
  })
  @ApiResponse({
    status: 200,
    description: 'Content profile updated successfully',
    type: ContentProfileResponseDto,
  })
  @ApiResponse({
    status: 400,
    description: 'Invalid input data or no fields to update',
  })
  @ApiResponse({ status: 404, description: 'Content profile not found' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async updateContentProfile(
    @Param('projectId', ParseUUIDPipe) projectId: string,
    @Param('contentProfileId', ParseUUIDPipe) contentProfileId: string,
    @Body() data: UpdateContentProfileDto,
  ): Promise<ContentProfileResponseDto> {
    return this.contentProfileService.update(projectId, contentProfileId, data);
  }

  @Delete(':contentProfileId')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({
    summary: 'Delete a content profile by ID',
  })
  @ApiParam({
    name: 'projectId',
    description: 'ID of the project',
    type: String,
  })
  @ApiParam({
    name: 'contentProfileId',
    description: 'ID of the content profile',
    type: String,
  })
  @ApiResponse({
    status: 204,
    description: 'Content profile deleted successfully',
  })
  @ApiResponse({ status: 404, description: 'Content profile not found' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async deleteContentProfile(
    @Param('contentProfileId', ParseUUIDPipe) contentProfileId: string,
    @Request() req: AuthenticatedRequest,
  ): Promise<void> {
    return this.contentProfileService.delete(contentProfileId, req.user.id);
  }
}
