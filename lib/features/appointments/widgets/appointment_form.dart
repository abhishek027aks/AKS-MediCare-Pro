import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/helpers/appointment_helper.dart';
import '../../../shared/widgets/doctor_dropdown_field.dart';
import '../../../shared/widgets/patient_picker_field.dart';
import '../../patients/models/patient_model.dart';
import '../models/appointment_model.dart';

class AppointmentForm extends StatefulWidget {
  const AppointmentForm({
    super.key,
    this.initialAppointment,
    required this.onSave,
    this.onCancel,
    this.isLoading = false,
  });

  final AppointmentModel? initialAppointment;
  final ValueChanged<AppointmentModel> onSave;
  final VoidCallback? onCancel;
  final bool isLoading;

  @override
  State<AppointmentForm> createState() => _AppointmentFormState();
}

class _AppointmentFormState extends State<AppointmentForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _reasonController;
  late final TextEditingController _notesController;

  PatientModel? _selectedPatient;
  int? _doctorId;
  String _doctorName = '';

  DateTime _appointmentDate = DateTime.now();
  String _appointmentTime = AppointmentHelper.timeSlots.first;
  String _status = AppointmentHelper.statuses.first;

  @override
  void initState() {
    super.initState();

    final appointment = widget.initialAppointment;

    _reasonController = TextEditingController(text: appointment?.reasonForVisit ?? '');
    _notesController = TextEditingController(text: appointment?.notes ?? '');

    _doctorId = appointment?.doctorId;
    _doctorName = appointment?.doctorName ?? '';
    _appointmentDate = appointment?.appointmentDate ?? DateTime.now();
    _appointmentTime = appointment?.appointmentTime ?? AppointmentHelper.timeSlots.first;
    _status = appointment?.status ?? AppointmentHelper.statuses.first;

    if (appointment != null) {
      _selectedPatient = PatientModel(
        id: appointment.patientId,
        uhid: appointment.patientUhid,
        fullName: appointment.patientName,
        gender: '',
        dateOfBirth: DateTime(1970),
        mobile: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _appointmentDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() => _appointmentDate = picked);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedPatient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a patient')),
      );
      return;
    }

    if (_doctorName.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select or enter a doctor')),
      );
      return;
    }

    final appointment = AppointmentModel(
      id: widget.initialAppointment?.id,
      appointmentNo: widget.initialAppointment?.appointmentNo ?? '',
      patientId: _selectedPatient!.id!,
      patientName: _selectedPatient!.fullName,
      patientUhid: _selectedPatient!.uhid,
      doctorId: _doctorId,
      doctorName: _doctorName,
      appointmentDate: _appointmentDate,
      appointmentTime: _appointmentTime,
      reasonForVisit: _reasonController.text.trim().isEmpty ? null : _reasonController.text.trim(),
      status: _status,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      createdAt: widget.initialAppointment?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    widget.onSave(appointment);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initialAppointment != null;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(Icons.event_available_outlined, size: 60),
                  const SizedBox(height: 12),
                  Text(
                    isEdit ? 'Edit Appointment' : 'Schedule Appointment',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  if (isEdit) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Appointment No : ${widget.initialAppointment!.appointmentNo}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          PatientPickerField(
            selectedPatient: _selectedPatient,
            enabled: !widget.isLoading && !isEdit,
            onSelected: (patient) => setState(() => _selectedPatient = patient),
          ),
          const SizedBox(height: 16),
          DoctorDropdownField(
            selectedDoctorId: _doctorId,
            selectedDoctorName: _doctorName,
            enabled: !widget.isLoading,
            onChanged: (id, name) => setState(() {
              _doctorId = id;
              _doctorName = name;
            }),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: widget.isLoading ? null : _pickDate,
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Appointment Date',
                prefixIcon: Icon(Icons.event_outlined),
                suffixIcon: Icon(Icons.arrow_drop_down),
                border: OutlineInputBorder(),
              ),
              child: Text(DateFormat('dd/MM/yyyy').format(_appointmentDate)),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _appointmentTime,
            decoration: const InputDecoration(
              labelText: 'Time Slot',
              prefixIcon: Icon(Icons.access_time_outlined),
              border: OutlineInputBorder(),
            ),
            items: AppointmentHelper.timeSlots
                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                .toList(),
            onChanged: widget.isLoading
                ? null
                : (value) {
                    if (value == null) return;
                    setState(() => _appointmentTime = value);
                  },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _status,
            decoration: const InputDecoration(
              labelText: 'Status',
              prefixIcon: Icon(Icons.flag_outlined),
              border: OutlineInputBorder(),
            ),
            items: AppointmentHelper.statuses
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: widget.isLoading
                ? null
                : (value) {
                    if (value == null) return;
                    setState(() => _status = value);
                  },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _reasonController,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Reason for Visit (optional)',
              prefixIcon: Icon(Icons.description_outlined),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _notesController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Notes (optional)',
              prefixIcon: Icon(Icons.notes_outlined),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: widget.isLoading
                      ? null
                      : widget.onCancel ?? () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.close),
                  label: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FilledButton.icon(
                  onPressed: widget.isLoading ? null : _submit,
                  icon: widget.isLoading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(isEdit ? Icons.save : Icons.event_available),
                  label: Text(isEdit ? 'Save Changes' : 'Schedule'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
