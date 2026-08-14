import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { WorkLocationModule } from './modules/work-location/work-location.module';
import { WorkScheduleModule } from './modules/work-schedule/work-schedule.module';
import { AttendanceModule } from './modules/attendance/attendance.module';

@Module({
  imports: [WorkLocationModule, WorkScheduleModule, AttendanceModule],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
