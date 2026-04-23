import { ApiProperty } from '@nestjs/swagger';
import { IsEmail, IsNotEmpty, IsEnum, IsUUID } from 'class-validator';
import { ProjectMemberRole } from 'src/project-member/enum/member-role.enum';

export class InviteMemberDto {
  @ApiProperty({ example: '123e4567-e89b-12d3-a456-426614174000' })
  @IsUUID()
  @IsNotEmpty()
  projectId: string;

  @ApiProperty({ example: 'user@example.com' })
  @IsEmail()
  @IsNotEmpty()
  email: string;

  @ApiProperty({
    enum: [ProjectMemberRole.Admin, ProjectMemberRole.Member],
    default: ProjectMemberRole.Member,
  })
  @IsEnum([ProjectMemberRole.Admin, ProjectMemberRole.Member])
  role: ProjectMemberRole;
}
