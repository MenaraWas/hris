import { Module } from '@nestjs/common';
import { LeaveBalanceService } from './leave-balance.service';
import { LeaveBalanceController } from './leave-balance.controller';

@Module({
  providers: [LeaveBalanceService],
  controllers: [LeaveBalanceController]
})
export class LeaveBalanceModule {}
