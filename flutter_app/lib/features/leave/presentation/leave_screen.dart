import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../domain/leave_provider.dart';
import '../domain/leave_model.dart';

class LeaveScreen extends ConsumerStatefulWidget {
  const LeaveScreen({super.key});

  @override
  ConsumerState<LeaveScreen> createState() => _LeaveScreenState();
}

class _LeaveScreenState extends ConsumerState<LeaveScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.microtask(() => ref.read(leaveProvider.notifier).loadAll());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(leaveProvider);

    ref.listen(leaveProvider, (previous, next) {
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
        title: const Text('Cuti'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Saldo & Riwayat'),
            Tab(text: 'Ajukan Cuti'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBalanceTab(state),
          _buildRequestTab(state),
        ],
      ),
    );
  }

  Widget _buildBalanceTab(LeaveState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Saldo cuti
          const Text(
            'Saldo Cuti',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          if (state.balances.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: Text('Belum ada saldo cuti')),
              ),
            )
          else
            ...state.balances.map((balance) => _buildBalanceCard(balance)),

          const SizedBox(height: 24),

          // Riwayat pengajuan
          const Text(
            'Riwayat Pengajuan',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          if (state.requests.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: Text('Belum ada riwayat pengajuan')),
              ),
            )
          else
            ...state.requests.map((request) => _buildRequestCard(request)),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(LeaveBalanceModel balance) {
    final percentage = balance.totalDays > 0
        ? balance.usedDays / balance.totalDays
        : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  balance.leaveTypeLabel,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${balance.remainingDays} hari tersisa',
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: percentage,
              backgroundColor: Colors.grey.shade200,
              color: percentage > 0.7 ? Colors.red : Colors.blue,
            ),
            const SizedBox(height: 4),
            Text(
              '${balance.usedDays} dari ${balance.totalDays} hari terpakai',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestCard(LeaveRequestModel request) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  request.leaveTypeLabel,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: request.statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    request.statusLabel,
                    style: TextStyle(
                      color: request.statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${DateFormat('d MMM yyyy').format(request.startDate)} - ${DateFormat('d MMM yyyy').format(request.endDate)}',
              style: const TextStyle(color: Colors.grey),
            ),
            Text(
              '${request.totalDays} hari',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(request.reason),
            if (request.rejectNote != null) ...[
              const SizedBox(height: 4),
              Text(
                'Alasan ditolak: ${request.rejectNote}',
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRequestTab(LeaveState state) {
    return _LeaveRequestForm(
      isSubmitting: state.isSubmitting,
      balances: state.balances,
      onSubmit: (leaveType, startDate, endDate, reason) async {
        final success = await ref.read(leaveProvider.notifier).submitRequest(
              leaveType: leaveType,
              startDate: startDate,
              endDate: endDate,
              reason: reason,
            );
        if (success) {
          _tabController.animateTo(0);
        }
      },
    );
  }
}

class _LeaveRequestForm extends StatefulWidget {
  final bool isSubmitting;
  final List<LeaveBalanceModel> balances;
  final Function(String, DateTime, DateTime, String) onSubmit;

  const _LeaveRequestForm({
    required this.isSubmitting,
    required this.balances,
    required this.onSubmit,
  });

  @override
  State<_LeaveRequestForm> createState() => _LeaveRequestFormState();
}

class _LeaveRequestFormState extends State<_LeaveRequestForm> {
  String _selectedLeaveType = 'annual';
  DateTime? _startDate;
  DateTime? _endDate;
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(picked)) {
            _endDate = picked;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  int get _totalDays {
    if (_startDate == null || _endDate == null) return 0;
    return _endDate!.difference(_startDate!).inDays + 1;
  }

  void _handleSubmit() {
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih tanggal cuti terlebih dahulu')),
      );
      return;
    }
    if (_reasonController.text.trim().length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alasan minimal 10 karakter')),
      );
      return;
    }
    widget.onSubmit(
      _selectedLeaveType,
      _startDate!,
      _endDate!,
      _reasonController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Pilih jenis cuti
          const Text('Jenis Cuti', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedLeaveType,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items: const [
              DropdownMenuItem(value: 'annual', child: Text('Cuti Tahunan')),
              DropdownMenuItem(value: 'sick', child: Text('Cuti Sakit')),
              DropdownMenuItem(value: 'permission', child: Text('Izin')),
            ],
            onChanged: (value) {
              setState(() => _selectedLeaveType = value!);
            },
          ),
          const SizedBox(height: 16),

          // Pilih tanggal
          const Text('Tanggal', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickDate(true),
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: Text(
                    _startDate != null
                        ? DateFormat('d MMM yyyy').format(_startDate!)
                        : 'Tanggal Mulai',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickDate(false),
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: Text(
                    _endDate != null
                        ? DateFormat('d MMM yyyy').format(_endDate!)
                        : 'Tanggal Selesai',
                  ),
                ),
              ),
            ],
          ),

          if (_totalDays > 0) ...[
            const SizedBox(height: 8),
            Text(
              'Total: $_totalDays hari',
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
          const SizedBox(height: 16),

          // Alasan
          const Text('Alasan', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _reasonController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Tuliskan alasan pengajuan cuti...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),

          // Tombol submit
          ElevatedButton(
            onPressed: widget.isSubmitting ? null : _handleSubmit,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: widget.isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text('Ajukan Cuti', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}