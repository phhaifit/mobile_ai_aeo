import { ApiProperty } from '@nestjs/swagger';
import { IsEmail, IsEnum, IsUUID } from 'class-validator';
import { ProjectMemberRole } from '../enum/member-role.enum';

export class UpdateMemberRoleDto {
  @ApiProperty({ enum: [ProjectMemberRole.Admin, ProjectMemberRole.Member] })
  @IsEnum(ProjectMemberRole)
  role: ProjectMemberRole;
}

export class ProjectMemberResponseDto {
  @ApiProperty({ required: false })
  @IsUUID()
  id: string;

  @ApiProperty({ required: false })
  fullname: string;

  @ApiProperty({ required: false })
  @IsEnum(ProjectMemberRole)
  role: ProjectMemberRole;

  @ApiProperty({ required: false })
  @IsEmail()
  email: string;

  @ApiProperty({ required: false })
  createdAt: string;

  @ApiProperty({ required: false })
  updatedAt: string;
}
