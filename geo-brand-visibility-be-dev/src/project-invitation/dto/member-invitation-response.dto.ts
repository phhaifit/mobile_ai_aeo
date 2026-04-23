import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsEnum, IsUUID, IsString } from 'class-validator';
import { ProjectMemberRole } from 'src/project-member/enum/member-role.enum';
import { InvitationStatus } from 'src/project-invitation/enum/invitation-status.enum';

export class MemberInvitationResponseDto {
  @ApiProperty({ example: '123e4567-e89b-12d3-a456-426614174000' })
  @IsUUID()
  @IsNotEmpty()
  id: string;

  @ApiProperty({ example: 'Project Name' })
  @IsString()
  @IsNotEmpty()
  projectName: string;

  @ApiProperty({ example: 'Inviter Name' })
  @IsString()
  @IsNotEmpty()
  inviterName: string;

  @ApiProperty({
    enum: [ProjectMemberRole.Admin, ProjectMemberRole.Member],
    default: ProjectMemberRole.Member,
  })
  @IsEnum([ProjectMemberRole.Admin, ProjectMemberRole.Member])
  role: ProjectMemberRole;

  @ApiProperty({ required: false })
  @IsEnum(InvitationStatus)
  status: InvitationStatus;

  @ApiProperty({ required: false })
  createdAt: string;

  @ApiProperty({ required: false })
  expiresAt: string;
}
