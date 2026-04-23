import {
  Body,
  Controller,
  Param,
  Post,
  Request,
  Res,
  Get,
  UseGuards,
} from '@nestjs/common';
import { ApiOperation, ApiResponse, ApiTags } from '@nestjs/swagger';
import { v4 as uuidv4 } from 'uuid';
import { ContentClusterService } from './content-cluster.service';
import {
  GenerateClusterPlanDto,
  GenerateClusterArticlesDto,
} from './dto/cluster.dto';
import { type AuthenticatedRequest } from 'src/auth/guards/jwt-auth.guard';
import { SseService } from 'src/sse/sse.service';
import { ProjectMembershipGuard } from '../auth/guards/project-membership.guard';
import { RequireProjectMembership } from '../auth/decorators/require-project-membership.decorator';
import type { Response } from 'express';

@ApiTags('Content Cluster')
@Controller()
@UseGuards(ProjectMembershipGuard)
export class ContentClusterController {
  constructor(
    private readonly contentClusterService: ContentClusterService,
    private readonly sseService: SseService,
  ) {}

  @Post('projects/:projectId/cluster/generate-plan')
  @RequireProjectMembership()
  @ApiOperation({
    summary: 'Generate a topic cluster plan using AI',
    description:
      'Given a topic, generates a pillar + satellite article plan with titles, outlines, and keywords.',
  })
  @ApiResponse({
    status: 200,
    description: 'Cluster plan generated successfully',
  })
  async generateClusterPlan(
    @Body() dto: GenerateClusterPlanDto,
    @Request() req: AuthenticatedRequest,
  ) {
    return this.contentClusterService.generateClusterPlan(dto, req.user.id);
  }

  @Post('projects/:projectId/cluster/generate-articles')
  @RequireProjectMembership()
  @ApiOperation({
    summary: 'Generate all articles in a cluster plan',
    description:
      'Takes the accepted cluster plan and generates all articles sequentially (pillar first). Returns a jobId for SSE streaming.',
  })
  @ApiResponse({
    status: 200,
    description: 'Article generation job created',
  })
  generateClusterArticles(
    @Body() dto: GenerateClusterArticlesDto,
    @Request() req: AuthenticatedRequest,
  ): { jobId: string } {
    const jobId = uuidv4();
    this.sseService.createChannel(jobId, req.user.id);

    void this.contentClusterService
      .generateClusterArticles(dto, req.user.id, jobId)
      .then((results) => {
        this.sseService.send(jobId, 'result', { articles: results });
        this.sseService.close(jobId);
      })
      .catch((error: unknown) => {
        const message =
          error instanceof Error
            ? error.message
            : 'Cluster article generation failed';
        this.sseService.send(jobId, 'failed', { message });
        this.sseService.close(jobId);
      });

    return { jobId };
  }

  @Get('cluster/jobs/:jobId/stream')
  @ApiOperation({ summary: 'Stream cluster generation job events' })
  @ApiResponse({ status: 200, description: 'SSE stream opened' })
  async streamClusterJob(
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
}
