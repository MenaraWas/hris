import 'package:flutter/material.dart';

class AttendanceModel {
  final String id;
  final String employeeId;
  final String tenantId;
  final DateTime date;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final double? checkInLat;
  final double? checkInLon;
  final double? checkOutLat;
  final double? checkOutLon;
  final String status;
  final String? note;

  AttendanceModel({
    required this.id,
    required this.employeeId,
    required this.tenantId,
    required this.date,
    this.checkInTime,
    this.checkOutTime,
    this.checkInLat,
    this.checkInLon,
    this.checkOutLat,
    this.checkOutLon,
    required this.status,
    this.note,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'],
      employeeId: json['employeeId'],
      tenantId: json['tenantId'],
      date: DateTime.parse(json['date']),
      checkInTime: json['checkInTime'] != null
          ? DateTime.parse(json['checkInTime']).toLocal()
          : null,
      checkOutTime: json['checkOutTime'] != null
          ? DateTime.parse(json['checkOutTime']).toLocal()
          : null,
      checkInLat: json['checkInLat']?.toDouble(),
      checkInLon: json['checkInLon']?.toDouble(),
      checkOutLat: json['checkOutLat']?.toDouble(),
      checkOutLon: json['checkOutLon']?.toDouble(),
      status: json['status'],
      note: json['note'],
    );
  }

  bool get hasCheckedIn => checkInTime != null;
  bool get hasCheckedOut => checkOutTime != null;

  String get statusLabel {
    switch (status) {
      case 'present':
        return 'Hadir';
      case 'late':
        return 'Terlambat';
      case 'absent':
        return 'Tidak Hadir';
      default:
        return 'Belum Presensi';
    }
  }

  Color get statusColor {
    switch (status) {
      case 'present':
        return const Color(0xFF1D9E75);
      case 'late':
        return const Color(0xFFF59E0B);
      case 'absent':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6B7280);
    }
  }
}

class MonthlySummary {
  final int present;
  final int late;
  final int absent;
  final int total;

  MonthlySummary({
    required this.present,
    required this.late,
    required this.absent,
    required this.total,
  });

  factory MonthlySummary.fromJson(Map<String, dynamic> json) {
    return MonthlySummary(
      present: json['present'] ?? 0,
      late: json['late'] ?? 0,
      absent: json['absent'] ?? 0,
      total: json['total'] ?? 0,
    );
  }
}