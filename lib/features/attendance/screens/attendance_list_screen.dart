import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/export_button.dart';
import '../models/attendance_model.dart';
import '../providers/attendance_provider.dart';
import '../widgets/delete_attendance_dialog.dart';
import 'add_attendance_screen.dart';
import 'attendance_details_screen.dart';
import 'edit_attendance_screen.dart';

class AttendanceListScreen extends ConsumerStatefulWidget {
  const AttendanceListScreen({super.key});

  @override
  ConsumerState<AttendanceListScreen> createState() => _AttendanceListScreenState();
}

class _AttendanceListScreenState extends ConsumerState<AttendanceListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _statusFilter = 'All';

  Color _statusColor(String status) {
    switch (status) {
      case 'Present':
        return Colors.green;
      case 'Half Day':
        return Colors.orange;
      case 'On Leave':
        return Colors.blue;
      case 'Holiday':
        return Colors.purple;
      default:
        return Colors.red;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(attendanceProvider);
    final records = state.records;

    final filtered = records.where((record) {
      final query = _searchQuery.toLowerCase();

      final matchesQuery = record.staffName.toLowerCase().contains(query) ||
          record.role.toLowerCase().contains(query);

      final matchesStatus = _statusFilter == 'All' || record.status == _statusFilter;

      return matchesQuery && matchesStatus;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Attendance'),
        actions: [
          ExportButton(
            baseName: 'attendance',
            sheetName: 'Attendance',
            headers: const ['Staff Name', 'Role', 'Date', 'Status', 'Check-in', 'Check-out'],
            rowsBuilder: () => filtered
                .map((r) => [
                      r.staffName,
                      r.role,
                      DateFormat('dd/MM/yyyy').format(r.date),
                      r.status,
                      r.checkInTime ?? '',
                      r.checkOutTime ?? '',
                    ])
                .toList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const AddAttendanceScreen()),
          );

          if (result == true && mounted) {
            await ref.read(attendanceProvider.notifier).refresh();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Mark Attendance'),
      ),
      body: Column(
        children: [
          if (state.isLoading) const LinearProgressIndicator(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by staff name or role...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      'All',
                      'Present',
                      'Absent',
                      'Half Day',
                      'On Leave',
                      'Holiday',
                    ].map((status) {
                      final selected = _statusFilter == status;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(status),
                          selected: selected,
                          onSelected: (_) => setState(() => _statusFilter = status),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.read(attendanceProvider.notifier).refresh(),
              child: filtered.isEmpty
                  ? const SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      child: SizedBox(height: 400, child: _EmptyState()),
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final AttendanceModel record = filtered[index];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => AttendanceDetailsScreen(record: record)),
                              );
                              if (mounted) await ref.read(attendanceProvider.notifier).refresh();
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 26,
                                    backgroundColor: _statusColor(record.status).withValues(alpha: 0.15),
                                    child: Icon(Icons.fact_check_outlined, color: _statusColor(record.status)),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          record.staffName,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        ),
                                        const SizedBox(height: 4),
                                        Text('${record.role}  •  ${DateFormat('dd/MM/yyyy').format(record.date)}'),
                                        const SizedBox(height: 10),
                                        Chip(
                                          backgroundColor: _statusColor(record.status).withValues(alpha: 0.15),
                                          label: Text(
                                            record.status,
                                            style: TextStyle(color: _statusColor(record.status)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  PopupMenuButton<String>(
                                    onSelected: (value) async {
                                      switch (value) {
                                        case 'view':
                                          await Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (_) => AttendanceDetailsScreen(record: record)),
                                          );
                                          if (mounted) await ref.read(attendanceProvider.notifier).refresh();
                                          break;
                                        case 'edit':
                                          final updated = await Navigator.push<bool>(
                                            context,
                                            MaterialPageRoute(builder: (_) => EditAttendanceScreen(record: record)),
                                          );
                                          if (updated == true && mounted) {
                                            await ref.read(attendanceProvider.notifier).refresh();
                                          }
                                          break;
                                        case 'delete':
                                          final deleted = await showDialog<bool>(
                                            context: context,
                                            builder: (_) => DeleteAttendanceDialog(record: record),
                                          );
                                          if (deleted == true && mounted) {
                                            await ref.read(attendanceProvider.notifier).refresh();
                                          }
                                          break;
                                      }
                                    },
                                    itemBuilder: (_) => const [
                                      PopupMenuItem(value: 'view', child: Text('View')),
                                      PopupMenuItem(value: 'edit', child: Text('Edit')),
                                      PopupMenuItem(value: 'delete', child: Text('Delete')),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fact_check_outlined, size: 80),
            SizedBox(height: 20),
            Text('No attendance records found', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Try changing your filters or mark attendance.', textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
