import { Injectable, BadRequestException, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { ConfigService } from '@nestjs/config';
import { Conversation, Message, MessageRole } from './entities/conversation.entity';
import { AiProviderInterface, AiMessage } from './providers/ai-provider.interface';
import { AnthropicProvider } from './providers/anthropic.provider';
import { OpenAiProvider } from './providers/openai.provider';
import { GeminiProvider } from './providers/gemini.provider';
import { SendMessageDto, AiProvider, GetRecommendationsDto, AiInsightRequestDto, AiSearchDto } from './dto/ai.dto';

const SYSTEM_PROMPT = `You are CalcMaster AI — an intelligent assistant embedded in CalcMaster, a world calculator and converter app. You help users with:
- Unit conversions (distance, volume, weight, temperature, speed, area, data, fuel, pressure, energy)
- Financial calculations (tax, tip, discount, interest, EMI, currency)
- Scientific calculations and number base conversions
- Tools (GPS, Ohm's law, BMI, dates, time zones, aspect ratio)

Be concise, accurate, and friendly. Format numbers with appropriate precision.
When the user's region or locale is known, tailor currency/tax advice accordingly.`;

@Injectable()
export class AiService {
  private readonly providers = new Map<string, AiProviderInterface>();
  private readonly defaultProvider: string;

  constructor(
    @InjectRepository(Conversation) private readonly convRepo: Repository<Conversation>,
    @InjectRepository(Message) private readonly msgRepo: Repository<Message>,
    private readonly config: ConfigService,
    anthropic: AnthropicProvider,
    openai: OpenAiProvider,
    gemini: GeminiProvider,
  ) {
    this.providers.set('anthropic', anthropic);
    this.providers.set('openai', openai);
    this.providers.set('gemini', gemini);
    this.defaultProvider = this.config.get('ai.defaultProvider') || 'anthropic';
  }

  async sendMessage(userId: string, dto: SendMessageDto) {
    const providerName = dto.provider || this.defaultProvider;
    const provider = this.providers.get(providerName);
    if (!provider?.isConfigured()) {
      throw new BadRequestException(`AI provider "${providerName}" is not configured`);
    }

    let conversation: Conversation;
    if (dto.conversationId) {
      const found = await this.convRepo.findOne({
        where: { id: dto.conversationId, userId },
      });
      if (!found) throw new NotFoundException('Conversation not found');
      conversation = found;
    } else {
      conversation = this.convRepo.create({
        userId,
        title: dto.message.slice(0, 60),
        context: dto.context,
      });
      conversation = await this.convRepo.save(conversation);
    }

    const userMsg = this.msgRepo.create({
      conversationId: conversation.id,
      role: MessageRole.USER,
      content: dto.message,
    });
    await this.msgRepo.save(userMsg);

    const history = await this.msgRepo.find({
      where: { conversationId: conversation.id },
      order: { createdAt: 'ASC' },
      take: 50,
    });

    const aiMessages: AiMessage[] = [
      { role: 'system', content: this.buildSystemPrompt(dto.context) },
      ...history.map((m) => ({ role: m.role as AiMessage['role'], content: m.content })),
    ];

    const result = await provider.chat(aiMessages, { maxTokens: 2048 });

    const assistantMsg = this.msgRepo.create({
      conversationId: conversation.id,
      role: MessageRole.ASSISTANT,
      content: result.content,
      model: result.model,
      provider: result.provider,
      tokensUsed: result.tokensUsed,
    });
    await this.msgRepo.save(assistantMsg);

    return {
      conversationId: conversation.id,
      message: {
        id: assistantMsg.id,
        role: assistantMsg.role,
        content: assistantMsg.content,
        model: result.model,
        tokensUsed: result.tokensUsed,
        createdAt: assistantMsg.createdAt,
      },
    };
  }

  async getConversations(userId: string) {
    return this.convRepo.find({
      where: { userId, isArchived: false },
      order: { updatedAt: 'DESC' },
      take: 50,
    });
  }

  async getConversation(userId: string, conversationId: string) {
    const conv = await this.convRepo.findOne({
      where: { id: conversationId, userId },
    });
    if (!conv) throw new NotFoundException('Conversation not found');

    const messages = await this.msgRepo.find({
      where: { conversationId },
      order: { createdAt: 'ASC' },
    });

    return { ...conv, messages };
  }

  async deleteConversation(userId: string, conversationId: string) {
    const conv = await this.convRepo.findOne({ where: { id: conversationId, userId } });
    if (!conv) throw new NotFoundException('Conversation not found');
    await this.msgRepo.delete({ conversationId });
    await this.convRepo.delete(conversationId);
  }

  async getRecommendations(userId: string, dto: GetRecommendationsDto) {
    const provider = this.getDefaultProvider();
    const prompt = `Based on the user's context, suggest 3-5 relevant ${dto.category} features or actions they might find useful.
User locale: ${dto.locale || 'en'}, region: ${dto.region || 'us'}.
Additional context: ${dto.context || 'none'}.
Return as a JSON array of objects with fields: title, description, action, icon.`;

    const result = await provider.chat(
      [
        { role: 'system', content: 'You are a recommendation engine. Return valid JSON only.' },
        { role: 'user', content: prompt },
      ],
      { maxTokens: 1024, temperature: 0.7 },
    );

    try {
      const jsonMatch = result.content.match(/\[[\s\S]*\]/);
      return JSON.parse(jsonMatch?.[0] || '[]');
    } catch {
      return [];
    }
  }

  async getInsights(userId: string, dto: AiInsightRequestDto) {
    const provider = this.getDefaultProvider();
    const prompt = `Analyze this data and provide a ${dto.insightType || 'summary'} insight:
${JSON.stringify(dto.data, null, 2)}
Return a JSON object with fields: summary, details (array of strings), confidence (0-1).`;

    const result = await provider.chat(
      [
        { role: 'system', content: 'You are a data analysis AI. Return valid JSON only.' },
        { role: 'user', content: prompt },
      ],
      { maxTokens: 1024, temperature: 0.3 },
    );

    try {
      const jsonMatch = result.content.match(/\{[\s\S]*\}/);
      return JSON.parse(jsonMatch?.[0] || '{}');
    } catch {
      return { summary: result.content, details: [], confidence: 0 };
    }
  }

  async search(userId: string, dto: AiSearchDto) {
    const provider = this.getDefaultProvider();
    const prompt = `The user is searching for: "${dto.query}" within scope: ${dto.scope || 'all'}.
Suggest relevant CalcMaster features, conversions, or calculations that match.
Return a JSON array of objects with fields: title, description, route, relevance (0-1).`;

    const result = await provider.chat(
      [
        { role: 'system', content: SYSTEM_PROMPT + '\nReturn valid JSON only.' },
        { role: 'user', content: prompt },
      ],
      { maxTokens: 512, temperature: 0.5 },
    );

    try {
      const jsonMatch = result.content.match(/\[[\s\S]*\]/);
      return JSON.parse(jsonMatch?.[0] || '[]');
    } catch {
      return [];
    }
  }

  private getDefaultProvider(): AiProviderInterface {
    const provider = this.providers.get(this.defaultProvider);
    if (!provider?.isConfigured()) {
      for (const [, p] of this.providers) {
        if (p.isConfigured()) return p;
      }
      throw new BadRequestException('No AI provider is configured');
    }
    return provider;
  }

  private buildSystemPrompt(context?: string): string {
    let prompt = SYSTEM_PROMPT;
    if (context) {
      prompt += `\n\nCurrent user context: ${context}`;
    }
    return prompt;
  }
}
