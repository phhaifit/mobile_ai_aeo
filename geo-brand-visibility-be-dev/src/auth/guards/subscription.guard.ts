import {
  Injectable,
  CanActivate,
  ExecutionContext,
  ForbiddenException,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { IS_PUBLIC_KEY } from '../decorators/public.decorator';
import { SKIP_SUBSCRIPTION_CHECK_KEY } from '../decorators/skip-subscription-check.decorator';
import { SubscriptionRepository } from '../../subscription/subscription.repository';
import { ACTIVE_STATUSES } from '../../subscription/subscription.constants';

@Injectable()
export class SubscriptionGuard implements CanActivate {
  constructor(
    private readonly reflector: Reflector,
    private readonly subscriptionRepository: SubscriptionRepository,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const isPublic = this.reflector.getAllAndOverride<boolean>(IS_PUBLIC_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);
    if (isPublic) return true;

    const skipCheck = this.reflector.getAllAndOverride<boolean>(
      SKIP_SUBSCRIPTION_CHECK_KEY,
      [context.getHandler(), context.getClass()],
    );
    if (skipCheck) return true;

    const request = context.switchToHttp().getRequest();
    const projectId = request.params?.projectId;

    if (!projectId) return true;

    const subscription =
      await this.subscriptionRepository.findByProjectId(projectId);

    if (
      subscription &&
      ACTIVE_STATUSES.includes(
        subscription.status as (typeof ACTIVE_STATUSES)[number],
      )
    ) {
      return true;
    }

    throw new ForbiddenException({
      statusCode: 403,
      error: { code: 'SUBSCRIPTION_REQUIRED' },
      message: 'An active subscription is required to access this resource',
    });
  }
}
