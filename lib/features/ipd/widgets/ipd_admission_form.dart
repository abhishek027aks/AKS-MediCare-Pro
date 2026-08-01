import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/helpers/ipd_helper.dart';
import '../../../core/validators.dart';
import '../../../shared/widgets/doctor_dropdown_field.dart';
import '../../../shared/widgets/patient_picker_field.dart';
import '../../patients/models/patient_model.dart';
import '../data/repositories/ipd_repository.dart';
import '../models/ipd_admission_model.dart';

class IpdAdmissionForm extends StatefulWidget {
  const IpdAdmissionForm({
    super.key,
    this.initialAdmission,
    required this.onSave,
    this.onCancel,
    this.isLoading = false,
  });

  final IpdAdmissionModel? initialAdmission;
  final ValueChanged<IpdAdmissionModel> onSave;
  final VoidCallback? onCancel;
  final bool isLoading;

  @override
  State<IpdAdmissionForm> createState() => _IpdAdmissionFormState();
}

class _IpdAdmissionFormState extends State<IpdAdmissionForm> {
  final _formKey = GlobalKey<FormState>();
  final IpdRepository _repository = IpdRepository.instance;

  late final TextEditingController _bedNumberController;
  late final TextEditingController _diagnosisController;
  late final TextEditingController _roomChargesController;
  late final TextEditingController _dischargeSummaryController;
  late final TextEditingController _notesController;

  PatientModel? _selectedPatient;
  int? _doctorId;
  String _doctorName = '';

  DateTime _admissionDate = DateTime.now();
  DateTime? _dischargeDate;

  String _ward = IpdHelper.wards.first;
  String _admissionType = IpdHelper.admissionTypes.first;
  String _status = IpdHelper.statuses.first;

  @override
  void initState() {
    super.initState();

    final admission = widget.initialAdmission;

    _bedNumberController = TextEditingController(text: admission?.bedNumber ?? '');
    _diagnosisController = TextEditingController(text: admission?.diagnosis ?? '');
    _roomChargesController = TextEditingController(
      text: admission == null ? '' : admission.roomChargesPerDay.toStringAsFixed(0),
    );
    _dischargeSummaryController =
        TextEditingController(text: admission?.dischargeSummary ?? '');
    _notesController = TextEditingController(text: admission?.notes ?? '');

    _doctorId = admission?.doctorId;
    _doctorName = admission?.doctorName ?? '';
    _admissionDate = admission?.admissionDate ?? DateTime.now();
    _dischargeDate = admission?.dischargeDate;
    _ward = admission?.ward ?? IpdHelper.wards.first;
    _admissionType = admission?.admissionType ?? IpdHelper.admissionTypes.first;
    _status = admission?.status ?? IpdHelper.statuses.first;

    if (admission != null) {
      _selectedPatient = PatientModel(
        id: admission.patientId,
        uhid: admission.patientUhid,
        fullName: admission.patientName,
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
    _bedNumberController.dispose();
    _diagnosisController.dispose();
    _roomChargesController.dispose();
    _dischargeSummaryController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickAdmissionDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _admissionDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );

    if (picked != null) {
      setState(() => _admissionDate = picked);
    }
  }

  Future<void> _pickDischargeDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dischargeDate ?? DateTime.now(),
      firstDate: _admissionDate,
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );

    if (picked != null) {
      setState(() => _dischargeDate = picked);
    }
  }

  Future<void> _submit() async {
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
        const SnackBar(content: Text('Please select or enter the admitting doctor')),
      );
      return;
    }

    if (_status == 'Discharged' && _dischargeDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a discharge date')),
      );
      return;
    }

    final bedOccupied = await _repository.isBedOccupied(
      ward: _ward,
      bedNumber: _bedNumberController.text.trim(),
      excludingAdmissionId: widget.initialAdmission?.id,
    );

    if (bedOccupied && _status == 'Admitted') {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bed ${_bedNumberController.text.trim()} in $_ward is already occupied.')),
      );
      return;
    }

    final admission = IpdAdmissionModel(
      id: widget.initialAdmission?.id,
      admissionNo: widget.initialAdmission?.admissionNo ?? '',
      patientId: _selectedPatient!.id!,
      patientName: _selectedPatient!.fullName,
      patientUhid: _selectedPatient!.uhid,
      doctorId: _doctorId,
      doctorName: _doctorName,
      ward: _ward,
      bedNumber: _bedNumberController.text.trim(),
      admissionType: _admissionType,
      admissionDate: _admissionDate,
      diagnosis: _diagnosisController.text.trim().isEmpty ? null : _diagnosisController.text.trim(),
      roomChargesPerDay: double.tryParse(_roomChargesController.text.trim()) ?? 0,
      status: _status,
      dischargeDate: _status == 'Discharged' ? _dischargeDate : null,
      dischargeSummary: _dischargeSummaryController.text.trim().isEmpty
          ? null
          : _dischargeSummaryController.text.trim(),
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      createdAt: widget.initialAdmission?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    widget.onSave(admission);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initialAdmission != null;

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
                  const Icon(Icons.bed_outlined, size: 60),
                  const SizedBox(height: 12),
                  Text(
                    isEdit ? 'Edit Admission' : 'New Patient Admission',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  if (isEdit) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Admission No : ${widget.initialAdmission!.admissionNo}',
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
          DropdownButtonFormField<String>(
            initialValue: _ward,
            decoration: const InputDecoration(
              labelText: 'Ward',
              prefixIcon: Icon(Icons.meeting_room_outlined),
              border: OutlineInputBorder(),
            ),
            items: IpdHelper.wards.map((w) => DropdownMenuItem(value: w, child: Text(w))).toList(),
            onChanged: widget.isLoading
                ? null
                : (value) {
                    if (value == null) return;
                    setState(() => _ward = value);
                  },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _bedNumberController,
            decoration: const InputDecoration(
              labelText: 'Bed Number',
              prefixIcon: Icon(Icons.bed_outlined),
              border: OutlineInputBorder(),
            ),
            validator: (value) => AppValidators.requiredField(value, 'Bed number'),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _admissionType,
            decoration: const InputDecoration(
              labelText: 'Admission Type',
              prefixIcon: Icon(Icons.category_outlined),
              border: OutlineInputBorder(),
            ),
            items: IpdHelper.admissionTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
            onChanged: widget.isLoading
                ? null
                : (value) {
                    if (value == null) return;
                    setState(() => _admissionType = value);
                  },
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: widget.isLoading ? null : _pickAdmissionDate,
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Admission Date',
                prefixIcon: Icon(Icons.event_outlined),
                suffixIcon: Icon(Icons.arrow_drop_down),
                border: OutlineInputBorder(),
              ),
              child: Text(DateFormat('dd/MM/yyyy').format(_admissionDate)),
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
            controller: _roomChargesController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Room Charges / Day',
              prefixIcon: Icon(Icons.currency_rupee),
              border: OutlineInputBorder(),
            ),
            validator: (value) => AppValidators.requiredField(value, 'Room charges'),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _status,
            decoration: const InputDecoration(
              labelText: 'Status',
              prefixIcon: Icon(Icons.flag_outlined),
              border: OutlineInputBorder(),
            ),
            items: IpdHelper.statuses.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: widget.isLoading
                ? null
                : (value) {
                    if (value == null) return;
                    setState(() => _status = value);
                  },
          ),
          if (_status == 'Discharged') ...[
            const SizedBox(height: 16),
            InkWell(
              onTap: widget.isLoading ? null : _pickDischargeDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Discharge Date',
                  prefixIcon: Icon(Icons.event_available_outlined),
                  suffixIcon: Icon(Icons.arrow_drop_down),
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  _dischargeDate == null
                      ? 'Select discharge date'
                      : DateFormat('dd/MM/yyyy').format(_dischargeDate!),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _dischargeSummaryController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Discharge Summary (optional)',
                prefixIcon: Icon(Icons.summarize_outlined),
                border: OutlineInputBorder(),
              ),
            ),
          ],
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
                  label: Text(isEdit ? 'Save Changes' : 'Admit Patient'),
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
