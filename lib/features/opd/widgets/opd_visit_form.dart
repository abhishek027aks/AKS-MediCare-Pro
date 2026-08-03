import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/helpers/opd_helper.dart';
import '../../../core/validators.dart';
import '../../../shared/widgets/doctor_dropdown_field.dart';
import '../../../shared/widgets/patient_picker_field.dart';
import '../../patients/models/patient_model.dart';
import '../models/opd_visit_model.dart';

class OpdVisitForm extends StatefulWidget {
  const OpdVisitForm({
    super.key,
    this.initialVisit,
    required this.onSave,
    this.onCancel,
    this.isLoading = false,
    this.prefillPatient,
    this.prefillDoctorId,
    this.prefillDoctorName,
  });

  final OpdVisitModel? initialVisit;
  final PatientModel? prefillPatient;
  final int? prefillDoctorId;
  final String? prefillDoctorName;
  final ValueChanged<OpdVisitModel> onSave;
  final VoidCallback? onCancel;
  final bool isLoading;

  @override
  State<OpdVisitForm> createState() => _OpdVisitFormState();
}

class _OpdVisitFormState extends State<OpdVisitForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _feeController;
  late final TextEditingController _complaintController;
  late final TextEditingController _diagnosisController;
  late final TextEditingController _prescriptionController;
  late final TextEditingController _notesController;

  PatientModel? _selectedPatient;
  int? _doctorId;
  String _doctorName = '';

  DateTime _visitDate = DateTime.now();
  DateTime? _followUpDate;

  String _visitType = OpdHelper.visitTypes.first;
  String _status = OpdHelper.statuses.first;

  @override
  void initState() {
    super.initState();

    final visit = widget.initialVisit;

    _feeController = TextEditingController(
      text: visit == null ? '' : visit.consultationFee.toStringAsFixed(0),
    );
    _complaintController =
        TextEditingController(text: visit?.chiefComplaint ?? '');
    _diagnosisController = TextEditingController(text: visit?.diagnosis ?? '');
    _prescriptionController =
        TextEditingController(text: visit?.prescription ?? '');
    _notesController = TextEditingController(text: visit?.notes ?? '');

    _doctorId = visit?.doctorId ?? widget.prefillDoctorId;
    _doctorName = visit?.doctorName ?? widget.prefillDoctorName ?? '';
    _visitDate = visit?.visitDate ?? DateTime.now();
    _followUpDate = visit?.followUpDate;
    _visitType = visit?.visitType ?? OpdHelper.visitTypes.first;
    _status = visit?.status ?? OpdHelper.statuses.first;

    if (visit != null) {
      _selectedPatient = PatientModel(
        id: visit.patientId,
        uhid: visit.patientUhid,
        fullName: visit.patientName,
        gender: '',
        dateOfBirth: DateTime(1970),
        mobile: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } else {
      _selectedPatient = widget.prefillPatient;
    }
  }

  @override
  void dispose() {
    _feeController.dispose();
    _complaintController.dispose();
    _diagnosisController.dispose();
    _prescriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickVisitDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _visitDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );

    if (picked != null) {
      setState(() {
        _visitDate = picked;
      });
    }
  }

  Future<void> _pickFollowUpDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _followUpDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _followUpDate = picked;
      });
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

    final visit = OpdVisitModel(
      id: widget.initialVisit?.id,
      visitNo: widget.initialVisit?.visitNo ?? '',
      patientId: _selectedPatient!.id!,
      patientName: _selectedPatient!.fullName,
      patientUhid: _selectedPatient!.uhid,
      doctorId: _doctorId,
      doctorName: _doctorName,
      visitDate: _visitDate,
      visitType: _visitType,
      chiefComplaint: _complaintController.text.trim().isEmpty
          ? null
          : _complaintController.text.trim(),
      diagnosis: _diagnosisController.text.trim().isEmpty
          ? null
          : _diagnosisController.text.trim(),
      prescription: _prescriptionController.text.trim().isEmpty
          ? null
          : _prescriptionController.text.trim(),
      consultationFee: double.tryParse(_feeController.text.trim()) ?? 0,
      followUpDate: _followUpDate,
      status: _status,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      createdAt: widget.initialVisit?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    widget.onSave(visit);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initialVisit != null;

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
                  const Icon(Icons.local_hospital_outlined, size: 60),
                  const SizedBox(height: 12),
                  Text(
                    isEdit ? 'Edit OPD Visit' : 'New OPD Visit',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  if (isEdit) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Visit No : ${widget.initialVisit!.visitNo}',
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
            onSelected: (patient) {
              setState(() {
                _selectedPatient = patient;
              });
            },
          ),
          const SizedBox(height: 16),
          DoctorDropdownField(
            selectedDoctorId: _doctorId,
            selectedDoctorName: _doctorName,
            enabled: !widget.isLoading,
            onChanged: (id, name) {
              setState(() {
                _doctorId = id;
                _doctorName = name;
              });
            },
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: widget.isLoading ? null : _pickVisitDate,
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Visit Date',
                prefixIcon: Icon(Icons.event_outlined),
                suffixIcon: Icon(Icons.arrow_drop_down),
                border: OutlineInputBorder(),
              ),
              child: Text(DateFormat('dd/MM/yyyy').format(_visitDate)),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _visitType,
            decoration: const InputDecoration(
              labelText: 'Visit Type',
              prefixIcon: Icon(Icons.repeat_outlined),
              border: OutlineInputBorder(),
            ),
            items: OpdHelper.visitTypes
                .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                .toList(),
            onChanged: widget.isLoading
                ? null
                : (value) {
                    if (value == null) return;
                    setState(() => _visitType = value);
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
            items: OpdHelper.statuses
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
            controller: _feeController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Consultation Fee',
              prefixIcon: Icon(Icons.currency_rupee),
              border: OutlineInputBorder(),
            ),
            validator: (value) =>
                AppValidators.requiredField(value, 'Consultation fee'),
          ),
          const SizedBox(height: 20),
          Text('Clinical Notes', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          TextFormField(
            controller: _complaintController,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Chief Complaint (optional)',
              prefixIcon: Icon(Icons.report_problem_outlined),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _diagnosisController,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Diagnosis (optional)',
              prefixIcon: Icon(Icons.biotech_outlined),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _prescriptionController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Prescription (optional)',
              prefixIcon: Icon(Icons.medication_outlined),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: widget.isLoading ? null : _pickFollowUpDate,
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Follow-up Date (optional)',
                prefixIcon: const Icon(Icons.event_repeat_outlined),
                suffixIcon: _followUpDate == null
                    ? const Icon(Icons.arrow_drop_down)
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _followUpDate = null),
                      ),
                border: const OutlineInputBorder(),
              ),
              child: Text(
                _followUpDate == null
                    ? 'No follow-up scheduled'
                    : DateFormat('dd/MM/yyyy').format(_followUpDate!),
              ),
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
                      : Icon(isEdit ? Icons.save : Icons.add),
                  label: Text(isEdit ? 'Save Changes' : 'Create Visit'),
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
