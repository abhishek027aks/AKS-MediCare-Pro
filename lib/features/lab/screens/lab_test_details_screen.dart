import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/helpers/date_helper.dart';
import '../../billing/models/bill_item_model.dart';
import '../../billing/screens/add_bill_screen.dart';
import '../../patients/models/patient_model.dart';
import '../models/lab_test_model.dart';
import '../providers/lab_provider.dart';
import '../widgets/delete_lab_test_dialog.dart';
import 'edit_lab_test_screen.dart';

class LabTestDetailsScreen extends ConsumerWidget {
  const LabTestDetailsScreen({super.key, required this.test});

  final LabTestModel test;

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
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lab Test Details'), centerTitle: true),
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
                    const Icon(Icons.biotech_outlined, size: 52),
                    const SizedBox(height: 12),
                    Text(
                      test.patientName,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text('UHID : ${test.patientUhid}'),
                    Text('Test No : ${test.testNo}'),
                    const SizedBox(height: 16),
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
                    Text('Test Information', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    _InfoTile(icon: Icons.medical_services_outlined, title: 'Referring Doctor', value: test.doctorName),
                    const Divider(),
                    _InfoTile(icon: Icons.biotech_outlined, title: 'Test Name', value: test.testName),
                    const Divider(),
                    _InfoTile(icon: Icons.category_outlined, title: 'Category', value: test.testCategory),
                    const Divider(),
                    _InfoTile(icon: Icons.water_drop_outlined, title: 'Sample Type', value: test.sampleType),
                    const Divider(),
                    _InfoTile(icon: Icons.event_outlined, title: 'Order Date', value: AppDateHelper.formatDate(test.orderDate)),
                    const Divider(),
                    _InfoTile(
                      icon: Icons.currency_rupee,
                      title: 'Test Fee',
                      value: '₹${test.testFee.toStringAsFixed(2)}',
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
                    Text('Result', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    _InfoTile(
                      icon: Icons.numbers_outlined,
                      title: 'Result Value',
                      value: test.resultValue == null
                          ? '—'
                          : '${test.resultValue} ${test.resultUnit ?? ''}'.trim(),
                    ),
                    const Divider(),
                    _InfoTile(icon: Icons.rule_outlined, title: 'Normal Range', value: test.normalRange ?? '—'),
                    const Divider(),
                    _InfoTile(
                      icon: Icons.event_available_outlined,
                      title: 'Result Date',
                      value: test.resultDate == null ? '—' : AppDateHelper.formatDate(test.resultDate!),
                    ),
                    const Divider(),
                    _InfoTile(icon: Icons.notes_outlined, title: 'Notes', value: test.notes ?? '—'),
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
                          id: test.patientId,
                          uhid: test.patientUhid,
                          fullName: test.patientName,
                          gender: '',
                          dateOfBirth: DateTime(1970),
                          mobile: '',
                          createdAt: DateTime.now(),
                          updatedAt: DateTime.now(),
                        ),
                        prefillBillType: 'Laboratory',
                        prefillReferenceNo: test.testNo,
                        prefillItems: [
                          BillItemModel(
                            description: test.testName,
                            quantity: 1,
                            unitPrice: test.testFee,
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
                    MaterialPageRoute(builder: (_) => EditLabTestScreen(test: test)),
                  );

                  if (updated == true && context.mounted) {
                    await ref.read(labProvider.notifier).refresh();
                    if (context.mounted) Navigator.pop(context);
                  }
                },
                icon: const Icon(Icons.edit),
                label: const Text('Edit Test'),
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
                    builder: (_) => DeleteLabTestDialog(test: test),
                  );

                  if (deleted == true && context.mounted) {
                    await ref.read(labProvider.notifier).refresh();
                    if (context.mounted) Navigator.pop(context);
                  }
                },
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete Test'),
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
