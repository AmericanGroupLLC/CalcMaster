import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import {
  AiProviderInterface,
  AiMessage,
  AiCompletionOptions,
  AiCompletionResult,
} from './ai-provider.interface';

@Injectable()
export class GeminiProvider implements AiProviderInterface {
  readonly name = 'gemini';
  private readonly apiKey: string | undefined;

  constructor(private readonly config: ConfigService) {
    this.apiKey = this.config.get('ai.geminiKey');
  }

  isConfigured(): boolean {
    return !!this.apiKey;
  }

  async chat(messages: AiMessage[], options?: AiCompletionOptions): Promise<AiCompletionResult> {
    const model = options?.model || 'gemini-2.0-flash';

    const contents = messages
      .filter((m) => m.role !== 'system')
      .map((m) => ({
        role: m.role === 'assistant' ? 'model' : 'user',
        parts: [{ text: m.content }],
      }));

    const systemInstruction = messages
      .filter((m) => m.role === 'system')
      .map((m) => m.content)
      .join('\n');

    const body: Record<string, any> = {
      contents,
      generationConfig: {
        maxOutputTokens: options?.maxTokens || 2048,
      },
    };
    if (systemInstruction) {
      body.systemInstruction = { parts: [{ text: systemInstruction }] };
    }
    if (options?.temperature !== undefined) {
      body.generationConfig.temperature = options.temperature;
    }

    const url = `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent`;
    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), 60000);
    const response = await fetch(url, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-goog-api-key': this.apiKey!,
      },
      body: JSON.stringify(body),
      signal: controller.signal,
    });
    clearTimeout(timeout);

    if (!response.ok) {
      const err = await response.text();
      throw new Error(`Gemini API error ${response.status}: ${err}`);
    }

    const data = await response.json();
    const content = data.candidates?.[0]?.content?.parts?.[0]?.text || '';
    const tokensUsed =
      (data.usageMetadata?.promptTokenCount || 0) +
      (data.usageMetadata?.candidatesTokenCount || 0);

    return { content, model, provider: this.name, tokensUsed };
  }
}
