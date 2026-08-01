import 'package:flutter/material.dart';

import '../data/repositories/medicine_repository.dart';
import '../models/medicine_model.dart';
import '../widgets/medicine_form.dart';

class EditMedicineScreen extends StatefulWidget {
  const EditMedicineScreen({super.key, required this.medicine});

  final MedicineModel medicine;

  @override
  State<EditMedicineScreen> createState() => _EditMedicineScreenState();
}

class _EditMedicineScreenState extends State<EditMedicineScreen> {
  final MedicineRepository _repository = MedicineRepository.instance;
  bool _isLoading = false;

  Future<void> _saveMedicine(MedicineModel medicine) async {
    setState(() => _isLoading = true);

    try {
      final exists = await _repository.nameExists(medicine.name, excludingId: medicine.id);

      if (exists) {
        throw Exception('A medicine with this name already exists.');
      }

      final rows = await _repository.updateMedicine(medicine);

      if (!mounted) return;

      if (rows > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Medicine updated successfully.'),
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
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Medicine'), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: MedicineForm(
            initialMedicine: widget.medicine,
            isLoading: _isLoading,
            onSave: _saveMedicine,
            onCancel: () => Navigator.pop(context),
          ),
        ),
      ),
    );
  }
}
