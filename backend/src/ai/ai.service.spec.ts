import { Test, TestingModule } from '@nestjs/testing';
import { ConfigService } from '@nestjs/config';
import { getRepositoryToken } from '@nestjs/typeorm';
import { BadRequestException, NotFoundException } from '@nestjs/common';
import { AiService } from './ai.service';
import { Conversation, Message } from './entities/conversation.entity';
import { AnthropicProvider } from './providers/anthropic.provider';
import { OpenAiProvider } from './providers/openai.provider';
import { GeminiProvider } from './providers/gemini.provider';

const mockConvRepo = {
  findOne: jest.fn(),
  create: jest.fn(),
  save: jest.fn(),
  find: jest.fn(),
  findAndCount: jest.fn(),
  remove: jest.fn(),
  delete: jest.fn(),
};

const mockMsgRepo = {
  create: jest.fn(),
  save: jest.fn(),
  find: jest.fn(),
};

const mockAnthropicProvider = {
  name: 'anthropic',
  isConfigured: jest.fn().mockReturnValue(true),
  chat: jest.fn().mockResolvedValue({
    content: 'Hello! I am CalcMaster AI.',
    model: 'claude-sonnet-4-6',
    provider: 'anthropic',
    tokensUsed: 50,
  }),
};

const mockOpenAiProvider = {
  name: 'openai',
  isConfigured: jest.fn().mockReturnValue(false),
  chat: jest.fn(),
};

const mockGeminiProvider = {
  name: 'gemini',
  isConfigured: jest.fn().mockReturnValue(false),
  chat: jest.fn(),
};

const mockConfigService = {
  get: jest.fn().mockImplementation((key: string) => {
    if (key === 'ai.defaultProvider') return 'anthropic';
    if (key === 'ai.defaultModel') return 'claude-sonnet-4-6';
    return '';
  }),
};

describe('AiService', () => {
  let service: AiService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AiService,
        { provide: getRepositoryToken(Conversation), useValue: mockConvRepo },
        { provide: getRepositoryToken(Message), useValue: mockMsgRepo },
        { provide: ConfigService, useValue: mockConfigService },
        { provide: AnthropicProvider, useValue: mockAnthropicProvider },
        { provide: OpenAiProvider, useValue: mockOpenAiProvider },
        { provide: GeminiProvider, useValue: mockGeminiProvider },
      ],
    }).compile();

    service = module.get<AiService>(AiService);
    jest.clearAllMocks();
  });

  describe('sendMessage', () => {
    it('should create a new conversation and return AI response', async () => {
      const mockConv = { id: 'conv-1', userId: 'user-1', title: 'Test', context: null };
      const mockMsg = { id: 'msg-1', role: 'assistant', content: 'Hello!', createdAt: new Date() };

      mockConvRepo.create.mockReturnValue(mockConv);
      mockConvRepo.save.mockResolvedValue(mockConv);
      mockMsgRepo.create.mockReturnValue({ id: 'user-msg', role: 'user', content: 'Hi' });
      mockMsgRepo.save.mockResolvedValue({ id: 'user-msg' });
      mockMsgRepo.find.mockResolvedValue([{ id: 'user-msg', role: 'user', content: 'Hi' }]);
      mockAnthropicProvider.isConfigured.mockReturnValue(true);
      mockAnthropicProvider.chat.mockResolvedValue({
        content: 'Hello! I am CalcMaster AI.',
        model: 'claude-sonnet-4-6',
        provider: 'anthropic',
        tokensUsed: 50,
      });

      const result = await service.sendMessage('user-1', {
        message: 'Hi',
        provider: 'anthropic',
      });

      expect(result).toHaveProperty('conversationId');
      expect(result).toHaveProperty('message');
    });

    it('should throw BadRequestException when provider is not configured', async () => {
      mockAnthropicProvider.isConfigured.mockReturnValue(false);

      await expect(
        service.sendMessage('user-1', { message: 'Hi', provider: 'anthropic' }),
      ).rejects.toThrow(BadRequestException);
    });

    it('should throw NotFoundException for non-existent conversation', async () => {
      mockAnthropicProvider.isConfigured.mockReturnValue(true);
      mockConvRepo.findOne.mockResolvedValue(null);

      await expect(
        service.sendMessage('user-1', {
          message: 'Hi',
          conversationId: 'nonexistent',
        }),
      ).rejects.toThrow(NotFoundException);
    });
  });

  describe('getConversations', () => {
    it('should return paginated conversations', async () => {
      mockConvRepo.findAndCount.mockResolvedValue([[{ id: 'conv-1' }], 1]);

      const result = await service.getConversations('user-1');
      expect(result).toHaveProperty('conversations');
      expect(result).toHaveProperty('total');
    });
  });
});
