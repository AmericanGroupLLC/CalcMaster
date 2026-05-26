import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  Index,
} from 'typeorm';

export enum AffiliateCategory {
  SHOPPING = 'shopping',
  NUTRITION = 'nutrition',
  WELLNESS = 'wellness',
  SUBSCRIPTION = 'subscription',
  FINANCE = 'finance',
}

@Entity('affiliate_clicks')
export class AffiliateClick {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ nullable: true })
  @Index()
  userId: string;

  @Column()
  @Index()
  affiliateProvider: string;

  @Column()
  campaignId: string;

  @Column({ type: 'enum', enum: AffiliateCategory })
  category: AffiliateCategory;

  @Column({ nullable: true })
  targetUrl: string;

  @Column({ nullable: true })
  referralCode: string;

  @Column({ default: false })
  converted: boolean;

  @Column({ nullable: true })
  conversionValue: number;

  @Column({ nullable: true })
  platform: string;

  @CreateDateColumn()
  @Index()
  clickedAt: Date;

  @Column({ nullable: true })
  convertedAt: Date;
}
