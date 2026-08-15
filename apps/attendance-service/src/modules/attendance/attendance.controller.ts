import { Controller, Post, Get, Body, Param, Req, UseGuards, Query } from '@nestjs/common';
import { AttendanceService } from './attendance.service';
import { ClockInDto } from './dto/clock-in.dto';
import { ClockOutDto } from './dto/clock-out.dto';
import { JwtAuthGuard, TenantGuard } from '@hris/shared-guards';

@UseGuards(JwtAuthGuard, TenantGuard)
@Controller('attendance')
export class AttendanceController {
  constructor(private readonly attendanceService: AttendanceService) {}

  @Post('clock-in')
  clockIn(@Req() req: any, @Body() dto: ClockInDto) {
    return this.attendanceService.clockIn(req.tenantId, dto);
  }

  @Post('clock-out')
  clockOut(@Req() req: any, @Body() dto: ClockOutDto) {
    return this.attendanceService.clockOut(req.tenantId, dto);
  }

  @Get('daily/:employeeId')
  getDaily(
    @Req() req: any,
    @Param('employeeId') employeeId: string,
    @Query('date') date: string,
  ) {
    return this.attendanceService.getDaily(
      req.tenantId,
      employeeId,
      date ? new Date(date) : new Date(),
    );
  }

  @Get('monthly/:employeeId')
  getMonthly(
    @Req() req: any,
    @Param('employeeId') employeeId: string,
    @Query('year') year: string,
    @Query('month') month: string,
  ) {
    return this.attendanceService.getMonthly(
      req.tenantId,
      employeeId,
      parseInt(year) || new Date().getFullYear(),
      parseInt(month) || new Date().getMonth() + 1,
    );
  }
}