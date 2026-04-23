import {
  Injectable,
  Logger,
  BadRequestException,
  NotFoundException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import Stripe from 'stripe';
import { SubscriptionRepository } from './subscription.repository';
import { SubscriptionStatusResponseDto } from './dto/subscription-status-response.dto';
import { BillingDetailsResponseDto } from './dto/billing-details-response.dto';
import { ACTIVE_STATUSES, PLANS } from './subscription.constants';
import { MailService } from '../mail/mail.service';
import { buildInvoicePaidEmailHtml } from './templates/invoice-paid-email.template';
import { buildPaymentFailedEmailHtml } from './templates/payment-failed-email.template';

@Injectable()
export class SubscriptionService {
  private readonly logger = new Logger(SubscriptionService.name);
  private readonly stripe: Stripe;

  private readonly basePriceId: string;
  private readonly meteredPriceId: string;
  private readonly meterEventName: string;
  readonly frontendUrl: string;
  private readonly webhookSecret: string;

  constructor(
    private readonly subscriptionRepository: SubscriptionRepository,
    private readonly configService: ConfigService,
    private readonly mailService: MailService,
  ) {
    this.stripe = new Stripe(
      this.configService.get<string>('STRIPE_SECRET_KEY')!,
    );
    this.basePriceId = this.configService.get<string>('STRIPE_BASE_PRICE_ID')!;
    this.meteredPriceId = this.configService.get<string>(
      'STRIPE_METERED_PRICE_ID',
    )!;
    this.meterEventName =
      this.configService.get<string>('STRIPE_METER_EVENT_NAME') ||
      'content_generated';
    this.frontendUrl = this.configService.get<string>('FRONTEND_URL')!;
    this.webhookSecret = this.configService.get<string>(
      'STRIPE_WEBHOOK_SECRET',
    )!;
  }

  async getSubscriptionStatus(
    projectId: string,
  ): Promise<SubscriptionStatusResponseDto> {
    const subscription =
      await this.subscriptionRepository.findByProjectId(projectId);

    if (!subscription) {
      return {
        status: 'none',
        canAccessFeatures: false,
        currentPeriodEnd: null,
        cancelAtPeriodEnd: false,
        plan: null,
        usage: null,
      };
    }

    const status = subscription.status as 'active' | 'past_due' | 'canceled';
    const canAccessFeatures = ACTIVE_STATUSES.includes(
      status as (typeof ACTIVE_STATUSES)[number],
    );

    let usage: { count: number; estimatedCharge: number } | null = null;
    if (subscription.currentPeriodStart && subscription.currentPeriodEnd) {
      const count = await this.subscriptionRepository.getUsageCount(
        projectId,
        subscription.currentPeriodStart,
        subscription.currentPeriodEnd,
      );
      usage = {
        count,
        estimatedCharge:
          Math.round(count * PLANS.PRO.perContentPrice * 100) / 100,
      };
    }

    return {
      status,
      canAccessFeatures,
      currentPeriodEnd: subscription.currentPeriodEnd,
      cancelAtPeriodEnd: subscription.cancelAtPeriodEnd,
      plan: {
        name: PLANS.PRO.name,
        interval: 'month',
      },
      usage,
    };
  }

  getPlans() {
    return {
      name: PLANS.PRO.name,
      basePrice: PLANS.PRO.basePrice,
      perContentPrice: PLANS.PRO.perContentPrice,
      features: PLANS.PRO.features,
    };
  }

  async createCheckoutSession(projectId: string): Promise<{ url: string }> {
    const existingDbSub =
      await this.subscriptionRepository.findByProjectId(projectId);
    if (
      existingDbSub &&
      ACTIVE_STATUSES.includes(
        existingDbSub.status as (typeof ACTIVE_STATUSES)[number],
      )
    ) {
      throw new BadRequestException(
        'An active subscription already exists for this project',
      );
    }

    let stripeCustomerId =
      await this.subscriptionRepository.getProjectStripeCustomerId(projectId);

    // Validate existing Stripe customer hasn't been deleted
    if (stripeCustomerId) {
      const existingCustomer =
        await this.stripe.customers.retrieve(stripeCustomerId);
      if (existingCustomer.deleted) {
        this.logger.warn(
          `Stripe customer ${stripeCustomerId} was deleted, creating a new one for project ${projectId}`,
        );
        stripeCustomerId = null;
      }
    }

    if (!stripeCustomerId) {
      const customer = await this.stripe.customers.create({
        metadata: { projectId },
      });
      stripeCustomerId = customer.id;
      await this.subscriptionRepository.updateProjectStripeCustomerId(
        projectId,
        stripeCustomerId,
      );
    }

    const existingStripeSubs = await this.stripe.subscriptions.list({
      customer: stripeCustomerId,
      limit: 10,
    });

    const aliveSub = existingStripeSubs.data.find((sub) =>
      ['active', 'past_due', 'trialing', 'incomplete'].includes(sub.status),
    );

    if (aliveSub) {
      // Self-heal: sync the Stripe subscription to our DB
      const period = this.getSubscriptionPeriod(aliveSub);
      await this.subscriptionRepository.deleteByProjectId(projectId);
      await this.subscriptionRepository.upsertByStripeSubscriptionId({
        projectId,
        stripeSubscriptionId: aliveSub.id,
        stripeCustomerId,
        status: aliveSub.status,
        priceId: aliveSub.items.data[0].price.id,
        currentPeriodStart: period.currentPeriodStart,
        currentPeriodEnd: period.currentPeriodEnd,
        cancelAtPeriodEnd: aliveSub.cancel_at_period_end,
      });

      this.logger.log(
        `Self-healed subscription ${aliveSub.id} for project ${projectId} (missed webhook)`,
      );

      throw new BadRequestException(
        'An active subscription already exists for this project',
      );
    }

    const session = await this.stripe.checkout.sessions.create({
      customer: stripeCustomerId,
      mode: 'subscription',
      locale: 'en',
      line_items: [
        { price: this.basePriceId, quantity: 1 },
        { price: this.meteredPriceId },
      ],
      success_url: `${this.frontendUrl}/settings/billing?checkout=success`,
      cancel_url: `${this.frontendUrl}/settings/billing?checkout=canceled`,
      metadata: { projectId },
      subscription_data: {
        metadata: { projectId },
      },
      adaptive_pricing: { enabled: false },
    });

    if (!session.url) {
      throw new BadRequestException('Failed to create checkout session');
    }

    return { url: session.url };
  }

  async createPortalSession(projectId: string): Promise<{ url: string }> {
    const stripeCustomerId =
      await this.subscriptionRepository.getSubscriptionStripeCustomerId(
        projectId,
      );

    if (!stripeCustomerId) {
      throw new NotFoundException('No billing account found for this project');
    }

    const session = await this.stripe.billingPortal.sessions.create({
      customer: stripeCustomerId,
      return_url: `${this.frontendUrl}/settings/billing`,
    });

    return { url: session.url };
  }

  async getBillingDetails(
    projectId: string,
  ): Promise<BillingDetailsResponseDto> {
    const stripeCustomerId =
      await this.subscriptionRepository.getSubscriptionStripeCustomerId(
        projectId,
      );

    if (!stripeCustomerId) {
      return {
        paymentMethods: [],
        billingInfo: { name: null, email: null },
        invoices: [],
      };
    }

    const [customer, paymentMethods, invoices] = await Promise.all([
      this.stripe.customers.retrieve(stripeCustomerId),
      this.stripe.customers.listPaymentMethods(stripeCustomerId, {
        type: 'card',
      }),
      this.stripe.invoices.list({ customer: stripeCustomerId, limit: 12 }),
    ]);

    if (customer.deleted) {
      return {
        paymentMethods: [],
        billingInfo: { name: null, email: null },
        invoices: [],
      };
    }

    const defaultPaymentMethodId =
      typeof customer.invoice_settings?.default_payment_method === 'string'
        ? customer.invoice_settings.default_payment_method
        : (customer.invoice_settings?.default_payment_method?.id ?? null);

    return {
      paymentMethods: paymentMethods.data.map((pm) => ({
        id: pm.id,
        brand: pm.card?.brand ?? 'unknown',
        last4: pm.card?.last4 ?? '****',
        expMonth: pm.card?.exp_month ?? 0,
        expYear: pm.card?.exp_year ?? 0,
        cardholderName: pm.billing_details?.name ?? null,
        country: pm.card?.country ?? null,
        isDefault: pm.id === defaultPaymentMethodId,
      })),
      billingInfo: {
        name: customer.name ?? null,
        email: customer.email ?? null,
      },
      invoices: invoices.data.map((inv) => ({
        id: inv.id,
        date: inv.created
          ? new Date(inv.created * 1000).toISOString()
          : new Date().toISOString(),
        amount:
          inv.status === 'paid'
            ? (inv.amount_paid ?? 0) / 100
            : (inv.amount_due ?? 0) / 100,
        currency: inv.currency ?? 'usd',
        status: inv.status ?? 'draft',
        invoicePdf: inv.invoice_pdf ?? null,
        hostedInvoiceUrl: inv.hosted_invoice_url ?? null,
      })),
    };
  }

  async getCostExplorerData(
    projectId: string,
    startDate: string,
    endDate: string,
  ) {
    // Clamp date range to current subscription period (full timestamp precision)
    const subscription =
      await this.subscriptionRepository.findByProjectId(projectId);
    if (
      subscription?.currentPeriodStart &&
      startDate < subscription.currentPeriodStart
    ) {
      startDate = subscription.currentPeriodStart;
    }
    if (
      subscription?.currentPeriodEnd &&
      endDate > subscription.currentPeriodEnd
    ) {
      endDate = subscription.currentPeriodEnd;
    }

    const dailyUsage = await this.subscriptionRepository.getDailyUsage(
      projectId,
      startDate,
      endDate,
    );

    const perContentPrice = PLANS.PRO.perContentPrice;
    const today = new Date().toISOString().split('T')[0];

    let totalCount = 0;
    let todayCount = 0;
    const dailyCosts = dailyUsage.map((day) => {
      totalCount += day.count;
      if (day.date === today) {
        todayCount = day.count;
      }
      return {
        date: day.date,
        count: day.count,
        cost: Math.round(day.count * perContentPrice * 100) / 100,
      };
    });

    const totalCost = Math.round(totalCount * perContentPrice * 100) / 100;
    const daysWithData = dailyCosts.length || 1;
    const dailyAverageCost = Math.round((totalCost / daysWithData) * 100) / 100;
    const todayCost = Math.round(todayCount * perContentPrice * 100) / 100;

    return {
      summary: {
        totalCost,
        dailyAverageCost,
        todayCost,
        contentCount: totalCount,
      },
      dailyCosts,
    };
  }

  async reportUsage(projectId: string, quantity: number = 1): Promise<void> {
    const subscription =
      await this.subscriptionRepository.findByProjectId(projectId);

    if (!subscription) {
      this.logger.warn(
        `No subscription found for project ${projectId}, skipping usage report`,
      );
      return;
    }

    const isActive = ACTIVE_STATUSES.includes(
      subscription.status as (typeof ACTIVE_STATUSES)[number],
    );
    if (!isActive) {
      this.logger.warn(
        `Subscription for project ${projectId} is not active (${subscription.status}), skipping usage report`,
      );
      return;
    }

    await this.stripe.billing.meterEvents.create({
      event_name: this.meterEventName,
      payload: {
        stripe_customer_id: subscription.stripeCustomerId,
        value: String(quantity),
      },
    });

    this.logger.log(
      `Reported ${quantity} usage unit(s) for project ${projectId}`,
    );
  }

  async handleWebhookEvent(event: Stripe.Event): Promise<void> {
    const eventId = event.id;

    // Idempotency check
    const alreadyProcessed =
      await this.subscriptionRepository.isEventProcessed(eventId);
    if (alreadyProcessed) {
      this.logger.log(`Event ${eventId} already processed, skipping`);
      return;
    }

    const eventData = event.data.object as unknown as Record<string, unknown>;

    try {
      switch (event.type) {
        case 'checkout.session.completed':
          await this.handleCheckoutCompleted(event.data.object);
          break;
        case 'customer.subscription.updated':
          await this.handleSubscriptionUpdated(event.data.object);
          break;
        case 'customer.subscription.deleted':
          await this.handleSubscriptionDeleted(event.data.object);
          break;
        case 'invoice.paid':
          await this.handleInvoicePaid(event.data.object);
          break;
        case 'invoice.payment_failed':
          await this.handleInvoicePaymentFailed(event.data.object);
          break;
        default:
          this.logger.log(`Unhandled event type: ${event.type}`);
          await this.subscriptionRepository.recordEvent(
            eventId,
            event.type,
            eventData,
          );
          return;
      }

      // Record successful event
      await this.subscriptionRepository.recordEvent(
        eventId,
        event.type,
        eventData,
      );
    } catch (error) {
      const errorMessage =
        error instanceof Error ? error.message : String(error);
      this.logger.error(
        `Failed to process event ${eventId} (${event.type}): ${errorMessage}`,
      );

      // Record failed event for idempotency + debugging
      await this.subscriptionRepository.recordEvent(
        eventId,
        event.type,
        eventData,
        'error',
        errorMessage,
      );

      throw error;
    }
  }

  constructWebhookEvent(payload: Buffer, signature: string): Stripe.Event {
    return this.stripe.webhooks.constructEvent(
      payload,
      signature,
      this.webhookSecret,
    );
  }

  private getSubscriptionPeriod(subscription: Stripe.Subscription) {
    const item = subscription.items.data[0];
    return {
      currentPeriodStart: new Date(
        item.current_period_start * 1000,
      ).toISOString(),
      currentPeriodEnd: new Date(item.current_period_end * 1000).toISOString(),
    };
  }

  private getSubscriptionCustomerId(subscription: Stripe.Subscription): string {
    return typeof subscription.customer === 'string'
      ? subscription.customer
      : subscription.customer.id;
  }

  private getInvoiceSubscriptionId(invoice: Stripe.Invoice): string | null {
    const subDetails = invoice.parent?.subscription_details;
    if (!subDetails?.subscription) return null;
    return typeof subDetails.subscription === 'string'
      ? subDetails.subscription
      : subDetails.subscription.id;
  }

  private async handleCheckoutCompleted(
    session: Stripe.Checkout.Session,
  ): Promise<void> {
    const projectId = session.metadata?.projectId;
    if (!projectId || !session.subscription) {
      this.logger.warn('Checkout session missing projectId or subscription');
      return;
    }

    const subscriptionId =
      typeof session.subscription === 'string'
        ? session.subscription
        : session.subscription.id;

    // Sync email from checkout to Stripe customer (customer was created without email)
    const customerId =
      typeof session.customer === 'string'
        ? session.customer
        : session.customer?.id;
    if (customerId && session.customer_details?.email) {
      await this.stripe.customers.update(customerId, {
        email: session.customer_details.email,
      });
    }

    // Retrieve full subscription details from Stripe
    const subscription =
      await this.stripe.subscriptions.retrieve(subscriptionId);
    const period = this.getSubscriptionPeriod(subscription);

    // Remove old canceled subscription row to avoid projectId unique constraint violation
    await this.subscriptionRepository.deleteByProjectId(projectId);

    await this.subscriptionRepository.upsertByStripeSubscriptionId({
      projectId,
      stripeSubscriptionId: subscription.id,
      stripeCustomerId: this.getSubscriptionCustomerId(subscription),
      status: subscription.status,
      priceId: subscription.items.data[0].price.id,
      currentPeriodStart: period.currentPeriodStart,
      currentPeriodEnd: period.currentPeriodEnd,
      cancelAtPeriodEnd: subscription.cancel_at_period_end,
    });

    await this.subscriptionRepository.updateProjectAutoFlags(projectId, {
      autoGenerate: true,
      autoAnalysis: true,
    });

    // Clear temporary stripeCustomerId from Project — ProjectSubscription is now the source of truth
    await this.subscriptionRepository.updateProjectStripeCustomerId(
      projectId,
      null,
    );

    this.logger.log(
      `Subscription ${subscription.id} created for project ${projectId}`,
    );

    try {
      const email =
        session.customer_details?.email ??
        (await this.getCustomerEmail(
          this.getSubscriptionCustomerId(subscription),
        ));
      if (email) {
        const latestInvoice = subscription.latest_invoice;
        const invoiceId =
          typeof latestInvoice === 'string' ? latestInvoice : latestInvoice?.id;
        let amountFormatted = `$${PLANS.PRO.basePrice.toFixed(2)}`;
        let invoicePdfUrl: string | null = null;

        if (invoiceId) {
          const invoice = await this.stripe.invoices.retrieve(invoiceId);
          amountFormatted = `$${((invoice.amount_paid ?? 0) / 100).toFixed(2)}`;
          invoicePdfUrl = invoice.invoice_pdf ?? null;
        }

        const html = buildInvoicePaidEmailHtml({
          amountFormatted,
          currency: 'USD',
          paidDate: new Date().toLocaleDateString('en-US', {
            year: 'numeric',
            month: 'long',
            day: 'numeric',
          }),
          invoicePdfUrl,
          billingPageUrl: `${this.frontendUrl}/settings/billing`,
        });
        await this.mailService.sendMail(
          email,
          'Payment Confirmed — AEO Pro',
          html,
        );
        this.logger.log(
          `[Email] First payment confirmation sent to ${email} for project ${projectId} (amount: ${amountFormatted})`,
        );
      } else {
        this.logger.warn(
          `[Email] No email available for checkout session, skipping first payment email`,
        );
      }
    } catch (error) {
      this.logger.error(
        `[Email] Failed to send first payment email for project ${projectId}: ${error instanceof Error ? error.message : String(error)}`,
      );
    }
  }

  private async handleSubscriptionUpdated(
    subscription: Stripe.Subscription,
  ): Promise<void> {
    const existing =
      await this.subscriptionRepository.findByStripeSubscriptionId(
        subscription.id,
      );

    if (!existing) {
      this.logger.warn(`Subscription ${subscription.id} not found in database`);
      return;
    }

    const period = this.getSubscriptionPeriod(subscription);

    await this.subscriptionRepository.upsertByStripeSubscriptionId({
      projectId: existing.projectId,
      stripeSubscriptionId: subscription.id,
      stripeCustomerId: this.getSubscriptionCustomerId(subscription),
      status: subscription.status,
      priceId: subscription.items.data[0].price.id,
      currentPeriodStart: period.currentPeriodStart,
      currentPeriodEnd: period.currentPeriodEnd,
      cancelAtPeriodEnd: subscription.cancel_at_period_end,
      canceledAt: subscription.canceled_at
        ? new Date(subscription.canceled_at * 1000).toISOString()
        : null,
    });
  }

  private async handleSubscriptionDeleted(
    subscription: Stripe.Subscription,
  ): Promise<void> {
    const existing =
      await this.subscriptionRepository.findByStripeSubscriptionId(
        subscription.id,
      );

    if (!existing) {
      this.logger.warn(
        `Subscription ${subscription.id} not found for deletion`,
      );
      return;
    }

    await this.subscriptionRepository.upsertByStripeSubscriptionId({
      projectId: existing.projectId,
      stripeSubscriptionId: subscription.id,
      stripeCustomerId: this.getSubscriptionCustomerId(subscription),
      status: 'canceled',
      priceId: existing.priceId,
      canceledAt: new Date().toISOString(),
    });

    await this.subscriptionRepository.updateProjectAutoFlags(
      existing.projectId,
      { autoGenerate: false, autoAnalysis: false },
    );

    // Clear stripeCustomerId so a fresh customer is created on next checkout
    await this.subscriptionRepository.updateProjectStripeCustomerId(
      existing.projectId,
      null,
    );
  }

  private async handleInvoicePaid(invoice: Stripe.Invoice): Promise<void> {
    const subscriptionId = this.getInvoiceSubscriptionId(invoice);
    if (!subscriptionId) {
      this.logger.warn(
        `[Email] invoice.paid: could not extract subscriptionId from invoice ${invoice.id}, skipping`,
      );
      return;
    }

    const existing =
      await this.subscriptionRepository.findByStripeSubscriptionId(
        subscriptionId,
      );

    if (!existing) {
      this.logger.warn(
        `[Email] invoice.paid: subscription ${subscriptionId} not found in database, skipping`,
      );
      return;
    }

    // Retrieve updated subscription from Stripe
    const subscription =
      await this.stripe.subscriptions.retrieve(subscriptionId);
    const period = this.getSubscriptionPeriod(subscription);

    await this.subscriptionRepository.upsertByStripeSubscriptionId({
      projectId: existing.projectId,
      stripeSubscriptionId: subscription.id,
      stripeCustomerId: this.getSubscriptionCustomerId(subscription),
      status: 'active',
      priceId: subscription.items.data[0].price.id,
      currentPeriodStart: period.currentPeriodStart,
      currentPeriodEnd: period.currentPeriodEnd,
    });

    // Skip email for first invoice — handleCheckoutCompleted already sent it
    if (invoice.billing_reason === 'subscription_create') {
      this.logger.log(
        `[Email] Skipping invoice paid email for first invoice (handled by checkout), project ${existing.projectId}`,
      );
      return;
    }

    // Send payment confirmation email for renewal invoices
    try {
      const customerId =
        typeof invoice.customer === 'string'
          ? invoice.customer
          : invoice.customer?.id;
      if (customerId) {
        const email = await this.getCustomerEmail(customerId);
        if (email) {
          const amountFormatted = `$${((invoice.amount_paid ?? 0) / 100).toFixed(2)}`;
          const html = buildInvoicePaidEmailHtml({
            amountFormatted,
            currency: (invoice.currency ?? 'usd').toUpperCase(),
            paidDate: new Date(
              (invoice.created ?? Date.now() / 1000) * 1000,
            ).toLocaleDateString('en-US', {
              year: 'numeric',
              month: 'long',
              day: 'numeric',
            }),
            invoicePdfUrl: invoice.invoice_pdf ?? null,
            billingPageUrl: `${this.frontendUrl}/settings/billing`,
          });
          await this.mailService.sendMail(
            email,
            'Payment Confirmed — AEO Pro',
            html,
          );
          this.logger.log(
            `[Email] Invoice paid email sent to ${email} for project ${existing.projectId} (amount: ${amountFormatted})`,
          );
        } else {
          this.logger.warn(
            `[Email] No email found for Stripe customer ${customerId}, skipping invoice paid email`,
          );
        }
      }
    } catch (error) {
      this.logger.error(
        `[Email] Failed to send invoice paid email for project ${existing.projectId}: ${error instanceof Error ? error.message : String(error)}`,
      );
    }
  }

  private async handleInvoicePaymentFailed(
    invoice: Stripe.Invoice,
  ): Promise<void> {
    const subscriptionId = this.getInvoiceSubscriptionId(invoice);
    if (!subscriptionId) {
      this.logger.warn(
        `[Email] invoice.payment_failed: could not extract subscriptionId from invoice ${invoice.id}, skipping`,
      );
      return;
    }

    const existing =
      await this.subscriptionRepository.findByStripeSubscriptionId(
        subscriptionId,
      );

    if (!existing) {
      this.logger.warn(
        `[Email] invoice.payment_failed: subscription ${subscriptionId} not found in database, skipping`,
      );
      return;
    }

    await this.subscriptionRepository.upsertByStripeSubscriptionId({
      projectId: existing.projectId,
      stripeSubscriptionId: existing.stripeSubscriptionId,
      stripeCustomerId: existing.stripeCustomerId,
      status: 'past_due',
      priceId: existing.priceId,
    });

    // Send payment failed email
    try {
      const email = await this.getCustomerEmail(existing.stripeCustomerId);
      if (email) {
        const html = buildPaymentFailedEmailHtml({
          planName: PLANS.PRO.name,
          billingPageUrl: `${this.frontendUrl}/settings/billing`,
        });
        await this.mailService.sendMail(
          email,
          'Payment Failed — Action Required',
          html,
        );
        this.logger.log(
          `[Email] Payment failed email sent to ${email} for project ${existing.projectId}`,
        );
      } else {
        this.logger.warn(
          `[Email] No email found for Stripe customer ${existing.stripeCustomerId}, skipping payment failed email`,
        );
      }
    } catch (error) {
      this.logger.error(
        `[Email] Failed to send payment failed email for project ${existing.projectId}: ${error instanceof Error ? error.message : String(error)}`,
      );
    }
  }

  async getCustomerEmail(stripeCustomerId: string): Promise<string | null> {
    try {
      const customer = await this.stripe.customers.retrieve(stripeCustomerId);
      if (customer.deleted) return null;
      return customer.email ?? null;
    } catch (error) {
      this.logger.error(
        `Failed to retrieve customer ${stripeCustomerId}: ${error instanceof Error ? error.message : String(error)}`,
      );
      return null;
    }
  }
}
