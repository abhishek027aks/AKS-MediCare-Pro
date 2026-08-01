import 'package:flutter/material.dart';

import '../data/repositories/ipd_repository.dart';
import '../models/ipd_admission_model.dart';
import '../widgets/ipd_admission_form.dart';

class EditIpdAdmissionScreen extends StatefulWidget {
  const EditIpdAdmissionScreen({super.key, required this.admission});

  final IpdAdmissionModel admission;

  @override
  State<EditIpdAdmissionScreen> createState() => _EditIpdAdmissionScreenState();
}

class _EditIpdAdmissionScreenState extends State<EditIpdAdmissionScreen> {
  final IpdRepository _repository = IpdRepository.instance;
  bool _isLoading = false;

  Future<void> _saveAdmission(IpdAdmissionModel admission) async {
    setState(() => _isLoading = true);

    try {
      final rows = await _repository.updateAdmission(admission);

      if (!mounted) return;

      if (rows > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Admission updated successfully.'),
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
      appBar: AppBar(title: const Text('Edit Admission'), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: IpdAdmissionForm(
            initialAdmission: widget.admission,
            isLoading: _isLoading,
            onSave: _saveAdmission,
            onCancel: () => Navigator.pop(context),
          ),
        ),
      ),
    );
  }
}
