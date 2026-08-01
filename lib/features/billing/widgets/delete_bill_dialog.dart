import 'package:flutter/material.dart';

import '../data/repositories/billing_repository.dart';
import '../models/bill_model.dart';

class DeleteBillDialog extends StatefulWidget {
  const DeleteBillDialog({super.key, required this.bill});

  final BillModel bill;

  @override
  State<DeleteBillDialog> createState() => _DeleteBillDialogState();
}

class _DeleteBillDialogState extends State<DeleteBillDialog> {
  final BillingRepository _repository = BillingRepository.instance;
  bool _isLoading = false;

  Future<void> _delete() async {
    if (widget.bill.id == null) {
      Navigator.pop(context, false);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final rows = await _repository.deleteBill(widget.bill.id!);

      if (!mounted) return;

      if (rows > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bill deleted successfully.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to delete bill.')),
        );
        Navigator.pop(context, false);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
      Navigator.pop(context, false);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(Icons.warning_amber_rounded, size: 48, color: Colors.red),
      title: const Text('Delete Bill'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Are you sure you want to delete this bill?',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.receipt_long_outlined)),
            title: Text(widget.bill.patientName),
            subtitle: Text('Invoice No : ${widget.bill.invoiceNo}'),
          ),
          const SizedBox(height: 10),
          const Text(
            'This action cannot be undone.',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          style: FilledButton.styleFrom(backgroundColor: Colors.red),
          onPressed: _isLoading ? null : _delete,
          icon: _isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.delete),
          label: const Text('Delete'),
        ),
      ],
    );
  }
}
