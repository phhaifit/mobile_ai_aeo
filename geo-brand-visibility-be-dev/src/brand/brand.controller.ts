import {
  Controller,
  Body,
  Get,
  Patch,
  Post,
  Delete,
  Request,
  UploadedFile,
  UseInterceptors,
} from '@nestjs/common';
import { UUIDParam } from '../shared/decorators/uuid-param.decorator';
import {
  ApiOperation,
  ApiResponse,
  ApiTags,
  ApiBearerAuth,
  ApiConsumes,
} from '@nestjs/swagger';
import { BrandService } from './brand.service';
import { BrandProfileResponseDto } from './dto/brand-profile-response.dto';
import { UpdateBrandRequestDTO } from './dto/update-brand-request.dto';
import { DomainStatusResponseDto } from './dto/domain-status-response.dto';
import type { AuthenticatedRequest } from '../auth/guards/jwt-auth.guard';
import { BrandInitRequestDto } from './dto/brand-init-request.dto';
import { FileInterceptor } from '@nestjs/platform-express';
import type { Express } from 'express';

@ApiTags('brands')
@Controller('brands')
@ApiBearerAuth('JWT-auth')
export class BrandController {
  constructor(private readonly brandService: BrandService) {}

  @Post()
  @ApiOperation({ summary: 'Create brand profile' })
  @ApiResponse({
    status: 200,
    description: 'Brand profile created successfully',
    type: BrandProfileResponseDto,
  })
  @ApiResponse({
    status: 400,
    description: 'Invalid project ID or brand ID',
  })
  @ApiResponse({
    status: 500,
    description: 'Internal server error',
  })
  async createBrand(
    @Body() data: BrandInitRequestDto,
    @Request() req: AuthenticatedRequest,
  ): Promise<BrandProfileResponseDto> {
    return await this.brandService.createBrand({
      ...data,
      userId: req.user.id,
    });
  }

  @Get('/:id')
  @ApiOperation({ summary: 'Get brand profile' })
  @ApiResponse({
    status: 200,
    description: 'Brand profile retrieved successfully',
    type: BrandProfileResponseDto,
  })
  @ApiResponse({
    status: 400,
    description: 'Invalid project ID or brand ID',
  })
  @ApiResponse({
    status: 500,
    description: 'Internal server error',
  })
  async getBrand(
    @UUIDParam('id') id: string,
    @Request() req: AuthenticatedRequest,
  ): Promise<BrandProfileResponseDto> {
    return await this.brandService.findBrandById(id, req.user.id);
  }

  @Get('/:id/domain-status')
  @ApiOperation({ summary: 'Get domain verification status' })
  @ApiResponse({
    status: 200,
    description: 'Domain status retrieved successfully',
    type: DomainStatusResponseDto,
  })
  async getDomainStatus(
    @UUIDParam('id') id: string,
    @Request() req: AuthenticatedRequest,
  ): Promise<DomainStatusResponseDto> {
    return await this.brandService.getDomainStatus(id, req.user.id);
  }

  @Patch('/:id')
  @ApiOperation({ summary: 'Update brand profile' })
  @ApiResponse({
    status: 200,
    description: 'Brand profile updated successfully',
    type: BrandProfileResponseDto,
  })
  @ApiResponse({
    status: 400,
    description: 'Invalid brand ID',
  })
  @ApiResponse({
    status: 500,
    description: 'Internal server error',
  })
  async updateBrand(
    @UUIDParam('id') id: string,
    @Body() data: UpdateBrandRequestDTO,
    @Request() req: AuthenticatedRequest,
  ): Promise<BrandProfileResponseDto> {
    return await this.brandService.updateBrand(id, data, req.user.id);
  }

  @Post('/:id/logo')
  @ApiConsumes('multipart/form-data')
  @ApiOperation({ summary: 'Upload brand logo' })
  @ApiResponse({
    status: 200,
    description: 'Brand logo uploaded successfully',
    type: BrandProfileResponseDto,
  })
  @UseInterceptors(
    FileInterceptor('file', {
      limits: { fileSize: 2 * 1024 * 1024 },
    }),
  )
  async uploadLogo(
    @UUIDParam('id') id: string,
    @UploadedFile() file: Express.Multer.File,
    @Request() req: AuthenticatedRequest,
  ): Promise<BrandProfileResponseDto> {
    return await this.brandService.uploadLogo(id, file, req.user.id);
  }

  @Delete('/:id/logo')
  @ApiOperation({ summary: 'Remove brand logo' })
  @ApiResponse({
    status: 200,
    description: 'Brand logo removed successfully',
    type: BrandProfileResponseDto,
  })
  async removeLogo(
    @UUIDParam('id') id: string,
    @Request() req: AuthenticatedRequest,
  ): Promise<BrandProfileResponseDto> {
    return await this.brandService.removeLogo(id, req.user.id);
  }

  @Post('/:id/default-article-image')
  @ApiConsumes('multipart/form-data')
  @ApiOperation({ summary: 'Upload default article image' })
  @ApiResponse({
    status: 200,
    description: 'Default article image uploaded successfully',
    type: BrandProfileResponseDto,
  })
  @UseInterceptors(
    FileInterceptor('file', {
      limits: { fileSize: 2 * 1024 * 1024 },
    }),
  )
  async uploadDefaultArticleImage(
    @UUIDParam('id') id: string,
    @UploadedFile() file: Express.Multer.File,
    @Request() req: AuthenticatedRequest,
  ): Promise<BrandProfileResponseDto> {
    return await this.brandService.uploadDefaultArticleImage(
      id,
      file,
      req.user.id,
    );
  }

  @Delete('/:id/default-article-image')
  @ApiOperation({ summary: 'Remove default article image' })
  @ApiResponse({
    status: 200,
    description: 'Default article image removed successfully',
    type: BrandProfileResponseDto,
  })
  async removeDefaultArticleImage(
    @UUIDParam('id') id: string,
    @Request() req: AuthenticatedRequest,
  ): Promise<BrandProfileResponseDto> {
    return await this.brandService.removeDefaultArticleImage(id, req.user.id);
  }

  @Get('projects/:id')
  @ApiOperation({ summary: 'Get brand by project ID' })
  @ApiResponse({
    status: 200,
    description: 'Brand profile retrieved successfully',
    type: BrandProfileResponseDto,
  })
  @ApiResponse({
    status: 404,
    description: 'Brand not found for project',
  })
  async getBrandByProjectId(
    @UUIDParam('id') id: string,
  ): Promise<BrandProfileResponseDto> {
    return await this.brandService.findBrandByProjectId(id);
  }
}
