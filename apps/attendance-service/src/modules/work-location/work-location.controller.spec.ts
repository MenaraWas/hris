import { Test, TestingModule } from '@nestjs/testing';
import { WorkLocationController } from './work-location.controller';

describe('WorkLocationController', () => {
  let controller: WorkLocationController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [WorkLocationController],
    }).compile();

    controller = module.get<WorkLocationController>(WorkLocationController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
