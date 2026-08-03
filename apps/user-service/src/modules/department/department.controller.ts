import { Controller, Get, Post, Patch, Delete, Body, Param, Req, UseGuards } from '@nestjs/common';
import { DepartmentService } from './department.service';
import { CreateDepartmentDto } from './dto/create-department.dto';
import { UpdateDepartmentDto } from './dto/update-department.dto';
import { JwtAuthGuard, RolesGuard, TenantGuard, Roles } from '@hris/shared-guards';

@UseGuards(JwtAuthGuard, TenantGuard)
@Controller('departments')
export class DepartmentController {
  constructor(private readonly departmentService: DepartmentService) {}

  @Roles('admin')
  @UseGuards(RolesGuard)
  @Post()
  create(@Req() req: any, @Body() dto: CreateDepartmentDto) {
    return this.departmentService.create(req.tenantId, dto);
  }

  @Get()
  findAll(@Req() req: any) {
    return this.departmentService.findAll(req.tenantId);
  }

  @Get(':id')
  findOne(@Req() req: any, @Param('id') id: string) {
    return this.departmentService.findOne(req.tenantId, id);
  }

  @Roles('admin')
  @UseGuards(RolesGuard)
  @Patch(':id')
  update(@Req() req: any, @Param('id') id: string, @Body() dto: UpdateDepartmentDto) {
    return this.departmentService.update(req.tenantId, id, dto);
  }

  @Roles('admin')
  @UseGuards(RolesGuard)
  @Delete(':id')
  remove(@Req() req: any, @Param('id') id: string) {
    return this.departmentService.remove(req.tenantId, id);
  }
}