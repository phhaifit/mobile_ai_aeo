import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Param,
  Body,
  Request,
} from '@nestjs/common';
import { ApiOperation, ApiResponse, ApiTags } from '@nestjs/swagger';
import { PromptDTO } from '../prompt/dto/prompt.dto';
import { PromptService } from '../prompt/prompt.service';
import { ApiBearerAuth } from '@nestjs/swagger';
import { TopicService } from './topic.service';
import { TopicDTO } from './dto/topic.dto';
import { CreateTopicRequestDTO } from './dto/create-topics.dto';
import {
  UpdateTopicRequestDTO,
  UpdateTopicResponseDTO,
} from './dto/update-topic.dto';
import { DeleteTopicsDto } from './dto/delete-topics.dto';
import type { AuthenticatedRequest } from '../auth/guards/jwt-auth.guard';

@ApiTags('topics')
@Controller('topics')
@ApiBearerAuth('JWT-auth')
export class TopicController {
  constructor(
    private readonly promptService: PromptService,
    private readonly topicService: TopicService,
  ) {}

  @Post()
  @ApiOperation({ summary: 'Create multiple topics' })
  @ApiResponse({
    status: 201,
    description: 'Topics created successfully',
    type: [TopicDTO],
  })
  @ApiResponse({ status: 400, description: 'Invalid request' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 500, description: 'Internal server error' })
  async createTopics(
    @Body() data: CreateTopicRequestDTO,
    @Request() req: AuthenticatedRequest,
  ): Promise<TopicDTO[]> {
    return this.topicService.createTopics(data, req.user.id);
  }

  @Patch(':topicId')
  @ApiOperation({
    summary: 'Update topic name and monitoring status',
    description: 'Update the name and/or monitoring status of a specific topic',
  })
  @ApiResponse({
    status: 200,
    description: 'Topic name updated successfully',
    type: TopicDTO,
  })
  @ApiResponse({ status: 404, description: 'Topic not found' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 500, description: 'Internal server error' })
  async updateTopicName(
    @Param('topicId') topicId: string,
    @Body() data: UpdateTopicRequestDTO,
    @Request() req: AuthenticatedRequest,
  ): Promise<UpdateTopicResponseDTO> {
    return this.topicService.updateTopic(topicId, data, req.user.id);
  }

  @Delete('delete-many')
  @ApiOperation({
    summary: 'Bulk delete topics',
    description:
      'Soft deletes multiple topics by setting isDeleted to true. Topics are not permanently removed from the database.',
  })
  @ApiResponse({
    status: 200,
    description: 'Topics deleted successfully',
  })
  @ApiResponse({ status: 400, description: 'Invalid request' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 500, description: 'Internal server error' })
  async bulkDeleteTopics(
    @Body() data: DeleteTopicsDto,
    @Request() req: AuthenticatedRequest,
  ): Promise<void> {
    await this.topicService.deleteMany(data, req.user.id);
  }

  @Get(':topicId/prompts')
  @ApiOperation({ summary: 'Get all prompts for a specific topic' })
  @ApiResponse({
    status: 200,
    description: 'Prompts retrieved successfully',
    type: [PromptDTO],
  })
  @ApiResponse({ status: 404, description: 'Topic not found' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 500, description: 'Internal server error' })
  async getPromptsByTopicId(
    @Param('topicId') topicId: string,
    @Request() req: AuthenticatedRequest,
  ): Promise<PromptDTO[]> {
    const { data } = await this.promptService.getPromptsByTopic(
      topicId,
      req.user.id,
    );
    return data;
  }
}
