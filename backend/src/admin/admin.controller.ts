import { Controller, Get, UseGuards } from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiOperation } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard, Roles } from '../auth/guards/roles.guard';
import { UserRole } from '../users/entities/user.entity';
import { UsersService } from '../users/users.service';
import { SubscriptionsService } from '../subscriptions/subscriptions.service';
import { AnalyticsService } from '../analytics/analytics.service';

@ApiTags('admin')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(UserRole.ADMIN)
@Controller('admin')
export class AdminController {
  constructor(
    private readonly usersService: UsersService,
    private readonly subscriptionsService: SubscriptionsService,
    private readonly analyticsService: AnalyticsService,
  ) {}

  @Get('dashboard')
  @ApiOperation({ summary: 'Admin dashboard summary' })
  async getDashboard() {
    const now = new Date();
    const thirtyDaysAgo = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);
    const sevenDaysAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);

    const [users, subStats, events7d, dau] = await Promise.all([
      this.usersService.findAll(1, 1),
      this.subscriptionsService.getStats(),
      this.analyticsService.getEventCounts(sevenDaysAgo, now),
      this.analyticsService.getDailyActiveUsers(thirtyDaysAgo, now),
    ]);

    return {
      totalUsers: users.total,
      subscriptions: subStats,
      eventsLast7Days: events7d,
      dailyActiveUsers: dau,
      generatedAt: now.toISOString(),
    };
  }

  @Get('health')
  @ApiOperation({ summary: 'System health check' })
  getHealth() {
    return {
      status: 'ok',
      uptime: process.uptime(),
      memoryUsage: process.memoryUsage(),
      timestamp: new Date().toISOString(),
    };
  }
}
