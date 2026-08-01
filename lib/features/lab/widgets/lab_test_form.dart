import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/helpers/lab_helper.dart';
import '../../../core/validators.dart';
import '../../../shared/widgets/doctor_dropdown_field.dart';
import '../../../shared/widgets/patient_picker_field.dart';
import '../../patients/models/patient_model.dart';
import '../models/lab_test_model.dart';

class LabTestForm extends StatefulWidget {
  const LabTestForm({
    super.key,
    this.initialTest,
    required this.onSave,
    this.onCancel,
    this.isLoading = false,
  });

  final LabTestModel? initialTest;
  final ValueChanged<LabTestModel> onSave;
  final VoidCallback? onCancel;
  final bool isLoading;

  @override
  State<LabTestForm> createState() => _LabTestFormState();
}

class _LabTestFormState extends State<LabTestForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _testNameController;
  late final TextEditingController _feeController;
  late final TextEditingController _resultValueController;
  late final TextEditingController _normalRangeController;
  late final TextEditingController _resultUnitController;
  late final TextEditingController _notesController;

  PatientModel? _selectedPatient;
  int? _doctorId;
  String _doctorName = '';

  DateTime _orderDate = DateTime.now();
  DateTime? _resultDate;

  String _testCategory = LabHelper.testCategories.first;
  String _sampleType = LabHelper.sampleTypes.first;
  String _status = LabHelper.statuses.first;

  @override
  void initState() {
    super.initState();

    final test = widget.initialTest;

    _testNameController = TextEditingController(text: test?.testName ?? '');
    _feeController = TextEditingController(
      text: test == null ? '' : test.testFee.toStringAsFixed(0),
    );
    _resultValueController = TextEditingController(text: test?.resultValue ?? '');
    _normalRangeController = TextEditingController(text: test?.normalRange ?? '');
    _resultUnitController = TextEditingController(text: test?.resultUnit ?? '');
    _notesController = TextEditingController(text: test?.notes ?? '');

    _doctorId = test?.doctorId;
    _doctorName = test?.doctorName ?? '';
    _orderDate = test?.orderDate ?? DateTime.now();
    _resultDate = test?.resultDate;
    _testCategory = test?.testCategory ?? LabHelper.testCategories.first;
    _sampleType = test?.sampleType ?? LabHelper.sampleTypes.first;
    _status = test?.status ?? LabHelper.statuses.first;

    if (test != null) {
      _selectedPatient = PatientModel(
        id: test.patientId,
        uhid: test.patientUhid,
        fullName: test.patientName,
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
    _testNameController.dispose();
    _feeController.dispose();
    _resultValueController.dispose();
    _normalRangeController.dispose();
    _resultUnitController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickOrderDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _orderDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );

    if (picked != null) {
      setState(() => _orderDate = picked);
    }
  }

  Future<void> _pickResultDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _resultDate ?? DateTime.now(),
      firstDate: _orderDate,
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );

    if (picked != null) {
      setState(() => _resultDate = picked);
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
        const SnackBar(content: Text('Please select or enter the referring doctor')),
      );
      return;
    }

    final test = LabTestModel(
      id: widget.initialTest?.id,
      testNo: widget.initialTest?.testNo ?? '',
      patientId: _selectedPatient!.id!,
      patientName: _selectedPatient!.fullName,
      patientUhid: _selectedPatient!.uhid,
      doctorId: _doctorId,
      doctorName: _doctorName,
      testName: _testNameController.text.trim(),
      testCategory: _testCategory,
      sampleType: _sampleType,
      orderDate: _orderDate,
      status: _status,
      resultValue: _resultValueController.text.trim().isEmpty
          ? null
          : _resultValueController.text.trim(),
      normalRange: _normalRangeController.text.trim().isEmpty
          ? null
          : _normalRangeController.text.trim(),
      resultUnit: _resultUnitController.text.trim().isEmpty
          ? null
          : _resultUnitController.text.trim(),
      resultDate: _status == 'Completed' ? (_resultDate ?? DateTime.now()) : _resultDate,
      testFee: double.tryParse(_feeController.text.trim()) ?? 0,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      createdAt: widget.initialTest?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    widget.onSave(test);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initialTest != null;

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
                  const Icon(Icons.biotech_outlined, size: 60),
                  const SizedBox(height: 12),
                  Text(
                    isEdit ? 'Edit Lab Test' : 'Order Lab Test',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  if (isEdit) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Test No : ${widget.initialTest!.testNo}',
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
          TextFormField(
            controller: _testNameController,
            decoration: const InputDecoration(
              labelText: 'Test Name',
              prefixIcon: Icon(Icons.biotech_outlined),
              border: OutlineInputBorder(),
            ),
            validator: (value) => AppValidators.requiredField(value, 'Test name'),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _testCategory,
            decoration: const InputDecoration(
              labelText: 'Test Category',
              prefixIcon: Icon(Icons.category_outlined),
              border: OutlineInputBorder(),
            ),
            items: LabHelper.testCategories
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: widget.isLoading
                ? null
                : (value) {
                    if (value == null) return;
                    setState(() => _testCategory = value);
                  },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _sampleType,
            decoration: const InputDecoration(
              labelText: 'Sample Type',
              prefixIcon: Icon(Icons.water_drop_outlined),
              border: OutlineInputBorder(),
            ),
            items: LabHelper.sampleTypes
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: widget.isLoading
                ? null
                : (value) {
                    if (value == null) return;
                    setState(() => _sampleType = value);
                  },
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: widget.isLoading ? null : _pickOrderDate,
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Order Date',
                prefixIcon: Icon(Icons.event_outlined),
                suffixIcon: Icon(Icons.arrow_drop_down),
                border: OutlineInputBorder(),
              ),
              child: Text(DateFormat('dd/MM/yyyy').format(_orderDate)),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _status,
            decoration: const InputDecoration(
              labelText: 'Status',
              prefixIcon: Icon(Icons.flag_outlined),
              border: OutlineInputBorder(),
            ),
            items: LabHelper.statuses
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
              labelText: 'Test Fee',
              prefixIcon: Icon(Icons.currency_rupee),
              border: OutlineInputBorder(),
            ),
            validator: (value) => AppValidators.requiredField(value, 'Test fee'),
          ),
          if (_status == 'Completed' || _status == 'In Progress') ...[
            const SizedBox(height: 24),
            Text('Result', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            TextFormField(
              controller: _resultValueController,
              decoration: const InputDecoration(
                labelText: 'Result Value (optional)',
                prefixIcon: Icon(Icons.numbers_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _normalRangeController,
                    decoration: const InputDecoration(
                      labelText: 'Normal Range',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _resultUnitController,
                    decoration: const InputDecoration(
                      labelText: 'Unit',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: widget.isLoading ? null : _pickResultDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Result Date (optional)',
                  prefixIcon: Icon(Icons.event_available_outlined),
                  suffixIcon: Icon(Icons.arrow_drop_down),
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  _resultDate == null
                      ? 'Not set'
                      : DateFormat('dd/MM/yyyy').format(_resultDate!),
                ),
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
                  label: Text(isEdit ? 'Save Changes' : 'Order Test'),
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
