import {
  BadRequestException,
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Body,
  Param,
  ParseUUIDPipe,
  HttpCode,
  HttpStatus,
  Request,
  UploadedFile,
  UseInterceptors,
} from '@nestjs/common';
import {
  ApiOperation,
  ApiResponse,
  ApiTags,
  ApiBearerAuth,
  ApiParam,
  ApiConsumes,
  ApiBody,
} from '@nestjs/swagger';
import { FileInterceptor } from '@nestjs/platform-express';
import { ServiceService } from './service.service';
import {
  ImportServicesResponseDto,
  ServiceResponseDto,
} from './dto/service-response.dto';
import { CreateServiceDto } from './dto/create-service.dto';
import { UpdateServiceDto } from './dto/update-service.dto';
import { type AuthenticatedRequest } from '../auth/guards/jwt-auth.guard';

@ApiTags('services')
@Controller('brands/:brandId/services')
@ApiBearerAuth('JWT-auth')
export class ServiceController {
  constructor(private readonly serviceService: ServiceService) {}

  @Get()
  @ApiOperation({ summary: 'List all services/products for a brand' })
  @ApiParam({ name: 'brandId', description: 'Brand ID', type: String })
  @ApiResponse({
    status: 200,
    description: 'Services retrieved successfully',
    type: [ServiceResponseDto],
  })
  async list(
    @Param('brandId', ParseUUIDPipe) brandId: string,
    @Request() req: AuthenticatedRequest,
  ): Promise<ServiceResponseDto[]> {
    return this.serviceService.findByBrandId(brandId, req.user.id);
  }

  @Post()
  @ApiOperation({ summary: 'Create a service/product for a brand' })
  @ApiParam({ name: 'brandId', description: 'Brand ID', type: String })
  @ApiResponse({
    status: 201,
    description: 'Service created successfully',
    type: ServiceResponseDto,
  })
  @ApiResponse({ status: 400, description: 'Invalid input data' })
  @ApiResponse({ status: 404, description: 'Brand not found' })
  async create(
    @Param('brandId', ParseUUIDPipe) brandId: string,
    @Body() dto: CreateServiceDto,
    @Request() req: AuthenticatedRequest,
  ): Promise<ServiceResponseDto> {
    return this.serviceService.create(brandId, dto, req.user.id);
  }

  @Post('import')
  @ApiOperation({ summary: 'Import services/products from a CSV file' })
  @ApiParam({ name: 'brandId', description: 'Brand ID', type: String })
  @ApiConsumes('multipart/form-data')
  @ApiBody({
    description: 'CSV file with columns: name, description, price, category',
    schema: {
      type: 'object',
      properties: {
        file: { type: 'string', format: 'binary' },
      },
    },
  })
  @ApiResponse({
    status: 200,
    description: 'CSV imported successfully',
    type: ImportServicesResponseDto,
  })
  @ApiResponse({ status: 400, description: 'Invalid file' })
  @ApiResponse({ status: 404, description: 'Brand not found' })
  @UseInterceptors(
    FileInterceptor('file', {
      limits: { fileSize: 1 * 1024 * 1024 },
    }),
  )
  async importCsv(
    @Param('brandId', ParseUUIDPipe) brandId: string,
    @UploadedFile() file: Express.Multer.File,
    @Request() req: AuthenticatedRequest,
  ): Promise<ImportServicesResponseDto> {
    if (!file) {
      throw new BadRequestException('CSV file is required');
    }
    return this.serviceService.importFromCsv(brandId, file, req.user.id);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Update a service/product' })
  @ApiParam({ name: 'brandId', description: 'Brand ID', type: String })
  @ApiParam({ name: 'id', description: 'Service ID', type: String })
  @ApiResponse({
    status: 200,
    description: 'Service updated successfully',
    type: ServiceResponseDto,
  })
  @ApiResponse({ status: 400, description: 'Invalid input data' })
  @ApiResponse({ status: 404, description: 'Service not found' })
  async update(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateServiceDto,
    @Request() req: AuthenticatedRequest,
  ): Promise<ServiceResponseDto> {
    return this.serviceService.update(id, dto, req.user.id);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Delete a service/product' })
  @ApiParam({ name: 'brandId', description: 'Brand ID', type: String })
  @ApiParam({ name: 'id', description: 'Service ID', type: String })
  @ApiResponse({ status: 204, description: 'Service deleted successfully' })
  @ApiResponse({ status: 404, description: 'Service not found' })
  async delete(
    @Param('id', ParseUUIDPipe) id: string,
    @Request() req: AuthenticatedRequest,
  ): Promise<void> {
    return this.serviceService.delete(id, req.user.id);
  }
}
