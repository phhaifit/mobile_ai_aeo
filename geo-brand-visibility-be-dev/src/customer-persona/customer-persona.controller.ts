import {
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
} from '@nestjs/common';
import {
  ApiOperation,
  ApiResponse,
  ApiTags,
  ApiBearerAuth,
  ApiParam,
} from '@nestjs/swagger';
import { CustomerPersonaService } from './customer-persona.service';
import { CustomerPersonaResponseDto } from './dto/customer-persona-response.dto';
import { CreateCustomerPersonaDto } from './dto/create-customer-persona.dto';
import { UpdateCustomerPersonaDto } from './dto/update-customer-persona.dto';
import { type AuthenticatedRequest } from '../auth/guards/jwt-auth.guard';

@ApiTags('customer-personas')
@Controller('brands/:brandId/customer-personas')
@ApiBearerAuth('JWT-auth')
export class CustomerPersonaController {
  constructor(
    private readonly customerPersonaService: CustomerPersonaService,
  ) {}

  @Get()
  @ApiOperation({ summary: 'List all customer personas for a brand' })
  @ApiParam({ name: 'brandId', description: 'Brand ID', type: String })
  @ApiResponse({
    status: 200,
    description: 'Customer personas retrieved successfully',
    type: [CustomerPersonaResponseDto],
  })
  async list(
    @Param('brandId', ParseUUIDPipe) brandId: string,
    @Request() req: AuthenticatedRequest,
  ): Promise<CustomerPersonaResponseDto[]> {
    return this.customerPersonaService.findByBrandId(brandId, req.user.id);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get a customer persona by ID' })
  @ApiParam({ name: 'brandId', description: 'Brand ID', type: String })
  @ApiParam({ name: 'id', description: 'Persona ID', type: String })
  @ApiResponse({
    status: 200,
    description: 'Customer persona retrieved successfully',
    type: CustomerPersonaResponseDto,
  })
  @ApiResponse({ status: 404, description: 'Customer persona not found' })
  async findById(
    @Param('id', ParseUUIDPipe) id: string,
    @Request() req: AuthenticatedRequest,
  ): Promise<CustomerPersonaResponseDto> {
    return this.customerPersonaService.findById(id, req.user.id);
  }

  @Post('generate')
  @ApiOperation({
    summary: 'AI-generate buyer personas from brand information',
  })
  @ApiParam({ name: 'brandId', description: 'Brand ID', type: String })
  @ApiResponse({
    status: 201,
    description: 'Personas generated successfully',
    type: [CreateCustomerPersonaDto],
  })
  @ApiResponse({ status: 404, description: 'Brand not found' })
  async generate(
    @Param('brandId', ParseUUIDPipe) brandId: string,
    @Body() body: { additionalContext?: string },
    @Request() req: AuthenticatedRequest,
  ): Promise<CreateCustomerPersonaDto[]> {
    return this.customerPersonaService.generatePersonas(
      brandId,
      req.user.id,
      body?.additionalContext,
    );
  }

  @Post()
  @ApiOperation({ summary: 'Create a customer persona for a brand' })
  @ApiParam({ name: 'brandId', description: 'Brand ID', type: String })
  @ApiResponse({
    status: 201,
    description: 'Customer persona created successfully',
    type: CustomerPersonaResponseDto,
  })
  @ApiResponse({ status: 400, description: 'Invalid input data' })
  @ApiResponse({ status: 404, description: 'Brand not found' })
  async create(
    @Param('brandId', ParseUUIDPipe) brandId: string,
    @Body() dto: CreateCustomerPersonaDto,
    @Request() req: AuthenticatedRequest,
  ): Promise<CustomerPersonaResponseDto> {
    return this.customerPersonaService.create(brandId, dto, req.user.id);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Update a customer persona' })
  @ApiParam({ name: 'brandId', description: 'Brand ID', type: String })
  @ApiParam({ name: 'id', description: 'Persona ID', type: String })
  @ApiResponse({
    status: 200,
    description: 'Customer persona updated successfully',
    type: CustomerPersonaResponseDto,
  })
  @ApiResponse({ status: 400, description: 'Invalid input data' })
  @ApiResponse({ status: 404, description: 'Customer persona not found' })
  async update(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateCustomerPersonaDto,
    @Request() req: AuthenticatedRequest,
  ): Promise<CustomerPersonaResponseDto> {
    return this.customerPersonaService.update(id, dto, req.user.id);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Delete a customer persona' })
  @ApiParam({ name: 'brandId', description: 'Brand ID', type: String })
  @ApiParam({ name: 'id', description: 'Persona ID', type: String })
  @ApiResponse({
    status: 204,
    description: 'Customer persona deleted successfully',
  })
  @ApiResponse({ status: 404, description: 'Customer persona not found' })
  async delete(
    @Param('id', ParseUUIDPipe) id: string,
    @Request() req: AuthenticatedRequest,
  ): Promise<void> {
    return this.customerPersonaService.delete(id, req.user.id);
  }
}
