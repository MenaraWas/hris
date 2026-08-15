import { Controller, Get, Post, Body, Param, Req, UseGuards } from '@nestjs/common';
import { WorkLocationService } from './work-location.service';
import { CreateWorkLocationDto } from './dto/create-work-location.dto';
import { JwtAuthGuard, TenantGuard, RolesGuard, Roles } from '@hris/shared-guards';

@UseGuards(JwtAuthGuard, TenantGuard)
@Controller('work-locations')
export class WorkLocationController {
  constructor(private readonly workLocationService: WorkLocationService) {}

  @Roles('admin')
  @UseGuards(RolesGuard)
  @Post()
  create(@Req() req: any, @Body() dto: CreateWorkLocationDto) {
    return this.workLocationService.create(req.tenantId, dto);
  }

  @Get()
  findAll(@Req() req: any) {
    return this.workLocationService.findAll(req.tenantId);
  }

  @Get(':id')
  findOne(@Req() req: any, @Param('id') id: string) {
    return this.workLocationService.findOne(req.tenantId, id);
  }
}