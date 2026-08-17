import 'package:flutter/material.dart';

class LeaveBalanceModel {
  final String id;
  final String employeeId;
  final String leaveType;
  final int year;
  final int totalDays;
  final int usedDays;
  final int remainingDays;

  LeaveBalanceModel({
    required this.id,
    required this.employeeId,
    required this.leaveType,
    required this.year,
    required this.totalDays,
    required this.usedDays,
    required this.remainingDays,
  });

  factory LeaveBalanceModel.fromJson(Map<String, dynamic> json) {
    return LeaveBalanceModel(
      id: json['id'],
      employeeId: json['employeeId'],
      leaveType: json['leaveType'],
      year: json['year'],
      totalDays: json['totalDays'],
      usedDays: json['usedDays'],
      remainingDays: json['remainingDays'],
    );
  }

  String get leaveTypeLabel {
    switch (leaveType) {
      case 'annual':
        return 'Cuti Tahunan';
      case 'sick':
        return 'Cuti Sakit';
      case 'permission':
        return 'Izin';
      default:
        return leaveType;
    }
  }
}

class LeaveRequestModel {
  final String id;
  final String employeeId;
  final String leaveType;
  final DateTime startDate;
  final DateTime endDate;
  final int totalDays;
  final String reason;
  final String status;
  final String? rejectNote;
  final DateTime createdAt;

  LeaveRequestModel({
    required this.id,
    required this.employeeId,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    required this.reason,
    required this.status,
    this.rejectNote,
    required this.createdAt,
  });

  factory LeaveRequestModel.fromJson(Map<String, dynamic> json) {
    return LeaveRequestModel(
      id: json['id'],
      employeeId: json['employeeId'],
      leaveType: json['leaveType'],
      startDate: DateTime.parse(json['startDate']).toLocal(),
      endDate: DateTime.parse(json['endDate']).toLocal(),
      totalDays: json['totalDays'],
      reason: json['reason'],
      status: json['status'],
      rejectNote: json['rejectNote'],
      createdAt: DateTime.parse(json['createdAt']).toLocal(),
    );
  }

  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'Menunggu';
      case 'approved':
        return 'Disetujui';
      case 'rejected':
        return 'Ditolak';
      default:
        return status;
    }
  }

  Color get statusColor {
    switch (status) {
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'approved':
        return const Color(0xFF1D9E75);
      case 'rejected':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6B7280);
    }
  }

  String get leaveTypeLabel {
    switch (leaveType) {
      case 'annual':
        return 'Cuti Tahunan';
      case 'sick':
        return 'Cuti Sakit';
      case 'permission':
        return 'Izin';
      default:
        return leaveType;
    }
  }
}