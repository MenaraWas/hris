import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { PrismaModule } from './prisma.module';
import { WorkLocationModule } from './modules/work-location/work-location.module';
import { WorkScheduleModule } from './modules/work-schedule/work-schedule.module';
import { AttendanceModule } from './modules/attendance/attendance.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    PrismaModule,
    WorkLocationModule,
    WorkScheduleModule,
    AttendanceModule,
  ],
})
export class AppModule {}