import { Controller, Get } from '@nestjs/common';
import { ApiOperation, ApiResponse, ApiTags } from '@nestjs/swagger';
import { ModelService } from './model.service';
import { ModelDto } from './dto/model.dto';
import { ApiBearerAuth } from '@nestjs/swagger';

@ApiTags('models')
@Controller('models')
@ApiBearerAuth('JWT-auth')
export class ModelController {
  constructor(private readonly modelService: ModelService) {}

  @Get()
  @ApiOperation({ summary: 'Get all models' })
  @ApiResponse({
    status: 200,
    description: 'List of all models',
    type: [ModelDto],
  })
  @ApiResponse({ status: 404, description: 'Models not found' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 500, description: 'Internal server error' })
  async getAllModels(): Promise<ModelDto[]> {
    return this.modelService.getAllModels();
  }
}
