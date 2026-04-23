import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Param,
  Body,
  Query,
  Request,
  Res,
  UseGuards,
  NotFoundException,
  Logger,
} from '@nestjs/common';
import {
  ApiOperation,
  ApiResponse,
  ApiTags,
  ApiBearerAuth,
  ApiQuery,
  ApiParam,
} from '@nestjs/swagger';
import type { Response } from 'express';
import { type AuthenticatedRequest } from 'src/auth/guards/jwt-auth.guard';
import { ProjectMembershipGuard } from '../auth/guards/project-membership.guard';
import { RequireProjectMembership } from '../auth/decorators/require-project-membership.decorator';
import { Public } from 'src/auth/decorators/public.decorator';
import { SocialService } from './social.service';
import { SocialPlatform } from './enums';
import {
  SaveSocialAccountsDto,
  ConnectTokenAccountDto,
  ConnectWebhookAccountDto,
  UpdateSocialAccountDto,
  SocialAccountResponseDto,
} from './dto/social-account.dto';
import { CreateSocialPostDto } from './dto/social-post.dto';
import { ConfigService } from '@nestjs/config';

@ApiTags('social')
@Controller()
@ApiBearerAuth('JWT-auth')
@UseGuards(ProjectMembershipGuard)
export class SocialController {
  private readonly logger = new Logger(SocialController.name);

  constructor(
    private readonly socialService: SocialService,
    private readonly configService: ConfigService,
  ) {}

  // ============================================================
  // Platform discovery
  // ============================================================

  @Get('social/platforms')
  @ApiOperation({
    summary: 'Get all available social platforms and their connection configs',
  })
  @ApiResponse({ status: 200, description: 'List of platforms' })
  getAvailablePlatforms() {
    return this.socialService.getAvailablePlatforms();
  }

  // ============================================================
  // OAuth flow
  // ============================================================

  @Get('projects/:projectId/social/connect/:platform')
  @RequireProjectMembership()
  @ApiOperation({ summary: 'Get OAuth connect URL for a platform' })
  @ApiParam({ name: 'platform', enum: SocialPlatform })
  @ApiResponse({ status: 200, description: 'OAuth connect URL' })
  getConnectUrl(
    @Param('projectId') projectId: string,
    @Param('platform') platform: SocialPlatform,
    @Request() req: AuthenticatedRequest,
  ) {
    const connectUrl = this.socialService.getConnectUrl(
      platform,
      projectId,
      req.user.id,
    );
    return { connectUrl };
  }

  @Public()
  @Get('social/callback/:platform')
  @ApiOperation({
    summary: 'OAuth callback endpoint (public, called by platform)',
  })
  @ApiParam({ name: 'platform', enum: SocialPlatform })
  async handleOAuthCallback(
    @Param('platform') platform: SocialPlatform,
    @Query('code') code: string,
    @Query('state') state: string,
    @Res() res: Response,
  ) {
    try {
      const { channels, state: stateData } =
        await this.socialService.handleOAuthCallback(platform, code, state);

      // Redirect to frontend with channels data
      const frontendUrl = this.configService.get<string>('APP_URL');
      const channelsParam = encodeURIComponent(JSON.stringify(channels));
      const redirectUrl =
        `${frontendUrl}/social/callback?` +
        `platform=${platform}` +
        `&projectId=${stateData.projectId}` +
        `&channels=${channelsParam}`;

      return res.redirect(redirectUrl);
    } catch (error) {
      const frontendUrl = this.configService.get<string>('APP_URL');
      return res.redirect(
        `${frontendUrl}/social/callback?error=${encodeURIComponent(error.message)}`,
      );
    }
  }

  // ============================================================
  // Account management
  // ============================================================

  @Post('projects/:projectId/social/accounts/oauth')
  @RequireProjectMembership()
  @ApiOperation({
    summary: 'Save OAuth-connected accounts (after user selects pages)',
  })
  @ApiResponse({
    status: 201,
    description: 'Accounts saved',
    type: [SocialAccountResponseDto],
  })
  async saveOAuthAccounts(
    @Param('projectId') projectId: string,
    @Body() dto: SaveSocialAccountsDto,
    @Request() req: AuthenticatedRequest,
  ) {
    return this.socialService.saveOAuthAccounts(projectId, req.user.id, dto);
  }

  @Post('projects/:projectId/social/accounts/token')
  @RequireProjectMembership()
  @ApiOperation({
    summary: 'Connect a token/bot-based account (Telegram, Zalo OA, etc.)',
  })
  @ApiResponse({
    status: 201,
    description: 'Account connected',
    type: SocialAccountResponseDto,
  })
  async connectTokenAccount(
    @Param('projectId') projectId: string,
    @Body() dto: ConnectTokenAccountDto,
    @Request() req: AuthenticatedRequest,
  ) {
    return this.socialService.saveDirectAccount(
      projectId,
      req.user.id,
      dto.platform,
      dto.platform, // accountName derived from validation
      dto.credentials,
    );
  }

  @Post('projects/:projectId/social/accounts/webhook')
  @RequireProjectMembership()
  @ApiOperation({ summary: 'Connect a webhook-based account (Discord, Slack)' })
  @ApiResponse({
    status: 201,
    description: 'Account connected',
    type: SocialAccountResponseDto,
  })
  async connectWebhookAccount(
    @Param('projectId') projectId: string,
    @Body() dto: ConnectWebhookAccountDto,
    @Request() req: AuthenticatedRequest,
  ) {
    return this.socialService.saveDirectAccount(
      projectId,
      req.user.id,
      dto.platform,
      dto.accountName,
      dto.credentials,
    );
  }

  @Get('projects/:projectId/social/accounts')
  @RequireProjectMembership()
  @ApiOperation({ summary: 'List all connected social accounts for a project' })
  @ApiResponse({
    status: 200,
    description: 'List of connected accounts',
    type: [SocialAccountResponseDto],
  })
  async getAccounts(@Param('projectId') projectId: string) {
    return this.socialService.getAccountsByProject(projectId);
  }

  @Get('projects/:projectId/social/accounts/:accountId/queue')
  @RequireProjectMembership()
  @ApiOperation({ summary: 'Get publishing queue status for a social account' })
  @ApiResponse({
    status: 200,
    description: 'Queue status with rate limit info',
  })
  async getAccountQueueStatus(@Param('accountId') accountId: string) {
    return this.socialService.getAccountQueueStatus(accountId);
  }

  @Get('projects/:projectId/social/accounts/:accountId/post-stats')
  @RequireProjectMembership()
  @ApiOperation({
    summary: 'Get daily post statistics for a social account',
  })
  @ApiResponse({
    status: 200,
    description: 'Post stats with rate limit info',
  })
  async getAccountPostStats(@Param('accountId') accountId: string) {
    return this.socialService.getAccountPostStats(accountId);
  }

  @Get('projects/:projectId/social/accounts/:accountId/scheduled-slots')
  @RequireProjectMembership()
  @ApiOperation({
    summary: 'Get upcoming scheduled post slots for a social account',
  })
  @ApiResponse({
    status: 200,
    description: 'List of scheduled post times',
  })
  async getAccountScheduledSlots(@Param('accountId') accountId: string) {
    return this.socialService.getAccountScheduledSlots(accountId);
  }

  @Patch('social/accounts/:accountId')
  @ApiOperation({
    summary: 'Update a social account (e.g. toggle autoPublish)',
  })
  @ApiResponse({
    status: 200,
    description: 'Account updated',
    type: SocialAccountResponseDto,
  })
  async updateAccount(
    @Param('accountId') accountId: string,
    @Body() dto: UpdateSocialAccountDto,
    @Request() req: AuthenticatedRequest,
  ) {
    return this.socialService.updateAccount(accountId, req.user.id, dto);
  }

  @Delete('social/accounts/:accountId')
  @ApiOperation({ summary: 'Disconnect a social account' })
  @ApiResponse({ status: 200, description: 'Account disconnected' })
  async disconnectAccount(
    @Param('accountId') accountId: string,
    @Request() req: AuthenticatedRequest,
  ) {
    await this.socialService.disconnectAccount(accountId, req.user.id);
    return { success: true };
  }

  // ============================================================
  // Posts
  // ============================================================

  @Post('projects/:projectId/social/posts')
  @RequireProjectMembership()
  @ApiOperation({ summary: 'Create and publish/schedule a social post' })
  @ApiResponse({ status: 201, description: 'Post created' })
  async createPost(
    @Param('projectId') projectId: string,
    @Body() dto: CreateSocialPostDto,
    @Request() req: AuthenticatedRequest,
  ) {
    this.logger.debug(
      `[createPost] message.length=${dto.message?.length} title=${dto.title ? `"${dto.title.substring(0, 50)}"` : 'none'} accounts=${dto.socialAccountIds?.length}`,
    );
    return this.socialService.createPost(projectId, req.user.id, dto);
  }

  @Get('projects/:projectId/social/posts')
  @RequireProjectMembership()
  @ApiOperation({ summary: 'List social posts for a project' })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  @ApiQuery({ name: 'offset', required: false, type: Number })
  async getPosts(
    @Param('projectId') projectId: string,
    @Query('limit') limit?: number,
    @Query('offset') offset?: number,
  ) {
    return this.socialService.getPostsByProject(
      projectId,
      limit ? Number(limit) : undefined,
      offset ? Number(offset) : undefined,
    );
  }

  @Get('social/posts/:postId')
  @ApiOperation({ summary: 'Get a social post by ID with target statuses' })
  @ApiResponse({ status: 200, description: 'Post details' })
  async getPost(@Param('postId') postId: string) {
    return this.socialService.getPostById(postId);
  }

  @Delete('social/posts/:postId')
  @ApiOperation({ summary: 'Delete a social post (only if not yet published)' })
  @ApiResponse({ status: 200, description: 'Post deleted' })
  async deletePost(
    @Param('postId') postId: string,
    @Request() req: AuthenticatedRequest,
  ) {
    await this.socialService.deletePost(postId, req.user.id);
    return { success: true };
  }
}
