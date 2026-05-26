import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { AnalyticsService } from './analytics.service';
import { AnalyticsEvent } from './entities/analytics-event.entity';

const mockEventRepo = {
  create: jest.fn(),
  save: jest.fn(),
  createQueryBuilder: jest.fn(),
};

describe('AnalyticsService', () => {
  let service: AnalyticsService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AnalyticsService,
        { provide: getRepositoryToken(AnalyticsEvent), useValue: mockEventRepo },
      ],
    }).compile();

    service = module.get<AnalyticsService>(AnalyticsService);
    jest.clearAllMocks();
  });

  describe('track', () => {
    it('should create and save an analytics event', async () => {
      const eventData = { event: 'tab_open', userId: 'user-1', properties: { name: 'convert' } };
      const savedEvent = { id: 'event-1', ...eventData };

      mockEventRepo.create.mockReturnValue(savedEvent);
      mockEventRepo.save.mockResolvedValue(savedEvent);

      const result = await service.track(eventData);
      expect(result).toEqual(savedEvent);
      expect(mockEventRepo.create).toHaveBeenCalledWith(eventData);
    });
  });

  describe('trackBatch', () => {
    it('should save multiple events', async () => {
      const events = [
        { event: 'tab_open', userId: 'user-1' },
        { event: 'convert_used', userId: 'user-1' },
      ];

      mockEventRepo.create.mockImplementation((e: any) => e);
      mockEventRepo.save.mockResolvedValue(events);

      await service.trackBatch(events);
      expect(mockEventRepo.save).toHaveBeenCalledTimes(1);
    });
  });
});
