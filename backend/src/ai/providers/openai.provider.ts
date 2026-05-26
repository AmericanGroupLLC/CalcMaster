import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import {
  AiProviderInterface,
  AiMessage,
  AiCompletionOptions,
  AiCompletionResult,
} from './ai-provider.interface';

@Injectable()
export class OpenAiProvider implements AiProviderInterface {
  readonly name = 'openai';
  private readonly apiKey: string | undefined;

  constructor(private readonly config: ConfigService) {
    this.apiKey = this.config.get('ai.openaiKey');
  }

  isConfigured(): boolean {
    return !!this.apiKey;
  }

  async chat(messages: AiMessage[], options?: AiCompletionOptions): Promise<AiCompletionResult> {
    const model = options?.model || 'gpt-4o';

    const body: Record<string, any> = {
      model,
      max_tokens: options?.maxTokens || 2048,
      messages: messages.map((m) => ({ role: m.role, content: m.content })),
    };
    if (options?.temperature !== undefined) {
      body.temperature = options.temperature;
    }

    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), 60000);
    const response = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${this.apiKey}`,
      },
      body: JSON.stringify(body),
      signal: controller.signal,
    });
    clearTimeout(timeout);

    if (!response.ok) {
      const err = await response.text();
      throw new Error(`OpenAI API error ${response.status}: ${err}`);
    }

    const data = await response.json();
    const content = data.choices?.[0]?.message?.content || '';
    const tokensUsed = data.usage?.total_tokens || 0;

    return { content, model, provider: this.name, tokensUsed };
  }
}
