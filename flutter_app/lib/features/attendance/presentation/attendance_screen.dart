import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../domain/attendance_provider.dart';
import '../domain/attendance_model.dart';

class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.microtask(() {
      ref.read(attendanceProvider.notifier).loadToday();
      ref.read(attendanceProvider.notifier).loadMonthly();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(attendanceProvider);

    // tampilkan snackbar kalau ada pesan sukses atau error
    ref.listen(attendanceProvider, (previous, next) {
      if (next.successMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.successMessage!),
            backgroundColor: Colors.green,
          ),
        );
      }
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Presensi'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Hari Ini'),
            Tab(text: 'Riwayat'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTodayTab(state),
          _buildHistoryTab(state),
        ],
      ),
    );
  }

  Widget _buildTodayTab(AttendanceState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final attendance = state.todayAttendance;
    final now = DateTime.now();
    final dateStr = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(now);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Card tanggal dan status
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    dateStr,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: attendance != null
                          ? attendance.statusColor.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      attendance?.statusLabel ?? 'Belum Presensi',
                      style: TextStyle(
                        color: attendance?.statusColor ?? Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Card jam masuk dan keluar
          Row(
            children: [
              Expanded(
                child: _buildTimeCard(
                  label: 'Jam Masuk',
                  time: attendance?.checkInTime != null
                      ? DateFormat('HH:mm').format(attendance!.checkInTime!)
                      : '--:--',
                  icon: Icons.login,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTimeCard(
                  label: 'Jam Keluar',
                  time: attendance?.checkOutTime != null
                      ? DateFormat('HH:mm').format(attendance!.checkOutTime!)
                      : '--:--',
                  icon: Icons.logout,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Tombol clock-in
          if (attendance == null || !attendance.hasCheckedIn)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: state.isClockingIn
                    ? null
                    : () => ref.read(attendanceProvider.notifier).clockIn(),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                icon: state.isClockingIn
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.login),
                label: Text(
                  state.isClockingIn ? 'Mengambil lokasi...' : 'Clock In',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),

          // Tombol clock-out
          if (attendance != null &&
              attendance.hasCheckedIn &&
              !attendance.hasCheckedOut)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: state.isClockingOut
                    ? null
                    : () => ref.read(attendanceProvider.notifier).clockOut(),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                icon: state.isClockingOut
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.logout),
                label: Text(
                  state.isClockingOut ? 'Mengambil lokasi...' : 'Clock Out',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),

          // Sudah clock-out
          if (attendance != null && attendance.hasCheckedOut)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 8),
                  Text(
                    'Presensi hari ini selesai',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTimeCard({
    required String label,
    required String time,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              time,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTab(AttendanceState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final summary = state.summary;
    final attendances = state.monthlyAttendances;

    return Column(
      children: [
        // Summary bulanan
        if (summary != null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildSummaryCard('Hadir', summary.present, Colors.green),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildSummaryCard('Terlambat', summary.late, Colors.orange),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildSummaryCard('Absen', summary.absent, Colors.red),
                ),
              ],
            ),
          ),

        // List riwayat
        Expanded(
          child: attendances.isEmpty
              ? const Center(child: Text('Belum ada data presensi bulan ini'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: attendances.length,
                  itemBuilder: (context, index) {
                    final item = attendances[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: item.statusColor.withOpacity(0.1),
                          child: Icon(
                            Icons.calendar_today,
                            color: item.statusColor,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          DateFormat('EEEE, d MMM', 'id_ID').format(item.date),
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          item.checkInTime != null
                              ? 'Masuk: ${DateFormat('HH:mm').format(item.checkInTime!)}'
                              : 'Tidak ada data',
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: item.statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            item.statusLabel,
                            style: TextStyle(
                              color: item.statusColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String label, int count, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}