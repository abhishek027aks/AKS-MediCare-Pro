import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/helpers/date_helper.dart';
import '../models/inventory_item_model.dart';
import '../providers/inventory_provider.dart';
import '../widgets/delete_inventory_item_dialog.dart';
import 'edit_inventory_item_screen.dart';

class InventoryItemDetailsScreen extends ConsumerWidget {
  const InventoryItemDetailsScreen({super.key, required this.item});

  final InventoryItemModel item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Item Details'), centerTitle: true),
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
                    const Icon(Icons.inventory_2_outlined, size: 52),
                    const SizedBox(height: 12),
                    Text(
                      item.itemName,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text('${item.category}  •  ${item.department}'),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      children: [
                        Chip(
                          avatar: Icon(item.isActive ? Icons.check_circle : Icons.cancel, size: 18),
                          label: Text(item.isActive ? 'Active' : 'Inactive'),
                        ),
                        Chip(label: Text(item.condition)),
                        if (item.isUnderWarranty)
                          const Chip(
                            backgroundColor: Color(0x1A4CAF50),
                            avatar: Icon(Icons.verified_outlined, size: 18, color: Colors.green),
                            label: Text('Under Warranty', style: TextStyle(color: Colors.green)),
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
                    Text('Stock Details', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    _InfoTile(icon: Icons.numbers_outlined, title: 'Quantity', value: '${item.quantity} ${item.unit}'),
                    const Divider(),
                    _InfoTile(icon: Icons.build_outlined, title: 'Condition', value: item.condition),
                    const Divider(),
                    _InfoTile(icon: Icons.qr_code_outlined, title: 'Serial Number', value: item.serialNumber ?? '—'),
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
                    Text('Purchase Details', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    _InfoTile(
                      icon: Icons.event_outlined,
                      title: 'Purchase Date',
                      value: item.purchaseDate == null ? '—' : AppDateHelper.formatDate(item.purchaseDate!),
                    ),
                    const Divider(),
                    _InfoTile(
                      icon: Icons.currency_rupee,
                      title: 'Purchase Price',
                      value: item.purchasePrice == null ? '—' : '₹${item.purchasePrice!.toStringAsFixed(2)}',
                    ),
                    const Divider(),
                    _InfoTile(icon: Icons.local_shipping_outlined, title: 'Supplier', value: item.supplier ?? '—'),
                    const Divider(),
                    _InfoTile(
                      icon: Icons.event_busy_outlined,
                      title: 'Warranty Expiry',
                      value: item.warrantyExpiry == null ? '—' : AppDateHelper.formatDate(item.warrantyExpiry!),
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
                    Text('Notes', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    Text(item.notes ?? '—'),
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
                    MaterialPageRoute(builder: (_) => EditInventoryItemScreen(item: item)),
                  );

                  if (updated == true && context.mounted) {
                    await ref.read(inventoryProvider.notifier).refresh();
                    if (context.mounted) Navigator.pop(context);
                  }
                },
                icon: const Icon(Icons.edit),
                label: const Text('Edit Item'),
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
                    builder: (_) => DeleteInventoryItemDialog(item: item),
                  );

                  if (deleted == true && context.mounted) {
                    await ref.read(inventoryProvider.notifier).refresh();
                    if (context.mounted) Navigator.pop(context);
                  }
                },
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete Item'),
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
