import {
  Controller,
  Get,
  Param,
  Body,
  Patch,
  UseGuards,
  Query,
} from '@nestjs/common';
import { ApiOperation, ApiTags, ApiBearerAuth } from '@nestjs/swagger';
import { ContentAgentService } from './content-agent.service';
import { ProjectMembershipGuard } from '../auth/guards/project-membership.guard';
import { RequireProjectMembership } from '../auth/decorators/require-project-membership.decorator';
import { UpdateContentAgentDto } from './dto/content-agent.dto';
import { AgentExecutionQueryDto } from './dto/agent-execution-query.dto';

@ApiTags('content-agents')
@ApiBearerAuth('JWT-auth')
@UseGuards(ProjectMembershipGuard)
@Controller('projects/:projectId/content-agents')
export class ProjectContentAgentController {
  constructor(private readonly contentAgentService: ContentAgentService) {}

  @Get()
  @RequireProjectMembership()
  @ApiOperation({ summary: 'Get all content agents and stats for a project' })
  async getAgentsByProject(@Param('projectId') projectId: string) {
    return this.contentAgentService.getAgentsWithStats(projectId);
  }

  @Get('executions')
  @RequireProjectMembership()
  @ApiOperation({ summary: 'Get agent execution history for a project' })
  async getExecutionsByProject(
    @Param('projectId') projectId: string,
    @Query() query: AgentExecutionQueryDto,
  ) {
    return this.contentAgentService.getExecutionHistory(projectId, query);
  }
}

@ApiTags('content-agents')
@ApiBearerAuth('JWT-auth')
@UseGuards(ProjectMembershipGuard)
@Controller('content-agents')
export class ContentAgentController {
  constructor(private readonly contentAgentService: ContentAgentService) {}

  @Patch(':id')
  @ApiOperation({ summary: 'Update an agent (isActive or profile)' })
  async updateAgent(
    @Param('id') id: string,
    @Body() updateDto: UpdateContentAgentDto,
  ) {
    return this.contentAgentService.updateAgent(id, updateDto);
  }
}
