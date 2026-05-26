import {
  Controller,
  Get,
  Patch,
  Delete,
  Body,
  UseGuards,
  Request,
  Query,
} from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiOperation, ApiQuery } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard, Roles } from '../auth/guards/roles.guard';
import { UserRole } from './entities/user.entity';
import { UsersService } from './users.service';

@ApiTags('users')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get('me')
  @ApiOperation({ summary: 'Get current user profile' })
  getProfile(@Request() req: { user: { id: string } }) {
    return this.usersService.findById(req.user.id);
  }

  @Patch('me')
  @ApiOperation({ summary: 'Update current user profile' })
  updateProfile(@Request() req: { user: { id: string } }, @Body() updates: Record<string, unknown>) {
    return this.usersService.updateProfile(req.user.id, updates);
  }

  @Patch('me/fcm-token')
  @ApiOperation({ summary: 'Update FCM push token' })
  updateFcmToken(@Request() req: { user: { id: string } }, @Body('fcmToken') fcmToken: string) {
    return this.usersService.updateFcmToken(req.user.id, fcmToken);
  }

  @Get('me/export')
  @ApiOperation({ summary: 'Export all user data (GDPR)' })
  exportData(@Request() req: { user: { id: string } }) {
    return this.usersService.exportData(req.user.id);
  }

  @Delete('me')
  @ApiOperation({ summary: 'Delete account (GDPR right to erasure)' })
  deleteAccount(@Request() req: { user: { id: string } }) {
    return this.usersService.deleteAccount(req.user.id);
  }

  @Get()
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'List all users (admin)' })
  @ApiQuery({ name: 'page', required: false })
  @ApiQuery({ name: 'limit', required: false })
  listUsers(@Query('page') page?: string, @Query('limit') limit?: string) {
    return this.usersService.findAll(
      parseInt(page ?? '1') || 1,
      parseInt(limit ?? '20') || 20,
    );
  }
}
