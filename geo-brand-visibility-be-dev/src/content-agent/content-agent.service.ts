import { Injectable, Logger, NotFoundException } from '@nestjs/common';
import { ContentAgentRepository } from './content-agent.repository';
import { UpdateContentAgentDto } from './dto/content-agent.dto';
import { ContentAgentUpdate } from './content-agent.repository';
import { AgentExecutionQueryDto } from './dto/agent-execution-query.dto';

@Injectable()
export class ContentAgentService {
  private readonly logger = new Logger(ContentAgentService.name);

  constructor(
    private readonly contentAgentRepository: ContentAgentRepository,
  ) {}

  async seedDefaults(projectId: string): Promise<void> {
    this.logger.log(`Seeding default agents for project ${projectId}`);
    return this.contentAgentRepository.seedDefaults(projectId);
  }

  async getAgentsWithStats(projectId: string) {
    const [agents, stats, availableBlogPromptCount] = await Promise.all([
      this.contentAgentRepository.findByProjectId(projectId),
      this.contentAgentRepository.getAgentStats(projectId),
      this.contentAgentRepository.getAvailableBlogPromptCount(projectId),
    ]);

    return {
      agents,
      stats,
      availableBlogPromptCount,
    };
  }

  async updateAgent(id: string, dto: UpdateContentAgentDto) {
    const agent = await this.contentAgentRepository.findById(id);
    if (!agent) {
      throw new NotFoundException(`Content agent with ID ${id} not found`);
    }

    if (dto.isActive === true) {
      this.logger.log(
        `Activating agent ${id} and deactivating others for project ${agent.projectId}`,
      );
      await this.contentAgentRepository.deactivateAllAgents(agent.projectId);
    }

    const updateData: ContentAgentUpdate = { ...dto };

    return this.contentAgentRepository.update(id, updateData);
  }

  async getExecutionHistory(projectId: string, query: AgentExecutionQueryDto) {
    return this.contentAgentRepository.getAgentExecutions(projectId, query);
  }
}
