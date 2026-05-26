import { Test, TestingModule } from '@nestjs/testing';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { getRepositoryToken } from '@nestjs/typeorm';
import { ConflictException, UnauthorizedException } from '@nestjs/common';
import { AuthService } from './auth.service';
import { User, AuthProvider, UserRole } from '../users/entities/user.entity';
import * as bcrypt from 'bcryptjs';

const mockUser: Partial<User> = {
  id: 'test-uuid-1234',
  email: 'test@example.com',
  passwordHash: '',
  displayName: 'Test User',
  role: UserRole.USER,
  locale: 'en',
  region: 'US',
  mfaEnabled: false,
  mfaSecret: undefined,
  isDeleted: false,
  provider: AuthProvider.EMAIL,
};

const mockUserRepo = {
  findOne: jest.fn(),
  create: jest.fn(),
  save: jest.fn(),
  update: jest.fn(),
};

const mockJwtService = {
  sign: jest.fn().mockReturnValue('mock-jwt-token'),
  verify: jest.fn(),
  decode: jest.fn(),
};

const mockConfigService = {
  get: jest.fn().mockImplementation((key: string) => {
    const config: Record<string, string> = {
      'jwt.accessExpiresIn': '15m',
      'jwt.refreshExpiresIn': '7d',
      'google.clientId': 'mock-google-client-id',
    };
    return config[key] || '';
  }),
};

describe('AuthService', () => {
  let service: AuthService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AuthService,
        { provide: getRepositoryToken(User), useValue: mockUserRepo },
        { provide: JwtService, useValue: mockJwtService },
        { provide: ConfigService, useValue: mockConfigService },
      ],
    }).compile();

    service = module.get<AuthService>(AuthService);
    jest.clearAllMocks();
  });

  describe('register', () => {
    it('should register a new user and return tokens', async () => {
      const hashedPassword = await bcrypt.hash('password123', 12);
      const savedUser = { ...mockUser, passwordHash: hashedPassword };

      mockUserRepo.findOne.mockResolvedValue(null);
      mockUserRepo.create.mockReturnValue(savedUser);
      mockUserRepo.save.mockResolvedValue(savedUser);
      mockUserRepo.update.mockResolvedValue(undefined);

      const result = await service.register({
        email: 'test@example.com',
        password: 'password123',
        displayName: 'Test User',
      });

      expect(result).toHaveProperty('accessToken');
      expect(result).toHaveProperty('refreshToken');
      expect(result.user.email).toBe('test@example.com');
    });

    it('should throw ConflictException if email already exists', async () => {
      mockUserRepo.findOne.mockResolvedValue(mockUser);

      await expect(
        service.register({ email: 'test@example.com', password: 'password123' }),
      ).rejects.toThrow(ConflictException);
    });
  });

  describe('login', () => {
    it('should return tokens for valid credentials', async () => {
      const hashedPassword = await bcrypt.hash('password123', 12);
      const userWithPassword = { ...mockUser, passwordHash: hashedPassword };

      mockUserRepo.findOne.mockResolvedValue(userWithPassword);
      mockUserRepo.update.mockResolvedValue(undefined);

      const result = await service.login({
        email: 'test@example.com',
        password: 'password123',
      });

      expect(result).toHaveProperty('accessToken');
    });

    it('should throw UnauthorizedException for invalid password', async () => {
      const hashedPassword = await bcrypt.hash('correctpassword', 12);
      const userWithPassword = { ...mockUser, passwordHash: hashedPassword };

      mockUserRepo.findOne.mockResolvedValue(userWithPassword);

      await expect(
        service.login({ email: 'test@example.com', password: 'wrongpassword' }),
      ).rejects.toThrow(UnauthorizedException);
    });

    it('should throw UnauthorizedException for non-existent user', async () => {
      mockUserRepo.findOne.mockResolvedValue(null);

      await expect(
        service.login({ email: 'nouser@example.com', password: 'password123' }),
      ).rejects.toThrow(UnauthorizedException);
    });

    it('should return requiresMfa for MFA-enabled users', async () => {
      const hashedPassword = await bcrypt.hash('password123', 12);
      const mfaUser = { ...mockUser, passwordHash: hashedPassword, mfaEnabled: true, mfaSecret: 'secret' };

      mockUserRepo.findOne.mockResolvedValue(mfaUser);

      const result = await service.login({
        email: 'test@example.com',
        password: 'password123',
      });

      expect(result).toHaveProperty('requiresMfa', true);
      expect(result).toHaveProperty('tempToken');
    });
  });

  describe('logout', () => {
    it('should clear the refresh token', async () => {
      mockUserRepo.update.mockResolvedValue(undefined);

      await service.logout('test-uuid-1234');

      expect(mockUserRepo.update).toHaveBeenCalledWith('test-uuid-1234', {
        refreshToken: undefined,
      });
    });
  });
});
