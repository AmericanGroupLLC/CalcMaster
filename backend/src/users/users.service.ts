import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from './entities/user.entity';

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(User) private readonly userRepo: Repository<User>,
  ) {}

  async findById(id: string): Promise<User> {
    const user = await this.userRepo.findOne({ where: { id, isDeleted: false } });
    if (!user) throw new NotFoundException('User not found');
    return user;
  }

  async updateProfile(id: string, updates: Record<string, unknown>): Promise<User> {
    await this.findById(id);
    const allowed = ['displayName', 'locale', 'region', 'avatarUrl', 'pushEnabled', 'emailNotificationsEnabled'];
    const filtered: Partial<User> = {};
    for (const key of allowed) {
      if (updates[key] !== undefined) (filtered as Record<string, unknown>)[key] = updates[key];
    }
    await this.userRepo.update(id, filtered);
    return this.findById(id);
  }

  async updateFcmToken(id: string, fcmToken: string): Promise<void> {
    await this.userRepo.update(id, { fcmToken });
  }

  async deleteAccount(id: string): Promise<void> {
    await this.userRepo.update(id, {
      isDeleted: true,
      deletedAt: new Date(),
      email: `deleted_${id}@deleted.local`,
      displayName: 'Deleted User',
      avatarUrl: undefined,
      fcmToken: undefined,
      refreshToken: undefined,
      mfaSecret: undefined,
      mfaEnabled: false,
    });
  }

  async exportData(id: string): Promise<Record<string, any>> {
    const user = await this.userRepo.findOne({
      where: { id },
      relations: { subscriptions: true, conversations: true },
    });
    if (!user) throw new NotFoundException('User not found');
    const { passwordHash, refreshToken, mfaSecret, ...safeUser } = user as any;
    return safeUser;
  }

  async findAll(page = 1, limit = 20) {
    const [users, total] = await this.userRepo.findAndCount({
      where: { isDeleted: false },
      order: { createdAt: 'DESC' },
      skip: (page - 1) * limit,
      take: limit,
    });
    return { users, total, page, totalPages: Math.ceil(total / limit) };
  }
}
