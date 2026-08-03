import { ConflictException, Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../prisma-service';
import { CreateDepartmentDto } from './dto/create-department.dto';
import { UpdateDepartmentDto } from './dto/update-department.dto';

@Injectable()
export class DepartmentService {
  constructor(private prisma: PrismaService) {}

  async create(tenantId: string, dto: CreateDepartmentDto) {
    const existing = await this.prisma.department.findUnique({
      where: { name_tenantId: { name: dto.name, tenantId } },
    });

    if (existing) {
      throw new ConflictException('Nama Department sudah ada');
    }

    const department = await this.prisma.department.create({
      data: { tenantId, name: dto.name },
    });

    return { message: 'Department berhasil dibuat', data: department };
  }

  async findAll(tenantId: string) {
    const departments = await this.prisma.department.findMany({
      where: { tenantId },
      include: { _count: { select: { employees: true } } },
      orderBy: { name: 'asc' },
    });

    return { message: 'OK', data: departments };
  }

  async findOne(tenantId: string, id: string) {
    const department = await this.prisma.department.findFirst({
      where: { id, tenantId },
      include: { _count: { select: { employees: true } } },
    });

    if (!department) {
      throw new NotFoundException('Departemen tidak ditemukan');
    }

    return { message: 'OK', data: department };
  }

  async update(tenantId: string, id: string, dto: UpdateDepartmentDto) {
    await this.findOne(tenantId, id);

    const department = await this.prisma.department.update({
      where: { id },
      data: { name: dto.name },
    });

    return { message: 'Departement berhasil di update', data: department };
  }

  async remove(tenantId: string, id: string) {
    await this.findOne(tenantId, id);

    await this.prisma.department.delete({ where: { id } });
    return { message: 'Departement Berhasil dihapus' };
  }
}
