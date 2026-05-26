import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Between } from 'typeorm';
import { AnalyticsEvent } from './entities/analytics-event.entity';

@Injectable()
export class AnalyticsService {
  constructor(
    @InjectRepository(AnalyticsEvent) private readonly eventRepo: Repository<AnalyticsEvent>,
  ) {}

  async track(data: Partial<AnalyticsEvent>): Promise<AnalyticsEvent> {
    const event = this.eventRepo.create(data);
    return this.eventRepo.save(event);
  }

  async trackBatch(events: Partial<AnalyticsEvent>[]): Promise<void> {
    const entities = events.map((e) => this.eventRepo.create(e));
    await this.eventRepo.save(entities);
  }

  async getEventCounts(startDate: Date, endDate: Date, eventName?: string) {
    const qb = this.eventRepo
      .createQueryBuilder('e')
      .select('e.event', 'event')
      .addSelect('COUNT(*)', 'count')
      .where('e.createdAt BETWEEN :start AND :end', { start: startDate, end: endDate });

    if (eventName) {
      qb.andWhere('e.event = :eventName', { eventName });
    }

    return qb.groupBy('e.event').orderBy('count', 'DESC').getRawMany();
  }

  async getDailyActiveUsers(startDate: Date, endDate: Date) {
    return this.eventRepo
      .createQueryBuilder('e')
      .select("DATE(e.createdAt)", 'date')
      .addSelect('COUNT(DISTINCT COALESCE(e.userId, e.anonymousId))', 'users')
      .where('e.createdAt BETWEEN :start AND :end', { start: startDate, end: endDate })
      .groupBy("DATE(e.createdAt)")
      .orderBy('date', 'ASC')
      .getRawMany();
  }

  async getRetention(cohortDate: Date, days: number) {
    // Simplified retention: users who returned N days after first seen
    const cohortEnd = new Date(cohortDate.getTime() + 24 * 60 * 60 * 1000);
    const cohortUsers = await this.eventRepo
      .createQueryBuilder('e')
      .select('DISTINCT COALESCE(e.userId, e.anonymousId)', 'uid')
      .where('e.createdAt BETWEEN :start AND :end', { start: cohortDate, end: cohortEnd })
      .getRawMany();

    const cohortSize = cohortUsers.length;
    const retention: { day: number; retained: number; rate: number }[] = [];

    for (let d = 1; d <= days; d++) {
      const dayStart = new Date(cohortDate.getTime() + d * 24 * 60 * 60 * 1000);
      const dayEnd = new Date(dayStart.getTime() + 24 * 60 * 60 * 1000);
      const uids = cohortUsers.map((u) => u.uid);
      if (uids.length === 0) {
        retention.push({ day: d, retained: 0, rate: 0 });
        continue;
      }
      const returned = await this.eventRepo
        .createQueryBuilder('e')
        .select('COUNT(DISTINCT COALESCE(e.userId, e.anonymousId))', 'count')
        .where('COALESCE(e.userId, e.anonymousId) IN (:...uids)', { uids })
        .andWhere('e.createdAt BETWEEN :start AND :end', { start: dayStart, end: dayEnd })
        .getRawOne();
      const retained = parseInt(returned?.count || '0');
      retention.push({ day: d, retained, rate: cohortSize ? retained / cohortSize : 0 });
    }

    return { cohortSize, retention };
  }

  async getFunnelAnalysis(events: string[], startDate: Date, endDate: Date) {
    const steps: { event: string; users: number; dropoff: number }[] = [];
    let prevUsers = 0;

    for (const event of events) {
      const result = await this.eventRepo
        .createQueryBuilder('e')
        .select('COUNT(DISTINCT COALESCE(e.userId, e.anonymousId))', 'users')
        .where('e.event = :event', { event })
        .andWhere('e.createdAt BETWEEN :start AND :end', { start: startDate, end: endDate })
        .getRawOne();
      const users = parseInt(result?.users || '0');
      steps.push({
        event,
        users,
        dropoff: prevUsers ? ((prevUsers - users) / prevUsers) * 100 : 0,
      });
      prevUsers = users;
    }

    return steps;
  }
}
