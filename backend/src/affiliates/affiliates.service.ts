import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { AffiliateClick, AffiliateCategory } from './entities/affiliate.entity';

@Injectable()
export class AffiliatesService {
  constructor(
    @InjectRepository(AffiliateClick) private readonly clickRepo: Repository<AffiliateClick>,
  ) {}

  async trackClick(data: {
    userId?: string;
    affiliateProvider: string;
    campaignId: string;
    category: AffiliateCategory;
    targetUrl: string;
    referralCode?: string;
    platform?: string;
  }): Promise<AffiliateClick> {
    const click = this.clickRepo.create(data);
    return this.clickRepo.save(click);
  }

  async trackConversion(clickId: string, value: number): Promise<AffiliateClick | null> {
    const click = await this.clickRepo.findOne({ where: { id: clickId } });
    if (!click) return null;
    click.converted = true;
    click.conversionValue = value;
    click.convertedAt = new Date();
    return this.clickRepo.save(click);
  }

  async getStats(startDate: Date, endDate: Date) {
    const clicks = await this.clickRepo
      .createQueryBuilder('c')
      .select('c.affiliateProvider', 'provider')
      .addSelect('c.category', 'category')
      .addSelect('COUNT(*)', 'clicks')
      .addSelect('SUM(CASE WHEN c.converted THEN 1 ELSE 0 END)', 'conversions')
      .addSelect('SUM(COALESCE(c.conversionValue, 0))', 'revenue')
      .where('c.clickedAt BETWEEN :start AND :end', { start: startDate, end: endDate })
      .groupBy('c.affiliateProvider')
      .addGroupBy('c.category')
      .getRawMany();

    return clicks;
  }

  async getProviders() {
    // Placeholder affiliate providers - replace with real partner configs
    return [
      { id: 'amazon', name: 'Amazon Associates', categories: ['shopping'], active: true },
      { id: 'myprotein', name: 'MyProtein', categories: ['nutrition'], active: true },
      { id: 'headspace', name: 'Headspace', categories: ['wellness'], active: true },
      { id: 'audible', name: 'Audible', categories: ['subscription'], active: true },
      { id: 'nerdwallet', name: 'NerdWallet', categories: ['finance'], active: true },
    ];
  }
}
