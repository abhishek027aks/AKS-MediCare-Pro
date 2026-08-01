import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/helpers/date_helper.dart';
import '../models/lab_test_model.dart';
import '../providers/lab_provider.dart';
import '../widgets/delete_lab_test_dialog.dart';
import 'add_lab_test_screen.dart';
import 'edit_lab_test_screen.dart';
import 'lab_test_details_screen.dart';

class LabTestListScreen extends ConsumerStatefulWidget {
  const LabTestListScreen({super.key});

  @override
  ConsumerState<LabTestListScreen> createState() => _LabTestListScreenState();
}

class _LabTestListScreenState extends ConsumerState<LabTestListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _statusFilter = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Completed':
        return Colors.green;
      case 'In Progress':
      case 'Sample Collected':
        return Colors.orange;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(labProvider);
    final tests = state.tests;

    final filtered = tests.where((test) {
      final query = _searchQuery.toLowerCase();

      final matchesQuery = test.patientName.toLowerCase().contains(query) ||
          test.patientUhid.toLowerCase().contains(query) ||
          test.testNo.toLowerCase().contains(query) ||
          test.testName.toLowerCase().contains(query);

      final matchesStatus = _statusFilter == 'All' || test.status == _statusFilter;

      return matchesQuery && matchesStatus;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Laboratory Tests')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const AddLabTestScreen()),
          );

          if (result == true && mounted) {
            await ref.read(labProvider.notifier).refresh();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Order Test'),
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
                    hintText: 'Search by patient, UHID, test no or name...',
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
                      'Ordered',
                      'Sample Collected',
                      'In Progress',
                      'Completed',
                      'Cancelled',
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
              onRefresh: () => ref.read(labProvider.notifier).refresh(),
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
                        final LabTestModel test = filtered[index];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => LabTestDetailsScreen(test: test)),
                              );
                              if (mounted) await ref.read(labProvider.notifier).refresh();
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 26,
                                    backgroundColor: _statusColor(test.status).withValues(alpha: 0.15),
                                    child: Icon(Icons.biotech_outlined, color: _statusColor(test.status)),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          test.patientName,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        ),
                                        const SizedBox(height: 4),
                                        Text('Test No : ${test.testNo}'),
                                        const SizedBox(height: 4),
                                        Text(test.testName),
                                        const SizedBox(height: 4),
                                        Text('Ordered : ${AppDateHelper.formatDate(test.orderDate)}'),
                                        const SizedBox(height: 10),
                                        Chip(
                                          backgroundColor: _statusColor(test.status).withValues(alpha: 0.15),
                                          label: Text(
                                            test.status,
                                            style: TextStyle(color: _statusColor(test.status)),
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
                                            MaterialPageRoute(builder: (_) => LabTestDetailsScreen(test: test)),
                                          );
                                          if (mounted) await ref.read(labProvider.notifier).refresh();
                                          break;
                                        case 'edit':
                                          final updated = await Navigator.push<bool>(
                                            context,
                                            MaterialPageRoute(builder: (_) => EditLabTestScreen(test: test)),
                                          );
                                          if (updated == true && mounted) {
                                            await ref.read(labProvider.notifier).refresh();
                                          }
                                          break;
                                        case 'delete':
                                          final deleted = await showDialog<bool>(
                                            context: context,
                                            builder: (_) => DeleteLabTestDialog(test: test),
                                          );
                                          if (deleted == true && mounted) {
                                            await ref.read(labProvider.notifier).refresh();
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
            Icon(Icons.biotech_outlined, size: 80),
            SizedBox(height: 20),
            Text('No lab tests found', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Try changing your filters or order a new test.', textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
