import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/leave_repository.dart';
import '../domain/leave_model.dart';
import '../../../core/storage/secure_storage.dart';

final leaveRepositoryProvider = Provider((ref) => LeaveRepository());

class LeaveState {
  final bool isLoading;
  final bool isSubmitting;
  final String? error;
  final String? successMessage;
  final List<LeaveBalanceModel> balances;
  final List<LeaveRequestModel> requests;

  LeaveState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.error,
    this.successMessage,
    this.balances = const [],
    this.requests = const [],
  });

  LeaveState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    String? error,
    String? successMessage,
    List<LeaveBalanceModel>? balances,
    List<LeaveRequestModel>? requests,
  }) {
    return LeaveState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
      successMessage: successMessage,
      balances: balances ?? this.balances,
      requests: requests ?? this.requests,
    );
  }
}

class LeaveNotifier extends StateNotifier<LeaveState> {
  final LeaveRepository _repository;

  LeaveNotifier(this._repository) : super(LeaveState());

  Future<void> loadAll() async {
    state = state.copyWith(isLoading: true);
    try {
      final userData = await SecureStorage.getUserData();
      final employeeId = userData['userId']!;

      final results = await Future.wait([
        _repository.getBalances(employeeId),
        _repository.getMyRequests(employeeId),
      ]);

      state = state.copyWith(
        isLoading: false,
        balances: results[0] as List<LeaveBalanceModel>,
        requests: results[1] as List<LeaveRequestModel>,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<bool> submitRequest({
    required String leaveType,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
  }) async {
    state = state.copyWith(isSubmitting: true, error: null);
    try {
      final userData = await SecureStorage.getUserData();
      final employeeId = userData['userId']!;

      final request = await _repository.createRequest(
        employeeId: employeeId,
        leaveType: leaveType,
        startDate: startDate,
        endDate: endDate,
        reason: reason,
      );

      state = state.copyWith(
        isSubmitting: false,
        requests: [request, ...state.requests],
        successMessage: 'Pengajuan cuti berhasil dikirim',
      );

      // reload balances karena mungkin berubah
      await loadAll();
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }
}

final leaveProvider = StateNotifierProvider<LeaveNotifier, LeaveState>((ref) {
  return LeaveNotifier(ref.watch(leaveRepositoryProvider));
});