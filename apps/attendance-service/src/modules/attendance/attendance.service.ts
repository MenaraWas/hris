import {
  Injectable,
  BadRequestException,
  NotFoundException,
  Inject,
} from '@nestjs/common';
import { ClientProxy } from '@nestjs/microservices';
import { PrismaService } from '../../prisma.service';
import { ClockInDto } from './dto/clock-in.dto';
import { ClockOutDto } from './dto/clock-out.dto';
import { WorkLocationService } from '../work-location/work-location.service';
import { isWithinRadius } from '@hris/shared-utils';
import { toStartOfDay, toEndOfDay, getMonthRange } from '@hris/shared-utils';
import { firstValueFrom } from 'rxjs';

@Injectable()
export class AttendanceService {
  constructor(
    private prisma: PrismaService,
    private workLocationService: WorkLocationService,
    @Inject('USER_SERVICE') private userClient: ClientProxy,
  ) {}

  async clockIn(tenantId: string, dto: ClockInDto) {
    // validasi employee lewat TCP ke user-service
    const validation = await firstValueFrom(
      this.userClient.send('validate_employee', {
        employeeId: dto.employeeId,
        tenantId,
      }),
    );

    if (!validation.isValid) {
      throw new NotFoundException('Employee tidak ditemukan');
    }

    // cek apakah sudah clock-in hari ini
    const today = new Date();
    const existing = await this.prisma.attendance.findUnique({
      where: {
        employeeId_date_tenantId: {
          employeeId: dto.employeeId,
          date: toStartOfDay(today),
          tenantId,
        },
      },
    });

    if (existing?.checkInTime) {
      throw new BadRequestException('Sudah melakukan clock-in hari ini');
    }

    // validasi GPS — cari lokasi kantor terdekat yang dalam radius
    const locations = await this.workLocationService.findAllRaw(tenantId);
    let matchedLocation = null;

    for (const loc of locations) {
      const withinRadius = isWithinRadius(
        dto.latitude,
        dto.longitude,
        loc.latitude,
        loc.longitude,
        loc.radiusInMeters,
      );
      if (withinRadius) {
        matchedLocation = loc;
        break;
      }
    }

    if (!matchedLocation) {
      throw new BadRequestException(
        'Lokasi kamu berada di luar radius kantor yang diizinkan',
      );
    }

    // tentukan status: hadir atau terlambat (pakai jam 08:00 sebagai batas)
    const checkInHour = today.getHours();
    const checkInMinute = today.getMinutes();
    const lateThresholdHour = 8;
    const lateThresholdMinute = 0;
    const isLate =
      checkInHour > lateThresholdHour ||
      (checkInHour === lateThresholdHour && checkInMinute > lateThresholdMinute);

    const status = isLate ? 'late' : 'present';

    // simpan atau update attendance
    const attendance = await this.prisma.attendance.upsert({
      where: {
        employeeId_date_tenantId: {
          employeeId: dto.employeeId,
          date: toStartOfDay(today),
          tenantId,
        },
      },
      create: {
        tenantId,
        employeeId: dto.employeeId,
        workLocationId: matchedLocation.id,
        date: toStartOfDay(today),
        checkInTime: today,
        checkInLat: dto.latitude,
        checkInLon: dto.longitude,
        status,
        note: dto.note,
      },
      update: {
        checkInTime: today,
        checkInLat: dto.latitude,
        checkInLon: dto.longitude,
        workLocationId: matchedLocation.id,
        status,
        note: dto.note,
      },
    });

    return {
      message: `Clock-in berhasil, status: ${status}`,
      data: attendance,
    };
  }

  async clockOut(tenantId: string, dto: ClockOutDto) {
    const today = new Date();

    const attendance = await this.prisma.attendance.findUnique({
      where: {
        employeeId_date_tenantId: {
          employeeId: dto.employeeId,
          date: toStartOfDay(today),
          tenantId,
        },
      },
    });

    if (!attendance) {
      throw new BadRequestException('Belum melakukan clock-in hari ini');
    }

    if (attendance.checkOutTime) {
      throw new BadRequestException('Sudah melakukan clock-out hari ini');
    }

    // validasi GPS saat clock-out
    const locations = await this.workLocationService.findAllRaw(tenantId);
    let matchedLocation = null;

    for (const loc of locations) {
      const withinRadius = isWithinRadius(
        dto.latitude,
        dto.longitude,
        loc.latitude,
        loc.longitude,
        loc.radiusInMeters,
      );
      if (withinRadius) {
        matchedLocation = loc;
        break;
      }
    }

    if (!matchedLocation) {
      throw new BadRequestException(
        'Lokasi kamu berada di luar radius kantor yang diizinkan',
      );
    }

    const updated = await this.prisma.attendance.update({
      where: { id: attendance.id },
      data: {
        checkOutTime: today,
        checkOutLat: dto.latitude,
        checkOutLon: dto.longitude,
      },
    });

    return { message: 'Clock-out berhasil', data: updated };
  }

  async getDaily(tenantId: string, employeeId: string, date: Date) {
    const attendance = await this.prisma.attendance.findUnique({
      where: {
        employeeId_date_tenantId: {
          employeeId,
          date: toStartOfDay(date),
          tenantId,
        },
      },
      include: { workLocation: true },
    });

    return { message: 'OK', data: attendance };
  }

  async getMonthly(tenantId: string, employeeId: string, year: number, month: number) {
    const { start, end } = getMonthRange(year, month);

    const attendances = await this.prisma.attendance.findMany({
      where: {
        tenantId,
        employeeId,
        date: { gte: start, lte: end },
      },
      include: { workLocation: true },
      orderBy: { date: 'asc' },
    });

    const summary = {
      present: attendances.filter(a => a.status === 'present').length,
      late: attendances.filter(a => a.status === 'late').length,
      absent: attendances.filter(a => a.status === 'absent').length,
      total: attendances.length,
    };

    return { message: 'OK', data: attendances, summary };
  }
}