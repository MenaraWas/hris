import { Controller, Get, Post, Body, Param, Req, UseGuards, Query } from '@nestjs/common';
import { LeaveBalanceService } from './leave-balance.service';
import { CreateLeaveBalanceDto } from './dto/create-balance.dto';
import { JwtAuthGuard, TenantGuard, RolesGuard, Roles } from '@hris/shared-guards';

@UseGuards(JwtAuthGuard, TenantGuard)
@Controller('leave-balances')
export class LeaveBalanceController {
  constructor(private readonly leaveBalanceService: LeaveBalanceService) {}

  @Roles('admin')
  @UseGuards(RolesGuard)
  @Post()
  create(@Req() req: any, @Body() dto: CreateLeaveBalanceDto) {
    return this.leaveBalanceService.create(req.tenantId, dto);
  }

  @Get(':employeeId')
  findByEmployee(
    @Req() req: any,
    @Param('employeeId') employeeId: string,
    @Query('year') year: string,
  ) {
    return this.leaveBalanceService.findByEmployee(
      req.tenantId,
      employeeId,
      year ? parseInt(year) : undefined,
    );
  }
}