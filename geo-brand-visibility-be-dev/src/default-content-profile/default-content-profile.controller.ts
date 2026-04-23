import { Controller, Get, ParseUUIDPipe, Request, Query } from '@nestjs/common';
import {
  ApiOperation,
  ApiResponse,
  ApiQuery,
  ApiTags,
  ApiBearerAuth,
} from '@nestjs/swagger';
import { type AuthenticatedRequest } from '../auth/guards/jwt-auth.guard';
import { DefaultContentProfileService } from './default-content-profile.service';
import { ContentProfileTemplateDto } from './dto/content-profile-template.dto';

@ApiTags('default-content-profile')
@Controller()
@ApiBearerAuth('JWT-auth')
export class DefaultContentProfileController {
  constructor(
    private readonly defaultContentProfileService: DefaultContentProfileService,
  ) {}

  @Get('content-profiles/templates')
  @ApiOperation({
    summary: 'Get default writing style templates by project language',
  })
  @ApiQuery({
    name: 'language',
    description: 'language of templates',
    type: String,
  })
  @ApiResponse({
    status: 200,
    description: 'Templates retrieved successfully',
    type: [ContentProfileTemplateDto],
  })
  @ApiResponse({ status: 404, description: 'Templates not found' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getContentProfileTemplates(
    @Query('language') language: string,
    @Request() req: AuthenticatedRequest,
  ): Promise<ContentProfileTemplateDto[]> {
    return this.defaultContentProfileService.getTemplatesByProjectLanguage(
      language,
      req.user.id,
    );
  }
}
