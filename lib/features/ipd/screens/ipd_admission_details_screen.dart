import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/helpers/date_helper.dart';
import '../../billing/models/bill_item_model.dart';
import '../../billing/screens/add_bill_screen.dart';
import '../../patients/models/patient_model.dart';
import '../models/ipd_admission_model.dart';
import '../providers/ipd_provider.dart';
import '../widgets/delete_admission_dialog.dart';
import 'edit_ipd_admission_screen.dart';

class IpdAdmissionDetailsScreen extends ConsumerWidget {
  const IpdAdmissionDetailsScreen({super.key, required this.admission});

  final IpdAdmissionModel admission;

  Color _statusColor(String status) => status == 'Admitted' ? Colors.orange : Colors.green;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nights = admission.dischargeDate == null
        ? DateTime.now().difference(admission.admissionDate).inDays
        : admission.dischargeDate!.difference(admission.admissionDate).inDays;

    final estimatedRoomCharges = nights * admission.roomChargesPerDay;

    return Scaffold(
      appBar: AppBar(title: const Text('Admission Details'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Icon(Icons.bed_outlined, size: 52),
                    const SizedBox(height: 12),
                    Text(
                      admission.patientName,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text('UHID : ${admission.patientUhid}'),
                    Text('Admission No : ${admission.admissionNo}'),
                    const SizedBox(height: 16),
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
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Admission Information', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    _InfoTile(icon: Icons.medical_services_outlined, title: 'Admitting Doctor', value: admission.doctorName),
                    const Divider(),
                    _InfoTile(icon: Icons.meeting_room_outlined, title: 'Ward', value: admission.ward),
                    const Divider(),
                    _InfoTile(icon: Icons.bed_outlined, title: 'Bed Number', value: admission.bedNumber),
                    const Divider(),
                    _InfoTile(icon: Icons.category_outlined, title: 'Admission Type', value: admission.admissionType),
                    const Divider(),
                    _InfoTile(icon: Icons.event_outlined, title: 'Admission Date', value: AppDateHelper.formatDate(admission.admissionDate)),
                    const Divider(),
                    _InfoTile(icon: Icons.biotech_outlined, title: 'Diagnosis', value: admission.diagnosis ?? '—'),
                    const Divider(),
                    _InfoTile(
                      icon: Icons.currency_rupee,
                      title: 'Room Charges / Day',
                      value: '₹${admission.roomChargesPerDay.toStringAsFixed(2)}',
                    ),
                    const Divider(),
                    _InfoTile(
                      icon: Icons.calculate_outlined,
                      title: admission.status == 'Discharged' ? 'Total Nights' : 'Nights So Far',
                      value: '$nights  (₹${estimatedRoomCharges.toStringAsFixed(2)} room charges)',
                    ),
                  ],
                ),
              ),
            ),
            if (admission.status == 'Discharged') ...[
              const SizedBox(height: 20),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Discharge Information', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 12),
                      _InfoTile(
                        icon: Icons.event_available_outlined,
                        title: 'Discharge Date',
                        value: admission.dischargeDate == null
                            ? '—'
                            : AppDateHelper.formatDate(admission.dischargeDate!),
                      ),
                      const Divider(),
                      _InfoTile(icon: Icons.summarize_outlined, title: 'Discharge Summary', value: admission.dischargeSummary ?? '—'),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Notes', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    Text(admission.notes ?? '—'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Actions', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddBillScreen(
                        prefillPatient: PatientModel(
                          id: admission.patientId,
                          uhid: admission.patientUhid,
                          fullName: admission.patientName,
                          gender: '',
                          dateOfBirth: DateTime(1970),
                          mobile: '',
                          createdAt: DateTime.now(),
                          updatedAt: DateTime.now(),
                        ),
                        prefillBillType: 'IPD',
                        prefillReferenceNo: admission.admissionNo,
                        prefillItems: [
                          BillItemModel(
                            description:
                                'Room Charges — ${admission.ward} (Bed ${admission.bedNumber})',
                            quantity: nights == 0 ? 1 : nights,
                            unitPrice: admission.roomChargesPerDay,
                          ),
                        ],
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.receipt_long_outlined),
                label: const Text('Generate Bill'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () async {
                  final updated = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(builder: (_) => EditIpdAdmissionScreen(admission: admission)),
                  );

                  if (updated == true && context.mounted) {
                    await ref.read(ipdProvider.notifier).refresh();
                    if (context.mounted) Navigator.pop(context);
                  }
                },
                icon: const Icon(Icons.edit),
                label: const Text('Edit Admission'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
                onPressed: () async {
                  final deleted = await showDialog<bool>(
                    context: context,
                    builder: (_) => DeleteAdmissionDialog(admission: admission),
                  );

                  if (deleted == true && context.mounted) {
                    await ref.read(ipdProvider.notifier).refresh();
                    if (context.mounted) Navigator.pop(context);
                  }
                },
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete Admission'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoTile({required this.icon, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(
        value.isEmpty ? '—' : value,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}
