import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/helpers/id_helper.dart';
import '../../patients/models/patient_model.dart';
import '../data/repositories/billing_repository.dart';
import '../models/bill_item_model.dart';
import '../models/bill_model.dart';
import '../widgets/bill_form.dart';

class AddBillScreen extends ConsumerStatefulWidget {
  const AddBillScreen({
    super.key,
    this.prefillPatient,
    this.prefillBillType,
    this.prefillReferenceNo,
    this.prefillItems,
  });

  /// Lets another module (OPD, IPD, Lab) hand off directly into a
  /// pre-populated bill instead of the patient re-entering everything.
  final PatientModel? prefillPatient;
  final String? prefillBillType;
  final String? prefillReferenceNo;
  final List<BillItemModel>? prefillItems;

  @override
  ConsumerState<AddBillScreen> createState() => _AddBillScreenState();
}

class _AddBillScreenState extends ConsumerState<AddBillScreen> {
  bool _isSaving = false;

  Future<void> _saveBill(BillModel bill) async {
    setState(() => _isSaving = true);

    try {
      final invoiceNo = await IdHelper.generateInvoiceNumber();

      await BillingRepository.instance.createBill(bill.copyWith(invoiceNo: invoiceNo));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bill created successfully. Invoice No: $invoiceNo'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Bill'), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: BillForm(
            onSave: _saveBill,
            isLoading: _isSaving,
            onCancel: () => Navigator.pop(context),
            prefillPatient: widget.prefillPatient,
            prefillBillType: widget.prefillBillType,
            prefillReferenceNo: widget.prefillReferenceNo,
            prefillItems: widget.prefillItems,
          ),
        ),
      ),
    );
  }
}
