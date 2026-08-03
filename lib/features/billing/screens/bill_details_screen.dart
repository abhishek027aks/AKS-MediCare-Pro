import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/helpers/date_helper.dart';
import '../../../shared/services/pdf_service.dart';
import '../models/bill_model.dart';
import '../providers/billing_provider.dart';
import '../widgets/delete_bill_dialog.dart';
import 'edit_bill_screen.dart';

class BillDetailsScreen extends ConsumerWidget {
  const BillDetailsScreen({super.key, required this.bill});

  final BillModel bill;

  Color _statusColor(String status) {
    switch (status) {
      case 'Paid':
        return Colors.green;
      case 'Partial':
        return Colors.orange;
      default:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bill Details'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.print_outlined),
            tooltip: 'Print Invoice',
            onPressed: () => PdfService.printBill(bill),
          ),
        ],
      ),
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
                    const Icon(Icons.receipt_long_outlined, size: 52),
                    const SizedBox(height: 12),
                    Text(
                      bill.patientName,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text('UHID : ${bill.patientUhid}'),
                    Text('Invoice No : ${bill.invoiceNo}'),
                    const SizedBox(height: 16),
                    Chip(
                      backgroundColor: _statusColor(bill.paymentStatus).withValues(alpha: 0.15),
                      label: Text(
                        bill.paymentStatus,
                        style: TextStyle(color: _statusColor(bill.paymentStatus)),
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
                    Text('Items', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    ...bill.items.map(
                      (item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text('${item.description}  ×${item.quantity}'),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                '₹${item.amount.toStringAsFixed(2)}',
                                textAlign: TextAlign.right,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(),
                    _AmountRow(label: 'Subtotal', value: bill.subtotal),
                    _AmountRow(label: 'Discount', value: -bill.discount),
                    _AmountRow(label: 'Tax', value: bill.tax),
                    const Divider(),
                    _AmountRow(label: 'Total Amount', value: bill.totalAmount, bold: true),
                    _AmountRow(label: 'Paid Amount', value: bill.paidAmount),
                    _AmountRow(label: 'Balance', value: bill.balanceAmount, bold: true),
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
                    Text('Bill Information', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    _InfoTile(icon: Icons.category_outlined, title: 'Bill Type', value: bill.billType),
                    const Divider(),
                    _InfoTile(icon: Icons.link_outlined, title: 'Reference No', value: bill.referenceNo ?? '—'),
                    const Divider(),
                    _InfoTile(icon: Icons.event_outlined, title: 'Bill Date', value: AppDateHelper.formatDate(bill.billDate)),
                    const Divider(),
                    _InfoTile(icon: Icons.credit_card_outlined, title: 'Payment Mode', value: bill.paymentMode),
                    const Divider(),
                    _InfoTile(icon: Icons.notes_outlined, title: 'Notes', value: bill.notes ?? '—'),
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
                    MaterialPageRoute(builder: (_) => EditBillScreen(bill: bill)),
                  );

                  if (updated == true && context.mounted) {
                    await ref.read(billingProvider.notifier).refresh();
                    if (context.mounted) Navigator.pop(context);
                  }
                },
                icon: const Icon(Icons.edit),
                label: const Text('Edit Bill'),
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
                    builder: (_) => DeleteBillDialog(bill: bill),
                  );

                  if (deleted == true && context.mounted) {
                    await ref.read(billingProvider.notifier).refresh();
                    if (context.mounted) Navigator.pop(context);
                  }
                },
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete Bill'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _AmountRow extends StatelessWidget {
  final String label;
  final double value;
  final bool bold;

  const _AmountRow({required this.label, required this.value, this.bold = false});

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text('₹${value.toStringAsFixed(2)}', style: style),
        ],
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
