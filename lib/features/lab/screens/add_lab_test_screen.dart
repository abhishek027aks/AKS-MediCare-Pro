import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/helpers/id_helper.dart';
import '../data/repositories/lab_repository.dart';
import '../models/lab_test_model.dart';
import '../widgets/lab_test_form.dart';

class AddLabTestScreen extends ConsumerStatefulWidget {
  const AddLabTestScreen({super.key});

  @override
  ConsumerState<AddLabTestScreen> createState() => _AddLabTestScreenState();
}

class _AddLabTestScreenState extends ConsumerState<AddLabTestScreen> {
  bool _isSaving = false;

  Future<void> _saveTest(LabTestModel test) async {
    setState(() => _isSaving = true);

    try {
      final testNo = await IdHelper.generateTestNumber();

      await LabRepository.instance.createTest(test.copyWith(testNo: testNo));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lab test ordered successfully. Test No: $testNo'),
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
      appBar: AppBar(title: const Text('Order Lab Test'), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: LabTestForm(
            onSave: _saveTest,
            isLoading: _isSaving,
            onCancel: () => Navigator.pop(context),
          ),
        ),
      ),
    );
  }
}
