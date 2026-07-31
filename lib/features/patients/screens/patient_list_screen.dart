import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/helpers/patient_helper.dart';
import '../models/patient_model.dart';
import '../providers/patient_provider.dart';
import '../widgets/delete_patient_dialog.dart';
import 'add_patient_screen.dart';
import 'edit_patient_screen.dart';
import 'patient_details_screen.dart';

class PatientListScreen extends ConsumerStatefulWidget {
  const PatientListScreen({super.key});

  @override
  ConsumerState<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends ConsumerState<PatientListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _sortBy = 'Name';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshPatients() async {
    await ref.read(patientProvider.notifier).refresh();
  }

  void _sortPatients(List<PatientModel> patientsList, String value) {
    setState(() {
      _sortBy = value;

      switch (value) {
        case 'Name':
          patientsList.sort((a, b) => a.fullName.compareTo(b.fullName));
          break;

        case 'UHID':
          patientsList.sort((a, b) => a.uhid.compareTo(b.uhid));
          break;

        case 'Recently Added':
          patientsList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          break;
      }
    });
  }

  void _showFilterSheet(List<PatientModel> patientsList) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.sort_by_alpha),
                title: const Text('Sort by Name'),
                selected: _sortBy == 'Name',
                onTap: () {
                  Navigator.pop(context);
                  _sortPatients(patientsList, 'Name');
                },
              ),
              ListTile(
                leading: const Icon(Icons.badge_outlined),
                title: const Text('Sort by UHID'),
                selected: _sortBy == 'UHID',
                onTap: () {
                  Navigator.pop(context);
                  _sortPatients(patientsList, 'UHID');
                },
              ),
              ListTile(
                leading: const Icon(Icons.schedule),
                title: const Text('Sort by Recently Added'),
                selected: _sortBy == 'Recently Added',
                onTap: () {
                  Navigator.pop(context);
                  _sortPatients(patientsList, 'Recently Added');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(patientProvider);
    final patients = state.patients;

    final filteredPatients = patients.where((patient) {
      final query = _searchQuery.toLowerCase();

      return patient.fullName.toLowerCase().contains(query) ||
          patient.uhid.toLowerCase().contains(query) ||
          patient.mobile.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Patients'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterSheet(patients),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => const AddPatientScreen(),
            ),
          );

          if (result == true && mounted) {
            await ref.read(patientProvider.notifier).refresh();
          }
        },
        icon: const Icon(Icons.person_add),
        label: const Text('Register Patient'),
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
                    hintText: 'Search by name, UHID or mobile...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Total Patients : ${filteredPatients.length}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshPatients,
              child: filteredPatients.isEmpty
                  ? const SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: 400,
                        child: _EmptyState(),
                      ),
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredPatients.length,
                      itemBuilder: (context, index) {
                        final patient = filteredPatients[index];
                        final bool isActive = patient.isActive;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      PatientDetailsScreen(patient: patient),
                                ),
                              );

                              if (mounted) {
                                await ref
                                    .read(patientProvider.notifier)
                                    .refresh();
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 28,
                                    child: Text(
                                      PatientHelper.getInitials(
                                        patient.fullName,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          patient.fullName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text('UHID : ${patient.uhid}'),
                                        const SizedBox(height: 4),
                                        Text(
                                          PatientHelper.genderAgeLabel(
                                            patient.gender,
                                            patient.age,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text('Mobile : ${patient.mobile}'),
                                        const SizedBox(height: 10),
                                        Chip(
                                          avatar: Icon(
                                            isActive
                                                ? Icons.check_circle
                                                : Icons.cancel,
                                            size: 18,
                                            color: isActive
                                                ? Colors.green
                                                : Colors.red,
                                          ),
                                          label: Text(
                                            isActive ? 'Active' : 'Inactive',
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
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  PatientDetailsScreen(
                                                patient: patient,
                                              ),
                                            ),
                                          );
                                          if (mounted) {
                                            await ref
                                                .read(patientProvider.notifier)
                                                .refresh();
                                          }
                                          break;

                                        case 'edit':
                                          final updated =
                                              await Navigator.push<bool>(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  EditPatientScreen(
                                                patient: patient,
                                              ),
                                            ),
                                          );

                                          if (updated == true && mounted) {
                                            await ref
                                                .read(patientProvider.notifier)
                                                .refresh();
                                          }
                                          break;

                                        case 'delete':
                                          final deleted =
                                              await showDialog<bool>(
                                            context: context,
                                            builder: (_) =>
                                                DeletePatientDialog(
                                              patient: patient,
                                            ),
                                          );

                                          if (deleted == true && mounted) {
                                            await ref
                                                .read(patientProvider.notifier)
                                                .refresh();
                                          }
                                          break;
                                      }
                                    },
                                    itemBuilder: (_) => const [
                                      PopupMenuItem(
                                        value: 'view',
                                        child: Text('View'),
                                      ),
                                      PopupMenuItem(
                                        value: 'edit',
                                        child: Text('Edit'),
                                      ),
                                      PopupMenuItem(
                                        value: 'delete',
                                        child: Text('Delete'),
                                      ),
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.personal_injury_outlined,
              size: 80,
            ),
            SizedBox(height: 20),
            Text(
              'No patients found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Try changing your search or register a new patient.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
