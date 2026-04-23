import { Controller, Get, Post, Query, UseGuards } from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiOperation } from '@nestjs/swagger';
import { SubscriptionService } from './subscription.service';
import { ProjectMembershipGuard } from '../auth/guards/project-membership.guard';
import { RequireProjectMembership } from '../auth/decorators/require-project-membership.decorator';
import { ProjectMemberRole } from '../project-member/enum/member-role.enum';
import { UUIDParam } from '../shared/decorators/uuid-param.decorator';

@ApiTags('subscriptions')
@Controller('projects/:projectId/subscription')
@ApiBearerAuth('JWT-auth')
@UseGuards(ProjectMembershipGuard)
export class SubscriptionController {
  constructor(private readonly subscriptionService: SubscriptionService) {}

  @Get('status')
  @RequireProjectMembership()
  @ApiOperation({ summary: 'Get subscription status for a project' })
  getStatus(@UUIDParam('projectId') projectId: string) {
    return this.subscriptionService.getSubscriptionStatus(projectId);
  }

  @Get('plans')
  @RequireProjectMembership()
  @ApiOperation({ summary: 'Get available subscription plans' })
  getPlans() {
    return this.subscriptionService.getPlans();
  }

  @Get('billing-details')
  @RequireProjectMembership({ roles: [ProjectMemberRole.Admin] })
  @ApiOperation({ summary: 'Get billing details (payment methods, invoices)' })
  getBillingDetails(@UUIDParam('projectId') projectId: string) {
    return this.subscriptionService.getBillingDetails(projectId);
  }

  @Get('cost-explorer')
  @RequireProjectMembership({ roles: [ProjectMemberRole.Admin] })
  @ApiOperation({ summary: 'Get cost explorer data for content generation' })
  getCostExplorer(
    @UUIDParam('projectId') projectId: string,
    @Query('startDate') startDate: string,
    @Query('endDate') endDate: string,
  ) {
    return this.subscriptionService.getCostExplorerData(
      projectId,
      startDate,
      endDate,
    );
  }

  @Post('checkout')
  @RequireProjectMembership({ roles: [ProjectMemberRole.Admin] })
  @ApiOperation({ summary: 'Create a Stripe checkout session' })
  createCheckout(@UUIDParam('projectId') projectId: string) {
    return this.subscriptionService.createCheckoutSession(projectId);
  }

  @Post('portal')
  @RequireProjectMembership({ roles: [ProjectMemberRole.Admin] })
  @ApiOperation({ summary: 'Create a Stripe billing portal session' })
  createPortal(@UUIDParam('projectId') projectId: string) {
    return this.subscriptionService.createPortalSession(projectId);
  }
}
