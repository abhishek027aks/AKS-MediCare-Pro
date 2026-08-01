import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/helpers/date_helper.dart';
import '../models/bill_model.dart';
import '../providers/billing_provider.dart';
import '../widgets/delete_bill_dialog.dart';
import 'add_bill_screen.dart';
import 'bill_details_screen.dart';
import 'edit_bill_screen.dart';

class BillListScreen extends ConsumerStatefulWidget {
  const BillListScreen({super.key});

  @override
  ConsumerState<BillListScreen> createState() => _BillListScreenState();
}

class _BillListScreenState extends ConsumerState<BillListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _statusFilter = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
  Widget build(BuildContext context) {
    final state = ref.watch(billingProvider);
    final bills = state.bills;

    final filtered = bills.where((bill) {
      final query = _searchQuery.toLowerCase();

      final matchesQuery = bill.patientName.toLowerCase().contains(query) ||
          bill.patientUhid.toLowerCase().contains(query) ||
          bill.invoiceNo.toLowerCase().contains(query);

      final matchesStatus = _statusFilter == 'All' || bill.paymentStatus == _statusFilter;

      return matchesQuery && matchesStatus;
    }).toList();

    final totalOutstanding = bills.fold<double>(0, (sum, b) => sum + b.balanceAmount);

    return Scaffold(
      appBar: AppBar(title: const Text('Billing')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const AddBillScreen()),
          );

          if (result == true && mounted) {
            await ref.read(billingProvider.notifier).refresh();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('New Bill'),
      ),
      body: Column(
        children: [
          if (state.isLoading) const LinearProgressIndicator(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (bills.isNotEmpty)
                  Card(
                    color: Colors.red.withValues(alpha: 0.08),
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Outstanding',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '₹${totalOutstanding.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by patient, UHID or invoice no...',
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
                    children: ['All', 'Paid', 'Partial', 'Unpaid'].map((status) {
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
              onRefresh: () => ref.read(billingProvider.notifier).refresh(),
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
                        final BillModel bill = filtered[index];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => BillDetailsScreen(bill: bill)),
                              );
                              if (mounted) await ref.read(billingProvider.notifier).refresh();
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 26,
                                    backgroundColor: _statusColor(bill.paymentStatus).withValues(alpha: 0.15),
                                    child: Icon(Icons.receipt_long_outlined, color: _statusColor(bill.paymentStatus)),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          bill.patientName,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        ),
                                        const SizedBox(height: 4),
                                        Text('Invoice No : ${bill.invoiceNo}'),
                                        const SizedBox(height: 4),
                                        Text('${bill.billType}  •  ${AppDateHelper.formatDate(bill.billDate)}'),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Total : ₹${bill.totalAmount.toStringAsFixed(2)}   Balance : ₹${bill.balanceAmount.toStringAsFixed(2)}',
                                        ),
                                        const SizedBox(height: 10),
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
                                  PopupMenuButton<String>(
                                    onSelected: (value) async {
                                      switch (value) {
                                        case 'view':
                                          await Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (_) => BillDetailsScreen(bill: bill)),
                                          );
                                          if (mounted) await ref.read(billingProvider.notifier).refresh();
                                          break;
                                        case 'edit':
                                          final updated = await Navigator.push<bool>(
                                            context,
                                            MaterialPageRoute(builder: (_) => EditBillScreen(bill: bill)),
                                          );
                                          if (updated == true && mounted) {
                                            await ref.read(billingProvider.notifier).refresh();
                                          }
                                          break;
                                        case 'delete':
                                          final deleted = await showDialog<bool>(
                                            context: context,
                                            builder: (_) => DeleteBillDialog(bill: bill),
                                          );
                                          if (deleted == true && mounted) {
                                            await ref.read(billingProvider.notifier).refresh();
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
            Icon(Icons.receipt_long_outlined, size: 80),
            SizedBox(height: 20),
            Text('No bills found', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Try changing your filters or create a new bill.', textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
