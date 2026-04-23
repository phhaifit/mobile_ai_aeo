import { Controller, Get, Patch, Param, Body, Request } from '@nestjs/common';
import {
  ApiOperation,
  ApiResponse,
  ApiTags,
  ApiBearerAuth,
} from '@nestjs/swagger';
import { ContentInsightService } from './content-insight.service';
import { UpdateContentInsightDto } from './dto/update-content-insight.dto';
import { ContentInsightResponseDto } from './dto/content-insight-response.dto';
import type { AuthenticatedRequest } from '../auth/guards/jwt-auth.guard';
import { UUIDParam } from '../shared/decorators/uuid-param.decorator';

@ApiTags('content-insights')
@Controller()
@ApiBearerAuth('JWT-auth')
export class ContentInsightController {
  constructor(private readonly contentInsightService: ContentInsightService) {}

  @Get('contents/:contentId/content-insights')
  @ApiOperation({
    summary: 'Get all insights for a content',
    description: 'Retrieve all insights associated with a specific content',
  })
  @ApiResponse({
    status: 200,
    description: 'Content insights retrieved successfully',
    type: [ContentInsightResponseDto],
  })
  @ApiResponse({ status: 404, description: 'Content not found' })
  async findByContentId(
    @UUIDParam('contentId') contentId: string,
    @Request() req: AuthenticatedRequest,
  ): Promise<ContentInsightResponseDto[]> {
    return this.contentInsightService.findByContentId(contentId, req.user.id);
  }

  @Patch('content-insights/:id')
  @ApiOperation({
    summary: 'Update a content insight',
    description: 'Update an existing content insight',
  })
  @ApiResponse({
    status: 200,
    description: 'Content insight updated successfully',
    type: ContentInsightResponseDto,
  })
  @ApiResponse({ status: 404, description: 'Content insight not found' })
  async update(
    @UUIDParam('id') id: string,
    @Body() dto: UpdateContentInsightDto,
    @Request() req: AuthenticatedRequest,
  ): Promise<ContentInsightResponseDto> {
    return this.contentInsightService.update(id, dto, req.user.id);
  }
}
