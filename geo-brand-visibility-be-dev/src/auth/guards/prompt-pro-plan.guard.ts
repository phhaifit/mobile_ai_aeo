import {
  CanActivate,
  ExecutionContext,
  ForbiddenException,
  Injectable,
} from '@nestjs/common';
import { ACTIVE_STATUSES } from '../../subscription/subscription.constants';
import { SubscriptionRepository } from '../../subscription/subscription.repository';
import { PromptRepository } from '../../prompt/prompt.repository';

@Injectable()
export class PromptProPlanGuard implements CanActivate {
  constructor(
    private readonly promptRepository: PromptRepository,
    private readonly subscriptionRepository: SubscriptionRepository,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();

    const promptId = request.params?.promptId as string | undefined;
    const userId = request.user?.id as string | undefined;

    if (!promptId || !userId) {
      return true;
    }

    const projectId = await this.promptRepository.getProjectIdByPromptId(
      promptId,
      userId,
    );

    if (!projectId) {
      return true;
    }

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
