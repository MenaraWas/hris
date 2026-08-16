import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { LeaveModule } from './modules/leave/leave.module';
import { LeaveBalanceModule } from './modules/leave-balance/leave-balance.module';

@Module({
  imports: [LeaveModule, LeaveBalanceModule],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
