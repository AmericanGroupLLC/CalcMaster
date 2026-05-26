import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { BadRequestException } from '@nestjs/common';
import { SubscriptionsService } from './subscriptions.service';
import { Subscription, SubscriptionPlan, SubscriptionStatus, PaymentProvider } from './entities/subscription.entity';

const mockSubRepo = {
  findOne: jest.fn(),
  find: jest.fn(),
  findAndCount: jest.fn(),
  create: jest.fn(),
  save: jest.fn(),
  update: jest.fn(),
};

describe('SubscriptionsService', () => {
  let service: SubscriptionsService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        SubscriptionsService,
        { provide: getRepositoryToken(Subscription), useValue: mockSubRepo },
      ],
    }).compile();

    service = module.get<SubscriptionsService>(SubscriptionsService);
    jest.clearAllMocks();
  });

  describe('getActive', () => {
    it('should return active subscription', async () => {
      const mockSub = { id: 'sub-1', userId: 'user-1', plan: SubscriptionPlan.MONTHLY, status: SubscriptionStatus.ACTIVE };
      mockSubRepo.findOne.mockResolvedValue(mockSub);

      const result = await service.getActive('user-1');
      expect(result).toEqual(mockSub);
    });

    it('should return null when no active subscription', async () => {
      mockSubRepo.findOne.mockResolvedValue(null);
      const result = await service.getActive('user-1');
      expect(result).toBeNull();
    });
  });

  describe('create', () => {
    it('should create a monthly subscription', async () => {
      const mockSub = {
        id: 'sub-1',
        userId: 'user-1',
        plan: SubscriptionPlan.MONTHLY,
        status: SubscriptionStatus.ACTIVE,
        paymentProvider: PaymentProvider.APPLE,
      };

      mockSubRepo.findOne.mockResolvedValue(null);
      mockSubRepo.create.mockReturnValue(mockSub);
      mockSubRepo.save.mockResolvedValue(mockSub);

      const result = await service.create('user-1', SubscriptionPlan.MONTHLY, PaymentProvider.APPLE);
      expect(result.plan).toBe(SubscriptionPlan.MONTHLY);
    });

    it('should throw BadRequestException when active subscription exists', async () => {
      const existingSub = {
        id: 'sub-1',
        plan: SubscriptionPlan.ANNUAL,
        status: SubscriptionStatus.ACTIVE,
      };
      mockSubRepo.findOne.mockResolvedValue(existingSub);

      await expect(
        service.create('user-1', SubscriptionPlan.MONTHLY, PaymentProvider.APPLE),
      ).rejects.toThrow(BadRequestException);
    });
  });

  describe('cancel', () => {
    it('should cancel a subscription', async () => {
      const mockSub = { id: 'sub-1', userId: 'user-1', plan: SubscriptionPlan.MONTHLY, status: SubscriptionStatus.ACTIVE };
      mockSubRepo.findOne.mockResolvedValue(mockSub);
      mockSubRepo.save.mockResolvedValue({ ...mockSub, status: SubscriptionStatus.CANCELLED });

      const result = await service.cancel('user-1', 'sub-1');
      expect(result.status).toBe(SubscriptionStatus.CANCELLED);
    });
  });
});
