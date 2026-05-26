import {
  Controller,
  Post,
  Get,
  Body,
  Query,
  UseGuards,
  Request,
} from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiOperation, ApiQuery } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard, Roles } from '../auth/guards/roles.guard';
import { UserRole } from '../users/entities/user.entity';
import { AnalyticsService } from './analytics.service';
import { AnalyticsEvent } from './entities/analytics-event.entity';

@ApiTags('analytics')
@Controller('analytics')
export class AnalyticsController {
  constructor(private readonly analyticsService: AnalyticsService) {}

  @Post('track')
  @ApiOperation({ summary: 'Track an analytics event (auth optional)' })
  track(@Body() body: { event: string; properties?: Record<string, unknown>; anonymousId?: string; platform?: string; appVersion?: string; locale?: string; region?: string }, @Request() req: { user?: { id: string } }) {
    return this.analyticsService.track({
      userId: req.user?.id,
      anonymousId: body.anonymousId,
      event: body.event,
      properties: body.properties,
      platform: body.platform,
      appVersion: body.appVersion,
      locale: body.locale,
      region: body.region,
    });
  }

  @Post('track/batch')
  @ApiOperation({ summary: 'Track multiple events at once' })
  trackBatch(@Body() body: { events: Partial<AnalyticsEvent>[] }) {
    return this.analyticsService.trackBatch(body.events);
  }

  @Get('events')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get event counts (admin)' })
  @ApiQuery({ name: 'start', required: true })
  @ApiQuery({ name: 'end', required: true })
  @ApiQuery({ name: 'event', required: false })
  getEvents(@Query('start') start: string, @Query('end') end: string, @Query('event') event?: string) {
    return this.analyticsService.getEventCounts(new Date(start), new Date(end), event);
  }

  @Get('dau')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Daily active users (admin)' })
  getDau(@Query('start') start: string, @Query('end') end: string) {
    return this.analyticsService.getDailyActiveUsers(new Date(start), new Date(end));
  }

  @Get('retention')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Retention analysis (admin)' })
  getRetention(@Query('date') date: string, @Query('days') days: string) {
    return this.analyticsService.getRetention(new Date(date), parseInt(days) || 7);
  }

  @Get('funnel')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Funnel analysis (admin)' })
  getFunnel(@Query('events') events: string, @Query('start') start: string, @Query('end') end: string) {
    return this.analyticsService.getFunnelAnalysis(events.split(','), new Date(start), new Date(end));
  }
}
