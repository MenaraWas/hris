import { Module } from '@nestjs/common';
import { WorkScheduleService } from './work-schedule.service';
import { WorkScheduleController } from './work-schedule.controller';

@Module({
  providers: [WorkScheduleService],
  controllers: [WorkScheduleController]
})
export class WorkScheduleModule {}
