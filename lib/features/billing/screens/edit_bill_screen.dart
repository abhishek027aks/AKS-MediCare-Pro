import 'package:flutter/material.dart';

import '../data/repositories/billing_repository.dart';
import '../models/bill_model.dart';
import '../widgets/bill_form.dart';

class EditBillScreen extends StatefulWidget {
  const EditBillScreen({super.key, required this.bill});

  final BillModel bill;

  @override
  State<EditBillScreen> createState() => _EditBillScreenState();
}

class _EditBillScreenState extends State<EditBillScreen> {
  final BillingRepository _repository = BillingRepository.instance;
  bool _isLoading = false;

  Future<void> _saveBill(BillModel bill) async {
    setState(() => _isLoading = true);

    try {
      final rows = await _repository.updateBill(bill);

      if (!mounted) return;

      if (rows > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bill updated successfully.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No changes were saved.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Bill'), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: BillForm(
            initialBill: widget.bill,
            isLoading: _isLoading,
            onSave: _saveBill,
            onCancel: () => Navigator.pop(context),
          ),
        ),
      ),
    );
  }
}
