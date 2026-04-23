import {
  Controller,
  Post,
  Get,
  Patch,
  Delete,
  Body,
  Param,
  Request,
  Query,
  Headers,
  ValidationPipe,
  ParseUUIDPipe,
  UseGuards,
  UnauthorizedException,
  HttpStatus,
  Res,
  BadRequestException,
} from '@nestjs/common';
import type { Response } from 'express';
import {
  ApiOperation,
  ApiResponse,
  ApiTags,
  ApiBearerAuth,
  ApiQuery,
} from '@nestjs/swagger';
import { ProjectService } from './project.service';
import { MetricsOverviewDto, MetricsAnalyticsDto } from './dto/metrics.dto';
import { MetricsFilterDto } from './dto/metrics-filter.dto';
import { UpdateProjectDto } from './dto/update-project.dto';
import { GenerateDailyDto } from './dto/generate-daily.dto';
import { ProjectResponseDto } from './dto/project-response.dto';
import {
  StrategyReviewDto,
  StrategyReviewResponseDto,
} from './dto/strategy-review.dto';
import { type AuthenticatedRequest } from '../auth/guards/jwt-auth.guard';
import { PromptDTO } from '../prompt/dto/prompt.dto';
import { PromptService } from '../prompt/prompt.service';
import { TopicService } from '../topic/topic.service';
import { TopicDTO } from '../topic/dto/topic.dto';
import { GenerateTopicsResponseDTO } from '../topic/dto/generate-topics.dto';
import { ProjectMembershipGuard } from '../auth/guards/project-membership.guard';
import { RequireProjectMembership } from '../auth/decorators/require-project-membership.decorator';
import { ProjectMemberRole } from '../project-member/enum/member-role.enum';
import { Public } from '../auth/decorators/public.decorator';
import { ProjectStatus } from './enum/project-status.enum';
import { UserParam } from 'src/shared/decorators/user-param.decorator';
import { TaskEnqueueService } from 'src/task-enqueue/task-enqueue.service';
import { ModelDto } from 'src/model/dto/model.dto';
import { PaginationResult } from 'src/shared/dtos/pagination-result.dto';

@ApiTags('projects')
@Controller('projects')
@ApiBearerAuth('JWT-auth')
@UseGuards(ProjectMembershipGuard)
export class ProjectController {
  constructor(
    private readonly projectService: ProjectService,
    private readonly promptService: PromptService,
    private readonly topicService: TopicService,
    private readonly taskEnqueueService: TaskEnqueueService,
  ) {}

  @Post()
  @ApiOperation({ summary: 'Create a new project' })
  @ApiResponse({
    status: 201,
    description: 'Project created successfully',
    type: ProjectResponseDto,
  })
  @ApiResponse({
    status: 200,
    description: 'Existing draft project returned',
    type: ProjectResponseDto,
  })
  @ApiResponse({ status: 400, description: 'Invalid input data' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async createProject(
    @Request() req: AuthenticatedRequest,
    @Res({ passthrough: true }) res: Response,
  ): Promise<ProjectResponseDto> {
    const { project, isExisting } = await this.projectService.createProject(
      req.user.id,
    );

    res.status(isExisting ? HttpStatus.OK : HttpStatus.CREATED);
    return project;
  }

  @Get('me')
  @ApiOperation({
    summary: 'Ensure a project exists for the user, create one if not',
  })
  @ApiResponse({
    status: 200,
    description: 'Existing or new projects',
    type: [ProjectResponseDto],
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getOrCreateUserProject(
    @Request() req: AuthenticatedRequest,
  ): Promise<ProjectResponseDto[]> {
    return this.projectService.getOrCreateUserProject(req.user.id);
  }

  @Get()
  @ApiOperation({ summary: 'Get all projects for the authenticated user' })
  @ApiResponse({
    status: 200,
    description: 'Projects retrieved successfully',
    type: [ProjectResponseDto],
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getProjects(
    @Request() req: AuthenticatedRequest,
    @Query('status') status?: ProjectStatus,
  ): Promise<ProjectResponseDto[]> {
    if (status && !Object.values(ProjectStatus).includes(status)) {
      throw new BadRequestException(
        `Invalid status value. Must be one of: ${Object.values(ProjectStatus).join(', ')}`,
      );
    }
    return this.projectService.findProjectsByUser(req.user.id, status);
  }

  @Get(':projectId')
  @RequireProjectMembership()
  @ApiOperation({ summary: 'Get a specific project by ID' })
  @ApiResponse({
    status: 200,
    description: 'Project retrieved successfully',
    type: ProjectResponseDto,
  })
  @ApiResponse({ status: 404, description: 'Project not found' })
  @ApiResponse({ status: 403, description: 'Access denied' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getProject(
    @Param('projectId') projectId: string,
  ): Promise<ProjectResponseDto> {
    return this.projectService.findProjectById(projectId);
  }

  @Get(':projectId/models')
  @RequireProjectMembership()
  @ApiOperation({ summary: 'Get all models for a specific project' })
  @ApiResponse({
    status: 200,
    description: 'Project models retrieved successfully',
    type: [ModelDto],
  })
  @ApiResponse({ status: 403, description: 'Access denied' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getModelsByProjectId(
    @Param('projectId', new ParseUUIDPipe({ version: '4' })) projectId: string,
  ): Promise<ModelDto[]> {
    return this.projectService.getModelsByProjectId(projectId);
  }

  @Patch(':projectId')
  @RequireProjectMembership({ roles: [ProjectMemberRole.Admin] })
  @ApiOperation({
    summary: 'Update project properties (models and/or monitoring frequency)',
  })
  @ApiResponse({
    status: 200,
    description: 'Project updated successfully',
    type: ProjectResponseDto,
  })
  @ApiResponse({
    status: 400,
    description: 'Invalid input data or no fields to update',
  })
  @ApiResponse({ status: 404, description: 'Project not found' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async updateProject(
    @Param('projectId') projectId: string,
    @Body() updateProjectDto: UpdateProjectDto,
  ): Promise<ProjectResponseDto> {
    return this.projectService.updateProject(projectId, updateProjectDto);
  }

  @Patch(':projectId/strategy-review')
  @RequireProjectMembership()
  @ApiOperation({ summary: 'Mark or clear strategy review for a project' })
  @ApiResponse({
    status: 200,
    description: 'Strategy review status updated',
    type: StrategyReviewResponseDto,
  })
  @ApiResponse({ status: 404, description: 'Project not found' })
  @ApiResponse({ status: 403, description: 'Access denied' })
  @ApiResponse({ status: 400, description: 'Invalid input data' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async updateStrategyReview(
    @Param('projectId', new ParseUUIDPipe({ version: '4' })) projectId: string,
    @Body(new ValidationPipe({ transform: true })) body: StrategyReviewDto,
    @Request() req: AuthenticatedRequest,
  ): Promise<StrategyReviewResponseDto> {
    return this.projectService.updateStrategyReview(
      projectId,
      req.user.id,
      body.reviewed,
    );
  }

  @Delete(':projectId')
  @RequireProjectMembership({ roles: [ProjectMemberRole.Admin] })
  @ApiOperation({ summary: 'Delete a project' })
  @ApiResponse({
    status: 200,
    description: 'Project deleted successfully',
    schema: {
      type: 'object',
      properties: {
        success: { type: 'boolean' },
        message: { type: 'string' },
      },
    },
  })
  @ApiResponse({ status: 404, description: 'Project not found' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async deleteProject(@Param('projectId') projectId: string): Promise<void> {
    await this.projectService.deleteProject(projectId);
  }

  @Get(':projectId/prompts')
  @RequireProjectMembership()
  @ApiOperation({
    summary: 'Get all saved prompts for a specific project',
    description:
      'Retrieves all prompts that have been saved and are being monitored in a specific project.',
  })
  @ApiQuery({
    name: 'status',
    description: 'Filter by status: active, suggested, or inactive',
    required: false,
    enum: ['active', 'suggested', 'inactive'],
  })
  @ApiQuery({
    name: 'page',
    description: 'Page number',
    required: false,
    type: Number,
  })
  @ApiQuery({
    name: 'pageSize',
    description: 'Page size',
    required: false,
    type: Number,
  })
  @ApiQuery({
    name: 'search',
    description: 'Search prompts by content (case-insensitive, partial match)',
    required: false,
    type: String,
  })
  @ApiQuery({
    name: 'type',
    description: 'Filter by prompt type',
    required: false,
    isArray: true,
    enum: ['Informational', 'Commercial', 'Transactional', 'Navigational'],
  })
  @ApiQuery({
    name: 'isMonitored',
    description: 'Filter by isMonitored',
    required: false,
    type: Boolean,
  })
  @ApiResponse({
    status: 200,
    description: 'Saved prompts retrieved successfully',
    type: Object,
  })
  @ApiResponse({ status: 400, description: 'Invalid project ID' })
  @ApiResponse({ status: 500, description: 'Internal server error' })
  async getPromptsByProject(
    @Param('projectId', new ParseUUIDPipe({ version: '4' })) projectId: string,
    @Request() req: AuthenticatedRequest,
    @Query('status') status?: string,
    @Query('page') page?: number,
    @Query('pageSize') pageSize?: number,
    @Query('search') search?: string,
    @Query('type') type?: string | string[],
    @Query('isMonitored') isMonitored?: string | boolean,
  ): Promise<PaginationResult<PromptDTO>> {
    const typeList = (() => {
      if (type === undefined || type === null || type === '') return undefined;
      const raw = Array.isArray(type) ? type : String(type).split(',');
      const normalized = raw.map((v) => v.trim()).filter((v) => v.length > 0);
      return normalized.length > 0 ? (normalized as any) : undefined;
    })();

    const isMonitoredParsed = (() => {
      if (
        isMonitored === undefined ||
        isMonitored === null ||
        isMonitored === ''
      ) {
        return undefined;
      }
      if (typeof isMonitored === 'boolean') return isMonitored;
      const normalized = String(isMonitored).trim().toLowerCase();
      if (normalized === 'true' || normalized === '1') return true;
      if (normalized === 'false' || normalized === '0') return false;
      return undefined;
    })();

    return this.promptService.getPromptsByProject(
      projectId,
      req.user.id,
      status,
      page,
      pageSize,
      search,
      typeList,
      isMonitoredParsed,
    );
  }

  @Post(':projectId/activate-and-analyze')
  @RequireProjectMembership()
  @ApiOperation({ summary: 'Activate a project and trigger analysis for it' })
  @ApiResponse({
    status: 200,
    description: 'Project activated and analysis triggered successfully',
  })
  @ApiResponse({ status: 404, description: 'Project not found' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async activateAndAnalyzeNewProject(
    @Param('projectId') projectId: string,
    @UserParam('id') userId: string,
  ) {
    return this.projectService.activateAndAnalyzeNewProject(projectId, userId);
  }

  @Post(':projectId/content/generate-daily')
  @Public()
  @ApiOperation({ summary: 'Trigger daily content generation for a project' })
  @ApiResponse({
    status: 200,
    description: 'Content generation queued successfully',
  })
  @ApiResponse({ status: 404, description: 'Project not found' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async triggerDailyContentGeneration(
    @Param('projectId') projectId: string,
    @Headers('x-demo-secret') demoSecret: string,
    @Body() body: GenerateDailyDto,
  ) {
    if (demoSecret !== '@Abc12345') {
      throw new UnauthorizedException('Invalid demo secret');
    }

    // Fetch the project to get the owner's userId
    const project = await this.projectService.findProjectById(projectId);

    return this.taskEnqueueService.triggerDailyContentGenerationForProject(
      projectId,
      project.createdBy,
      body.blogBatchSize,
      body.socialBatchSize,
    );
  }

  @Post(':projectId/test-analyze')
  @ApiOperation({ summary: '[Test] Run analyzeProjectHelper directly' })
  @ApiResponse({
    status: 200,
    description: 'Analysis completed and report sent',
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async testAnalyzeProject(
    @Param('projectId') projectId: string,
    @Request() req: AuthenticatedRequest,
  ) {
    return this.projectService.analyzeProjectHelper(projectId, req.user.id);
  }

  @Post(':projectId/analysis/run')
  @Public()
  @ApiOperation({ summary: 'Trigger analysis for a project (secret API)' })
  @ApiResponse({
    status: 200,
    description: 'Analysis queued successfully',
  })
  @ApiResponse({ status: 404, description: 'Project not found' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async triggerAnalysis(
    @Param('projectId') projectId: string,
    @Headers('x-demo-secret') demoSecret: string,
  ) {
    if (demoSecret !== '@Abc12345') {
      throw new UnauthorizedException('Invalid demo secret');
    }

    const project = await this.projectService.findProjectById(projectId);

    return this.taskEnqueueService.triggerProjectAnalysis(
      projectId,
      project.createdBy,
    );
  }

  @Get(':projectId/metrics/overview')
  @RequireProjectMembership()
  @ApiOperation({ summary: 'Get metrics overview' })
  @ApiResponse({
    status: 200,
    description: 'Get metrics overview successfully',
    type: MetricsOverviewDto,
  })
  @ApiResponse({ status: 404, description: 'Project not found' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getMetricsOverview(
    @Param('projectId') projectId: string,
    @Query('start') startDate: string,
    @Query('end') endDate: string,
    @Request() req: AuthenticatedRequest,
  ): Promise<MetricsOverviewDto> {
    return this.projectService.getMetricsOverview(
      projectId,
      startDate,
      endDate,
      req.user.id,
    );
  }

  @Get(':projectId/metrics/analytics')
  @RequireProjectMembership()
  @ApiOperation({
    summary: 'Get metrics analytics',
    description:
      'Returns daily aggregated metrics including response counts, brand mentions, link references, and sentiment breakdown. Optionally filter by AI models and prompt types.',
  })
  @ApiResponse({
    status: 200,
    description: 'Analytics data retrieved successfully',
    type: MetricsAnalyticsDto,
  })
  @ApiResponse({
    status: 400,
    description: 'Invalid date format or parameters',
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getMetricsAnalytics(
    @Param('projectId') projectId: string,
    @Query(new ValidationPipe({ transform: true })) filters: MetricsFilterDto,
  ): Promise<MetricsAnalyticsDto> {
    return this.projectService.getMetricsAnalytics(
      projectId,
      filters.start,
      filters.end,
      filters.models,
      filters.promptTypes,
      filters.granularity,
    );
  }

  @Get(':projectId/topics')
  @RequireProjectMembership()
  @ApiOperation({
    summary: 'Get all topics for a specific project',
    description: 'Retrieves all topics associated with a specific project.',
  })
  @ApiResponse({
    status: 200,
    description: 'Topics retrieved successfully',
    type: [TopicDTO],
  })
  @ApiResponse({ status: 404, description: 'Project not found' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getTopicsByProjectId(
    @Param('projectId') projectId: string,
    @Request() req: AuthenticatedRequest,
  ): Promise<TopicDTO[]> {
    return this.topicService.getTopicsByProject(projectId, req.user.id);
  }

  @Post(':projectId/topics/generate')
  @RequireProjectMembership()
  @ApiOperation({
    summary: 'Generate topics for a specific project (preview only)',
    description:
      'Generates topics for brand visibility analysis. These are preview topics that are NOT saved to the database.',
  })
  @ApiResponse({
    status: 200,
    description: 'Topics generated successfully',
    type: GenerateTopicsResponseDTO,
  })
  @ApiResponse({ status: 404, description: 'Project or brand not found' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async generateTopicsByProjectId(
    @Param('projectId') projectId: string,
    @Request() req: AuthenticatedRequest,
  ): Promise<GenerateTopicsResponseDTO> {
    const data = await this.topicService.generateTopics(projectId, req.user.id);
    return { data };
  }
}
