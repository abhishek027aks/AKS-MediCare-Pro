import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/helpers/date_helper.dart';
import '../models/ipd_admission_model.dart';
import '../providers/ipd_provider.dart';
import '../widgets/delete_admission_dialog.dart';
import 'add_ipd_admission_screen.dart';
import 'edit_ipd_admission_screen.dart';
import 'ipd_admission_details_screen.dart';

class IpdAdmissionListScreen extends ConsumerStatefulWidget {
  const IpdAdmissionListScreen({super.key});

  @override
  ConsumerState<IpdAdmissionListScreen> createState() => _IpdAdmissionListScreenState();
}

class _IpdAdmissionListScreenState extends ConsumerState<IpdAdmissionListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _statusFilter = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _statusColor(String status) => status == 'Admitted' ? Colors.orange : Colors.green;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ipdProvider);
    final admissions = state.admissions;

    final filtered = admissions.where((admission) {
      final query = _searchQuery.toLowerCase();

      final matchesQuery = admission.patientName.toLowerCase().contains(query) ||
          admission.patientUhid.toLowerCase().contains(query) ||
          admission.admissionNo.toLowerCase().contains(query) ||
          admission.ward.toLowerCase().contains(query);

      final matchesStatus = _statusFilter == 'All' || admission.status == _statusFilter;

      return matchesQuery && matchesStatus;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('IPD Admissions')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const AddIpdAdmissionScreen()),
          );

          if (result == true && mounted) {
            await ref.read(ipdProvider.notifier).refresh();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('New Admission'),
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
                    hintText: 'Search by patient, UHID, admission no or ward...',
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
                    children: ['All', 'Admitted', 'Discharged'].map((status) {
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
              onRefresh: () => ref.read(ipdProvider.notifier).refresh(),
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
                        final IpdAdmissionModel admission = filtered[index];

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
                                  builder: (_) => IpdAdmissionDetailsScreen(admission: admission),
                                ),
                              );
                              if (mounted) await ref.read(ipdProvider.notifier).refresh();
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 26,
                                    backgroundColor: _statusColor(admission.status).withValues(alpha: 0.15),
                                    child: Icon(Icons.bed_outlined, color: _statusColor(admission.status)),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          admission.patientName,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        ),
                                        const SizedBox(height: 4),
                                        Text('Admission No : ${admission.admissionNo}'),
                                        const SizedBox(height: 4),
                                        Text('${admission.ward}  •  Bed ${admission.bedNumber}'),
                                        const SizedBox(height: 4),
                                        Text('Admitted : ${AppDateHelper.formatDate(admission.admissionDate)}'),
                                        const SizedBox(height: 10),
                                        Chip(
                                          backgroundColor: _statusColor(admission.status).withValues(alpha: 0.15),
                                          label: Text(
                                            admission.status,
                                            style: TextStyle(color: _statusColor(admission.status)),
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
                                            MaterialPageRoute(builder: (_) => IpdAdmissionDetailsScreen(admission: admission)),
                                          );
                                          if (mounted) await ref.read(ipdProvider.notifier).refresh();
                                          break;
                                        case 'edit':
                                          final updated = await Navigator.push<bool>(
                                            context,
                                            MaterialPageRoute(builder: (_) => EditIpdAdmissionScreen(admission: admission)),
                                          );
                                          if (updated == true && mounted) {
                                            await ref.read(ipdProvider.notifier).refresh();
                                          }
                                          break;
                                        case 'delete':
                                          final deleted = await showDialog<bool>(
                                            context: context,
                                            builder: (_) => DeleteAdmissionDialog(admission: admission),
                                          );
                                          if (deleted == true && mounted) {
                                            await ref.read(ipdProvider.notifier).refresh();
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
            Icon(Icons.bed_outlined, size: 80),
            SizedBox(height: 20),
            Text('No admissions found', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Try changing your filters or admit a new patient.', textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
