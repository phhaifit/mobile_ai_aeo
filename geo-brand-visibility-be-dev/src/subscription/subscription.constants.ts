export const SUBSCRIPTION_TABLE = 'ProjectSubscription';
export const STRIPE_EVENT_TABLE = 'StripeEvent';
export const PROJECT_TABLE = 'Project';

/**
 * Statuses that grant Pro access.
 * - 'active': subscription is current and paid
 * - 'past_due': latest invoice payment failed but Stripe is still retrying
 */
export const ACTIVE_STATUSES = ['active', 'past_due'] as const;

export const PLANS = {
  PRO: {
    name: 'AEO Pro',
    basePrice: 29,
    perContentPrice: 0.1,
    features: [
      'AI visibility tracking',
      'Automated content generation ($0.10/content)',
      'Competitor analysis (coming soon)',
      'Custom blog hosting',
      'Pay only for content you generate',
    ],
  },
} as const;
