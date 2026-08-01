import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/helpers/date_helper.dart';
import '../models/medicine_model.dart';
import '../providers/medicine_provider.dart';
import '../widgets/delete_medicine_dialog.dart';
import 'edit_medicine_screen.dart';

class MedicineDetailsScreen extends ConsumerWidget {
  const MedicineDetailsScreen({super.key, required this.medicine});

  final MedicineModel medicine;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Medicine Details'), centerTitle: true),
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
                    const Icon(Icons.medication_outlined, size: 52),
                    const SizedBox(height: 12),
                    Text(
                      medicine.name,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    if (medicine.genericName != null) ...[
                      const SizedBox(height: 6),
                      Text(medicine.genericName!),
                    ],
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      children: [
                        Chip(
                          avatar: Icon(
                            medicine.isActive ? Icons.check_circle : Icons.cancel,
                            size: 18,
                          ),
                          label: Text(medicine.isActive ? 'Active' : 'Inactive'),
                        ),
                        if (medicine.isLowStock)
                          Chip(
                            backgroundColor: Colors.orange.withValues(alpha: 0.15),
                            avatar: const Icon(Icons.warning_amber_rounded, size: 18, color: Colors.orange),
                            label: const Text('Low Stock', style: TextStyle(color: Colors.orange)),
                          ),
                        if (medicine.isExpired)
                          Chip(
                            backgroundColor: Colors.red.withValues(alpha: 0.15),
                            avatar: const Icon(Icons.event_busy, size: 18, color: Colors.red),
                            label: const Text('Expired', style: TextStyle(color: Colors.red)),
                          )
                        else if (medicine.isExpiringSoon)
                          Chip(
                            backgroundColor: Colors.orange.withValues(alpha: 0.15),
                            avatar: const Icon(Icons.event_busy, size: 18, color: Colors.orange),
                            label: const Text('Expiring Soon', style: TextStyle(color: Colors.orange)),
                          ),
                      ],
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
                    Text('Medicine Information', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    _InfoTile(icon: Icons.category_outlined, title: 'Category', value: medicine.category),
                    const Divider(),
                    _InfoTile(icon: Icons.factory_outlined, title: 'Manufacturer', value: medicine.manufacturer ?? '—'),
                    const Divider(),
                    _InfoTile(icon: Icons.inventory_2_outlined, title: 'Unit', value: medicine.unit),
                    const Divider(),
                    _InfoTile(icon: Icons.qr_code_outlined, title: 'Batch Number', value: medicine.batchNumber ?? '—'),
                    const Divider(),
                    _InfoTile(
                      icon: Icons.event_busy_outlined,
                      title: 'Expiry Date',
                      value: medicine.expiryDate == null ? '—' : AppDateHelper.formatDate(medicine.expiryDate!),
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
                    Text('Stock & Pricing', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    _InfoTile(
                      icon: Icons.numbers_outlined,
                      title: 'Stock Quantity',
                      value: '${medicine.stockQuantity} ${medicine.unit}',
                    ),
                    const Divider(),
                    _InfoTile(icon: Icons.rule_outlined, title: 'Reorder Level', value: '${medicine.reorderLevel} ${medicine.unit}'),
                    const Divider(),
                    _InfoTile(
                      icon: Icons.currency_rupee,
                      title: 'Unit Price',
                      value: '₹${medicine.unitPrice.toStringAsFixed(2)}',
                    ),
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
                onPressed: () async {
                  final updated = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(builder: (_) => EditMedicineScreen(medicine: medicine)),
                  );

                  if (updated == true && context.mounted) {
                    await ref.read(medicineProvider.notifier).refresh();
                    if (context.mounted) Navigator.pop(context);
                  }
                },
                icon: const Icon(Icons.edit),
                label: const Text('Edit Medicine'),
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
                    builder: (_) => DeleteMedicineDialog(medicine: medicine),
                  );

                  if (deleted == true && context.mounted) {
                    await ref.read(medicineProvider.notifier).refresh();
                    if (context.mounted) Navigator.pop(context);
                  }
                },
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete Medicine'),
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
