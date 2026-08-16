import { Controller, Get, Post, Patch, Body, Param, Req, UseGuards, Query } from '@nestjs/common';
import { LeaveService } from './leave.service';
import { CreateLeaveDto } from './dto/create-leave.dto';
import { ApproveLeaveDto, RejectLeaveDto } from './dto/approve-leave.dto';
import { JwtAuthGuard, TenantGuard, RolesGuard, Roles } from '@hris/shared-guards';

@UseGuards(JwtAuthGuard, TenantGuard)
@Controller('leaves')
export class LeaveController {
  constructor(private readonly leaveService: LeaveService) {}

  @Post()
  create(@Req() req: any, @Body() dto: CreateLeaveDto) {
    return this.leaveService.create(req.tenantId, dto);
  }

  @Roles('admin')
  @UseGuards(RolesGuard)
  @Get()
  findAll(@Req() req: any, @Query('status') status: string) {
    return this.leaveService.findAll(req.tenantId, status);
  }

  @Get('my/:employeeId')
  findByEmployee(@Req() req: any, @Param('employeeId') employeeId: string) {
    return this.leaveService.findByEmployee(req.tenantId, employeeId);
  }

  @Roles('admin')
  @UseGuards(RolesGuard)
  @Patch(':id/approve')
  approve(@Req() req: any, @Param('id') id: string, @Body() dto: ApproveLeaveDto) {
    return this.leaveService.approve(req.tenantId, id, dto);
  }

  @Roles('admin')
  @UseGuards(RolesGuard)
  @Patch(':id/reject')
  reject(@Req() req: any, @Param('id') id: string, @Body() dto: RejectLeaveDto) {
    return this.leaveService.reject(req.tenantId, id, dto);
  }
}