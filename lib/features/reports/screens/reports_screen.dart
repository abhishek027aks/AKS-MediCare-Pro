import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../billing/providers/billing_provider.dart';
import '../../ipd/providers/ipd_provider.dart';
import '../../lab/providers/lab_provider.dart';
import '../../opd/providers/opd_provider.dart';
import '../../patients/providers/patient_provider.dart';
import '../../pharmacy/providers/medicine_provider.dart';
import '../widgets/simple_bar_row.dart';
import '../widgets/stat_card.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patients = ref.watch(patientProvider).patients;
    final visits = ref.watch(opdProvider).visits;
    final admissions = ref.watch(ipdProvider).admissions;
    final bills = ref.watch(billingProvider).bills;
    final medicines = ref.watch(medicineProvider).medicines;
    final labTests = ref.watch(labProvider).tests;

    final activePatients = patients.where((p) => p.isActive).length;

    final todaysVisits = visits.where((v) => _isToday(v.visitDate)).length;
    final opdWaiting = visits.where((v) => v.status == 'Waiting').length;
    final opdInConsultation = visits.where((v) => v.status == 'In Consultation').length;
    final opdCompleted = visits.where((v) => v.status == 'Completed').length;

    final currentlyAdmitted = admissions.where((a) => a.status == 'Admitted').length;
    final discharged = admissions.where((a) => a.status == 'Discharged').length;

    final totalCollected = bills.fold<double>(0, (sum, b) => sum + b.paidAmount);
    final totalOutstanding = bills.fold<double>(0, (sum, b) => sum + b.balanceAmount);
    final paidBills = bills.where((b) => b.paymentStatus == 'Paid').length;
    final partialBills = bills.where((b) => b.paymentStatus == 'Partial').length;
    final unpaidBills = bills.where((b) => b.paymentStatus == 'Unpaid').length;

    final lowStock = medicines.where((m) => m.isLowStock).length;
    final expired = medicines.where((m) => m.isExpired).length;

    final pendingLabTests =
        labTests.where((t) => t.status != 'Completed' && t.status != 'Cancelled').length;
    final completedLabTests = labTests.where((t) => t.status == 'Completed').length;

    final maxOpdBar = [opdWaiting, opdInConsultation, opdCompleted]
        .fold<int>(0, (max, v) => v > max ? v : max);
    final maxBillBar = [paidBills, partialBills, unpaidBills]
        .fold<int>(0, (max, v) => v > max ? v : max);

    return Scaffold(
      appBar: AppBar(title: const Text('Reports & Analytics')),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(patientProvider.notifier).refresh();
          await ref.read(opdProvider.notifier).refresh();
          await ref.read(ipdProvider.notifier).refresh();
          await ref.read(billingProvider.notifier).refresh();
          await ref.read(medicineProvider.notifier).refresh();
          await ref.read(labProvider.notifier).refresh();
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Overview', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.4,
              children: [
                StatCard(
                  icon: Icons.personal_injury_outlined,
                  value: '${patients.length}',
                  label: 'Total Patients ($activePatients active)',
                  color: Colors.teal,
                ),
                StatCard(
                  icon: Icons.local_hospital_outlined,
                  value: '$todaysVisits',
                  label: "Today's OPD Visits",
                  color: Colors.blue,
                ),
                StatCard(
                  icon: Icons.bed_outlined,
                  value: '$currentlyAdmitted',
                  label: 'Currently Admitted',
                  color: Colors.deepPurple,
                ),
                StatCard(
                  icon: Icons.biotech_outlined,
                  value: '$pendingLabTests',
                  label: 'Pending Lab Tests',
                  color: Colors.cyan,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Revenue', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    icon: Icons.trending_up,
                    value: '₹${totalCollected.toStringAsFixed(0)}',
                    label: 'Total Collected',
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    icon: Icons.trending_down,
                    value: '₹${totalOutstanding.toStringAsFixed(0)}',
                    label: 'Total Outstanding',
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Bills by Payment Status', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    SimpleBarRow(label: 'Paid', value: paidBills, maxValue: maxBillBar, color: Colors.green),
                    SimpleBarRow(label: 'Partial', value: partialBills, maxValue: maxBillBar, color: Colors.orange),
                    SimpleBarRow(label: 'Unpaid', value: unpaidBills, maxValue: maxBillBar, color: Colors.red),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('OPD Activity', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Visits by Status', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    SimpleBarRow(label: 'Waiting', value: opdWaiting, maxValue: maxOpdBar, color: Colors.blueGrey),
                    SimpleBarRow(label: 'In Consultation', value: opdInConsultation, maxValue: maxOpdBar, color: Colors.orange),
                    SimpleBarRow(label: 'Completed', value: opdCompleted, maxValue: maxOpdBar, color: Colors.green),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Inpatient Care', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    icon: Icons.bed_outlined,
                    value: '$currentlyAdmitted',
                    label: 'Admitted',
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    icon: Icons.event_available_outlined,
                    value: '$discharged',
                    label: 'Discharged (all time)',
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Pharmacy Inventory', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    icon: Icons.warning_amber_rounded,
                    value: '$lowStock',
                    label: 'Low Stock Items',
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    icon: Icons.event_busy_outlined,
                    value: '$expired',
                    label: 'Expired Items',
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Laboratory', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    icon: Icons.hourglass_top_outlined,
                    value: '$pendingLabTests',
                    label: 'Pending Tests',
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    icon: Icons.check_circle_outline,
                    value: '$completedLabTests',
                    label: 'Completed Tests',
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
