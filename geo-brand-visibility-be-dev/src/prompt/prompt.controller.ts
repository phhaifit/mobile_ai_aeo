import {
  Controller,
  Post,
  Get,
  Body,
  Delete,
  Query,
  Request,
  Patch,
  UseGuards,
} from '@nestjs/common';
import {
  ApiOperation,
  ApiResponse,
  ApiTags,
  ApiBearerAuth,
  ApiQuery,
  ApiBody,
} from '@nestjs/swagger';
import { PromptService } from './prompt.service';
import { type AuthenticatedRequest } from '../auth/guards/jwt-auth.guard';
import {
  UpdatePromptRequestDTO,
  UpdatePromptResponseDTO,
} from './dto/update-prompt.dto';
import { PromptDTO } from './dto/prompt.dto';
import { GetResponsesResponseDTO } from './dto/get-responses.dto';
import { GetPromptAnalysisResultDTO } from './dto/get-prompt-analysis-result.dto';
import { CreatePromptDto } from './dto/create-prompt.dto';
import { GenerateContentDto } from '../content/dto/generate-content.dto';
import { GeneratedContentDto } from '../content/dto/generated-content.dto';
import { ContentService } from 'src/content/content.service';
import { ContentTopicListItemDto } from '../content/dto/content.dto';
import { Logger } from '@nestjs/common';
import { WebSearchResponseDto } from 'src/web-search/dtos/web-search-response.dto';
import { UUIDParam } from 'src/shared/decorators/uuid-param.decorator';
import { UserParam } from 'src/shared/decorators/user-param.decorator';
import { SearchOptionDto } from 'src/web-search/dtos/search-option.dto';
import {
  ValidateReferenceDto,
  ValidateReferenceResponseDto,
} from 'src/content/dto/validate-reference.dto';
import { GetPromptsByProjectQueryDto } from './dto/get-prompts-by-project-query.dto';
import { PaginationResult } from 'src/shared/dtos/pagination-result.dto';
import { GetPromptsByTopicQueryDto } from './dto/get-prompts-by-topic-query.dto';
import { PromptProPlanGuard } from '../auth/guards/prompt-pro-plan.guard';

@ApiTags('prompts')
@Controller('/prompts')
@ApiBearerAuth('JWT-auth')
export class PromptController {
  private readonly logger = new Logger(PromptController.name);

  constructor(
    private readonly promptService: PromptService,
    private readonly contentService: ContentService,
  ) {}

  @Get('get-or-generate')
  @ApiOperation({
    summary: 'Get existing prompts or generate new ones for a project',
    description:
      'Returns existing active prompts grouped by topic. If no prompts exist, generates new ones via AI, saves them, and returns them.',
  })
  @ApiQuery({
    name: 'projectId',
    description: 'The project ID',
    required: true,
    type: String,
  })
  @ApiResponse({
    status: 200,
    description: 'Prompts retrieved or generated successfully',
  })
  async getOrGeneratePrompts(
    @Query('projectId') projectId: string,
    @Request() req: AuthenticatedRequest,
  ) {
    const data = await this.promptService.getOrGeneratePrompts(
      projectId,
      req.user.id,
    );
    return { data };
  }

  @Post('single')
  @ApiOperation({
    summary: 'Create a single prompt',
    description:
      'Creates a single prompt and associates it with a topic. Optionally includes keywords.',
  })
  @ApiResponse({
    status: 201,
    description: 'Prompt created successfully',
    type: PromptDTO,
  })
  @ApiResponse({
    status: 400,
    description: 'Invalid request',
  })
  @ApiResponse({
    status: 404,
    description: 'Topic not found',
  })
  @ApiResponse({ status: 500, description: 'Internal server error' })
  async createPrompt(
    @Body() data: CreatePromptDto,
    @Request() req: AuthenticatedRequest,
  ): Promise<PromptDTO> {
    return this.promptService.createPrompt(data, req.user.id);
  }

  @Delete(':promptId')
  @ApiOperation({
    summary: 'Delete a prompt by ID',
    description:
      'Soft deletes a prompt by setting isDeleted to true. The prompt is not permanently removed from the database.',
  })
  @ApiResponse({
    status: 200,
    description: 'Prompt deleted successfully',
  })
  @ApiResponse({ status: 404, description: 'Prompt not found' })
  @ApiResponse({ status: 500, description: 'Internal server error' })
  async deletePrompt(
    @UUIDParam('promptId') promptId: string,
    @Request() req: AuthenticatedRequest,
  ): Promise<void> {
    await this.promptService.deletePrompt(promptId, req.user.id);
  }

  @Get('by-project')
  @ApiOperation({
    summary: 'Get prompts by project ID',
    description:
      'Retrieves prompts for a specific project. Use status query parameter to filter by status.',
  })
  @ApiQuery({
    name: 'projectId',
    description: 'The project ID',
    required: true,
    type: String,
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
    description: 'Prompts retrieved successfully',
    type: Object,
  })
  async getPromptsByProject(
    @Query() query: GetPromptsByProjectQueryDto,
    @Request() req: AuthenticatedRequest,
  ): Promise<PaginationResult<PromptDTO>> {
    return this.promptService.getPromptsByProject(
      query.projectId,
      req.user.id,
      query.status,
      query.page,
      query.pageSize,
      query.search,
      query.type,
      query.isMonitored,
    );
  }

  @Get('monitoring-capacity')
  @ApiOperation({
    summary: 'Get monitoring prompt capacity',
    description:
      'Returns the current count of monitored prompts and the monitoring limit for a project.',
  })
  @ApiQuery({
    name: 'projectId',
    description: 'The project ID',
    required: true,
    type: String,
  })
  @ApiResponse({
    status: 200,
    description: 'Monitoring capacity retrieved successfully',
  })
  async getMonitoringCapacity(@Query('projectId') projectId: string): Promise<{
    monitoredCount: number;
    limit: number;
    exhaustedCount: number;
  }> {
    return this.promptService.getMonitoringCapacity(projectId);
  }

  @Get('by-topic')
  @ApiOperation({
    summary: 'Get prompts by topic ID',
    description:
      'Retrieves prompts for a specific topic. Use status query parameter to filter by status.',
  })
  @ApiQuery({
    name: 'topicId',
    description: 'The topic ID',
    required: true,
    type: String,
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
    description: 'Prompts retrieved successfully',
    type: Object,
  })
  async getPromptsByTopic(
    @Query() query: GetPromptsByTopicQueryDto,
    @Request() req: AuthenticatedRequest,
  ): Promise<PaginationResult<PromptDTO>> {
    return this.promptService.getPromptsByTopic(
      query.topicId,
      req.user.id,
      query.status,
      query.page,
      query.pageSize,
      query.search,
      query.type,
      query.isMonitored,
    );
  }

  @Get('deleted/by-project')
  @ApiOperation({
    summary: 'Get deleted prompts by project ID',
    description: 'Retrieves all soft-deleted prompts for a specific project.',
  })
  @ApiQuery({
    name: 'projectId',
    description: 'The project ID',
    required: true,
    type: String,
  })
  @ApiResponse({
    status: 200,
    description: 'Deleted prompts retrieved successfully',
    type: [PromptDTO],
  })
  async getDeletedPromptsByProject(
    @Query('projectId') projectId: string,
  ): Promise<PromptDTO[]> {
    return this.promptService.getDeletedPromptsByProject(projectId);
  }

  @Get('deleted/by-topic')
  @ApiOperation({
    summary: 'Get deleted prompts by topic ID',
    description: 'Retrieves all soft-deleted prompts for a specific topic.',
  })
  @ApiQuery({
    name: 'topicId',
    description: 'The topic ID',
    required: true,
    type: String,
  })
  @ApiResponse({
    status: 200,
    description: 'Deleted prompts retrieved successfully',
    type: [PromptDTO],
  })
  async getDeletedPromptsByTopic(
    @Query('topicId') topicId: string,
  ): Promise<PromptDTO[]> {
    return this.promptService.getDeletedPromptsByTopic(topicId);
  }

  @Post(':promptId/restore')
  @ApiOperation({
    summary: 'Restore a soft-deleted prompt',
    description:
      'Restores a prompt by setting isDeleted to false. The prompt will appear in active lists again.',
  })
  @ApiResponse({
    status: 200,
    description: 'Prompt restored successfully',
    type: PromptDTO,
  })
  @ApiResponse({ status: 404, description: 'Prompt not found' })
  async restorePrompt(
    @UUIDParam('promptId') promptId: string,
  ): Promise<PromptDTO> {
    return this.promptService.restorePrompt(promptId);
  }

  @Get('suggested/by-project')
  @ApiOperation({
    summary: 'Get suggested prompts by project ID',
    description: 'Retrieves all AI-suggested prompts for a specific project.',
  })
  @ApiQuery({
    name: 'projectId',
    description: 'The project ID',
    required: true,
    type: String,
  })
  @ApiResponse({
    status: 200,
    description: 'Suggested prompts retrieved successfully',
    type: [PromptDTO],
  })
  async getSuggestedPromptsByProject(
    @Query('projectId') projectId: string,
  ): Promise<PromptDTO[]> {
    return this.promptService.getSuggestedPromptsByProject(projectId);
  }

  @Get('suggested/by-topic')
  @ApiOperation({
    summary: 'Get suggested prompts by topic ID',
    description: 'Retrieves all AI-suggested prompts for a specific topic.',
  })
  @ApiQuery({
    name: 'topicId',
    description: 'The topic ID',
    required: true,
    type: String,
  })
  @ApiResponse({
    status: 200,
    description: 'Suggested prompts retrieved successfully',
    type: [PromptDTO],
  })
  async getSuggestedPromptsByTopic(
    @Query('topicId') topicId: string,
  ): Promise<PromptDTO[]> {
    return this.promptService.getSuggestedPromptsByTopic(topicId);
  }

  @Post(':promptId/track')
  @ApiOperation({
    summary: 'Track a suggested prompt',
    description:
      'Moves a suggested prompt to active status. The prompt will appear in active lists.',
  })
  @ApiResponse({
    status: 200,
    description: 'Prompt tracked successfully',
    type: PromptDTO,
  })
  @ApiResponse({ status: 404, description: 'Prompt not found' })
  async trackPrompt(
    @UUIDParam('promptId') promptId: string,
  ): Promise<PromptDTO> {
    return this.promptService.trackPrompt(promptId);
  }

  @Post(':promptId/reject')
  @ApiOperation({
    summary: 'Reject a suggested prompt',
    description:
      'Moves a suggested prompt to inactive status. The prompt will appear in inactive lists.',
  })
  @ApiResponse({
    status: 200,
    description: 'Prompt rejected successfully',
    type: PromptDTO,
  })
  @ApiResponse({ status: 404, description: 'Prompt not found' })
  async rejectPrompt(
    @UUIDParam('promptId') promptId: string,
  ): Promise<PromptDTO> {
    return this.promptService.rejectPrompt(promptId);
  }

  @Post('ensure-suggestions/by-topic')
  @ApiOperation({
    summary: 'Ensure minimum suggested prompts for a topic',
    description:
      'Auto-generates suggested prompts for a topic using AI if count is below threshold. AI is aware of existing prompts to avoid duplicates.',
  })
  @ApiBody({
    schema: {
      properties: {
        topicId: { type: 'string', description: 'UUID of the topic' },
        minCount: {
          type: 'number',
          default: 10,
          description: 'Minimum number of suggested prompts to maintain',
        },
      },
      required: ['topicId'],
    },
  })
  @ApiResponse({
    status: 200,
    description: 'Suggested prompts ensured successfully',
    type: [PromptDTO],
  })
  @ApiResponse({ status: 404, description: 'Topic not found' })
  async ensureSuggestedPromptsByTopic(
    @Body()
    {
      topicId,
      minCount,
      personaId,
    }: { topicId: string; minCount?: number; personaId?: string },
    @Request() req: AuthenticatedRequest,
  ): Promise<PromptDTO[]> {
    return this.promptService.ensureSuggestedPromptsByTopic(
      topicId,
      req.user.id,
      minCount ?? 10,
      personaId,
    );
  }

  @Delete(':promptId/permanent')
  @ApiOperation({
    summary: 'Permanently delete a prompt',
    description:
      'Permanently removes a prompt from the database. This action cannot be undone.',
  })
  @ApiResponse({
    status: 200,
    description: 'Prompt permanently deleted',
  })
  @ApiResponse({ status: 404, description: 'Prompt not found' })
  async permanentlyDeletePrompt(
    @UUIDParam('promptId') promptId: string,
  ): Promise<void> {
    await this.promptService.permanentlyDeletePrompt(promptId);
  }

  @Patch(':promptId')
  @ApiOperation({
    summary: 'Update a prompt by ID',
    description:
      'Update properties of a prompt such as isMonitored or isDeleted.',
  })
  @ApiResponse({
    status: 200,
    description: 'Prompt updated successfully',
    type: UpdatePromptResponseDTO,
  })
  @ApiResponse({ status: 404, description: 'Prompt not found' })
  @ApiResponse({ status: 500, description: 'Internal server error' })
  async updatePrompt(
    @UUIDParam('promptId') promptId: string,
    @Body() data: UpdatePromptRequestDTO,
    @Request() req: AuthenticatedRequest,
  ): Promise<UpdatePromptResponseDTO> {
    return this.promptService.updatePrompt(promptId, data, req.user.id);
  }

  @Get(':promptId/responses')
  @ApiOperation({
    summary: 'Get responses for prompts in a project',
    description:
      'Retrieves responses generated for the prompts associated with a specific project.',
  })
  @ApiResponse({
    status: 200,
    description: 'Responses retrieved successfully',
    type: [GetResponsesResponseDTO],
    isArray: true,
  })
  @ApiResponse({ status: 400, description: 'Invalid request' })
  @ApiResponse({ status: 500, description: 'Internal server error' })
  async getResponses(
    @UUIDParam('promptId') promptId: string,
    @Query('start') startDate: string,
    @Query('end') endDate: string,
    @Request() req: AuthenticatedRequest,
  ): Promise<GetResponsesResponseDTO[]> {
    return this.promptService.getResponses(
      promptId,
      startDate,
      endDate,
      req.user.id,
    );
  }

  @Get(':promptId')
  @ApiOperation({
    summary: 'Get a specific prompt by ID',
    description: 'Retrieves a specific prompt using its unique identifier.',
  })
  @ApiResponse({
    status: 200,
    description: 'Prompt retrieved successfully',
    type: PromptDTO,
  })
  @ApiResponse({ status: 404, description: 'Prompt not found' })
  @ApiResponse({ status: 500, description: 'Internal server error' })
  async getPrompt(
    @UUIDParam('promptId') promptId: string,
    @Request() req: AuthenticatedRequest,
  ): Promise<PromptDTO> {
    return this.promptService.getPrompt(promptId, req.user.id);
  }

  @Get(':promptId/analysis-result')
  @ApiOperation({
    summary: 'Get analysis result for a specific prompt',
    description:
      'Retrieves the analysis result for a specific prompt using its unique identifier.',
  })
  @ApiResponse({
    status: 200,
    description: 'Analysis result retrieved successfully',
    type: String,
  })
  @ApiResponse({ status: 404, description: 'Prompt not found' })
  @ApiResponse({ status: 500, description: 'Internal server error' })
  async getAnalysisResult(
    @UUIDParam('promptId') promptId: string,
    @Query('start') startDate: string,
    @Query('end') endDate: string,
    @Request() req: AuthenticatedRequest,
  ): Promise<GetPromptAnalysisResultDTO> {
    return this.promptService.getAnalysisResult(
      promptId,
      startDate,
      endDate,
      req.user.id,
    );
  }

  @Post(':promptId/validate-reference')
  @ApiOperation({
    summary: 'Validate a reference page URL for content generation',
  })
  @ApiResponse({
    status: 200,
    description: 'Validation result with optional alternative suggestion',
  })
  async validateReference(
    @UserParam('id') userId: string,
    @UUIDParam('promptId') promptId: string,
    @Body() dto: ValidateReferenceDto,
  ): Promise<ValidateReferenceResponseDto> {
    return this.contentService.validateReference(promptId, userId, dto);
  }

  @Post(':id/content-generations')
  @ApiOperation({ summary: 'Generate content for a specific topic' })
  @ApiResponse({
    status: 200,
    description: 'Content generated successfully',
    type: GeneratedContentDto,
  })
  @ApiResponse({ status: 400, description: 'Bad request' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 404, description: 'Topic not found' })
  async generateContent(
    @UUIDParam('id') promptId: string,
    @Body() dto: GenerateContentDto,
    @Request() req: AuthenticatedRequest,
  ): Promise<GeneratedContentDto> {
    return this.contentService.generateContent(promptId, dto, req.user.id);
  }

  @Get(':id/contents')
  @ApiOperation({
    summary: 'Get all contents for a specific project and topic',
  })
  @ApiResponse({
    status: 200,
    description: 'List of contents retrieved successfully',
    type: [ContentTopicListItemDto],
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 404, description: 'Project or topic not found' })
  async getContentsByProjectAndTopic(
    @UUIDParam('id') promptId: string,
  ): Promise<ContentTopicListItemDto[]> {
    return this.contentService.getContentsByPromptId(promptId);
  }

  @Get(':promptId/top-pages')
  @ApiOperation({
    summary: 'Get all contents for a specific project and topic',
  })
  @ApiResponse({
    status: 200,
    description: 'List of contents retrieved successfully',
    type: [WebSearchResponseDto],
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 404, description: 'Project or topic not found' })
  async searchWebPages(
    @UserParam('id') userId: string,
    @UUIDParam('promptId') promptId: string,
    @Query() option: SearchOptionDto,
  ): Promise<WebSearchResponseDto[]> {
    return await this.promptService.getTopPages(promptId, userId, option);
  }

  @Post(':promptId/trigger')
  @UseGuards(PromptProPlanGuard)
  @ApiOperation({
    summary: 'Trigger analysis of a specific prompt',
  })
  @ApiResponse({
    status: 200,
    description: 'Analysis triggered successfully',
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 404, description: 'Prompt not found' })
  async analyzePrompt(
    @UUIDParam('promptId') promptId: string,
    @Request() req: AuthenticatedRequest,
  ) {
    return await this.promptService.analyzePrompt(promptId, req.user.id);
  }
}
