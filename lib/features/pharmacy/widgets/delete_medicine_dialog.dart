import 'package:flutter/material.dart';

import '../data/repositories/medicine_repository.dart';
import '../models/medicine_model.dart';

class DeleteMedicineDialog extends StatefulWidget {
  const DeleteMedicineDialog({super.key, required this.medicine});

  final MedicineModel medicine;

  @override
  State<DeleteMedicineDialog> createState() => _DeleteMedicineDialogState();
}

class _DeleteMedicineDialogState extends State<DeleteMedicineDialog> {
  final MedicineRepository _repository = MedicineRepository.instance;
  bool _isLoading = false;

  Future<void> _delete() async {
    if (widget.medicine.id == null) {
      Navigator.pop(context, false);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final rows = await _repository.deleteMedicine(widget.medicine.id!);

      if (!mounted) return;

      if (rows > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Medicine deleted successfully.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to delete medicine.')),
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
      title: const Text('Delete Medicine'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Are you sure you want to delete this medicine from inventory?',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.medication_outlined)),
            title: Text(widget.medicine.name),
            subtitle: Text('Stock : ${widget.medicine.stockQuantity} ${widget.medicine.unit}'),
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
