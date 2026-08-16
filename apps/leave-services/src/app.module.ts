import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { EventEmitterModule } from '@nestjs/event-emitter';
import { PrismaModule } from './prisma.module';
import { LeaveModule } from './modules/leave/leave.module';
import { LeaveBalanceModule } from './modules/leave-balance/leave-balance.module';
import { LeaveListener } from './events/leave.listener';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    EventEmitterModule.forRoot(),
    PrismaModule,
    LeaveModule,
    LeaveBalanceModule,
  ],
  providers: [LeaveListener],
})
export class AppModule {}