import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AiController } from './ai.controller';
import { AiService } from './ai.service';
import { Conversation, Message } from './entities/conversation.entity';
import { AnthropicProvider } from './providers/anthropic.provider';
import { OpenAiProvider } from './providers/openai.provider';
import { GeminiProvider } from './providers/gemini.provider';
import { AuthModule } from '../auth/auth.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([Conversation, Message]),
    AuthModule,
  ],
  controllers: [AiController],
  providers: [AiService, AnthropicProvider, OpenAiProvider, GeminiProvider],
  exports: [AiService],
})
export class AiModule {}
