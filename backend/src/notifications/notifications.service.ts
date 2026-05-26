import { Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { ConfigService } from '@nestjs/config';
import { User } from '../users/entities/user.entity';

interface PushPayload {
  title: string;
  body: string;
  data?: Record<string, string>;
  imageUrl?: string;
}

@Injectable()
export class NotificationsService {
  private readonly logger = new Logger(NotificationsService.name);
  private firebaseApp: any = null;

  constructor(
    @InjectRepository(User) private readonly userRepo: Repository<User>,
    private readonly config: ConfigService,
  ) {
    this.initFirebase();
  }

  private async initFirebase() {
    const projectId = this.config.get('firebase.projectId');
    if (!projectId) {
      this.logger.warn('Firebase not configured — push notifications disabled');
      return;
    }

    try {
      const admin = await import('firebase-admin');
      if (!admin.apps.length) {
        this.firebaseApp = admin.initializeApp({
          credential: admin.credential.cert({
            projectId,
            privateKey: this.config.get('firebase.privateKey')?.replace(/\\n/g, '\n'),
            clientEmail: this.config.get('firebase.clientEmail'),
          }),
        });
      } else {
        this.firebaseApp = admin.apps[0];
      }
    } catch (err) {
      this.logger.error('Firebase init failed', err);
    }
  }

  async sendToUser(userId: string, payload: PushPayload): Promise<boolean> {
    const user = await this.userRepo.findOne({
      where: { id: userId, isDeleted: false },
      select: { id: true, fcmToken: true, pushEnabled: true },
    });

    if (!user?.fcmToken || !user.pushEnabled) return false;
    return this.sendToToken(user.fcmToken, payload);
  }

  async sendToToken(token: string, payload: PushPayload): Promise<boolean> {
    if (!this.firebaseApp) {
      this.logger.debug(`[DRY RUN] Push to ${token.slice(0, 10)}...: ${payload.title}`);
      return true;
    }

    try {
      const admin = await import('firebase-admin');
      await admin.messaging().send({
        token,
        notification: {
          title: payload.title,
          body: payload.body,
          imageUrl: payload.imageUrl,
        },
        data: payload.data,
        apns: {
          payload: {
            aps: { sound: 'default', badge: 1 },
          },
        },
        android: {
          priority: 'high' as const,
          notification: { sound: 'default', channelId: 'calcmaster_default' },
        },
      });
      return true;
    } catch (err) {
      this.logger.error(`Push failed for token ${token.slice(0, 10)}...`, err);
      return false;
    }
  }

  async sendToTopic(topic: string, payload: PushPayload): Promise<boolean> {
    if (!this.firebaseApp) {
      this.logger.debug(`[DRY RUN] Push to topic ${topic}: ${payload.title}`);
      return true;
    }

    try {
      const admin = await import('firebase-admin');
      await admin.messaging().send({
        topic,
        notification: { title: payload.title, body: payload.body },
        data: payload.data,
      });
      return true;
    } catch (err) {
      this.logger.error(`Topic push failed for ${topic}`, err);
      return false;
    }
  }

  async sendBulk(userIds: string[], payload: PushPayload): Promise<{ sent: number; failed: number }> {
    let sent = 0;
    let failed = 0;
    for (const userId of userIds) {
      const ok = await this.sendToUser(userId, payload);
      ok ? sent++ : failed++;
    }
    return { sent, failed };
  }
}
