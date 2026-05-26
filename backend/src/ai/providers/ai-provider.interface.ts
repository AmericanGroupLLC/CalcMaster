export interface AiMessage {
  role: 'user' | 'assistant' | 'system';
  content: string;
}

export interface AiCompletionOptions {
  model?: string;
  maxTokens?: number;
  temperature?: number;
  systemPrompt?: string;
}

export interface AiCompletionResult {
  content: string;
  model: string;
  provider: string;
  tokensUsed: number;
}

export interface AiProviderInterface {
  readonly name: string;
  chat(messages: AiMessage[], options?: AiCompletionOptions): Promise<AiCompletionResult>;
  isConfigured(): boolean;
}
