import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/helpers/date_helper.dart';
import '../../../core/helpers/ipd_helper.dart';
import '../models/ipd_admission_model.dart';
import '../providers/ipd_provider.dart';
import 'ipd_admission_details_screen.dart';

class WardOccupancyScreen extends ConsumerWidget {
  const WardOccupancyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ipdProvider);
    final admitted = state.admissions.where((a) => a.status == 'Admitted').toList();

    // Group admitted patients by ward. Any ward name present in the
    // data but not in the standard list is included too, so nothing
    // silently disappears if a custom ward name was ever used.
    final wardNames = <String>{
      ...IpdHelper.wards,
      ...admitted.map((a) => a.ward),
    }.toList()
      ..sort();

    final byWard = <String, List<IpdAdmissionModel>>{
      for (final ward in wardNames) ward: admitted.where((a) => a.ward == ward).toList(),
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Ward / Bed Occupancy')),
      body: RefreshIndicator(
        onRefresh: () => ref.read(ipdProvider.notifier).refresh(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              elevation: 0,
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Patients Currently Admitted', style: TextStyle(fontWeight: FontWeight.w600)),
                    Text(
                      '${admitted.length}',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (state.isLoading) const LinearProgressIndicator(),
            ...wardNames.map((ward) {
              final patients = byWard[ward] ?? [];

              return Card(
                margin: const EdgeInsets.only(bottom: 14),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            ward,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Chip(
                            backgroundColor: (patients.isEmpty ? Colors.green : Colors.orange).withValues(alpha: 0.15),
                            label: Text(
                              patients.isEmpty ? 'Empty' : '${patients.length} occupied',
                              style: TextStyle(color: patients.isEmpty ? Colors.green : Colors.orange),
                            ),
                          ),
                        ],
                      ),
                      if (patients.isNotEmpty) ...[
                        const Divider(),
                        ...patients.map(
                          (admission) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.bed_outlined),
                            title: Text('Bed ${admission.bedNumber}  •  ${admission.patientName}'),
                            subtitle: Text(
                              'Admitted ${AppDateHelper.formatDate(admission.admissionDate)}  •  ${admission.doctorName}',
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => IpdAdmissionDetailsScreen(admission: admission),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
