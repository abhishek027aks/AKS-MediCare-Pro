import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/helpers/pharmacy_helper.dart';
import '../../../core/validators.dart';
import '../models/medicine_model.dart';

class MedicineForm extends StatefulWidget {
  const MedicineForm({
    super.key,
    this.initialMedicine,
    required this.onSave,
    this.onCancel,
    this.isLoading = false,
  });

  final MedicineModel? initialMedicine;
  final ValueChanged<MedicineModel> onSave;
  final VoidCallback? onCancel;
  final bool isLoading;

  @override
  State<MedicineForm> createState() => _MedicineFormState();
}

class _MedicineFormState extends State<MedicineForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _genericNameController;
  late final TextEditingController _manufacturerController;
  late final TextEditingController _stockController;
  late final TextEditingController _reorderController;
  late final TextEditingController _priceController;
  late final TextEditingController _batchController;

  String _category = PharmacyHelper.categories.first;
  String _unit = PharmacyHelper.units.first;
  DateTime? _expiryDate;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();

    final medicine = widget.initialMedicine;

    _nameController = TextEditingController(text: medicine?.name ?? '');
    _genericNameController = TextEditingController(text: medicine?.genericName ?? '');
    _manufacturerController = TextEditingController(text: medicine?.manufacturer ?? '');
    _stockController =
        TextEditingController(text: medicine == null ? '' : medicine.stockQuantity.toString());
    _reorderController =
        TextEditingController(text: medicine == null ? '10' : medicine.reorderLevel.toString());
    _priceController = TextEditingController(
      text: medicine == null ? '' : medicine.unitPrice.toStringAsFixed(2),
    );
    _batchController = TextEditingController(text: medicine?.batchNumber ?? '');

    _category = medicine?.category ?? PharmacyHelper.categories.first;
    _unit = medicine?.unit ?? PharmacyHelper.units.first;
    _expiryDate = medicine?.expiryDate;
    _isActive = medicine?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _genericNameController.dispose();
    _manufacturerController.dispose();
    _stockController.dispose();
    _reorderController.dispose();
    _priceController.dispose();
    _batchController.dispose();
    super.dispose();
  }

  Future<void> _pickExpiryDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );

    if (picked != null) {
      setState(() => _expiryDate = picked);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final medicine = MedicineModel(
      id: widget.initialMedicine?.id,
      name: _nameController.text.trim(),
      genericName:
          _genericNameController.text.trim().isEmpty ? null : _genericNameController.text.trim(),
      category: _category,
      manufacturer:
          _manufacturerController.text.trim().isEmpty ? null : _manufacturerController.text.trim(),
      unit: _unit,
      stockQuantity: int.tryParse(_stockController.text.trim()) ?? 0,
      reorderLevel: int.tryParse(_reorderController.text.trim()) ?? 0,
      unitPrice: double.tryParse(_priceController.text.trim()) ?? 0,
      batchNumber: _batchController.text.trim().isEmpty ? null : _batchController.text.trim(),
      expiryDate: _expiryDate,
      isActive: _isActive,
      createdAt: widget.initialMedicine?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    widget.onSave(medicine);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initialMedicine != null;

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
                  const Icon(Icons.medication_outlined, size: 60),
                  const SizedBox(height: 12),
                  Text(
                    isEdit ? 'Edit Medicine' : 'Add Medicine',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Medicine Name',
              prefixIcon: Icon(Icons.medication_outlined),
              border: OutlineInputBorder(),
            ),
            validator: (value) => AppValidators.requiredField(value, 'Medicine name'),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _genericNameController,
            decoration: const InputDecoration(
              labelText: 'Generic Name (optional)',
              prefixIcon: Icon(Icons.science_outlined),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _category,
            decoration: const InputDecoration(
              labelText: 'Category',
              prefixIcon: Icon(Icons.category_outlined),
              border: OutlineInputBorder(),
            ),
            items: PharmacyHelper.categories
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: widget.isLoading
                ? null
                : (value) {
                    if (value == null) return;
                    setState(() => _category = value);
                  },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _unit,
            decoration: const InputDecoration(
              labelText: 'Unit',
              prefixIcon: Icon(Icons.inventory_2_outlined),
              border: OutlineInputBorder(),
            ),
            items: PharmacyHelper.units
                .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                .toList(),
            onChanged: widget.isLoading
                ? null
                : (value) {
                    if (value == null) return;
                    setState(() => _unit = value);
                  },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _manufacturerController,
            decoration: const InputDecoration(
              labelText: 'Manufacturer (optional)',
              prefixIcon: Icon(Icons.factory_outlined),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          Text('Stock Details', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _stockController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Stock Quantity',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => AppValidators.requiredField(value, 'Stock quantity'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _reorderController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Reorder Level',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => AppValidators.requiredField(value, 'Reorder level'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _priceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Unit Price',
              prefixIcon: Icon(Icons.currency_rupee),
              border: OutlineInputBorder(),
            ),
            validator: (value) => AppValidators.requiredField(value, 'Unit price'),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _batchController,
            decoration: const InputDecoration(
              labelText: 'Batch Number (optional)',
              prefixIcon: Icon(Icons.qr_code_outlined),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: widget.isLoading ? null : _pickExpiryDate,
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Expiry Date (optional)',
                prefixIcon: const Icon(Icons.event_busy_outlined),
                suffixIcon: _expiryDate == null
                    ? const Icon(Icons.arrow_drop_down)
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _expiryDate = null),
                      ),
                border: const OutlineInputBorder(),
              ),
              child: Text(
                _expiryDate == null
                    ? 'No expiry date set'
                    : DateFormat('dd/MM/yyyy').format(_expiryDate!),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 0,
            child: SwitchListTile(
              value: _isActive,
              title: const Text('Active'),
              subtitle: Text(_isActive ? 'Available for dispensing' : 'Discontinued / inactive'),
              secondary: Icon(_isActive ? Icons.check_circle : Icons.cancel),
              onChanged: widget.isLoading
                  ? null
                  : (value) => setState(() => _isActive = value),
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
                      : Icon(isEdit ? Icons.save : Icons.add),
                  label: Text(isEdit ? 'Save Changes' : 'Add Medicine'),
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
