export class SubscriptionStatusResponseDto {
  status: 'active' | 'past_due' | 'canceled' | 'none';
  canAccessFeatures: boolean;
  currentPeriodEnd: string | null;
  cancelAtPeriodEnd: boolean;
  plan: {
    name: string;
    interval: 'month';
  } | null;
  usage: {
    count: number;
    estimatedCharge: number;
  } | null;
}
