import {
  Controller,
  Get,
  Post,
  Body,
  Query,
  Patch,
  Param,
} from '@nestjs/common';
import { ProjectInvitationService } from './project-invitation.service';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
} from '@nestjs/swagger';
import { InviteMemberDto } from 'src/project-invitation/dto/invite-member.dto';
import { UserParam } from 'src/shared/decorators/user-param.decorator';
import { PaginationQueryDto } from 'src/shared/dtos/pagination-query.dto';
import { UUIDParam } from 'src/shared/decorators/uuid-param.decorator';
import { AnswerInvitationDto } from './dto/answer-invitation.dto';
import { AcceptByTokenDto } from './dto/accept-by-token.dto';
import { Public } from 'src/auth/decorators/public.decorator';

@ApiTags('project-invitations')
@Controller('project-invitations')
@ApiBearerAuth('JWT-auth')
export class ProjectInvitationController {
  constructor(
    private readonly projectInvitationService: ProjectInvitationService,
  ) {}

  @Post()
  @ApiOperation({ summary: 'Invite a member to a project' })
  @ApiResponse({
    status: 201,
    description: 'Member invited successfully',
  })
  async inviteMember(
    @Body() inviteMemberDto: InviteMemberDto,
    @UserParam('id') userId: string,
  ) {
    const { projectId, email, role } = inviteMemberDto;

    return this.projectInvitationService.inviteMember(
      projectId,
      userId,
      email,
      role,
    );
  }

  @Get()
  @ApiOperation({ summary: 'Get all invitations for a project' })
  @ApiResponse({
    status: 200,
    description: 'Project invitations retrieved successfully',
  })
  async getInvitations(
    @UserParam('id') inviteeId: string,
    @Query() query: PaginationQueryDto,
  ) {
    return this.projectInvitationService.getInvitationsByInviteeId(
      inviteeId,
      query,
    );
  }

  @Get('token/:token')
  @Public()
  @ApiOperation({ summary: 'Get invitation details by token (public)' })
  @ApiResponse({
    status: 200,
    description: 'Invitation details retrieved successfully',
  })
  async getInvitationByToken(@Param('token') token: string) {
    return this.projectInvitationService.getInvitationByToken(token);
  }

  @Post('accept-by-token')
  @ApiOperation({ summary: 'Accept an invitation using a token' })
  @ApiResponse({
    status: 200,
    description: 'Invitation accepted successfully',
  })
  async acceptByToken(
    @Body() acceptByTokenDto: AcceptByTokenDto,
    @UserParam('id') userId: string,
    @UserParam('email') userEmail: string,
  ) {
    return this.projectInvitationService.acceptByToken(
      acceptByTokenDto.token,
      userId,
      userEmail,
    );
  }

  @Patch(':invitationId')
  @ApiOperation({ summary: 'Answer an invitation' })
  @ApiResponse({
    status: 200,
    description: 'Invitation answered successfully',
  })
  async answerInvitation(
    @Body() answerInvitationDto: AnswerInvitationDto,
    @UUIDParam('invitationId') invitationId: string,
  ) {
    return this.projectInvitationService.answerInvitation(
      invitationId,
      answerInvitationDto.answer,
    );
  }
}
