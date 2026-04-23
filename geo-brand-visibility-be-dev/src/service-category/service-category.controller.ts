import {
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  ParseUUIDPipe,
  Patch,
  Post,
  Request,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiOperation,
  ApiParam,
  ApiResponse,
  ApiTags,
} from '@nestjs/swagger';
import { ServiceCategoryService } from './service-category.service';
import { ServiceCategoryResponseDto } from './dto/service-category-response.dto';
import { CreateServiceCategoryDto } from './dto/create-service-category.dto';
import { UpdateServiceCategoryDto } from './dto/update-service-category.dto';
import { type AuthenticatedRequest } from '../auth/guards/jwt-auth.guard';

@ApiTags('service-categories')
@Controller('brands/:brandId/service-categories')
@ApiBearerAuth('JWT-auth')
export class ServiceCategoryController {
  constructor(private readonly categoryService: ServiceCategoryService) {}

  @Get()
  @ApiOperation({ summary: 'List all service categories for a brand' })
  @ApiParam({ name: 'brandId', type: String })
  @ApiResponse({ status: 200, type: [ServiceCategoryResponseDto] })
  async list(
    @Param('brandId', ParseUUIDPipe) brandId: string,
    @Request() req: AuthenticatedRequest,
  ): Promise<ServiceCategoryResponseDto[]> {
    return this.categoryService.findByBrandId(brandId, req.user.id);
  }

  @Post()
  @ApiOperation({ summary: 'Create a service category' })
  @ApiParam({ name: 'brandId', type: String })
  @ApiResponse({ status: 201, type: ServiceCategoryResponseDto })
  async create(
    @Param('brandId', ParseUUIDPipe) brandId: string,
    @Body() dto: CreateServiceCategoryDto,
    @Request() req: AuthenticatedRequest,
  ): Promise<ServiceCategoryResponseDto> {
    return this.categoryService.create(brandId, dto, req.user.id);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Update a service category' })
  @ApiParam({ name: 'brandId', type: String })
  @ApiParam({ name: 'id', type: String })
  @ApiResponse({ status: 200, type: ServiceCategoryResponseDto })
  async update(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateServiceCategoryDto,
    @Request() req: AuthenticatedRequest,
  ): Promise<ServiceCategoryResponseDto> {
    return this.categoryService.update(id, dto, req.user.id);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Delete a service category' })
  @ApiParam({ name: 'brandId', type: String })
  @ApiParam({ name: 'id', type: String })
  @ApiResponse({ status: 204 })
  async delete(
    @Param('id', ParseUUIDPipe) id: string,
    @Request() req: AuthenticatedRequest,
  ): Promise<void> {
    return this.categoryService.delete(id, req.user.id);
  }
}
