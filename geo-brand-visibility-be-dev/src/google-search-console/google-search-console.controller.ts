import {
  Controller,
  Get,
  Post,
  Delete,
  Body,
  Query,
  Request,
} from '@nestjs/common';
import {
  ApiTags,
  ApiBearerAuth,
  ApiOperation,
  ApiResponse,
  ApiParam,
  ApiBody,
} from '@nestjs/swagger';
import { UUIDParam } from '../shared/decorators/uuid-param.decorator';
import type { AuthenticatedRequest } from '../auth/guards/jwt-auth.guard';
import { GscService } from './google-search-console.service';
import { ConnectGscDto } from './dto/connect-gsc.dto';
import { LinkSiteDto } from './dto/link-site.dto';
import { QueryAnalyticsDto } from './dto/query-analytics.dto';
import {
  GscSuccessDto,
  GscConnectionStatusDto,
  GscSiteDto,
  GscPropertyDto,
  GscAnalyticsSummaryDto,
  GscQueryRowDto,
  GscPageRowDto,
  GscTrendPointDto,
} from './dto/gsc-response.dto';

@ApiTags('Google Search Console')
@Controller('gsc')
@ApiBearerAuth('JWT-auth')
export class GscController {
  constructor(private readonly gscService: GscService) {}

  @Post('connect')
  @ApiOperation({
    summary: 'Connect Google Search Console via OAuth',
    description:
      'Exchanges a Google OAuth authorization code (PKCE flow) for tokens and stores the encrypted refresh token. Must be called after the user completes the Google consent screen.',
  })
  @ApiBody({ type: ConnectGscDto })
  @ApiResponse({
    status: 201,
    description: 'GSC account connected successfully',
    type: GscSuccessDto,
  })
  @ApiResponse({
    status: 400,
    description: 'Invalid OAuth code or redirect URI',
  })
  @ApiResponse({
    status: 401,
    description: 'Unauthorized — missing or invalid JWT',
  })
  async connect(
    @Request() req: AuthenticatedRequest,
    @Body() dto: ConnectGscDto,
  ) {
    await this.gscService.handleOAuthCallback(req.user.id, dto.projectId, dto);
    return { success: true };
  }

  @Get('status/:projectId')
  @ApiOperation({
    summary: 'Get GSC connection status for a project',
    description:
      'Returns whether the current project has a connected Google account, which OAuth scopes were granted, and whether the stored credential is still valid.',
  })
  @ApiParam({
    name: 'projectId',
    description: 'UUID of the project',
    example: '3fa85f64-5717-4562-b3fc-2c963f66afa6',
  })
  @ApiResponse({
    status: 200,
    description: 'Connection status retrieved successfully',
    type: GscConnectionStatusDto,
  })
  @ApiResponse({
    status: 401,
    description: 'Unauthorized — missing or invalid JWT',
  })
  async getStatus(@UUIDParam('projectId') projectId: string) {
    return this.gscService.getConnectionStatus(projectId);
  }

  @Delete('disconnect/:projectId')
  @ApiOperation({
    summary: 'Disconnect Google Search Console for a project',
    description:
      "Deletes the project's stored Google OAuth credential and its linked GSC property. The project will need to reconnect to use GSC features again.",
  })
  @ApiParam({
    name: 'projectId',
    description: 'UUID of the project',
    example: '3fa85f64-5717-4562-b3fc-2c963f66afa6',
  })
  @ApiResponse({
    status: 200,
    description: 'GSC account disconnected successfully',
    type: GscSuccessDto,
  })
  @ApiResponse({
    status: 401,
    description: 'Unauthorized — missing or invalid JWT',
  })
  async disconnect(@UUIDParam('projectId') projectId: string) {
    await this.gscService.disconnect(projectId);
    return { success: true };
  }

  @Get('sites/:projectId')
  @ApiOperation({
    summary: 'List accessible GSC properties for a project',
    description:
      "Returns all Google Search Console properties the connected Google account has access to, including the user's permission level for each.",
  })
  @ApiParam({
    name: 'projectId',
    description: 'UUID of the project',
    example: '3fa85f64-5717-4562-b3fc-2c963f66afa6',
  })
  @ApiResponse({
    status: 200,
    description: 'List of accessible GSC properties',
    type: [GscSiteDto],
  })
  @ApiResponse({
    status: 401,
    description:
      'GSC not connected, or Google token was revoked — reconnect required',
  })
  async listSites(@UUIDParam('projectId') projectId: string) {
    return this.gscService.listSites(projectId);
  }

  @Post('link')
  @ApiOperation({
    summary: 'Link a GSC property to a project',
    description:
      'Associates a Google Search Console property with a project. The property must exist in the connected Google account. Each project can only have one linked GSC property.',
  })
  @ApiBody({ type: LinkSiteDto })
  @ApiResponse({
    status: 201,
    description: 'GSC property linked to project successfully',
    type: GscPropertyDto,
  })
  @ApiResponse({
    status: 400,
    description: 'Project already has a linked GSC property — unlink first',
  })
  @ApiResponse({
    status: 404,
    description:
      'Site URL not found in connected Google Search Console account',
  })
  @ApiResponse({
    status: 401,
    description: 'GSC not connected or token expired',
  })
  async linkSite(
    @Request() req: AuthenticatedRequest,
    @Body() dto: LinkSiteDto,
  ) {
    return this.gscService.linkSite(req.user.id, dto);
  }

  @Get('link/:projectId')
  @ApiOperation({
    summary: 'Get the GSC property linked to a project',
    description:
      'Returns the Google Search Console property currently linked to the specified project, or null if no property is linked.',
  })
  @ApiParam({
    name: 'projectId',
    description: 'UUID of the project',
    example: '3fa85f64-5717-4562-b3fc-2c963f66afa6',
  })
  @ApiResponse({
    status: 200,
    description: 'Linked GSC property, or null if none',
    type: GscPropertyDto,
  })
  @ApiResponse({
    status: 401,
    description: 'Unauthorized — missing or invalid JWT',
  })
  async getLinkedProperty(@UUIDParam('projectId') projectId: string) {
    return this.gscService.getLinkedProperty(projectId);
  }

  @Delete('link/:projectId')
  @ApiOperation({
    summary: 'Unlink the GSC property from a project',
    description:
      'Removes the Google Search Console property association from the specified project. Only the user who originally connected GSC can unlink it.',
  })
  @ApiParam({
    name: 'projectId',
    description: 'UUID of the project',
    example: '3fa85f64-5717-4562-b3fc-2c963f66afa6',
  })
  @ApiResponse({
    status: 200,
    description: 'GSC property unlinked successfully',
    type: GscSuccessDto,
  })
  @ApiResponse({
    status: 400,
    description: 'Only the user who connected GSC can unlink it',
  })
  @ApiResponse({
    status: 404,
    description: 'No GSC property linked to this project',
  })
  @ApiResponse({
    status: 401,
    description: 'Unauthorized — missing or invalid JWT',
  })
  async unlinkSite(
    @Request() req: AuthenticatedRequest,
    @UUIDParam('projectId') projectId: string,
  ) {
    await this.gscService.unlinkSite(req.user.id, projectId);
    return { success: true };
  }

  @Get('analytics/:projectId')
  @ApiOperation({
    summary: 'Get aggregated search analytics summary',
    description:
      'Returns total clicks, impressions, average CTR, and average position for the linked GSC property over the specified date range.',
  })
  @ApiParam({
    name: 'projectId',
    description: 'UUID of the project with a linked GSC property',
    example: '3fa85f64-5717-4562-b3fc-2c963f66afa6',
  })
  @ApiResponse({
    status: 200,
    description: 'Aggregated search analytics for the date range',
    type: GscAnalyticsSummaryDto,
  })
  @ApiResponse({
    status: 401,
    description: 'GSC not connected or token revoked',
  })
  @ApiResponse({
    status: 404,
    description: 'No GSC property linked to this project',
  })
  async getAnalytics(
    @Request() req: AuthenticatedRequest,
    @UUIDParam('projectId') projectId: string,
    @Query() query: QueryAnalyticsDto,
  ) {
    return this.gscService.getAnalyticsSummary(
      req.user.id,
      projectId,
      query.startDate,
      query.endDate,
    );
  }

  @Get('analytics/:projectId/queries')
  @ApiOperation({
    summary: 'Get top search queries',
    description:
      'Returns the top search queries driving traffic to the linked GSC property, sorted by clicks descending. Use rowLimit to control how many rows are returned.',
  })
  @ApiParam({
    name: 'projectId',
    description: 'UUID of the project with a linked GSC property',
    example: '3fa85f64-5717-4562-b3fc-2c963f66afa6',
  })
  @ApiResponse({
    status: 200,
    description:
      'Top search queries with click, impression, CTR and position metrics',
    type: [GscQueryRowDto],
  })
  @ApiResponse({
    status: 401,
    description: 'GSC not connected or token revoked',
  })
  @ApiResponse({
    status: 404,
    description: 'No GSC property linked to this project',
  })
  async getTopQueries(
    @Request() req: AuthenticatedRequest,
    @UUIDParam('projectId') projectId: string,
    @Query() query: QueryAnalyticsDto,
  ) {
    return this.gscService.getTopQueries(
      req.user.id,
      projectId,
      query.startDate,
      query.endDate,
      query.rowLimit,
    );
  }

  @Get('analytics/:projectId/pages')
  @ApiOperation({
    summary: 'Get top performing pages',
    description:
      'Returns the top pages by clicks for the linked GSC property in the given date range. Use rowLimit to control how many rows are returned.',
  })
  @ApiParam({
    name: 'projectId',
    description: 'UUID of the project with a linked GSC property',
    example: '3fa85f64-5717-4562-b3fc-2c963f66afa6',
  })
  @ApiResponse({
    status: 200,
    description: 'Top pages with click, impression, CTR and position metrics',
    type: [GscPageRowDto],
  })
  @ApiResponse({
    status: 401,
    description: 'GSC not connected or token revoked',
  })
  @ApiResponse({
    status: 404,
    description: 'No GSC property linked to this project',
  })
  async getTopPages(
    @Request() req: AuthenticatedRequest,
    @UUIDParam('projectId') projectId: string,
    @Query() query: QueryAnalyticsDto,
  ) {
    return this.gscService.getTopPages(
      req.user.id,
      projectId,
      query.startDate,
      query.endDate,
      query.rowLimit,
    );
  }

  @Get('analytics/:projectId/trend')
  @ApiOperation({
    summary: 'Get date-by-date search analytics trend',
    description:
      'Returns daily search analytics data (clicks, impressions, CTR, position) for the linked GSC property over the specified date range. Useful for plotting performance charts.',
  })
  @ApiParam({
    name: 'projectId',
    description: 'UUID of the project with a linked GSC property',
    example: '3fa85f64-5717-4562-b3fc-2c963f66afa6',
  })
  @ApiResponse({
    status: 200,
    description: 'Daily trend data points for the date range',
    type: [GscTrendPointDto],
  })
  @ApiResponse({
    status: 401,
    description: 'GSC not connected or token revoked',
  })
  @ApiResponse({
    status: 404,
    description: 'No GSC property linked to this project',
  })
  async getDateTrend(
    @Request() req: AuthenticatedRequest,
    @UUIDParam('projectId') projectId: string,
    @Query() query: QueryAnalyticsDto,
  ) {
    return this.gscService.getDateTrend(
      req.user.id,
      projectId,
      query.startDate,
      query.endDate,
    );
  }
}
