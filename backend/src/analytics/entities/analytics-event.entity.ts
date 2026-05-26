import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  Index,
} from 'typeorm';

@Entity('analytics_events')
export class AnalyticsEvent {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ nullable: true })
  @Index()
  userId: string;

  @Column({ nullable: true })
  anonymousId: string;

  @Column()
  @Index()
  event: string;

  @Column({ type: 'jsonb', nullable: true })
  properties: Record<string, any>;

  @Column({ nullable: true })
  platform: string;

  @Column({ nullable: true })
  appVersion: string;

  @Column({ nullable: true })
  locale: string;

  @Column({ nullable: true })
  region: string;

  @Column({ nullable: true })
  sessionId: string;

  @CreateDateColumn()
  @Index()
  createdAt: Date;
}
