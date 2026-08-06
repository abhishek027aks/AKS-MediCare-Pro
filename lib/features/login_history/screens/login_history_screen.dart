import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/helpers/date_helper.dart';
import '../../../shared/widgets/export_button.dart';
import '../models/login_history_model.dart';
import '../providers/login_history_provider.dart';

class LoginHistoryScreen extends ConsumerStatefulWidget {
  const LoginHistoryScreen({super.key, this.initialSearchQuery});

  /// Pre-fills the search box — used when opened from a specific
  /// employee's record ("View Login History" in User Management).
  final String? initialSearchQuery;

  @override
  ConsumerState<LoginHistoryScreen> createState() => _LoginHistoryScreenState();
}

class _LoginHistoryScreenState extends ConsumerState<LoginHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _statusFilter = 'All';

  @override
  void initState() {
    super.initState();
    if (widget.initialSearchQuery != null) {
      _searchQuery = widget.initialSearchQuery!;
      _searchController.text = widget.initialSearchQuery!;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginHistoryProvider);

    final filtered = state.history.where((entry) {
      final query = _searchQuery.toLowerCase();
      final matchesQuery = entry.usernameAttempted.toLowerCase().contains(query) ||
          (entry.userName ?? '').toLowerCase().contains(query);
      final matchesStatus = _statusFilter == 'All' || entry.status == _statusFilter;
      return matchesQuery && matchesStatus;
    }).toList();

    final failedCount = state.history.where((e) => e.status == 'Failed').length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login History'),
        actions: [
          ExportButton(
            baseName: 'login_history',
            sheetName: 'Login History',
            headers: const ['User', 'Role', 'Device', 'Status', 'Timestamp'],
            rowsBuilder: () => filtered
                .map((e) => [
                      e.userName ?? e.usernameAttempted,
                      e.role ?? '',
                      e.device,
                      e.status,
                      AppDateHelper.formatDateTime(e.timestamp),
                    ])
                .toList(),
          ),
        ],
      ),
      body: Column(
        children: [
          if (state.isLoading) const LinearProgressIndicator(),
          if (failedCount > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Card(
                color: Colors.red.withValues(alpha: 0.08),
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Colors.red),
                      const SizedBox(width: 10),
                      Text('$failedCount failed login attempt(s) recorded', style: const TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by username or name...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: ['All', 'Success', 'Failed'].map((status) {
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
              onRefresh: () => ref.read(loginHistoryProvider.notifier).refresh(),
              child: filtered.isEmpty
                  ? const SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 100),
                        child: Center(child: Text('No login history found.')),
                      ),
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final LoginHistoryModel entry = filtered[index];
                        final isFailed = entry.status == 'Failed';

                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: (isFailed ? Colors.red : Colors.green).withValues(alpha: 0.15),
                              child: Icon(
                                isFailed ? Icons.error_outline : Icons.check_circle_outline,
                                color: isFailed ? Colors.red : Colors.green,
                              ),
                            ),
                            title: Text(entry.userName ?? entry.usernameAttempted),
                            subtitle: Text(
                              '${entry.role ?? '—'}  •  ${entry.device}  •  ${AppDateHelper.formatDateTime(entry.timestamp)}',
                            ),
                            trailing: Chip(
                              backgroundColor: (isFailed ? Colors.red : Colors.green).withValues(alpha: 0.15),
                              label: Text(
                                entry.status,
                                style: TextStyle(color: isFailed ? Colors.red : Colors.green),
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
