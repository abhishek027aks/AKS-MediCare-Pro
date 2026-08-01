import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/helpers/date_helper.dart';
import '../../billing/models/bill_item_model.dart';
import '../../billing/screens/add_bill_screen.dart';
import '../../patients/models/patient_model.dart';
import '../models/opd_visit_model.dart';
import '../providers/opd_provider.dart';
import '../widgets/delete_visit_dialog.dart';
import 'edit_opd_visit_screen.dart';

class OpdVisitDetailsScreen extends ConsumerWidget {
  const OpdVisitDetailsScreen({super.key, required this.visit});

  final OpdVisitModel visit;

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
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Visit Details'), centerTitle: true),
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
                    const Icon(Icons.local_hospital_outlined, size: 52),
                    const SizedBox(height: 12),
                    Text(
                      visit.patientName,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text('UHID : ${visit.patientUhid}'),
                    Text('Visit No : ${visit.visitNo}'),
                    const SizedBox(height: 16),
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
                    Text('Visit Information', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    _InfoTile(icon: Icons.medical_services_outlined, title: 'Doctor', value: visit.doctorName),
                    const Divider(),
                    _InfoTile(icon: Icons.event_outlined, title: 'Visit Date', value: AppDateHelper.formatDate(visit.visitDate)),
                    const Divider(),
                    _InfoTile(icon: Icons.repeat_outlined, title: 'Visit Type', value: visit.visitType),
                    const Divider(),
                    _InfoTile(
                      icon: Icons.currency_rupee,
                      title: 'Consultation Fee',
                      value: '₹${visit.consultationFee.toStringAsFixed(2)}',
                    ),
                    const Divider(),
                    _InfoTile(
                      icon: Icons.event_repeat_outlined,
                      title: 'Follow-up Date',
                      value: visit.followUpDate == null
                          ? '—'
                          : AppDateHelper.formatDate(visit.followUpDate!),
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
                    Text('Clinical Notes', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    _InfoTile(icon: Icons.report_problem_outlined, title: 'Chief Complaint', value: visit.chiefComplaint ?? '—'),
                    const Divider(),
                    _InfoTile(icon: Icons.biotech_outlined, title: 'Diagnosis', value: visit.diagnosis ?? '—'),
                    const Divider(),
                    _InfoTile(icon: Icons.medication_outlined, title: 'Prescription', value: visit.prescription ?? '—'),
                    const Divider(),
                    _InfoTile(icon: Icons.notes_outlined, title: 'Notes', value: visit.notes ?? '—'),
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
                          id: visit.patientId,
                          uhid: visit.patientUhid,
                          fullName: visit.patientName,
                          gender: '',
                          dateOfBirth: DateTime(1970),
                          mobile: '',
                          createdAt: DateTime.now(),
                          updatedAt: DateTime.now(),
                        ),
                        prefillBillType: 'OPD',
                        prefillReferenceNo: visit.visitNo,
                        prefillItems: [
                          BillItemModel(
                            description: 'OPD Consultation — Dr. ${visit.doctorName}',
                            quantity: 1,
                            unitPrice: visit.consultationFee,
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
                    MaterialPageRoute(builder: (_) => EditOpdVisitScreen(visit: visit)),
                  );

                  if (updated == true && context.mounted) {
                    await ref.read(opdProvider.notifier).refresh();
                    if (context.mounted) Navigator.pop(context);
                  }
                },
                icon: const Icon(Icons.edit),
                label: const Text('Edit Visit'),
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
                    builder: (_) => DeleteVisitDialog(visit: visit),
                  );

                  if (deleted == true && context.mounted) {
                    await ref.read(opdProvider.notifier).refresh();
                    if (context.mounted) Navigator.pop(context);
                  }
                },
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete Visit'),
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
