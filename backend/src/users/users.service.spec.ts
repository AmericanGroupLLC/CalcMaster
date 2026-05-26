import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { NotFoundException } from '@nestjs/common';
import { UsersService } from './users.service';
import { User, AuthProvider, UserRole } from './entities/user.entity';

const mockUser: Partial<User> = {
  id: 'test-uuid-1234',
  email: 'test@example.com',
  displayName: 'Test User',
  role: UserRole.USER,
  locale: 'en',
  region: 'US',
  isDeleted: false,
  provider: AuthProvider.EMAIL,
};

const mockUserRepo = {
  findOne: jest.fn(),
  findAndCount: jest.fn(),
  update: jest.fn(),
};

describe('UsersService', () => {
  let service: UsersService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        UsersService,
        { provide: getRepositoryToken(User), useValue: mockUserRepo },
      ],
    }).compile();

    service = module.get<UsersService>(UsersService);
    jest.clearAllMocks();
  });

  describe('findById', () => {
    it('should return a user when found', async () => {
      mockUserRepo.findOne.mockResolvedValue(mockUser);
      const result = await service.findById('test-uuid-1234');
      expect(result).toEqual(mockUser);
    });

    it('should throw NotFoundException when user not found', async () => {
      mockUserRepo.findOne.mockResolvedValue(null);
      await expect(service.findById('nonexistent')).rejects.toThrow(NotFoundException);
    });
  });

  describe('updateProfile', () => {
    it('should update allowed fields only', async () => {
      mockUserRepo.findOne.mockResolvedValue(mockUser);
      mockUserRepo.update.mockResolvedValue(undefined);

      await service.updateProfile('test-uuid-1234', {
        displayName: 'New Name',
        locale: 'es',
        dangerousField: 'should be ignored',
      });

      expect(mockUserRepo.update).toHaveBeenCalledWith('test-uuid-1234', {
        displayName: 'New Name',
        locale: 'es',
      });
    });
  });

  describe('updateFcmToken', () => {
    it('should update the FCM token', async () => {
      mockUserRepo.update.mockResolvedValue(undefined);
      await service.updateFcmToken('test-uuid-1234', 'new-fcm-token');
      expect(mockUserRepo.update).toHaveBeenCalledWith('test-uuid-1234', {
        fcmToken: 'new-fcm-token',
      });
    });
  });

  describe('deleteAccount', () => {
    it('should soft-delete a user', async () => {
      mockUserRepo.update.mockResolvedValue(undefined);
      await service.deleteAccount('test-uuid-1234');
      expect(mockUserRepo.update).toHaveBeenCalledWith(
        'test-uuid-1234',
        expect.objectContaining({
          isDeleted: true,
          email: expect.stringContaining('deleted'),
        }),
      );
    });
  });
});
