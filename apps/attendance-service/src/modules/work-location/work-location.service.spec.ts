import { Test, TestingModule } from '@nestjs/testing';
import { WorkLocationService } from './work-location.service';

describe('WorkLocationService', () => {
  let service: WorkLocationService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [WorkLocationService],
    }).compile();

    service = module.get<WorkLocationService>(WorkLocationService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
