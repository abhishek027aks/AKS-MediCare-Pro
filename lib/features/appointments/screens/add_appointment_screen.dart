import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/helpers/id_helper.dart';
import '../data/repositories/appointment_repository.dart';
import '../models/appointment_model.dart';
import '../widgets/appointment_form.dart';

class AddAppointmentScreen extends ConsumerStatefulWidget {
  const AddAppointmentScreen({super.key});

  @override
  ConsumerState<AddAppointmentScreen> createState() => _AddAppointmentScreenState();
}

class _AddAppointmentScreenState extends ConsumerState<AddAppointmentScreen> {
  bool _isSaving = false;

  Future<void> _saveAppointment(AppointmentModel appointment) async {
    setState(() => _isSaving = true);

    try {
      final appointmentNo = await IdHelper.generateAppointmentNumber();

      await AppointmentRepository.instance.createAppointment(
        appointment.copyWith(appointmentNo: appointmentNo),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Appointment scheduled. No: $appointmentNo'),
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
      appBar: AppBar(title: const Text('Schedule Appointment'), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: AppointmentForm(
            onSave: _saveAppointment,
            isLoading: _isSaving,
            onCancel: () => Navigator.pop(context),
          ),
        ),
      ),
    );
  }
}
