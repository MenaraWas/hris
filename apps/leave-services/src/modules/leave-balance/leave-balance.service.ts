import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../prisma.service';
import { CreateLeaveBalanceDto } from './dto/create-balance.dto';

@Injectable()
export class LeaveBalanceService {
  constructor(private prisma: PrismaService) {}

  async create(tenantId: string, dto: CreateLeaveBalanceDto) {
    const year = dto.year || new Date().getFullYear();
    const totalDays = dto.totalDays || 12;

    const balance = await this.prisma.leaveBalance.upsert({
      where: {
        employeeId_leaveType_year_tenantId: {
          employeeId: dto.employeeId,
          leaveType: dto.leaveType,
          year,
          tenantId,
        },
      },
      create: {
        tenantId,
        employeeId: dto.employeeId,
        leaveType: dto.leaveType,
        year,
        totalDays,
        usedDays: 0,
        remainingDays: totalDays,
      },
      update: { totalDays, remainingDays: totalDays },
    });
    return { message: 'saldo cuti berhasil dibuat', data: balance };
  }

  async findByEmployee(tenantId: string, employeeId: string, year?: number) {
    const targetYear = year || new Date().getFullYear();

    const balances = await this.prisma.leaveBalance.findMany({
      where: { tenantId, employeeId, year: targetYear },
    });

    return { message: 'OK', data: balances };
  }

  async deductBalance(
    tenantId: string,
    employeeId: string,
    leaveType: string,
    days: number,
  ) {
    const year = new Date().getFullYear();

    const balance = await this.prisma.leaveBalance.findUnique({
      where: {
        employeeId_leaveType_year_tenantId: {
          employeeId,
          leaveType,
          year,
          tenantId,
        },
      },
    });

    if (!balance) {
      throw new NotFoundException('Saldo cuti tidak ditemukan');
    }

    if (balance.remainingDays < days) {
      throw new BadRequestException(
        `Saldo cuti tidak cukup. Sisa: ${balance.remainingDays} hari, dibutuhkan: ${days} hari`,
      );
    }

    return this.prisma.leaveBalance.update({
      where: { id: balance.id },
      data: {
        usedDays: balance.usedDays + days,
        remainingDays: balance.remainingDays - days,
      },
    });
  }

  async restoreBalance(
    tenantId: string,
    employeeId: string,
    leaveType: string,
    days: number,
  ) {
    const year = new Date().getFullYear();

    const balance = await this.prisma.leaveBalance.findUnique({
      where: {
        employeeId_leaveType_year_tenantId: {
          employeeId,
          leaveType,
          year,
          tenantId,
        },
      },
    });

    if (!balance) return;

    return this.prisma.leaveBalance.update({
      where: { id: balance.id },
      data: {
        usedDays: Math.max(0, balance.usedDays - days),
        remainingDays: Math.min(
          balance.totalDays,
          balance.remainingDays + days,
        ),
      },
    });
  }
}

