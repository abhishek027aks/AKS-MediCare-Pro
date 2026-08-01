import 'package:flutter/material.dart';

import '../data/repositories/lab_repository.dart';
import '../models/lab_test_model.dart';
import '../widgets/lab_test_form.dart';

class EditLabTestScreen extends StatefulWidget {
  const EditLabTestScreen({super.key, required this.test});

  final LabTestModel test;

  @override
  State<EditLabTestScreen> createState() => _EditLabTestScreenState();
}

class _EditLabTestScreenState extends State<EditLabTestScreen> {
  final LabRepository _repository = LabRepository.instance;
  bool _isLoading = false;

  Future<void> _saveTest(LabTestModel test) async {
    setState(() => _isLoading = true);

    try {
      final rows = await _repository.updateTest(test);

      if (!mounted) return;

      if (rows > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lab test updated successfully.'),
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
      appBar: AppBar(title: const Text('Edit Lab Test'), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: LabTestForm(
            initialTest: widget.test,
            isLoading: _isLoading,
            onSave: _saveTest,
            onCancel: () => Navigator.pop(context),
          ),
        ),
      ),
    );
  }
}
