import {
  Controller,
  Get,
  Post,
  Delete,
  Body,
  Query,
  Request,
} from '@nestjs/common';
import { ApiTags, ApiBearerAuth } from '@nestjs/swagger';
import { UUIDParam } from '../shared/decorators/uuid-param.decorator';
import type { AuthenticatedRequest } from '../auth/guards/jwt-auth.guard';
import { GaService } from './google-analytics.service';
import { ConnectGaDto } from './dto/connect-ga.dto';
import { LinkPropertyDto } from './dto/link-property.dto';
import { QueryAnalyticsDto } from './dto/query-analytics.dto';

@ApiTags('ga')
@Controller('ga')
@ApiBearerAuth('JWT-auth')
export class GaController {
  constructor(private readonly gaService: GaService) {}

  @Post('connect')
  async connect(
    @Request() req: AuthenticatedRequest,
    @Body() dto: ConnectGaDto,
  ) {
    await this.gaService.handleOAuthCallback(req.user.id, dto.projectId, dto);
    return { success: true };
  }

  @Get('status/:projectId')
  async getStatus(@UUIDParam('projectId') projectId: string) {
    return this.gaService.getConnectionStatus(projectId);
  }

  @Delete('disconnect/:projectId')
  async disconnect(@UUIDParam('projectId') projectId: string) {
    await this.gaService.disconnect(projectId);
    return { success: true };
  }

  @Get('properties/:projectId')
  async listProperties(@UUIDParam('projectId') projectId: string) {
    return this.gaService.listProperties(projectId);
  }

  @Post('link')
  async linkProperty(
    @Request() req: AuthenticatedRequest,
    @Body() dto: LinkPropertyDto,
  ) {
    return this.gaService.linkProperty(req.user.id, dto);
  }

  @Get('link/:projectId')
  async getLinkedProperty(@UUIDParam('projectId') projectId: string) {
    return this.gaService.getLinkedProperty(projectId);
  }

  @Delete('link/:projectId')
  async unlinkProperty(
    @Request() req: AuthenticatedRequest,
    @UUIDParam('projectId') projectId: string,
  ) {
    await this.gaService.unlinkProperty(req.user.id, projectId);
    return { success: true };
  }

  @Get('analytics/:projectId')
  async getAnalytics(
    @Request() req: AuthenticatedRequest,
    @UUIDParam('projectId') projectId: string,
    @Query() query: QueryAnalyticsDto,
  ) {
    return this.gaService.getAnalyticsSummary(
      req.user.id,
      projectId,
      query.startDate,
      query.endDate,
    );
  }

  @Get('analytics/:projectId/pages')
  async getTopPages(
    @Request() req: AuthenticatedRequest,
    @UUIDParam('projectId') projectId: string,
    @Query() query: QueryAnalyticsDto,
  ) {
    return this.gaService.getTopLandingPages(
      req.user.id,
      projectId,
      query.startDate,
      query.endDate,
      query.rowLimit,
    );
  }

  @Get('analytics/:projectId/trend')
  async getDateTrend(
    @Request() req: AuthenticatedRequest,
    @UUIDParam('projectId') projectId: string,
    @Query() query: QueryAnalyticsDto,
  ) {
    return this.gaService.getDateTrend(
      req.user.id,
      projectId,
      query.startDate,
      query.endDate,
    );
  }
}
