import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/helpers/inventory_helper.dart';
import '../../../core/validators.dart';
import '../models/inventory_item_model.dart';

class InventoryItemForm extends StatefulWidget {
  const InventoryItemForm({
    super.key,
    this.initialItem,
    required this.onSave,
    this.onCancel,
    this.isLoading = false,
  });

  final InventoryItemModel? initialItem;
  final ValueChanged<InventoryItemModel> onSave;
  final VoidCallback? onCancel;
  final bool isLoading;

  @override
  State<InventoryItemForm> createState() => _InventoryItemFormState();
}

class _InventoryItemFormState extends State<InventoryItemForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _quantityController;
  late final TextEditingController _priceController;
  late final TextEditingController _supplierController;
  late final TextEditingController _serialController;
  late final TextEditingController _notesController;

  String _category = InventoryHelper.categories.first;
  String _department = InventoryHelper.departments.first;
  String _unit = InventoryHelper.units.first;
  String _condition = InventoryHelper.conditions.first;

  DateTime? _purchaseDate;
  DateTime? _warrantyExpiry;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();

    final item = widget.initialItem;

    _nameController = TextEditingController(text: item?.itemName ?? '');
    _quantityController =
        TextEditingController(text: item == null ? '' : item.quantity.toString());
    _priceController = TextEditingController(
      text: item?.purchasePrice == null ? '' : item!.purchasePrice!.toStringAsFixed(0),
    );
    _supplierController = TextEditingController(text: item?.supplier ?? '');
    _serialController = TextEditingController(text: item?.serialNumber ?? '');
    _notesController = TextEditingController(text: item?.notes ?? '');

    _category = item?.category ?? InventoryHelper.categories.first;
    _department = item?.department ?? InventoryHelper.departments.first;
    _unit = item?.unit ?? InventoryHelper.units.first;
    _condition = item?.condition ?? InventoryHelper.conditions.first;
    _purchaseDate = item?.purchaseDate;
    _warrantyExpiry = item?.warrantyExpiry;
    _isActive = item?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _supplierController.dispose();
    _serialController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickPurchaseDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _purchaseDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => _purchaseDate = picked);
    }
  }

  Future<void> _pickWarrantyExpiry() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _warrantyExpiry ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );

    if (picked != null) {
      setState(() => _warrantyExpiry = picked);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final item = InventoryItemModel(
      id: widget.initialItem?.id,
      itemName: _nameController.text.trim(),
      category: _category,
      department: _department,
      quantity: int.tryParse(_quantityController.text.trim()) ?? 0,
      unit: _unit,
      purchaseDate: _purchaseDate,
      purchasePrice: double.tryParse(_priceController.text.trim()),
      supplier: _supplierController.text.trim().isEmpty ? null : _supplierController.text.trim(),
      condition: _condition,
      warrantyExpiry: _warrantyExpiry,
      serialNumber: _serialController.text.trim().isEmpty ? null : _serialController.text.trim(),
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      isActive: _isActive,
      createdAt: widget.initialItem?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    widget.onSave(item);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initialItem != null;

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
                  const Icon(Icons.inventory_2_outlined, size: 60),
                  const SizedBox(height: 12),
                  Text(
                    isEdit ? 'Edit Inventory Item' : 'Add Inventory Item',
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
              labelText: 'Item Name',
              prefixIcon: Icon(Icons.inventory_2_outlined),
              border: OutlineInputBorder(),
            ),
            validator: (value) => AppValidators.requiredField(value, 'Item name'),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _category,
            decoration: const InputDecoration(
              labelText: 'Category',
              prefixIcon: Icon(Icons.category_outlined),
              border: OutlineInputBorder(),
            ),
            items: InventoryHelper.categories
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
            initialValue: _department,
            decoration: const InputDecoration(
              labelText: 'Department / Location',
              prefixIcon: Icon(Icons.meeting_room_outlined),
              border: OutlineInputBorder(),
            ),
            items: InventoryHelper.departments
                .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                .toList(),
            onChanged: widget.isLoading
                ? null
                : (value) {
                    if (value == null) return;
                    setState(() => _department = value);
                  },
          ),
          const SizedBox(height: 24),
          Text('Stock Details', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Quantity',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => AppValidators.requiredField(value, 'Quantity'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _unit,
                  decoration: const InputDecoration(
                    labelText: 'Unit',
                    border: OutlineInputBorder(),
                  ),
                  items: InventoryHelper.units
                      .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                      .toList(),
                  onChanged: widget.isLoading
                      ? null
                      : (value) {
                          if (value == null) return;
                          setState(() => _unit = value);
                        },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _condition,
            decoration: const InputDecoration(
              labelText: 'Condition',
              prefixIcon: Icon(Icons.build_outlined),
              border: OutlineInputBorder(),
            ),
            items: InventoryHelper.conditions
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: widget.isLoading
                ? null
                : (value) {
                    if (value == null) return;
                    setState(() => _condition = value);
                  },
          ),
          const SizedBox(height: 24),
          Text('Purchase Details', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          InkWell(
            onTap: widget.isLoading ? null : _pickPurchaseDate,
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Purchase Date (optional)',
                prefixIcon: const Icon(Icons.event_outlined),
                suffixIcon: _purchaseDate == null
                    ? const Icon(Icons.arrow_drop_down)
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _purchaseDate = null),
                      ),
                border: const OutlineInputBorder(),
              ),
              child: Text(
                _purchaseDate == null ? 'Not set' : DateFormat('dd/MM/yyyy').format(_purchaseDate!),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _priceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Purchase Price (optional)',
              prefixIcon: Icon(Icons.currency_rupee),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _supplierController,
            decoration: const InputDecoration(
              labelText: 'Supplier (optional)',
              prefixIcon: Icon(Icons.local_shipping_outlined),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _serialController,
            decoration: const InputDecoration(
              labelText: 'Serial Number (optional)',
              prefixIcon: Icon(Icons.qr_code_outlined),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: widget.isLoading ? null : _pickWarrantyExpiry,
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Warranty Expiry (optional)',
                prefixIcon: const Icon(Icons.event_busy_outlined),
                suffixIcon: _warrantyExpiry == null
                    ? const Icon(Icons.arrow_drop_down)
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _warrantyExpiry = null),
                      ),
                border: const OutlineInputBorder(),
              ),
              child: Text(
                _warrantyExpiry == null
                    ? 'Not set'
                    : DateFormat('dd/MM/yyyy').format(_warrantyExpiry!),
              ),
            ),
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
          const SizedBox(height: 20),
          Card(
            elevation: 0,
            child: SwitchListTile(
              value: _isActive,
              title: const Text('Active'),
              subtitle: Text(_isActive ? 'In use' : 'Retired / disposed'),
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
                  label: Text(isEdit ? 'Save Changes' : 'Add Item'),
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
