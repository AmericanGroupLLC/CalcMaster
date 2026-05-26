import { IsString, IsOptional, IsEnum, IsArray, ValidateNested, IsUUID } from 'class-validator';
import { Type } from 'class-transformer';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export enum AiProvider {
  OPENAI = 'openai',
  ANTHROPIC = 'anthropic',
  GEMINI = 'gemini',
}

export class ChatMessageDto {
  @ApiProperty({ enum: ['user', 'assistant', 'system'] })
  @IsEnum(['user', 'assistant', 'system'])
  role: 'user' | 'assistant' | 'system';

  @ApiProperty()
  @IsString()
  content: string;
}

export class SendMessageDto {
  @ApiProperty({ description: 'User message' })
  @IsString()
  message: string;

  @ApiPropertyOptional({ description: 'Conversation ID — omit to start new' })
  @IsOptional()
  @IsUUID()
  conversationId?: string;

  @ApiPropertyOptional({ description: 'Extra context for the AI (e.g., current screen, region)' })
  @IsOptional()
  @IsString()
  context?: string;

  @ApiPropertyOptional({ enum: AiProvider })
  @IsOptional()
  @IsEnum(AiProvider)
  provider?: AiProvider;
}

export class GetRecommendationsDto {
  @ApiProperty({ description: 'Category: finance, units, tools, etc.' })
  @IsString()
  category: string;

  @ApiPropertyOptional({ description: 'Current user context as JSON' })
  @IsOptional()
  @IsString()
  context?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  locale?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  region?: string;
}

export class AiInsightRequestDto {
  @ApiProperty({ description: 'Data payload to analyze' })
  data: Record<string, any>;

  @ApiPropertyOptional({ description: 'Type of insight: summary, trend, anomaly, forecast' })
  @IsOptional()
  @IsString()
  insightType?: string;
}

export class AiSearchDto {
  @ApiProperty()
  @IsString()
  query: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  scope?: string;
}
