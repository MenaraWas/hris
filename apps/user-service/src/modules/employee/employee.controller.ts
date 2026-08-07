import {
  Controller, Get, Post, Patch, Delete,
  Body, Param, Req, UseGuards, Query
} from '@nestjs/common';
import { MessagePattern, Payload } from '@nestjs/microservices';
import { EmployeeService } from './employee.service';
import { CreateEmployeeDto } from './dto/create-employee.dto';
import { UpdateEmployeeDto } from './dto/update-employee.dto';
import { JwtAuthGuard, RolesGuard, TenantGuard, Roles } from '@hris/shared-guards';

@Controller('employees')
export class EmployeeController {
  constructor(private readonly employeeService: EmployeeService) {}

  // HTTP endpoints
  @UseGuards(JwtAuthGuard, TenantGuard)
  @Roles('admin')
  @UseGuards(RolesGuard)
  @Post()
  create(@Req() req: any, @Body() dto: CreateEmployeeDto) {
    return this.employeeService.create(req.tenantId, dto);
  }

  @UseGuards(JwtAuthGuard, TenantGuard)
  @Get()
  findAll(@Req() req: any, @Query() query: { page?: number; limit?: number }) {
    return this.employeeService.findAll(req.tenantId, query);
  }

  @UseGuards(JwtAuthGuard, TenantGuard)
  @Get(':id')
  findOne(@Req() req: any, @Param('id') id: string) {
    return this.employeeService.findOne(req.tenantId, id);
  }

  @UseGuards(JwtAuthGuard, TenantGuard)
  @Roles('admin')
  @UseGuards(RolesGuard)
  @Patch(':id')
  update(@Req() req: any, @Param('id') id: string, @Body() dto: UpdateEmployeeDto) {
    return this.employeeService.update(req.tenantId, id, dto);
  }

  @UseGuards(JwtAuthGuard, TenantGuard)
  @Roles('admin')
  @UseGuards(RolesGuard)
  @Delete(':id')
  remove(@Req() req: any, @Param('id') id: string) {
    return this.employeeService.remove(req.tenantId, id);
  }

  // TCP message handlers — tidak pakai guard karena komunikasi internal
  @MessagePattern('validate_employee')
  async validateEmployee(@Payload() data: { employeeId: string; tenantId: string }) {
    try {
      const result = await this.employeeService.findOne(data.tenantId, data.employeeId);
      return { isValid: true, employee: result.data };
    } catch {
      return { isValid: false, employee: null };
    }
  }

  @MessagePattern('get_employee')
  async getEmployee(@Payload() data: { employeeId: string; tenantId: string }) {
    try {
      const result = await this.employeeService.findOne(data.tenantId, data.employeeId);
      return result.data;
    } catch {
      return null;
    }
  }
}