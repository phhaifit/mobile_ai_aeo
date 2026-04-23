import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Body,
  Param,
  UseGuards,
  Request,
} from '@nestjs/common';
import { KeywordService } from './keyword.service';
import { KeywordDTO } from './dto/keyword.dto';
import { UpdateKeywordRequestDTO } from './dto/update-keyword.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import type { AuthenticatedRequest } from '../auth/guards/jwt-auth.guard';
import { SuggestKeywordRequestDTO } from './dto/suggest-keyword-request.dto';

@Controller()
@UseGuards(JwtAuthGuard)
export class KeywordController {
  constructor(private readonly keywordService: KeywordService) {}

  @Get('topics/:topicId/keywords')
  async getKeywordsByTopic(
    @Param('topicId') topicId: string,
  ): Promise<KeywordDTO[]> {
    return this.keywordService.getKeywordsByTopic(topicId);
  }

  @Get('projects/:projectId/keywords')
  async getKeywordsByProject(
    @Param('projectId') projectId: string,
  ): Promise<KeywordDTO[]> {
    return this.keywordService.getKeywordsByProject(projectId);
  }

  @Post('topics/:topicId/keywords')
  async createKeywords(
    @Param('topicId') topicId: string,
    @Body() dto: { keywords: string[] },
  ): Promise<KeywordDTO[]> {
    return this.keywordService.createKeywords(topicId, dto.keywords);
  }

  @Get('projects/:projectId/keywords/get-or-generate')
  async getOrGenerateKeywords(
    @Param('projectId') projectId: string,
    @Request() req: AuthenticatedRequest,
  ): Promise<{
    data: {
      topicId: string;
      topicName: string;
      keywords: { id: string; keyword: string }[];
    }[];
  }> {
    const data = await this.keywordService.getOrGenerateKeywords(
      projectId,
      req.user.id,
    );
    return { data };
  }

  @Post('keywords/suggest')
  async suggestKeywords(
    @Body() dto: SuggestKeywordRequestDTO,
    @Request() req: AuthenticatedRequest,
  ): Promise<{ data: { keyword: string }[] }> {
    const data = await this.keywordService.suggestKeywords(
      req.user.id,
      dto.keywords,
      dto.projectId,
      dto.topicId,
    );
    return { data };
  }

  @Patch('keywords/:keywordId')
  async updateKeyword(
    @Param('keywordId') keywordId: string,
    @Body() dto: UpdateKeywordRequestDTO,
  ): Promise<KeywordDTO> {
    return this.keywordService.updateKeyword(keywordId, dto.keyword);
  }

  @Delete('keywords/:keywordId')
  async deleteKeyword(@Param('keywordId') keywordId: string): Promise<void> {
    return this.keywordService.deleteKeyword(keywordId);
  }
}
