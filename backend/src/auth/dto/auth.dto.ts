import { IsEmail, IsString, MinLength, IsOptional, IsEnum, Matches } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class RegisterDto {
  @ApiProperty({ example: 'user@example.com' })
  @IsEmail()
  email: string;

  @ApiProperty({ example: 'SecureP@ss1' })
  @IsString()
  @MinLength(8)
  @Matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/, {
    message: 'Password must contain uppercase, lowercase, and a number',
  })
  password: string;

  @ApiPropertyOptional({ example: 'Alex' })
  @IsOptional()
  @IsString()
  displayName?: string;

  @ApiPropertyOptional({ example: 'en' })
  @IsOptional()
  @IsString()
  locale?: string;

  @ApiPropertyOptional({ example: 'us' })
  @IsOptional()
  @IsString()
  region?: string;
}

export class LoginDto {
  @ApiProperty({ example: 'user@example.com' })
  @IsEmail()
  email: string;

  @ApiProperty({ example: 'SecureP@ss1' })
  @IsString()
  password: string;
}

export class RefreshTokenDto {
  @ApiProperty()
  @IsString()
  refreshToken: string;
}

export class OAuthLoginDto {
  @ApiProperty()
  @IsString()
  idToken: string;

  @ApiProperty({ enum: ['google', 'apple'] })
  @IsEnum(['google', 'apple'])
  provider: 'google' | 'apple';

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  displayName?: string;
}

export class EnableMfaDto {
  @ApiProperty({ description: 'TOTP code from authenticator app' })
  @IsString()
  @Matches(/^\d{6}$/)
  code: string;
}

export class VerifyMfaDto {
  @ApiProperty()
  @IsString()
  @Matches(/^\d{6}$/)
  code: string;

  @ApiProperty()
  @IsString()
  tempToken: string;
}

export class AuthResponseDto {
  accessToken: string;
  refreshToken: string;
  user: {
    id: string;
    email: string;
    displayName: string;
    role: string;
    locale: string;
    region: string;
    mfaEnabled: boolean;
  };
}

export class MfaSetupResponseDto {
  secret: string;
  qrCodeUrl: string;
  otpauthUrl: string;
}
