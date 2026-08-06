import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/helpers/date_helper.dart';
import '../../../shared/widgets/export_button.dart';
import '../models/audit_log_model.dart';
import '../providers/audit_provider.dart';

class AuditLogScreen extends ConsumerStatefulWidget {
  const AuditLogScreen({super.key});

  @override
  ConsumerState<AuditLogScreen> createState() => _AuditLogScreenState();
}

class _AuditLogScreenState extends ConsumerState<AuditLogScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _actionFilter = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _actionColor(String action) {
    switch (action) {
      case 'Create':
        return Colors.green;
      case 'Update':
        return Colors.orange;
      case 'Delete':
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }

  IconData _actionIcon(String action) {
    switch (action) {
      case 'Create':
        return Icons.add_circle_outline;
      case 'Update':
        return Icons.edit_outlined;
      case 'Delete':
        return Icons.delete_outline;
      default:
        return Icons.history;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(auditProvider);
    final logs = state.logs;

    final filtered = logs.where((log) {
      final query = _searchQuery.toLowerCase();

      final matchesQuery = log.userName.toLowerCase().contains(query) ||
          log.module.toLowerCase().contains(query) ||
          log.description.toLowerCase().contains(query);

      final matchesAction = _actionFilter == 'All' || log.action == _actionFilter;

      return matchesQuery && matchesAction;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Audit Log'),
        actions: [
          ExportButton(
            baseName: 'audit_log',
            sheetName: 'Audit Log',
            headers: const ['User', 'Role', 'Action', 'Module', 'Description', 'Timestamp'],
            rowsBuilder: () => filtered
                .map((log) => [
                      log.userName,
                      log.role ?? '',
                      log.action,
                      log.module,
                      log.description,
                      AppDateHelper.formatDateTime(log.timestamp),
                    ])
                .toList(),
          ),
        ],
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
                    hintText: 'Search by user, module or description...',
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
                    children: ['All', 'Create', 'Update', 'Delete'].map((action) {
                      final selected = _actionFilter == action;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(action),
                          selected: selected,
                          onSelected: (_) => setState(() => _actionFilter = action),
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
              onRefresh: () => ref.read(auditProvider.notifier).refresh(),
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
                        final AuditLogModel log = filtered[index];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: _actionColor(log.action).withValues(alpha: 0.15),
                              child: Icon(_actionIcon(log.action), color: _actionColor(log.action)),
                            ),
                            title: Text(log.description),
                            subtitle: Text(
                              '${log.userName}${log.role != null ? " (${log.role})" : ""}  •  ${log.module}  •  ${AppDateHelper.formatDateTime(log.timestamp)}',
                            ),
                            trailing: Chip(
                              backgroundColor: _actionColor(log.action).withValues(alpha: 0.15),
                              label: Text(
                                log.action,
                                style: TextStyle(color: _actionColor(log.action)),
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
            Icon(Icons.history, size: 80),
            SizedBox(height: 20),
            Text('No audit activity yet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Actions across the app will appear here as they happen.', textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
