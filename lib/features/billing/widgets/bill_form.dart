import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/helpers/billing_helper.dart';
import '../../../shared/widgets/patient_picker_field.dart';
import '../../patients/models/patient_model.dart';
import '../models/bill_item_model.dart';
import '../models/bill_model.dart';

class BillForm extends StatefulWidget {
  const BillForm({
    super.key,
    this.initialBill,
    required this.onSave,
    this.onCancel,
    this.isLoading = false,
    this.prefillPatient,
    this.prefillBillType,
    this.prefillReferenceNo,
    this.prefillItems,
  });

  final BillModel? initialBill;
  final ValueChanged<BillModel> onSave;
  final VoidCallback? onCancel;
  final bool isLoading;

  /// The following are only applied when [initialBill] is null — they
  /// let other modules (OPD, IPD, Lab) hand off into a fresh bill
  /// with the patient, type, reference and line items already set.
  final PatientModel? prefillPatient;
  final String? prefillBillType;
  final String? prefillReferenceNo;
  final List<BillItemModel>? prefillItems;

  @override
  State<BillForm> createState() => _BillFormState();
}

class _BillFormState extends State<BillForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _referenceController;
  late final TextEditingController _discountController;
  late final TextEditingController _taxController;
  late final TextEditingController _paidController;
  late final TextEditingController _notesController;

  PatientModel? _selectedPatient;
  DateTime _billDate = DateTime.now();
  String _billType = BillingHelper.billTypes.first;
  String _paymentMode = BillingHelper.paymentModes.first;

  final List<_ItemRow> _itemRows = [];

  @override
  void initState() {
    super.initState();

    final bill = widget.initialBill;

    _referenceController = TextEditingController(text: bill?.referenceNo ?? '');
    _discountController =
        TextEditingController(text: bill == null ? '0' : bill.discount.toStringAsFixed(0));
    _taxController =
        TextEditingController(text: bill == null ? '0' : bill.tax.toStringAsFixed(0));
    _paidController =
        TextEditingController(text: bill == null ? '0' : bill.paidAmount.toStringAsFixed(0));
    _notesController = TextEditingController(text: bill?.notes ?? '');

    _billDate = bill?.billDate ?? DateTime.now();
    _billType = bill?.billType ?? widget.prefillBillType ?? BillingHelper.billTypes.first;
    _paymentMode = bill?.paymentMode ?? BillingHelper.paymentModes.first;

    if (bill == null && widget.prefillReferenceNo != null) {
      _referenceController.text = widget.prefillReferenceNo!;
    }

    if (bill != null) {
      _selectedPatient = PatientModel(
        id: bill.patientId,
        uhid: bill.patientUhid,
        fullName: bill.patientName,
        gender: '',
        dateOfBirth: DateTime(1970),
        mobile: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      for (final item in bill.items) {
        _itemRows.add(_ItemRow.fromItem(item));
      }
    } else {
      _selectedPatient = widget.prefillPatient;

      if (widget.prefillItems != null) {
        for (final item in widget.prefillItems!) {
          _itemRows.add(_ItemRow.fromItem(item));
        }
      }
    }

    if (_itemRows.isEmpty) {
      _itemRows.add(_ItemRow());
    }
  }

  @override
  void dispose() {
    _referenceController.dispose();
    _discountController.dispose();
    _taxController.dispose();
    _paidController.dispose();
    _notesController.dispose();
    for (final row in _itemRows) {
      row.dispose();
    }
    super.dispose();
  }

  double get _subtotal =>
      _itemRows.fold(0, (sum, row) => sum + row.amount);

  double get _discount => double.tryParse(_discountController.text.trim()) ?? 0;
  double get _tax => double.tryParse(_taxController.text.trim()) ?? 0;

  double get _total => (_subtotal - _discount + _tax).clamp(0, double.infinity);

  Future<void> _pickBillDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _billDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );

    if (picked != null) {
      setState(() => _billDate = picked);
    }
  }

  void _addItemRow() {
    setState(() {
      _itemRows.add(_ItemRow());
    });
  }

  void _removeItemRow(int index) {
    setState(() {
      _itemRows[index].dispose();
      _itemRows.removeAt(index);
      if (_itemRows.isEmpty) {
        _itemRows.add(_ItemRow());
      }
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedPatient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a patient')),
      );
      return;
    }

    final validItems = _itemRows
        .where((row) => row.descriptionController.text.trim().isNotEmpty)
        .map((row) => row.toBillItem())
        .toList();

    if (validItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one billable item')),
      );
      return;
    }

    final bill = BillModel(
      id: widget.initialBill?.id,
      invoiceNo: widget.initialBill?.invoiceNo ?? '',
      patientId: _selectedPatient!.id!,
      patientName: _selectedPatient!.fullName,
      patientUhid: _selectedPatient!.uhid,
      billType: _billType,
      referenceNo:
          _referenceController.text.trim().isEmpty ? null : _referenceController.text.trim(),
      billDate: _billDate,
      items: validItems,
      discount: _discount,
      tax: _tax,
      paidAmount: double.tryParse(_paidController.text.trim()) ?? 0,
      paymentMode: _paymentMode,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      createdAt: widget.initialBill?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    widget.onSave(bill);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initialBill != null;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(Icons.receipt_long_outlined, size: 60),
                  const SizedBox(height: 12),
                  Text(
                    isEdit ? 'Edit Bill' : 'New Bill',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  if (isEdit) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Invoice No : ${widget.initialBill!.invoiceNo}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          PatientPickerField(
            selectedPatient: _selectedPatient,
            enabled: !widget.isLoading && !isEdit,
            onSelected: (patient) => setState(() => _selectedPatient = patient),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _billType,
            decoration: const InputDecoration(
              labelText: 'Bill Type',
              prefixIcon: Icon(Icons.category_outlined),
              border: OutlineInputBorder(),
            ),
            items: BillingHelper.billTypes
                .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                .toList(),
            onChanged: widget.isLoading
                ? null
                : (value) {
                    if (value == null) return;
                    setState(() => _billType = value);
                  },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _referenceController,
            decoration: const InputDecoration(
              labelText: 'Reference No (OPD Visit / IPD Admission) (optional)',
              prefixIcon: Icon(Icons.link_outlined),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: widget.isLoading ? null : _pickBillDate,
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Bill Date',
                prefixIcon: Icon(Icons.event_outlined),
                suffixIcon: Icon(Icons.arrow_drop_down),
                border: OutlineInputBorder(),
              ),
              child: Text(DateFormat('dd/MM/yyyy').format(_billDate)),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Billable Items', style: Theme.of(context).textTheme.titleMedium),
              TextButton.icon(
                onPressed: widget.isLoading ? null : _addItemRow,
                icon: const Icon(Icons.add),
                label: const Text('Add Item'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ..._itemRows.asMap().entries.map((entry) {
            final index = entry.key;
            final row = entry.value;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 0,
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    TextFormField(
                      controller: row.descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Item / Service Description',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: row.quantityController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Qty',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: row.priceController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              labelText: 'Unit Price',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          onPressed: widget.isLoading ? null : () => _removeItemRow(index),
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Amount : ₹${row.amount.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 12),
          TextFormField(
            controller: _discountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Discount',
              prefixIcon: Icon(Icons.percent_outlined),
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _taxController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Tax',
              prefixIcon: Icon(Icons.request_quote_outlined),
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _SummaryRow(label: 'Subtotal', value: _subtotal),
                  _SummaryRow(label: 'Discount', value: -_discount),
                  _SummaryRow(label: 'Tax', value: _tax),
                  const Divider(),
                  _SummaryRow(label: 'Total Amount', value: _total, bold: true),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _paidController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Amount Paid',
              prefixIcon: Icon(Icons.payments_outlined),
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _paymentMode,
            decoration: const InputDecoration(
              labelText: 'Payment Mode',
              prefixIcon: Icon(Icons.credit_card_outlined),
              border: OutlineInputBorder(),
            ),
            items: BillingHelper.paymentModes
                .map((mode) => DropdownMenuItem(value: mode, child: Text(mode)))
                .toList(),
            onChanged: widget.isLoading
                ? null
                : (value) {
                    if (value == null) return;
                    setState(() => _paymentMode = value);
                  },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _notesController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Notes (optional)',
              prefixIcon: Icon(Icons.notes_outlined),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: widget.isLoading
                      ? null
                      : widget.onCancel ?? () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.close),
                  label: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FilledButton.icon(
                  onPressed: widget.isLoading ? null : _submit,
                  icon: widget.isLoading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(isEdit ? Icons.save : Icons.receipt_long),
                  label: Text(isEdit ? 'Save Changes' : 'Create Bill'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final double value;
  final bool bold;

  const _SummaryRow({required this.label, required this.value, this.bold = false});

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      fontSize: bold ? 16 : 14,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
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

/// Internal, form-only representation of a line item — keeps text
/// controllers alive across rebuilds without touching BillItemModel.
class _ItemRow {
  _ItemRow()
      : descriptionController = TextEditingController(),
        quantityController = TextEditingController(text: '1'),
        priceController = TextEditingController(text: '0');

  _ItemRow.fromItem(BillItemModel item)
      : descriptionController = TextEditingController(text: item.description),
        quantityController = TextEditingController(text: item.quantity.toString()),
        priceController = TextEditingController(text: item.unitPrice.toStringAsFixed(0));

  final TextEditingController descriptionController;
  final TextEditingController quantityController;
  final TextEditingController priceController;

  double get amount {
    final qty = int.tryParse(quantityController.text.trim()) ?? 0;
    final price = double.tryParse(priceController.text.trim()) ?? 0;
    return qty * price;
  }

  BillItemModel toBillItem() {
    return BillItemModel(
      description: descriptionController.text.trim(),
      quantity: int.tryParse(quantityController.text.trim()) ?? 1,
      unitPrice: double.tryParse(priceController.text.trim()) ?? 0,
    );
  }

  void dispose() {
    descriptionController.dispose();
    quantityController.dispose();
    priceController.dispose();
  }
}
