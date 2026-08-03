import 'package:flutter/material.dart';

import '../data/repositories/appointment_repository.dart';
import '../models/appointment_model.dart';
import '../widgets/appointment_form.dart';

class EditAppointmentScreen extends StatefulWidget {
  const EditAppointmentScreen({super.key, required this.appointment});

  final AppointmentModel appointment;

  @override
  State<EditAppointmentScreen> createState() => _EditAppointmentScreenState();
}

class _EditAppointmentScreenState extends State<EditAppointmentScreen> {
  final AppointmentRepository _repository = AppointmentRepository.instance;
  bool _isLoading = false;

  Future<void> _saveAppointment(AppointmentModel appointment) async {
    setState(() => _isLoading = true);

    try {
      final rows = await _repository.updateAppointment(appointment);

      if (!mounted) return;

      if (rows > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment updated successfully.'),
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
      appBar: AppBar(title: const Text('Edit Appointment'), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: AppointmentForm(
            initialAppointment: widget.appointment,
            isLoading: _isLoading,
            onSave: _saveAppointment,
            onCancel: () => Navigator.pop(context),
          ),
        ),
      ),
    );
  }
}
