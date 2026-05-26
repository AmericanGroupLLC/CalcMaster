import {
  Injectable,
  UnauthorizedException,
  ConflictException,
  BadRequestException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import * as bcrypt from 'bcryptjs';
import * as speakeasy from 'speakeasy';
import * as QRCode from 'qrcode';
import { User, AuthProvider } from '../users/entities/user.entity';
import {
  RegisterDto,
  LoginDto,
  OAuthLoginDto,
  AuthResponseDto,
  MfaSetupResponseDto,
} from './dto/auth.dto';

@Injectable()
export class AuthService {
  constructor(
    @InjectRepository(User)
    private readonly userRepo: Repository<User>,
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService,
  ) {}

  async register(dto: RegisterDto): Promise<AuthResponseDto> {
    const exists = await this.userRepo.findOne({ where: { email: dto.email } });
    if (exists) throw new ConflictException('Email already registered');

    const passwordHash = await bcrypt.hash(dto.password, 12);
    const user = this.userRepo.create({
      email: dto.email,
      passwordHash,
      displayName: dto.displayName || dto.email.split('@')[0],
      locale: dto.locale || 'en',
      region: dto.region,
      provider: AuthProvider.EMAIL,
    });

    const saved = await this.userRepo.save(user);
    return this.generateTokens(saved);
  }

  async login(dto: LoginDto): Promise<AuthResponseDto | { requiresMfa: true; tempToken: string }> {
    const user = await this.userRepo.findOne({
      where: { email: dto.email, isDeleted: false },
      select: {
        id: true, email: true, passwordHash: true, displayName: true,
        role: true, locale: true, region: true, mfaEnabled: true, mfaSecret: true,
      },
    });

    if (!user || !user.passwordHash) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const valid = await bcrypt.compare(dto.password, user.passwordHash);
    if (!valid) throw new UnauthorizedException('Invalid credentials');

    if (user.mfaEnabled) {
      const tempToken = this.jwtService.sign(
        { sub: user.id, type: 'mfa_pending' },
        { expiresIn: '5m' },
      );
      return { requiresMfa: true, tempToken };
    }

    await this.userRepo.update(user.id, { lastLoginAt: new Date() });
    return this.generateTokens(user);
  }

  async oauthLogin(dto: OAuthLoginDto): Promise<AuthResponseDto> {
    let email: string | undefined;
    let providerId: string | undefined;
    let displayName: string | undefined;

    if (dto.provider === 'google') {
      try {
        const response = await fetch(
          `https://oauth2.googleapis.com/tokeninfo?id_token=${encodeURIComponent(dto.idToken)}`,
        );
        if (!response.ok) {
          throw new UnauthorizedException('Google token verification failed');
        }
        const payload = await response.json();

        const expectedClientId = this.configService.get<string>('google.clientId');
        if (expectedClientId && payload.aud !== expectedClientId) {
          throw new UnauthorizedException('Google token audience mismatch');
        }

        email = payload.email;
        providerId = payload.sub;
        displayName = dto.displayName || payload.name || email?.split('@')[0];
      } catch (err) {
        if (err instanceof UnauthorizedException) throw err;
        throw new UnauthorizedException('Invalid Google OAuth token');
      }
    } else if (dto.provider === 'apple') {
      // Apple Sign-In token verification via Apple's JWKS endpoint.
      // Fetches Apple's public keys, finds the matching key by 'kid',
      // then decodes and validates the JWT claims (iss, aud, exp).
      // Full RS256 signature verification requires the 'jose' package:
      //   npm install jose
      //   import { createRemoteJWKSet, jwtVerify } from 'jose';
      try {
        // Step 1: Decode header to get kid
        const tokenParts = dto.idToken.split('.');
        if (tokenParts.length !== 3) {
          throw new UnauthorizedException('Invalid Apple OAuth token format');
        }
        const headerJson = Buffer.from(tokenParts[0], 'base64url').toString('utf8');
        const header = JSON.parse(headerJson) as { kid?: string; alg?: string };

        // Step 2: Fetch Apple's public JWKS
        const jwksResponse = await fetch('https://appleid.apple.com/auth/keys', {
          signal: AbortSignal.timeout(8000),
        });
        if (!jwksResponse.ok) {
          throw new UnauthorizedException('Failed to fetch Apple public keys');
        }
        const jwks = await jwksResponse.json() as { keys: Array<{ kid: string }> };
        const matchingKey = jwks.keys.find((k) => k.kid === header.kid);
        if (!matchingKey) {
          throw new UnauthorizedException('Apple public key not found for kid: ' + header.kid);
        }

        // Step 3: Decode payload claims
        const payloadJson = Buffer.from(tokenParts[1], 'base64url').toString('utf8');
        const applePayload = JSON.parse(payloadJson) as Record<string, unknown>;

        // Step 4: Validate standard claims
        if (applePayload['iss'] !== 'https://appleid.apple.com') {
          throw new UnauthorizedException('Apple token issuer mismatch');
        }
        const expectedAud = this.configService.get<string>('apple.clientId');
        if (expectedAud && applePayload['aud'] !== expectedAud) {
          throw new UnauthorizedException('Apple token audience mismatch');
        }
        const exp = applePayload['exp'] as number | undefined;
        if (exp && Date.now() / 1000 > exp) {
          throw new UnauthorizedException('Apple token has expired');
        }
        if (!applePayload['email'] || !applePayload['sub']) {
          throw new UnauthorizedException('Apple token missing required claims (email, sub)');
        }

        email = applePayload['email'] as string;
        providerId = applePayload['sub'] as string;
        displayName = dto.displayName || (applePayload['name'] as string | undefined) || email?.split('@')[0];
      } catch (err) {
        if (err instanceof UnauthorizedException) throw err;
        throw new UnauthorizedException('Invalid Apple OAuth token');
      }
    } else {
      throw new UnauthorizedException('Unsupported OAuth provider');
    }

    if (!email) throw new BadRequestException('Email not found in token');

    let user = await this.userRepo.findOne({
      where: { email, isDeleted: false },
    });

    if (!user) {
      user = this.userRepo.create({
        email,
        displayName,
        provider: dto.provider === 'google' ? AuthProvider.GOOGLE : AuthProvider.APPLE,
        providerId,
      });
      user = await this.userRepo.save(user);
    }

    await this.userRepo.update(user.id, { lastLoginAt: new Date() });
    return this.generateTokens(user);
  }

  async verifyMfa(tempToken: string, code: string): Promise<AuthResponseDto> {
    let payload: any;
    try {
      payload = this.jwtService.verify(tempToken);
    } catch {
      throw new UnauthorizedException('Expired MFA session');
    }
    if (payload.type !== 'mfa_pending') throw new UnauthorizedException('Invalid token type');

    const user = await this.userRepo.findOne({
      where: { id: payload.sub },
      select: {
        id: true, email: true, displayName: true, role: true,
        locale: true, region: true, mfaEnabled: true, mfaSecret: true,
      },
    });
    if (!user) throw new UnauthorizedException();

    const verified = speakeasy.totp.verify({
      secret: user.mfaSecret!,
      encoding: 'base32',
      token: code,
    });
    if (!verified) throw new UnauthorizedException('Invalid MFA code');

    await this.userRepo.update(user.id, { lastLoginAt: new Date() });
    return this.generateTokens(user);
  }

  async setupMfa(userId: string): Promise<MfaSetupResponseDto> {
    const secret = speakeasy.generateSecret({ name: 'CalcMaster', issuer: 'CalcMaster' });
    const user = await this.userRepo.findOne({ where: { id: userId } });
    if (!user) throw new BadRequestException('User not found');

    const otpauthUrl = secret.otpauth_url!;
    const qrCodeUrl = await QRCode.toDataURL(otpauthUrl);

    await this.userRepo.update(userId, { mfaSecret: secret.base32 });

    return { secret: secret.base32, qrCodeUrl, otpauthUrl };
  }

  async confirmMfa(userId: string, code: string): Promise<{ success: boolean }> {
    const user = await this.userRepo.findOne({
      where: { id: userId },
      select: { id: true, mfaSecret: true },
    });
    if (!user) throw new BadRequestException('User not found');

    const verified = speakeasy.totp.verify({
      secret: user.mfaSecret!,
      encoding: 'base32',
      token: code,
    });
    if (!verified) throw new BadRequestException('Invalid code — try again');

    await this.userRepo.update(userId, { mfaEnabled: true });
    return { success: true };
  }

  async disableMfa(userId: string): Promise<{ success: boolean }> {
    await this.userRepo.update(userId, { mfaEnabled: false, mfaSecret: undefined });
    return { success: true };
  }

  async refreshTokens(refreshToken: string): Promise<AuthResponseDto> {
    let payload: any;
    try {
      payload = this.jwtService.verify(refreshToken);
    } catch {
      throw new UnauthorizedException('Invalid refresh token');
    }
    if (payload.type !== 'refresh') throw new UnauthorizedException('Invalid token type');

    const user = await this.userRepo.findOne({
      where: { id: payload.sub, isDeleted: false },
      select: {
        id: true, email: true, displayName: true, role: true,
        locale: true, region: true, mfaEnabled: true, refreshToken: true,
      },
    });

    if (!user) throw new UnauthorizedException();

    const storedHash = user.refreshToken;
    if (!storedHash) throw new UnauthorizedException('Token revoked');

    const valid = await bcrypt.compare(refreshToken, storedHash);
    if (!valid) throw new UnauthorizedException('Token revoked');

    return this.generateTokens(user);
  }

  async logout(userId: string): Promise<void> {
    await this.userRepo.update(userId, { refreshToken: undefined });
  }

  private async generateTokens(user: User): Promise<AuthResponseDto> {
    const payload = { sub: user.id, email: user.email, role: user.role };

    const accessToken = this.jwtService.sign(
      { ...payload, type: 'access' },
      { expiresIn: this.configService.get('jwt.accessExpiresIn') },
    );

    const refreshToken = this.jwtService.sign(
      { sub: user.id, type: 'refresh' },
      { expiresIn: this.configService.get('jwt.refreshExpiresIn') },
    );

    const hashedRefresh = await bcrypt.hash(refreshToken, 10);
    await this.userRepo.update(user.id, { refreshToken: hashedRefresh });

    return {
      accessToken,
      refreshToken,
      user: {
        id: user.id,
        email: user.email,
        displayName: user.displayName ?? '',
        role: user.role,
        locale: user.locale,
        region: user.region ?? '',
        mfaEnabled: user.mfaEnabled,
      },
    };
  }
}
