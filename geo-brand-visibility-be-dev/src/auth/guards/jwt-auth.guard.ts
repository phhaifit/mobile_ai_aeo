import {
  Injectable,
  CanActivate,
  ExecutionContext,
  UnauthorizedException,
  Logger,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { TokenService } from '../../token/token.service';
import { UserRepository } from '../../user/user.repository';

interface RequestWithHeaders {
  headers: {
    authorization?: string;
  };
}

export interface AuthenticatedRequest extends RequestWithHeaders {
  user: {
    id: string;
    email: string;
  };
}

@Injectable()
export class JwtAuthGuard implements CanActivate {
  private readonly logger = new Logger(JwtAuthGuard.name);

  constructor(
    private readonly tokenService: TokenService,
    private readonly reflector: Reflector,
    private readonly userRepository: UserRepository,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const isPublic = this.reflector.getAllAndOverride<boolean>('isPublic', [
      context.getHandler(),
      context.getClass(),
    ]);

    if (isPublic) {
      return true;
    }

    const request = context.switchToHttp().getRequest<RequestWithHeaders>();
    const token = this.extractToken(request);

    if (!token) {
      this.logger.warn('No JWT token provided in request');
      throw new UnauthorizedException('Access token is required');
    }

    try {
      const payload = await this.tokenService.validateToken(token);

      const user = await this.userRepository.findById(payload.sub);
      if (!user) {
        throw new UnauthorizedException('User not found');
      }

      request['user'] = {
        id: payload.sub,
        email: payload.email,
      };

      return true;
    } catch (error) {
      const errorMessage =
        error instanceof Error ? error.message : 'Unknown error';
      this.logger.warn(`Invalid JWT token: ${errorMessage}`);
      throw new UnauthorizedException('Invalid or expired access token');
    }
  }

  private extractToken(request: RequestWithHeaders): string | undefined {
    const [type, token] = request.headers?.authorization?.split(' ') ?? [];
    return type === 'Bearer' ? token : undefined;
  }
}
