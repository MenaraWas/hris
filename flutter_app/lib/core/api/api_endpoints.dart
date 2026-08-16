class ApiEndpoints {
  static const String baseUrl = 'http://192.168.1.14:3000/api';
  // 10.0.2.2 adalah alias localhost untuk emulator Android
  // kalau pakai device fisik, ganti dengan IP laptop di jaringan lokal
  // contoh: http://192.168.1.x:3000/api

  // Auth
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String registerTenant = '/auth/register-tenant';

  // User
  static const String departments = '/users/departments';
  static const String employees = '/users/employees';

  // Attendance
  static const String clockIn = '/attendance/clock-in';
  static const String clockOut = '/attendance/clock-out';
  static const String workLocations = '/attendance/work-locations';
  static String attendanceDaily(String employeeId) => '/attendance/daily/$employeeId';
  static String attendanceMonthly(String employeeId) => '/attendance/monthly/$employeeId';

  // Leave
  static const String leaveRequest = '/leave/request';
  static const String leaveRequests = '/leave/requests';
  static const String leaveBalances = '/leave/balances';
  static String leaveByEmployee(String employeeId) => '/leave/requests/employee/$employeeId';
  static String leaveBalance(String employeeId) => '/leave/balances/$employeeId';
  static String approveLeave(String id) => '/leave/requests/$id/approve';
  static String rejectLeave(String id) => '/leave/requests/$id/reject';
}