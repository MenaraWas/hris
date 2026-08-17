import 'package:dio/dio.dart';
import '../../../core/api/dio_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../domain/attendance_model.dart';

class AttendanceRepository {
  final Dio _dio = DioClient.instance;

  Future<AttendanceModel?> getToday(String employeeId) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.attendanceDaily(employeeId),
      );
      if (response.data['data'] == null) return null;
      return AttendanceModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal mengambil data presensi');
    }
  }

  Future<AttendanceModel> clockIn({
    required String employeeId,
    required double latitude,
    required double longitude,
    String? note,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.clockIn,
        data: {
          'employeeId': employeeId,
          'latitude': latitude,
          'longitude': longitude,
          if (note != null) 'note': note,
        },
      );
      return AttendanceModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal clock-in');
    }
  }

  Future<AttendanceModel> clockOut({
    required String employeeId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.clockOut,
        data: {
          'employeeId': employeeId,
          'latitude': latitude,
          'longitude': longitude,
        },
      );
      return AttendanceModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal clock-out');
    }
  }

  Future<Map<String, dynamic>> getMonthly(
    String employeeId, {
    int? year,
    int? month,
  }) async {
    try {
      final now = DateTime.now();
      final response = await _dio.get(
        ApiEndpoints.attendanceMonthly(employeeId),
        queryParameters: {
          'year': year ?? now.year,
          'month': month ?? now.month,
        },
      );
      final List data = response.data['data'];
      final summary = MonthlySummary.fromJson(response.data['summary']);
      return {
        'attendances': data.map((e) => AttendanceModel.fromJson(e)).toList(),
        'summary': summary,
      };
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal mengambil rekap');
    }
  }
}