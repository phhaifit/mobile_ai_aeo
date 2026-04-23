import { Module } from '@nestjs/common';
import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';
import { UserModule } from '../user/user.module';
import { TokenModule } from '../token/token.module';
import { GoogleModule } from '../google/google.module';
import { ProjectMemberModule } from '../project-member/project-member.module';
import { ProjectMembershipGuard } from './guards/project-membership.guard';

@Module({
  imports: [TokenModule, GoogleModule, UserModule, ProjectMemberModule],
  controllers: [AuthController],
  providers: [AuthService, ProjectMembershipGuard],
  exports: [],
})
export class AuthModule {}
