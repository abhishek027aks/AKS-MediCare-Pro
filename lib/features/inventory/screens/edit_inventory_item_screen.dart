import 'package:flutter/material.dart';

import '../data/repositories/inventory_repository.dart';
import '../models/inventory_item_model.dart';
import '../widgets/inventory_item_form.dart';

class EditInventoryItemScreen extends StatefulWidget {
  const EditInventoryItemScreen({super.key, required this.item});

  final InventoryItemModel item;

  @override
  State<EditInventoryItemScreen> createState() => _EditInventoryItemScreenState();
}

class _EditInventoryItemScreenState extends State<EditInventoryItemScreen> {
  final InventoryRepository _repository = InventoryRepository.instance;
  bool _isLoading = false;

  Future<void> _saveItem(InventoryItemModel item) async {
    setState(() => _isLoading = true);

    try {
      final rows = await _repository.updateItem(item);

      if (!mounted) return;

      if (rows > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item updated successfully.'),
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
      appBar: AppBar(title: const Text('Edit Inventory Item'), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: InventoryItemForm(
            initialItem: widget.item,
            isLoading: _isLoading,
            onSave: _saveItem,
            onCancel: () => Navigator.pop(context),
          ),
        ),
      ),
    );
  }
}
