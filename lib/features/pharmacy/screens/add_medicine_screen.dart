import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/medicine_repository.dart';
import '../models/medicine_model.dart';
import '../widgets/medicine_form.dart';

class AddMedicineScreen extends ConsumerStatefulWidget {
  const AddMedicineScreen({super.key});

  @override
  ConsumerState<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends ConsumerState<AddMedicineScreen> {
  bool _isSaving = false;

  Future<void> _saveMedicine(MedicineModel medicine) async {
    setState(() => _isSaving = true);

    try {
      final repository = MedicineRepository.instance;

      final exists = await repository.nameExists(medicine.name);

      if (exists) {
        throw Exception('A medicine with this name already exists.');
      }

      await repository.createMedicine(medicine);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Medicine added successfully.'),
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
      appBar: AppBar(title: const Text('Add Medicine'), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: MedicineForm(
            onSave: _saveMedicine,
            isLoading: _isSaving,
            onCancel: () => Navigator.pop(context),
          ),
        ),
      ),
    );
  }
}
