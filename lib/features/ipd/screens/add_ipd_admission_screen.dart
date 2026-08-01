import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/helpers/id_helper.dart';
import '../data/repositories/ipd_repository.dart';
import '../models/ipd_admission_model.dart';
import '../widgets/ipd_admission_form.dart';

class AddIpdAdmissionScreen extends ConsumerStatefulWidget {
  const AddIpdAdmissionScreen({super.key});

  @override
  ConsumerState<AddIpdAdmissionScreen> createState() => _AddIpdAdmissionScreenState();
}

class _AddIpdAdmissionScreenState extends ConsumerState<AddIpdAdmissionScreen> {
  bool _isSaving = false;

  Future<void> _saveAdmission(IpdAdmissionModel admission) async {
    setState(() => _isSaving = true);

    try {
      final admissionNo = await IdHelper.generateAdmissionNumber();

      await IpdRepository.instance.createAdmission(
        admission.copyWith(admissionNo: admissionNo),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Patient admitted successfully. Admission No: $admissionNo'),
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
      appBar: AppBar(title: const Text('New Admission'), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: IpdAdmissionForm(
            onSave: _saveAdmission,
            isLoading: _isSaving,
            onCancel: () => Navigator.pop(context),
          ),
        ),
      ),
    );
  }
}
