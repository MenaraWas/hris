import { Controller, Get, Post, Patch, Delete, Body, Param, Req, UseGuards, Query } from '@nestjs/common';
import { EmployeeService } from './employee.service';
import { CreateEmployeeDto } from './dto/create-employee.dto';
import { UpdateEmployeeDto } from './dto/update-employee.dto';
import { JwtAuthGuard, RolesGuard, TenantGuard, Roles } from '@hris/shared-guards';

@UseGuards(JwtAuthGuard, TenantGuard)
@Controller('employees')
export class EmployeeController {
  constructor(private readonly employeeService: EmployeeService) {}

  @Roles('admin')
  @UseGuards(RolesGuard)
  @Post()
  create(@Req() req: any, @Body() dto: CreateEmployeeDto) {
    return this.employeeService.create(req.tenantId, dto);
  }

  @Get()
  findAll(@Req() req: any, @Query() query: { page?: number; limit?: number }) {
    return this.employeeService.findAll(req.tenantId, query);
  }

  @Get(':id')
  findOne(@Req() req: any, @Param('id') id: string) {
    return this.employeeService.findOne(req.tenantId, id);
  }

  @Roles('admin')
  @UseGuards(RolesGuard)
  @Patch(':id')
  update(@Req() req: any, @Param('id') id: string, @Body() dto: UpdateEmployeeDto) {
    return this.employeeService.update(req.tenantId, id, dto);
  }

  @Roles('admin')
  @UseGuards(RolesGuard)
  @Delete(':id')
  remove(@Req() req: any, @Param('id') id: string) {
    return this.employeeService.remove(req.tenantId, id);
  }
}