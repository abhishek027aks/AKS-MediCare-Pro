import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/helpers/patient_helper.dart';
import '../../../core/validators.dart';
import '../../../shared/services/patient_media_service.dart';
import '../models/patient_model.dart';

class PatientForm extends StatefulWidget {
  const PatientForm({
    super.key,
    this.initialPatient,
    required this.onSave,
    this.onCancel,
    this.isLoading = false,
  });

  final PatientModel? initialPatient;

  final ValueChanged<PatientModel> onSave;

  final VoidCallback? onCancel;

  final bool isLoading;

  @override
  State<PatientForm> createState() => _PatientFormState();
}

class _PatientFormState extends State<PatientForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _fullNameController;
  late final TextEditingController _mobileController;
  late final TextEditingController _alternateMobileController;
  late final TextEditingController _emailController;
  late final TextEditingController _addressController;
  late final TextEditingController _cityController;
  late final TextEditingController _stateController;
  late final TextEditingController _pincodeController;
  late final TextEditingController _occupationController;
  late final TextEditingController _emergencyNameController;
  late final TextEditingController _emergencyNumberController;
  late final TextEditingController _referredByController;
  late final TextEditingController _notesController;

  DateTime? _dateOfBirth;

  String _selectedGender = PatientHelper.genders.first;
  String? _selectedBloodGroup;
  String? _selectedMaritalStatus;

  bool _isActive = true;
  String? _photoPath;

  @override
  void initState() {
    super.initState();

    final patient = widget.initialPatient;

    _fullNameController = TextEditingController(text: patient?.fullName ?? '');
    _mobileController = TextEditingController(text: patient?.mobile ?? '');
    _alternateMobileController =
        TextEditingController(text: patient?.alternateMobile ?? '');
    _emailController = TextEditingController(text: patient?.email ?? '');
    _addressController = TextEditingController(text: patient?.address ?? '');
    _cityController = TextEditingController(text: patient?.city ?? '');
    _stateController = TextEditingController(text: patient?.state ?? '');
    _pincodeController = TextEditingController(text: patient?.pincode ?? '');
    _occupationController =
        TextEditingController(text: patient?.occupation ?? '');
    _emergencyNameController =
        TextEditingController(text: patient?.emergencyContactName ?? '');
    _emergencyNumberController =
        TextEditingController(text: patient?.emergencyContactNumber ?? '');
    _referredByController =
        TextEditingController(text: patient?.referredBy ?? '');
    _notesController = TextEditingController(text: patient?.notes ?? '');

    _dateOfBirth = patient?.dateOfBirth;
    _selectedGender = patient?.gender ?? PatientHelper.genders.first;
    _selectedBloodGroup = patient?.bloodGroup;
    _selectedMaritalStatus = patient?.maritalStatus;
    _isActive = patient?.isActive ?? true;
    _photoPath = patient?.photoPath;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _mobileController.dispose();
    _alternateMobileController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _occupationController.dispose();
    _emergencyNameController.dispose();
    _emergencyNumberController.dispose();
    _referredByController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(now.year - 20),
      firstDate: DateTime(1900),
      lastDate: now,
    );

    if (picked != null) {
      setState(() {
        _dateOfBirth = picked;
      });
    }
  }

  Future<void> _pickPhoto() async {
    final path = await PatientMediaService.pickAndSaveImage(filePrefix: 'patient');
    if (path == null) return;
    setState(() => _photoPath = path);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_dateOfBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select date of birth'),
        ),
      );
      return;
    }

    final patient = PatientModel(
      id: widget.initialPatient?.id,
      uhid: widget.initialPatient?.uhid ?? '',
      fullName: _fullNameController.text.trim(),
      gender: _selectedGender,
      dateOfBirth: _dateOfBirth!,
      bloodGroup: _selectedBloodGroup,
      maritalStatus: _selectedMaritalStatus,
      mobile: _mobileController.text.trim(),
      alternateMobile: _alternateMobileController.text.trim().isEmpty
          ? null
          : _alternateMobileController.text.trim(),
      email: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
      address: _addressController.text.trim().isEmpty
          ? null
          : _addressController.text.trim(),
      city: _cityController.text.trim().isEmpty
          ? null
          : _cityController.text.trim(),
      state: _stateController.text.trim().isEmpty
          ? null
          : _stateController.text.trim(),
      pincode: _pincodeController.text.trim().isEmpty
          ? null
          : _pincodeController.text.trim(),
      occupation: _occupationController.text.trim().isEmpty
          ? null
          : _occupationController.text.trim(),
      emergencyContactName: _emergencyNameController.text.trim().isEmpty
          ? null
          : _emergencyNameController.text.trim(),
      emergencyContactNumber: _emergencyNumberController.text.trim().isEmpty
          ? null
          : _emergencyNumberController.text.trim(),
      referredBy: _referredByController.text.trim().isEmpty
          ? null
          : _referredByController.text.trim(),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      photoPath: _photoPath,
      isActive: _isActive,
      createdAt: widget.initialPatient?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    widget.onSave(patient);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initialPatient != null;

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
                  InkWell(
                    onTap: _pickPhoto,
                    borderRadius: BorderRadius.circular(45),
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 45,
                          backgroundImage: _photoPath != null ? FileImage(File(_photoPath!)) : null,
                          child: _photoPath == null
                              ? const Icon(Icons.personal_injury_outlined, size: 44)
                              : null,
                        ),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: Colors.black87, shape: BoxShape.circle),
                          child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isEdit ? 'Edit Patient' : 'New Patient Registration',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  if (isEdit) ...[
                    const SizedBox(height: 6),
                    Text(
                      'UHID : ${widget.initialPatient!.uhid}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          Text(
            'Basic Details',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),

          TextFormField(
            controller: _fullNameController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(),
            ),
            validator: (value) =>
                AppValidators.requiredField(value, 'Full name'),
          ),

          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            initialValue: _selectedGender,
            decoration: const InputDecoration(
              labelText: 'Gender',
              prefixIcon: Icon(Icons.wc),
              border: OutlineInputBorder(),
            ),
            items: PatientHelper.genders
                .map(
                  (gender) => DropdownMenuItem(
                    value: gender,
                    child: Text(gender),
                  ),
                )
                .toList(),
            onChanged: widget.isLoading
                ? null
                : (value) {
                    if (value == null) return;
                    setState(() {
                      _selectedGender = value;
                    });
                  },
          ),

          const SizedBox(height: 16),

          InkWell(
            onTap: widget.isLoading ? null : _pickDateOfBirth,
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Date of Birth',
                prefixIcon: Icon(Icons.cake_outlined),
                suffixIcon: Icon(Icons.arrow_drop_down),
                border: OutlineInputBorder(),
              ),
              child: Text(
                _dateOfBirth == null
                    ? 'Select date of birth'
                    : DateFormat('dd/MM/yyyy').format(_dateOfBirth!),
              ),
            ),
          ),

          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            initialValue: _selectedBloodGroup,
            decoration: const InputDecoration(
              labelText: 'Blood Group',
              prefixIcon: Icon(Icons.bloodtype_outlined),
              border: OutlineInputBorder(),
            ),
            items: PatientHelper.bloodGroups
                .map(
                  (group) => DropdownMenuItem(
                    value: group,
                    child: Text(group),
                  ),
                )
                .toList(),
            onChanged: widget.isLoading
                ? null
                : (value) {
                    setState(() {
                      _selectedBloodGroup = value;
                    });
                  },
          ),

          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            initialValue: _selectedMaritalStatus,
            decoration: const InputDecoration(
              labelText: 'Marital Status',
              prefixIcon: Icon(Icons.family_restroom_outlined),
              border: OutlineInputBorder(),
            ),
            items: PatientHelper.maritalStatuses
                .map(
                  (status) => DropdownMenuItem(
                    value: status,
                    child: Text(status),
                  ),
                )
                .toList(),
            onChanged: widget.isLoading
                ? null
                : (value) {
                    setState(() {
                      _selectedMaritalStatus = value;
                    });
                  },
          ),

          const SizedBox(height: 24),

          Text(
            'Contact Details',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),

          TextFormField(
            controller: _mobileController,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Mobile Number',
              prefixIcon: Icon(Icons.phone_outlined),
              border: OutlineInputBorder(),
            ),
            validator: AppValidators.mobile,
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: _alternateMobileController,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Alternate Mobile (optional)',
              prefixIcon: Icon(Icons.phone_forwarded_outlined),
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Email (optional)',
              prefixIcon: Icon(Icons.email_outlined),
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return null;
              }
              return AppValidators.email(value);
            },
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: _addressController,
            maxLines: 2,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Address (optional)',
              prefixIcon: Icon(Icons.home_outlined),
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _cityController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'City',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _stateController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'State',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: _pincodeController,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Pincode',
              prefixIcon: Icon(Icons.pin_drop_outlined),
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 24),

          Text(
            'Other Details',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),

          TextFormField(
            controller: _occupationController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Occupation (optional)',
              prefixIcon: Icon(Icons.work_outline),
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: _emergencyNameController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Emergency Contact Name (optional)',
              prefixIcon: Icon(Icons.contact_emergency_outlined),
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: _emergencyNumberController,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Emergency Contact Number (optional)',
              prefixIcon: Icon(Icons.phone_in_talk_outlined),
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: _referredByController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Referred By (optional)',
              prefixIcon: Icon(Icons.recommend_outlined),
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

          const SizedBox(height: 20),

          Card(
            elevation: 0,
            child: SwitchListTile(
              value: _isActive,
              title: const Text('Active Patient'),
              subtitle: Text(
                _isActive
                    ? 'Patient record is active'
                    : 'Patient record is inactive',
              ),
              secondary: Icon(
                _isActive ? Icons.check_circle : Icons.cancel,
              ),
              onChanged: widget.isLoading
                  ? null
                  : (value) {
                      setState(() {
                        _isActive = value;
                      });
                    },
            ),
          ),

          const SizedBox(height: 28),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: widget.isLoading
                      ? null
                      : widget.onCancel ??
                          () {
                            Navigator.of(context).maybePop();
                          },
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
                      : Icon(isEdit ? Icons.save : Icons.person_add),
                  label: Text(isEdit ? 'Save Changes' : 'Register Patient'),
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
