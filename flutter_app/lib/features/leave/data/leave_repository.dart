import 'package:dio/dio.dart';
import '../../../core/api/dio_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../domain/leave_model.dart';

class LeaveRepository {
  final Dio _dio = DioClient.instance;

  Future<List<LeaveBalanceModel>> getBalances(String employeeId) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.leaveBalance(employeeId),
        queryParameters: {'year': DateTime.now().year},
      );
      final List data = response.data['data'];
      return data.map((e) => LeaveBalanceModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal mengambil saldo cuti');
    }
  }

  Future<List<LeaveRequestModel>> getMyRequests(String employeeId) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.leaveByEmployee(employeeId),
      );
      final List data = response.data['data'];
      return data.map((e) => LeaveRequestModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal mengambil riwayat cuti');
    }
  }

  Future<LeaveRequestModel> createRequest({
    required String employeeId,
    required String leaveType,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.leaveRequest,
        data: {
          'employeeId': employeeId,
          'leaveType': leaveType,
          'startDate': startDate.toIso8601String().split('T')[0],
          'endDate': endDate.toIso8601String().split('T')[0],
          'reason': reason,
        },
      );
      return LeaveRequestModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal mengajukan cuti');
    }
  }
}