import { Injectable, NotFoundException, BadRequestException, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import {
  Subscription,
  SubscriptionPlan,
  SubscriptionStatus,
  PaymentProvider,
} from './entities/subscription.entity';

@Injectable()
export class SubscriptionsService {
  private readonly logger = new Logger(SubscriptionsService.name);

  constructor(
    @InjectRepository(Subscription) private readonly subRepo: Repository<Subscription>,
  ) {}

  async getActive(userId: string): Promise<Subscription | null> {
    return this.subRepo.findOne({
      where: { userId, status: SubscriptionStatus.ACTIVE },
      order: { createdAt: 'DESC' },
    });
  }

  async create(
    userId: string,
    plan: SubscriptionPlan,
    provider: PaymentProvider,
    receipt?: string,
  ): Promise<Subscription> {
    const existing = await this.getActive(userId);
    if (existing && existing.plan !== SubscriptionPlan.FREE) {
      throw new BadRequestException('Active subscription already exists');
    }

    if (receipt) {
      const verification = await this.verifyReceipt(provider, receipt);
      if (!verification.valid) {
        throw new BadRequestException('Receipt verification failed');
      }
    }

    const now = new Date();
    let expiresAt: Date | undefined;
    let amount = 0;

    switch (plan) {
      case SubscriptionPlan.MONTHLY:
        expiresAt = new Date(now.getTime() + 30 * 24 * 60 * 60 * 1000);
        amount = 4.99;
        break;
      case SubscriptionPlan.ANNUAL:
        expiresAt = new Date(now.getTime() + 365 * 24 * 60 * 60 * 1000);
        amount = 29.99;
        break;
      case SubscriptionPlan.LIFETIME:
        amount = 79.99;
        break;
      default:
        throw new BadRequestException(`Unsupported subscription plan: ${plan as string}`);
    }

    const sub = this.subRepo.create({
      userId,
      plan,
      status: SubscriptionStatus.ACTIVE,
      paymentProvider: provider,
      receiptData: receipt,
      amount,
      startsAt: now,
      expiresAt,
      autoRenew: plan !== SubscriptionPlan.LIFETIME,
    });

    return this.subRepo.save(sub);
  }

  async cancel(userId: string, subscriptionId: string): Promise<Subscription> {
    const sub = await this.subRepo.findOne({
      where: { id: subscriptionId, userId },
    });
    if (!sub) throw new NotFoundException('Subscription not found');

    sub.status = SubscriptionStatus.CANCELLED;
    sub.cancelledAt = new Date();
    sub.autoRenew = false;
    return this.subRepo.save(sub);
  }

  async verifyReceipt(
    provider: PaymentProvider,
    receipt: string,
  ): Promise<{ valid: boolean; plan?: SubscriptionPlan }> {
    if (!receipt || receipt.trim().length === 0) {
      return { valid: false };
    }

    // TODO: Implement real receipt verification per provider
    // Apple: POST to https://buy.itunes.apple.com/verifyReceipt
    // Google: Use androidpublisher API
    // Stripe: Verify via Stripe SDK
    this.logger.warn(
      `Receipt verification not implemented for provider "${provider}". Rejecting by default (fail-safe).`,
    );
    return { valid: false };
  }

  async getHistory(userId: string) {
    return this.subRepo.find({
      where: { userId },
      order: { createdAt: 'DESC' },
    });
  }

  async getStats() {
    const total = await this.subRepo.count({ where: { status: SubscriptionStatus.ACTIVE } });
    const byPlan = await this.subRepo
      .createQueryBuilder('s')
      .select('s.plan', 'plan')
      .addSelect('COUNT(*)', 'count')
      .where('s.status = :status', { status: SubscriptionStatus.ACTIVE })
      .groupBy('s.plan')
      .getRawMany();
    return { totalActive: total, byPlan };
  }
}
