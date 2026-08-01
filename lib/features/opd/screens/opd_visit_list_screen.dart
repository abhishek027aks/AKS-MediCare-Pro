import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/helpers/date_helper.dart';
import '../models/opd_visit_model.dart';
import '../providers/opd_provider.dart';
import '../widgets/delete_visit_dialog.dart';
import 'add_opd_visit_screen.dart';
import 'edit_opd_visit_screen.dart';
import 'opd_visit_details_screen.dart';

class OpdVisitListScreen extends ConsumerStatefulWidget {
  const OpdVisitListScreen({super.key});

  @override
  ConsumerState<OpdVisitListScreen> createState() => _OpdVisitListScreenState();
}

class _OpdVisitListScreenState extends ConsumerState<OpdVisitListScreen> {
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
      case 'In Consultation':
        return Colors.orange;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(opdProvider);
    final visits = state.visits;

    final filteredVisits = visits.where((visit) {
      final query = _searchQuery.toLowerCase();

      final matchesQuery = visit.patientName.toLowerCase().contains(query) ||
          visit.patientUhid.toLowerCase().contains(query) ||
          visit.visitNo.toLowerCase().contains(query) ||
          visit.doctorName.toLowerCase().contains(query);

      final matchesStatus = _statusFilter == 'All' || visit.status == _statusFilter;

      return matchesQuery && matchesStatus;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('OPD Visits')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const AddOpdVisitScreen()),
          );

          if (result == true && mounted) {
            await ref.read(opdProvider.notifier).refresh();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('New Visit'),
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
                    hintText: 'Search by patient, UHID, visit no or doctor...',
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
                      'Waiting',
                      'In Consultation',
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
              onRefresh: () => ref.read(opdProvider.notifier).refresh(),
              child: filteredVisits.isEmpty
                  ? const SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      child: SizedBox(height: 400, child: _EmptyState()),
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredVisits.length,
                      itemBuilder: (context, index) {
                        final OpdVisitModel visit = filteredVisits[index];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => OpdVisitDetailsScreen(visit: visit),
                                ),
                              );
                              if (mounted) await ref.read(opdProvider.notifier).refresh();
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 26,
                                    backgroundColor: _statusColor(visit.status).withValues(alpha: 0.15),
                                    child: Icon(Icons.local_hospital_outlined, color: _statusColor(visit.status)),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          visit.patientName,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        ),
                                        const SizedBox(height: 4),
                                        Text('Visit No : ${visit.visitNo}'),
                                        const SizedBox(height: 4),
                                        Text('Doctor : ${visit.doctorName}'),
                                        const SizedBox(height: 4),
                                        Text('Date : ${AppDateHelper.formatDate(visit.visitDate)}'),
                                        const SizedBox(height: 10),
                                        Chip(
                                          backgroundColor: _statusColor(visit.status).withValues(alpha: 0.15),
                                          label: Text(
                                            visit.status,
                                            style: TextStyle(color: _statusColor(visit.status)),
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
                                            MaterialPageRoute(builder: (_) => OpdVisitDetailsScreen(visit: visit)),
                                          );
                                          if (mounted) await ref.read(opdProvider.notifier).refresh();
                                          break;
                                        case 'edit':
                                          final updated = await Navigator.push<bool>(
                                            context,
                                            MaterialPageRoute(builder: (_) => EditOpdVisitScreen(visit: visit)),
                                          );
                                          if (updated == true && mounted) {
                                            await ref.read(opdProvider.notifier).refresh();
                                          }
                                          break;
                                        case 'delete':
                                          final deleted = await showDialog<bool>(
                                            context: context,
                                            builder: (_) => DeleteVisitDialog(visit: visit),
                                          );
                                          if (deleted == true && mounted) {
                                            await ref.read(opdProvider.notifier).refresh();
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
            Icon(Icons.local_hospital_outlined, size: 80),
            SizedBox(height: 20),
            Text('No OPD visits found', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Try changing your filters or create a new visit.', textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
