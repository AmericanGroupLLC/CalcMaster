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

    // ── Apple App Store receipt verification ──────────────────────────────
    if (provider === PaymentProvider.APPLE) {
      const appleSecret = process.env.APPLE_SHARED_SECRET;
      if (!appleSecret) {
        this.logger.error('APPLE_SHARED_SECRET not configured — rejecting receipt');
        return { valid: false };
      }
      const prodUrl = 'https://buy.itunes.apple.com/verifyReceipt';
      const sandboxUrl = 'https://sandbox.itunes.apple.com/verifyReceipt';
      const verifyUrl = process.env.NODE_ENV === 'production' ? prodUrl : sandboxUrl;
      try {
        const body = JSON.stringify({
          'receipt-data': receipt,
          password: appleSecret,
          'exclude-old-transactions': true,
        });
        const res = await fetch(verifyUrl, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body,
          signal: AbortSignal.timeout(10_000),
        });
        const data = await res.json() as {
          status: number;
          latest_receipt_info?: Array<{ product_id: string; expires_date_ms: string }>;
        };
        // status 21007 means production receipt sent to sandbox — retry against prod
        if (data.status === 21007) {
          const retryRes = await fetch(prodUrl, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body,
            signal: AbortSignal.timeout(10_000),
          });
          return this._parseAppleReceipt(await retryRes.json() as typeof data);
        }
        return this._parseAppleReceipt(data);
      } catch (err) {
        this.logger.error(`Apple receipt verification failed: ${String(err)}`);
        return { valid: false };
      }
    }

    // ── Google Play receipt verification ──────────────────────────────────
    if (provider === PaymentProvider.GOOGLE) {
      // receipt must be JSON: { packageName, productId, purchaseToken }
      try {
        const { packageName, productId, purchaseToken } = JSON.parse(receipt) as {
          packageName: string;
          productId: string;
          purchaseToken: string;
        };
        const serviceAccountJson = process.env.GOOGLE_SERVICE_ACCOUNT_JSON;
        if (!serviceAccountJson) {
          this.logger.error('GOOGLE_SERVICE_ACCOUNT_JSON not configured — rejecting receipt');
          return { valid: false };
        }
        const sa = JSON.parse(serviceAccountJson) as { client_email: string; private_key: string };
        const tokenRes = await fetch('https://oauth2.googleapis.com/token', {
          method: 'POST',
          headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
          body: new URLSearchParams({
            grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
            assertion: this._buildGoogleJwt(sa.client_email, sa.private_key),
          }),
          signal: AbortSignal.timeout(10_000),
        });
        const tokenData = await tokenRes.json() as { access_token?: string };
        if (!tokenData.access_token) {
          this.logger.error('Failed to obtain Google OAuth token for receipt verification');
          return { valid: false };
        }
        const verifyRes = await fetch(
          `https://androidpublisher.googleapis.com/androidpublisher/v3/applications/${packageName}/purchases/subscriptions/${productId}/tokens/${purchaseToken}`,
          {
            headers: { Authorization: `Bearer ${tokenData.access_token}` },
            signal: AbortSignal.timeout(10_000),
          },
        );
        if (verifyRes.status === 200) {
          const sub = await verifyRes.json() as {
            paymentState?: number;
            expiryTimeMillis?: string;
          };
          const active =
            sub.paymentState === 1 && Number(sub.expiryTimeMillis) > Date.now();
          return { valid: active, plan: active ? SubscriptionPlan.MONTHLY : undefined };
        }
        return { valid: false };
      } catch (err) {
        this.logger.error(`Google receipt verification failed: ${String(err)}`);
        return { valid: false };
      }
    }

    // ── Stripe receipt verification ───────────────────────────────────────
    if (provider === PaymentProvider.STRIPE) {
      const stripeSecret = process.env.STRIPE_SECRET_KEY;
      if (!stripeSecret) {
        this.logger.error('STRIPE_SECRET_KEY not configured — rejecting receipt');
        return { valid: false };
      }
      try {
        // receipt is the Stripe subscription ID (sub_xxx)
        const res = await fetch(`https://api.stripe.com/v1/subscriptions/${receipt}`, {
          headers: { Authorization: `Bearer ${stripeSecret}` },
          signal: AbortSignal.timeout(10_000),
        });
        if (res.status === 200) {
          const sub = await res.json() as { status: string };
          return { valid: sub.status === 'active' };
        }
        return { valid: false };
      } catch (err) {
        this.logger.error(`Stripe receipt verification failed: ${String(err)}`);
        return { valid: false };
      }
    }

    this.logger.warn(`Unsupported payment provider: ${provider as string}`);
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

  // ── Private helpers ───────────────────────────────────────────────────

  private _parseAppleReceipt(data: {
    status: number;
    latest_receipt_info?: Array<{ product_id: string; expires_date_ms: string }>;
  }): { valid: boolean; plan?: SubscriptionPlan } {
    if (data.status !== 0) return { valid: false };
    const now = Date.now();
    const active = data.latest_receipt_info?.find(
      (r) => Number(r.expires_date_ms) > now,
    );
    if (!active) return { valid: false };
    const plan = active.product_id.includes('annual')
      ? SubscriptionPlan.ANNUAL
      : active.product_id.includes('lifetime')
        ? SubscriptionPlan.LIFETIME
        : SubscriptionPlan.MONTHLY;
    return { valid: true, plan };
  }

  /**
   * Build a minimal RS256 JWT for Google service-account OAuth2.
   * Uses only Node.js built-ins (crypto) — no external JWT library needed.
   */
  private _buildGoogleJwt(clientEmail: string, privateKey: string): string {
    const { createSign } = require('crypto') as typeof import('crypto');
    const now = Math.floor(Date.now() / 1000);
    const header = Buffer.from(JSON.stringify({ alg: 'RS256', typ: 'JWT' })).toString('base64url');
    const payload = Buffer.from(
      JSON.stringify({
        iss: clientEmail,
        scope: 'https://www.googleapis.com/auth/androidpublisher',
        aud: 'https://oauth2.googleapis.com/token',
        exp: now + 3600,
        iat: now,
      }),
    ).toString('base64url');
    const sign = createSign('RSA-SHA256');
    sign.update(`${header}.${payload}`);
    const sig = sign.sign(privateKey, 'base64url');
    return `${header}.${payload}.${sig}`;
  }
}
