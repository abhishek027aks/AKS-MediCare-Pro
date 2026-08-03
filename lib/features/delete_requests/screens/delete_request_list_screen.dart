import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/helpers/date_helper.dart';
import '../../auth/presentation/providers/auth_state_provider.dart';
import '../data/repositories/delete_request_repository.dart';
import '../models/delete_request_model.dart';
import '../providers/delete_request_provider.dart';

class DeleteRequestListScreen extends ConsumerStatefulWidget {
  const DeleteRequestListScreen({super.key});

  @override
  ConsumerState<DeleteRequestListScreen> createState() => _DeleteRequestListScreenState();
}

class _DeleteRequestListScreenState extends ConsumerState<DeleteRequestListScreen> {
  String _statusFilter = 'Pending';
  bool _isBusy = false;

  Color _statusColor(String status) {
    switch (status) {
      case 'Approved':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  Future<void> _approve(DeleteRequestModel request) async {
    final user = ref.read(currentUserProvider);
    if (user?.id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 48),
        title: const Text('Approve Deletion'),
        content: Text(
          'This will permanently delete "${request.recordLabel}" from ${request.module}. This cannot be undone. Continue?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Approve & Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isBusy = true);

    try {
      await DeleteRequestRepository.instance.approve(
        request: request,
        reviewerId: user!.id!,
        reviewerName: user.fullName,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request approved and record deleted.'), backgroundColor: Colors.green),
      );

      await ref.read(deleteRequestProvider.notifier).refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _reject(DeleteRequestModel request) async {
    final user = ref.read(currentUserProvider);
    if (user?.id == null) return;

    setState(() => _isBusy = true);

    await DeleteRequestRepository.instance.reject(
      request: request,
      reviewerId: user!.id!,
      reviewerName: user.fullName,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Request rejected — record kept.')),
    );

    await ref.read(deleteRequestProvider.notifier).refresh();
    if (mounted) setState(() => _isBusy = false);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(deleteRequestProvider);

    final filtered = _statusFilter == 'All'
        ? state.requests
        : state.requests.where((r) => r.status == _statusFilter).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Delete Requests')),
      body: Column(
        children: [
          if (state.isLoading) const LinearProgressIndicator(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: ['Pending', 'Approved', 'Rejected', 'All'].map((status) {
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
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.read(deleteRequestProvider.notifier).refresh(),
              child: filtered.isEmpty
                  ? const SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 100),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.delete_sweep_outlined, size: 64),
                              SizedBox(height: 16),
                              Text('No requests here.'),
                            ],
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final request = filtered[index];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        request.recordLabel,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                      ),
                                    ),
                                    Chip(
                                      backgroundColor: _statusColor(request.status).withValues(alpha: 0.15),
                                      label: Text(
                                        request.status,
                                        style: TextStyle(color: _statusColor(request.status)),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text('Module: ${request.module}'),
                                Text('Reason: ${request.reason}'),
                                Text('Requested by: ${request.requestedByName}'),
                                Text('Requested on: ${AppDateHelper.formatDateTime(request.requestedAt)}'),
                                if (request.reviewedByName != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    '${request.status} by ${request.reviewedByName} on '
                                    '${AppDateHelper.formatDateTime(request.reviewedAt!)}',
                                    style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
                                  ),
                                ],
                                if (request.status == 'Pending') ...[
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: _isBusy ? null : () => _reject(request),
                                          icon: const Icon(Icons.close, size: 18),
                                          label: const Text('Reject'),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: FilledButton.icon(
                                          style: FilledButton.styleFrom(backgroundColor: Colors.red),
                                          onPressed: _isBusy ? null : () => _approve(request),
                                          icon: const Icon(Icons.check, size: 18),
                                          label: const Text('Approve'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
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
