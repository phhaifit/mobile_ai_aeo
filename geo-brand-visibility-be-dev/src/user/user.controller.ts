import {
  Controller,
  Get,
  Patch,
  Body,
  Request,
  HttpCode,
} from '@nestjs/common';
import { UserService } from './user.service';
import type { AuthenticatedRequest } from '../auth/guards/jwt-auth.guard';
import { UserProfileResponseDTO } from './dto/user-profile-response.dto';
import {
  ApiBearerAuth,
  ApiOperation,
  ApiResponse,
  ApiTags,
} from '@nestjs/swagger';
import { IsBoolean } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

class UpdateUserMeDto {
  @ApiProperty({ description: 'Mark product tour as seen' })
  @IsBoolean()
  hasSeenTour: boolean;
}

@ApiTags('user')
@Controller('user')
@ApiBearerAuth('JWT-auth')
export class UserController {
  constructor(private readonly userService: UserService) {}

  @Get('/')
  @ApiOperation({ summary: 'Get user profile' })
  @ApiResponse({
    status: 200,
    description: 'User profile retrieved successfully',
    type: UserProfileResponseDTO,
  })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getProfile(
    @Request() req: AuthenticatedRequest,
  ): Promise<UserProfileResponseDTO> {
    return this.userService.getUserProfile(req.user.id);
  }

  @Patch('/me')
  @HttpCode(204)
  @ApiOperation({ summary: 'Update current user settings' })
  @ApiResponse({ status: 204, description: 'Updated' })
  async updateMe(
    @Request() req: AuthenticatedRequest,
    @Body() dto: UpdateUserMeDto,
  ): Promise<void> {
    if (dto.hasSeenTour) {
      await this.userService.markTourSeen(req.user.id);
    }
  }
}
