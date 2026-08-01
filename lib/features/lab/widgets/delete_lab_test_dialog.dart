import 'package:flutter/material.dart';

import '../data/repositories/lab_repository.dart';
import '../models/lab_test_model.dart';

class DeleteLabTestDialog extends StatefulWidget {
  const DeleteLabTestDialog({super.key, required this.test});

  final LabTestModel test;

  @override
  State<DeleteLabTestDialog> createState() => _DeleteLabTestDialogState();
}

class _DeleteLabTestDialogState extends State<DeleteLabTestDialog> {
  final LabRepository _repository = LabRepository.instance;
  bool _isLoading = false;

  Future<void> _delete() async {
    if (widget.test.id == null) {
      Navigator.pop(context, false);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final rows = await _repository.deleteTest(widget.test.id!);

      if (!mounted) return;

      if (rows > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lab test deleted successfully.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to delete lab test.')),
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
      title: const Text('Delete Lab Test'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Are you sure you want to delete this lab test record?',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.biotech_outlined)),
            title: Text(widget.test.patientName),
            subtitle: Text('Test No : ${widget.test.testNo}'),
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
