import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../data/attendance_repository.dart';
import '../domain/attendance_model.dart';
import '../../../core/storage/secure_storage.dart';

final attendanceRepositoryProvider = Provider((ref) => AttendanceRepository());

class AttendanceState {
  final bool isLoading;
  final bool isClockingIn;
  final bool isClockingOut;
  final String? error;
  final String? successMessage;
  final AttendanceModel? todayAttendance;
  final List<AttendanceModel> monthlyAttendances;
  final MonthlySummary? summary;

  AttendanceState({
    this.isLoading = false,
    this.isClockingIn = false,
    this.isClockingOut = false,
    this.error,
    this.successMessage,
    this.todayAttendance,
    this.monthlyAttendances = const [],
    this.summary,
  });

  AttendanceState copyWith({
    bool? isLoading,
    bool? isClockingIn,
    bool? isClockingOut,
    String? error,
    String? successMessage,
    AttendanceModel? todayAttendance,
    List<AttendanceModel>? monthlyAttendances,
    MonthlySummary? summary,
  }) {
    return AttendanceState(
      isLoading: isLoading ?? this.isLoading,
      isClockingIn: isClockingIn ?? this.isClockingIn,
      isClockingOut: isClockingOut ?? this.isClockingOut,
      error: error,
      successMessage: successMessage,
      todayAttendance: todayAttendance ?? this.todayAttendance,
      monthlyAttendances: monthlyAttendances ?? this.monthlyAttendances,
      summary: summary ?? this.summary,
    );
  }
}

class AttendanceNotifier extends StateNotifier<AttendanceState> {
  final AttendanceRepository _repository;

  AttendanceNotifier(this._repository) : super(AttendanceState());

  Future<void> loadToday() async {
    state = state.copyWith(isLoading: true);
    try {
      final userData = await SecureStorage.getUserData();
      final employeeId = userData['userId']!;
      final attendance = await _repository.getToday(employeeId);
      state = state.copyWith(isLoading: false, todayAttendance: attendance);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMonthly({int? year, int? month}) async {
    state = state.copyWith(isLoading: true);
    try {
      final userData = await SecureStorage.getUserData();
      final employeeId = userData['userId']!;
      final result = await _repository.getMonthly(
        employeeId,
        year: year,
        month: month,
      );
      state = state.copyWith(
        isLoading: false,
        monthlyAttendances: result['attendances'],
        summary: result['summary'],
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> clockIn() async {
    state = state.copyWith(isClockingIn: true, error: null);
    try {
      // minta permission GPS
      final permission = await _checkLocationPermission();
      if (!permission) {
        state = state.copyWith(
          isClockingIn: false,
          error: 'Permission lokasi diperlukan untuk clock-in',
        );
        return;
      }

      // ambil posisi GPS
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final userData = await SecureStorage.getUserData();
      final employeeId = userData['userId']!;

      final attendance = await _repository.clockIn(
        employeeId: employeeId,
        latitude: position.latitude,
        longitude: position.longitude,
      );

      state = state.copyWith(
        isClockingIn: false,
        todayAttendance: attendance,
        successMessage: 'Clock-in berhasil',
      );
    } catch (e) {
      state = state.copyWith(
        isClockingIn: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> clockOut() async {
    state = state.copyWith(isClockingOut: true, error: null);
    try {
      final permission = await _checkLocationPermission();
      if (!permission) {
        state = state.copyWith(
          isClockingOut: false,
          error: 'Permission lokasi diperlukan untuk clock-out',
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final userData = await SecureStorage.getUserData();
      final employeeId = userData['userId']!;

      final attendance = await _repository.clockOut(
        employeeId: employeeId,
        latitude: position.latitude,
        longitude: position.longitude,
      );

      state = state.copyWith(
        isClockingOut: false,
        todayAttendance: attendance,
        successMessage: 'Clock-out berhasil',
      );
    } catch (e) {
      state = state.copyWith(
        isClockingOut: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<bool> _checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }

    if (permission == LocationPermission.deniedForever) return false;

    return true;
  }
}

final attendanceProvider =
    StateNotifierProvider<AttendanceNotifier, AttendanceState>((ref) {
  return AttendanceNotifier(ref.watch(attendanceRepositoryProvider));
});