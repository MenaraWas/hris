import { Injectable, BadRequestException, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../prisma.service';
import { CreateLeaveDto } from './dto/create-leave.dto';
import { ApproveLeaveDto, RejectLeaveDto } from './dto/approve-leave.dto';
import { LeaveBalanceService } from '../leave-balance/leave-balance.service';
import { EventEmitter2 } from '@nestjs/event-emitter';

@Injectable()
export class LeaveService {
  constructor(
    private prisma: PrismaService,
    private leaveBalanceService: LeaveBalanceService,
    private eventEmitter: EventEmitter2,
  ) {}

  private calculateDays(startDate: Date, endDate: Date): number {
    const diffTime = Math.abs(endDate.getTime() - startDate.getTime());
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24)) + 1;
    return diffDays;
  }

  async create(tenantId: string, dto: CreateLeaveDto) {
    const startDate = new Date(dto.startDate);
    const endDate = new Date(dto.endDate);

    if (endDate < startDate) {
      throw new BadRequestException('Tanggal selesai tidak boleh sebelum tanggal mulai');
    }

    const totalDays = this.calculateDays(startDate, endDate);

    // cek saldo cuti mencukupi
    const year = startDate.getFullYear();
    const balance = await this.prisma.leaveBalance.findUnique({
      where: {
        employeeId_leaveType_year_tenantId: {
          employeeId: dto.employeeId,
          leaveType: dto.leaveType,
          year,
          tenantId,
        },
      },
    });

    if (!balance || balance.remainingDays < totalDays) {
      throw new BadRequestException(
        `Saldo cuti tidak cukup. Sisa: ${balance?.remainingDays || 0} hari, dibutuhkan: ${totalDays} hari`,
      );
    }

    // cek apakah ada pengajuan yang overlapping
    const overlapping = await this.prisma.leaveRequest.findFirst({
      where: {
        tenantId,
        employeeId: dto.employeeId,
        status: { in: ['pending', 'approved'] },
        OR: [
          { startDate: { lte: endDate }, endDate: { gte: startDate } },
        ],
      },
    });

    if (overlapping) {
      throw new BadRequestException('Terdapat pengajuan cuti yang bertabrakan dengan tanggal yang dipilih');
    }

    const leaveRequest = await this.prisma.leaveRequest.create({
      data: {
        tenantId,
        employeeId: dto.employeeId,
        leaveType: dto.leaveType,
        startDate,
        endDate,
        totalDays,
        reason: dto.reason,
        status: 'pending',
      },
    });

    // emit event supaya bisa diproses notifikasi
    this.eventEmitter.emit('leave.requested', {
      tenantId,
      employeeId: dto.employeeId,
      leaveRequestId: leaveRequest.id,
      totalDays,
    });

    return { message: 'Pengajuan cuti berhasil dikirim', data: leaveRequest };
  }

  async findAll(tenantId: string, status?: string) {
    const where: any = { tenantId };
    if (status) where.status = status;

    const requests = await this.prisma.leaveRequest.findMany({
      where,
      orderBy: { createdAt: 'desc' },
    });

    return { message: 'OK', data: requests };
  }

  async findByEmployee(tenantId: string, employeeId: string) {
    const requests = await this.prisma.leaveRequest.findMany({
      where: { tenantId, employeeId },
      orderBy: { createdAt: 'desc' },
    });

    return { message: 'OK', data: requests };
  }

  async approve(tenantId: string, id: string, dto: ApproveLeaveDto) {
    const leaveRequest = await this.prisma.leaveRequest.findFirst({
      where: { id, tenantId },
    });

    if (!leaveRequest) throw new NotFoundException('Pengajuan cuti tidak ditemukan');

    if (leaveRequest.status !== 'pending') {
      throw new BadRequestException('Pengajuan ini sudah diproses sebelumnya');
    }

    // kurangi saldo cuti
    await this.leaveBalanceService.deductBalance(
      tenantId,
      leaveRequest.employeeId,
      leaveRequest.leaveType,
      leaveRequest.totalDays,
    );

    const updated = await this.prisma.leaveRequest.update({
      where: { id },
      data: {
        status: 'approved',
        approvedBy: dto.approvedBy,
        approvedAt: new Date(),
      },
    });

    // emit event notifikasi
    this.eventEmitter.emit('leave.approved', {
      tenantId,
      employeeId: leaveRequest.employeeId,
      leaveRequestId: id,
    });

    return { message: 'Pengajuan cuti disetujui', data: updated };
  }

  async reject(tenantId: string, id: string, dto: RejectLeaveDto) {
    const leaveRequest = await this.prisma.leaveRequest.findFirst({
      where: { id, tenantId },
    });

    if (!leaveRequest) throw new NotFoundException('Pengajuan cuti tidak ditemukan');

    if (leaveRequest.status !== 'pending') {
      throw new BadRequestException('Pengajuan ini sudah diproses sebelumnya');
    }

    const updated = await this.prisma.leaveRequest.update({
      where: { id },
      data: {
        status: 'rejected',
        rejectedBy: dto.rejectedBy,
        rejectedAt: new Date(),
        rejectNote: dto.rejectNote,
      },
    });

    // emit event notifikasi
    this.eventEmitter.emit('leave.rejected', {
      tenantId,
      employeeId: leaveRequest.employeeId,
      leaveRequestId: id,
      rejectNote: dto.rejectNote,
    });

    return { message: 'Pengajuan cuti ditolak', data: updated };
  }
}