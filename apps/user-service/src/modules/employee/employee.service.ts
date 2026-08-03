import { Injectable, ConflictException, NotFoundException } from '@nestjs/common';
import { CreateEmployeeDto } from './dto/create-employee.dto';
import { UpdateEmployeeDto } from './dto/update-employee.dto';
import { getPaginationParams, buildPaginationMeta } from '@hris/shared-utils';
import { PrismaService } from 'src/prisma-service';

@Injectable()
export class EmployeeService {
  constructor(private prisma: PrismaService) {}

  async create(tenantId: string, dto: CreateEmployeeDto) {
    const existing = await this.prisma.employee.findUnique({
      where: { email_tenantId: { email: dto.email, tenantId } },
    });

    if (existing) {
      throw new ConflictException('Email karyawan sudah terdaftar');
    }

    const employee = await this.prisma.employee.create({
      data: {
        tenantId,
        userId: dto.userId,
        name: dto.name,
        email: dto.email,
        phone: dto.phone,
        address: dto.address,
        position: dto.position,
        departmentId: dto.departmentId,
        joinDate: dto.joinDate ? new Date(dto.joinDate) : null,
      },
      include: { department: true },
    });

    return { message: 'Karyawan berhasil ditambahkan', data: employee };
  }

  async findAll(tenantId: string, query: { page?: number; limit?: number }) {
    const { skip, take } = getPaginationParams(query);

    const [employees, total] = await Promise.all([
      this.prisma.employee.findMany({
        where: { tenantId },
        include: { department: true },
        skip,
        take,
        orderBy: { name: 'asc' },
      }),
      this.prisma.employee.count({ where: { tenantId } }),
    ]);

    return {
      message: 'OK',
      data: employees,
      meta: buildPaginationMeta(total, query.page || 1, query.limit || 10),
    };
  }

  async findOne(tenantId: string, id: string) {
    const employee = await this.prisma.employee.findFirst({
      where: { id, tenantId },
      include: { department: true },
    });

    if (!employee) {
      throw new NotFoundException('Karyawan tidak ditemukan');
    }

    return { message: 'OK', data: employee };
  }

  async update(tenantId: string, id: string, dto: UpdateEmployeeDto) {
    await this.findOne(tenantId, id);

    const employee = await this.prisma.employee.update({
      where: { id },
      data: {
        ...dto,
        joinDate: dto.joinDate ? new Date(dto.joinDate) : undefined,
      },
      include: { department: true },
    });

    return { message: 'Karyawan berhasil diupdate', data: employee };
  }

  async remove(tenantId: string, id: string) {
    await this.findOne(tenantId, id);
    await this.prisma.employee.delete({ where: { id } });
    return { message: 'Karyawan berhasil dihapus' };
  }
}