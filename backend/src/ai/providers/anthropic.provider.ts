import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import {
  AiProviderInterface,
  AiMessage,
  AiCompletionOptions,
  AiCompletionResult,
} from './ai-provider.interface';

@Injectable()
export class AnthropicProvider implements AiProviderInterface {
  readonly name = 'anthropic';
  private readonly apiKey: string | undefined;
  private readonly defaultModel: string;

  constructor(private readonly config: ConfigService) {
    this.apiKey = this.config.get('ai.anthropicKey');
    this.defaultModel = this.config.get('ai.defaultModel') || 'claude-sonnet-4-6';
  }

  isConfigured(): boolean {
    return !!this.apiKey;
  }

  async chat(messages: AiMessage[], options?: AiCompletionOptions): Promise<AiCompletionResult> {
    const model = options?.model || this.defaultModel;
    const systemMessages = messages.filter((m) => m.role === 'system');
    const chatMessages = messages.filter((m) => m.role !== 'system');

    const body: Record<string, any> = {
      model,
      max_tokens: options?.maxTokens || 2048,
      messages: chatMessages.map((m) => ({ role: m.role, content: m.content })),
    };

    if (systemMessages.length > 0) {
      body.system = systemMessages.map((m) => m.content).join('\n');
    }
    if (options?.temperature !== undefined) {
      body.temperature = options.temperature;
    }

    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), 60000);
    const response = await fetch('https://api.anthropic.com/v1/messages', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': this.apiKey!,
        'anthropic-version': '2023-06-01',
      },
      body: JSON.stringify(body),
      signal: controller.signal,
    });
    clearTimeout(timeout);

    if (!response.ok) {
      const err = await response.text();
      throw new Error(`Anthropic API error ${response.status}: ${err}`);
    }

    const data = await response.json();
    const content = data.content?.[0]?.text || '';
    const tokensUsed = (data.usage?.input_tokens || 0) + (data.usage?.output_tokens || 0);

    return { content, model, provider: this.name, tokensUsed };
  }
}
