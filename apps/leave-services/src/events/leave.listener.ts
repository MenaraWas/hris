import { Injectable, Logger } from '@nestjs/common';
import { OnEvent } from '@nestjs/event-emitter';

@Injectable()
export class LeaveListener {
  private readonly logger = new Logger(LeaveListener.name);

  @OnEvent('leave.requested')
  handleLeaveRequested(payload: any) {
    this.logger.log(
      `Pengajuan cuti baru dari employee ${payload.employeeId} selama ${payload.totalDays} hari`
    );
    // di sini nanti bisa kirim push notification ke admin lewat FCM
  }

  @OnEvent('leave.approved')
  handleLeaveApproved(payload: any) {
    this.logger.log(
      `Cuti employee ${payload.employeeId} disetujui`
    );
    // di sini nanti bisa kirim push notification ke karyawan
  }

  @OnEvent('leave.rejected')
  handleLeaveRejected(payload: any) {
    this.logger.log(
      `Cuti employee ${payload.employeeId} ditolak. Alasan: ${payload.rejectNote}`
    );
    // di sini nanti bisa kirim push notification ke karyawan
  }
}