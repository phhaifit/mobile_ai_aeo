import {
  Controller,
  Get,
  Param,
  NotFoundException,
  Delete,
  Body,
  Patch,
  Query,
  Post,
  UseGuards,
  Request,
  Res,
} from '@nestjs/common';
import {
  ApiOperation,
  ApiResponse,
  ApiTags,
  ApiBearerAuth,
  ApiQuery,
  ApiParam,
} from '@nestjs/swagger';
import { ContentService } from './content.service';
import { ContentImageService } from './content-image.service';
import {
  ContentDto,
  ContentListItemDto,
  DeleteContentsDto,
  UpdateContentDto,
} from './dto/content.dto';
import { GenerateContentDto } from './dto/generate-content.dto';
import { ContentQueryDto } from './dto/content-query.dto';
import { PaginationResult } from 'src/shared/dtos/pagination-result.dto';
import { type AuthenticatedRequest } from 'src/auth/guards/jwt-auth.guard';
import { ProjectMembershipGuard } from '../auth/guards/project-membership.guard';
import { RequireProjectMembership } from '../auth/decorators/require-project-membership.decorator';
import { SseService } from 'src/sse/sse.service';
import { v4 as uuidv4 } from 'uuid';
import { Public } from 'src/auth/decorators/public.decorator';
import {
  UploadImageDto,
  PresignedUrlResponseDto,
  ImageUploadResponseDto,
  GetPresignedUrlDto,
} from './dto/image-metadata.dto';
import type { Response } from 'express';

@ApiTags('contents')
@Controller()
@ApiBearerAuth('JWT-auth')
@UseGuards(ProjectMembershipGuard)
export class ContentController {
  constructor(
    private readonly contentService: ContentService,
    private readonly sseService: SseService,
    private readonly contentImageService: ContentImageService,
  ) {}

  @Post('contents/backfill-embeddings')
  @ApiOperation({
    summary:
      'Backfill embeddings for all published content across all projects',
  })
  @ApiQuery({
    name: 'limit',
    required: false,
    type: Number,
    description: 'Max number of contents to embed (for benchmarking)',
  })
  @ApiResponse({
    status: 200,
    description: 'Embeddings backfilled',
  })
  async backfillEmbeddings(@Query('limit') limit?: string): Promise<{
    projectsProcessed: number;
    totalEmbedded: number;
  }> {
    return this.contentService.backfillEmbeddings(
      limit ? parseInt(limit, 10) : undefined,
    );
  }

  @Get('projects/:projectId/contents')
  @RequireProjectMembership()
  @ApiOperation({
    summary:
      'Get all contents for a specific project with optional filtering and sorting',
    description:
      'Supports filtering by status, topic, keywords, date range and sorting by date, topic, status, or keyword',
  })
  @ApiResponse({
    status: 200,
    description: 'List of contents retrieved successfully',
    type: [ContentListItemDto],
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - not a project member' })
  @ApiResponse({ status: 404, description: 'Project not found' })
  async getContentsByProject(
    @Param('projectId') projectId: string,
    @Query() queryDto: ContentQueryDto,
  ): Promise<PaginationResult<ContentListItemDto>> {
    return this.contentService.getPaginatedContentsByProjectId(
      projectId,
      queryDto,
    );
  }

  @Get('contents/:id')
  @ApiOperation({ summary: 'Get specific content by ID' })
  @ApiResponse({
    status: 200,
    description: 'Content retrieved successfully',
    type: ContentDto,
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - no access to content' })
  @ApiResponse({ status: 404, description: 'Content not found' })
  async getContentById(
    @Param('id') id: string,
    @Request() req: AuthenticatedRequest,
  ): Promise<ContentDto> {
    const content = await this.contentService.getContentById(id, req.user.id);

    if (!content) {
      throw new NotFoundException(`Content with ID ${id} not found`);
    }

    return content;
  }

  @Delete('contents/delete-many')
  @ApiOperation({ summary: 'Delete multiple contents by IDs' })
  @ApiResponse({
    status: 200,
    description: 'Contents deleted successfully',
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - no access to content' })
  @ApiResponse({
    status: 409,
    description: 'Cannot delete PUBLISHED content',
  })
  async deleteContents(
    @Body() deleteDto: DeleteContentsDto,
    @Request() req: AuthenticatedRequest,
  ): Promise<void> {
    await this.contentService.deleteContents(deleteDto.ids, req.user.id);
  }

  @Patch('contents/:id')
  @ApiOperation({ summary: 'Update content by ID' })
  @ApiResponse({
    status: 200,
    description: 'Content updated successfully',
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - no access to content' })
  @ApiResponse({ status: 404, description: 'Content not found' })
  @ApiResponse({
    status: 409,
    description: 'Cannot update slug on PUBLISHED content',
  })
  async updateContent(
    @Param('id') id: string,
    @Body() updateDto: UpdateContentDto,
    @Request() req: AuthenticatedRequest,
  ): Promise<void> {
    await this.contentService.updateContent(id, req.user.id, updateDto);
  }

  @Post('contents/:id/publish')
  @ApiOperation({
    summary: 'Publish content',
    description:
      'Publish content to make it visible on the public blog. Only COMPLETE content can be published.',
  })
  @ApiResponse({
    status: 200,
    description: 'Content published successfully',
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - no access to content' })
  @ApiResponse({ status: 404, description: 'Content not found' })
  @ApiResponse({
    status: 409,
    description:
      'Content is not in COMPLETE status or was modified by another request',
  })
  async publishContent(
    @Param('id') id: string,
    @Request() req: AuthenticatedRequest,
  ): Promise<void> {
    await this.contentService.publishContent(id, req.user.id);
  }

  @Post('contents/:id/unpublish')
  @ApiOperation({
    summary: 'Unpublish content',
    description:
      'Unpublish content to remove it from the public blog. Only PUBLISHED content can be unpublished.',
  })
  @ApiResponse({
    status: 200,
    description: 'Content unpublished successfully',
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - no access to content' })
  @ApiResponse({ status: 404, description: 'Content not found' })
  @ApiResponse({
    status: 409,
    description:
      'Content is not in PUBLISHED status or was modified by another request',
  })
  async unpublishContent(
    @Param('id') id: string,
    @Request() req: AuthenticatedRequest,
  ): Promise<void> {
    await this.contentService.unpublishContent(id, req.user.id);
  }

  @Post('contents/:id/republish')
  @ApiOperation({
    summary: 'Republish content',
    description:
      'Sync current body to publishedBody and re-embed. Only PUBLISHED content can be republished.',
  })
  @ApiResponse({
    status: 200,
    description: 'Content republished successfully',
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - no access to content' })
  @ApiResponse({ status: 404, description: 'Content not found' })
  @ApiResponse({
    status: 409,
    description:
      'Content is not in PUBLISHED status or was modified by another request',
  })
  async republishContent(
    @Param('id') id: string,
    @Request() req: AuthenticatedRequest,
  ): Promise<void> {
    await this.contentService.republishContent(id, req.user.id);
  }

  @Post('contents/:id/regenerate')
  @ApiOperation({
    summary: 'Regenerate content',
    description:
      'Regenerate content using the original prompt and settings. Blog uses rewrite mode (preserves structure), social generates fresh content.',
  })
  @ApiResponse({
    status: 200,
    description: 'Regeneration job created successfully',
  })
  @ApiResponse({
    status: 400,
    description: 'Content has no associated prompt',
  })
  @ApiResponse({ status: 404, description: 'Content not found' })
  regenerateContent(
    @Param('id') id: string,
    @Body() body: { improvement?: string },
    @Request() req: AuthenticatedRequest,
  ): { jobId: string } {
    const jobId = uuidv4();
    this.sseService.createChannel(jobId, req.user.id);

    void this.contentService
      .regenerateContent(id, req.user.id, jobId, body.improvement)
      .then((result) => {
        this.sseService.send(jobId, 'result', result);
        this.sseService.close(jobId);
      })
      .catch((error: unknown) => {
        const message =
          error instanceof Error
            ? error.message
            : 'Content regeneration failed';
        this.sseService.send(jobId, 'failed', { message });
        this.sseService.close(jobId);
      });

    return { jobId };
  }

  @Post('prompts/:promptId/generations')
  @ApiOperation({
    summary: 'Start content generation job with SSE streaming',
  })
  @ApiResponse({
    status: 200,
    description: 'Job created successfully',
  })
  async createContentGenerationJob(
    @Param('promptId') promptId: string,
    @Body() dto: GenerateContentDto,
    @Request() req: AuthenticatedRequest,
  ): Promise<{ jobId: string }> {
    const jobId = uuidv4();
    this.sseService.createChannel(jobId, req.user.id);

    void this.contentService
      .generateContent(promptId, dto, req.user.id, jobId)
      .then((result) => {
        this.sseService.send(jobId, 'result', result);
        this.sseService.close(jobId);
      })
      .catch((error: unknown) => {
        const message =
          error instanceof Error ? error.message : 'Content generation failed';
        this.sseService.send(jobId, 'failed', { message });
        this.sseService.close(jobId);
      });

    return { jobId };
  }

  @Get('contents/jobs/:jobId/stream')
  @ApiOperation({ summary: 'Stream content generation job events' })
  @ApiResponse({
    status: 200,
    description: 'SSE stream opened',
  })
  async streamContentJob(
    @Param('jobId') jobId: string,
    @Request() req: AuthenticatedRequest,
    @Res() res: Response,
  ): Promise<void> {
    const status = this.sseService.attach(jobId, req.user.id, res);

    if (status === 'not_found') {
      res.status(404).json({ message: 'Job not found' });
      return;
    }

    if (status === 'forbidden') {
      res.status(403).json({ message: 'Forbidden' });
      return;
    }
  }

  @Get('contents/by-job/:jobId')
  @ApiOperation({ summary: 'Get content by jobId for reconnection' })
  @ApiResponse({
    status: 200,
    description: 'Content retrieved successfully',
    type: ContentDto,
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - no access to content' })
  @ApiResponse({ status: 404, description: 'Content not found' })
  async getContentByJobId(
    @Param('jobId') jobId: string,
    @Request() req: AuthenticatedRequest,
  ): Promise<ContentDto | null> {
    return this.contentService.getContentByJobId(jobId, req.user.id);
  }

  @Public()
  @Post('webhooks/n8n/content-progress')
  @ApiOperation({ summary: 'Receive content generation progress from n8n' })
  @ApiResponse({
    status: 200,
    description: 'Progress received',
  })
  handleN8nProgress(
    @Body()
    body: {
      jobId?: string;
      step?: string;
      status?: string;
      message?: string;
    },
  ): { ok: true } {
    const jobId = body.jobId;
    if (!jobId) {
      return { ok: true };
    }

    if (body.status === 'failed') {
      this.sseService.send(jobId, 'failed', {
        message: body.message || 'Content generation failed',
      });
      this.sseService.close(jobId);
      return { ok: true };
    }

    if (body.step) {
      void this.contentService
        .updateContentJobProgress(jobId, body.step)
        .catch((error) => {
          console.warn(
            `Failed to save step to database for job ${jobId}:`,
            error,
          );
        });

      this.sseService.send(jobId, 'step', { step: body.step });
    }

    return { ok: true };
  }

  @Post('contents/:id/image/upload-from-url')
  @ApiOperation({
    summary: 'Download image from URL and upload to R2',
    description:
      'Downloads an image from the provided URL, renames it, and uploads to Cloudflare R2 with app.aeo.how domain',
  })
  @ApiQuery({
    name: 'contentId',
    required: true,
    description: 'Content ID for organizing images',
    example: 'content-123',
  })
  @ApiResponse({
    status: 201,
    description: 'Image successfully uploaded',
    type: ImageUploadResponseDto,
  })
  @ApiResponse({ status: 400, description: 'Invalid URL or download failed' })
  async uploadFromUrl(
    @Body() dto: UploadImageDto,
    @Param('id') contentId: string,
    @Request() req: AuthenticatedRequest,
  ): Promise<ImageUploadResponseDto> {
    return await this.contentImageService.uploadImageFromUrl(
      contentId,
      req.user.id,
      dto.sourceUrl,
      dto.type,
    );
  }

  @Get('contents/:id/image/presigned-url')
  @ApiOperation({
    summary: 'Generate presigned URL for frontend uploads',
    description:
      'Generates a presigned URL that allows frontend to upload images directly to R2',
  })
  @ApiQuery({
    name: 'filename',
    required: true,
    description: 'Original filename',
    example: 'profile-image.jpg',
  })
  @ApiQuery({
    name: 'contentId',
    required: true,
    description: 'Content ID for organizing images',
    example: 'content-123',
  })
  @ApiQuery({
    name: 'contentType',
    required: false,
    description: 'MIME type of the file',
    example: 'image/jpeg',
  })
  @ApiQuery({
    name: 'expiresIn',
    required: false,
    description: 'URL expiration time in seconds',
    example: 600,
  })
  @ApiResponse({
    status: 201,
    description: 'Presigned URL generated successfully',
    type: PresignedUrlResponseDto,
  })
  async getPresignedUrl(
    @Query() dto: GetPresignedUrlDto,
    @Param('id') contentId: string,
    @Request() req: AuthenticatedRequest,
  ): Promise<PresignedUrlResponseDto> {
    return await this.contentImageService.generatePresignedUrlForContent(
      contentId,
      req.user.id,
      dto.filename,
      dto.contentType,
      dto.expiresIn,
      dto.type,
    );
  }

  @Delete('contents/:id/image/:key')
  @ApiOperation({
    summary: 'Delete an image from R2',
    description: 'Deletes a specific image from R2 storage by its key',
  })
  @ApiParam({
    name: 'key',
    description: 'Full key/path of the image to delete',
    example: 'contents/content-123/image-uuid.jpg',
  })
  @ApiResponse({
    status: 200,
    description: 'Image successfully deleted',
  })
  async deleteImage(
    @Param('id') contentId: string,
    @Param('key') key: string,
    @Request() req: AuthenticatedRequest,
  ): Promise<{ message: string }> {
    await this.contentImageService.deleteContentImage(
      contentId,
      req.user.id,
      key,
    );
    return { message: 'Image deleted successfully' };
  }

  @Get('contents/:id/image/:key/download')
  @ApiOperation({
    summary: 'Download image',
    description: 'Streams the image file for download',
  })
  @ApiParam({
    name: 'id',
    description: 'Content ID',
    example: 'content-123',
  })
  @ApiParam({
    name: 'key',
    description: 'Full key/path of the image',
    example: 'contents/content-123/image-uuid.jpg',
  })
  @ApiResponse({
    status: 200,
    description: 'Image streamed successfully',
  })
  async downloadImage(
    @Param('id') contentId: string,
    @Param('key') key: string,
    @Request() req: AuthenticatedRequest,
    @Res() res: Response,
  ): Promise<void> {
    await this.contentImageService.streamImageForDownload(
      contentId,
      req.user.id,
      key,
      res,
    );
  }
}
