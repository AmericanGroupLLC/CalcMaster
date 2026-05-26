import { Controller, Post, Get, Body, Query, UseGuards } from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiOperation } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard, Roles } from '../auth/guards/roles.guard';
import { UserRole } from '../users/entities/user.entity';
import { AffiliatesService } from './affiliates.service';
import { AffiliateCategory } from './entities/affiliate.entity';

@ApiTags('affiliates')
@Controller('affiliates')
export class AffiliatesController {
  constructor(private readonly affiliatesService: AffiliatesService) {}

  @Post('click')
  @ApiOperation({ summary: 'Track affiliate click' })
  trackClick(@Body() body: {
    userId?: string;
    affiliateProvider: string;
    campaignId: string;
    category: AffiliateCategory;
    targetUrl: string;
    referralCode?: string;
    platform?: string;
  }) {
    return this.affiliatesService.trackClick(body);
  }

  @Post('conversion')
  @ApiOperation({ summary: 'Track affiliate conversion' })
  trackConversion(@Body() body: { clickId: string; value: number }) {
    return this.affiliatesService.trackConversion(body.clickId, body.value);
  }

  @Get('providers')
  @ApiOperation({ summary: 'List affiliate providers' })
  getProviders() {
    return this.affiliatesService.getProviders();
  }

  @Get('stats')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Affiliate stats (admin)' })
  getStats(@Query('start') start: string, @Query('end') end: string) {
    return this.affiliatesService.getStats(new Date(start), new Date(end));
  }
}
