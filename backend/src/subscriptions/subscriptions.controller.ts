import {
  Controller,
  Get,
  Post,
  Delete,
  Body,
  Param,
  UseGuards,
  Request,
} from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiOperation } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard, Roles } from '../auth/guards/roles.guard';
import { UserRole } from '../users/entities/user.entity';
import { SubscriptionsService } from './subscriptions.service';
import { CreateSubscriptionDto, VerifyReceiptDto } from './dto/subscription.dto';

@ApiTags('subscriptions')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('subscriptions')
export class SubscriptionsController {
  constructor(private readonly subsService: SubscriptionsService) {}

  @Get('active')
  @ApiOperation({ summary: 'Get current active subscription' })
  getActive(@Request() req: { user: { id: string } }) {
    return this.subsService.getActive(req.user.id);
  }

  @Post()
  @ApiOperation({ summary: 'Create or upgrade subscription' })
  create(
    @Request() req: { user: { id: string } },
    @Body() body: CreateSubscriptionDto,
  ) {
    return this.subsService.create(req.user.id, body.plan, body.provider, body.receipt);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Cancel subscription' })
  cancel(@Request() req: { user: { id: string } }, @Param('id') id: string) {
    return this.subsService.cancel(req.user.id, id);
  }

  @Post('verify-receipt')
  @ApiOperation({ summary: 'Verify purchase receipt' })
  verifyReceipt(@Body() body: VerifyReceiptDto) {
    return this.subsService.verifyReceipt(body.provider, body.receipt);
  }

  @Get('history')
  @ApiOperation({ summary: 'Get subscription history' })
  getHistory(@Request() req: { user: { id: string } }) {
    return this.subsService.getHistory(req.user.id);
  }

  @Get('stats')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Subscription stats (admin)' })
  getStats() {
    return this.subsService.getStats();
  }
}
