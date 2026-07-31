import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/helpers/id_helper.dart';
import '../data/repositories/patient_repository.dart';
import '../models/patient_model.dart';
import '../widgets/patient_form.dart';

class AddPatientScreen extends ConsumerStatefulWidget {
  const AddPatientScreen({super.key});

  @override
  ConsumerState<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends ConsumerState<AddPatientScreen> {
  bool _isSaving = false;

  Future<void> _savePatient(PatientModel patient) async {
    try {
      setState(() {
        _isSaving = true;
      });

      final repository = PatientRepository.instance;

      final exists = await repository.mobileExists(patient.mobile);

      if (exists) {
        throw Exception('A patient with this mobile number already exists.');
      }

      final uhid = await IdHelper.generateUHID();

      await repository.createPatient(patient.copyWith(uhid: uhid));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Patient registered successfully. UHID: $uhid'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Registration'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: PatientForm(
            onSave: _savePatient,
            isLoading: _isSaving,
            onCancel: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }
}
