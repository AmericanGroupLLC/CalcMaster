import { Controller, Post, Body, UseGuards } from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiOperation } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard, Roles } from '../auth/guards/roles.guard';
import { UserRole } from '../users/entities/user.entity';
import { NotificationsService } from './notifications.service';
import { SendToUserDto, SendToTopicDto, SendBulkDto } from './dto/notification.dto';

@ApiTags('notifications')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('notifications')
export class NotificationsController {
  constructor(private readonly notificationsService: NotificationsService) {}

  @Post('send')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Send push to a user (admin)' })
  sendToUser(@Body() dto: SendToUserDto) {
    return this.notificationsService.sendToUser(dto.userId, {
      title: dto.title,
      body: dto.body,
      data: dto.data,
    });
  }

  @Post('send/topic')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Send push to a topic (admin)' })
  sendToTopic(@Body() dto: SendToTopicDto) {
    return this.notificationsService.sendToTopic(dto.topic, {
      title: dto.title,
      body: dto.body,
    });
  }

  @Post('send/bulk')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Send push to multiple users (admin)' })
  sendBulk(@Body() dto: SendBulkDto) {
    return this.notificationsService.sendBulk(dto.userIds, {
      title: dto.title,
      body: dto.body,
    });
  }
}
