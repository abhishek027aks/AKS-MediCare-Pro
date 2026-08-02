import 'package:flutter/material.dart';

import '../../../core/helpers/staff_helper.dart';
import '../../../core/validators.dart';
import '../../auth/data/repositories/user_repository.dart';
import '../../user_management/models/user_model.dart';
import '../data/repositories/staff_repository.dart';
import '../models/staff_profile_model.dart';

class StaffProfileForm extends StatefulWidget {
  const StaffProfileForm({
    super.key,
    this.initialProfile,
    required this.onSave,
    this.onCancel,
    this.isLoading = false,
  });

  final StaffProfileModel? initialProfile;
  final ValueChanged<StaffProfileModel> onSave;
  final VoidCallback? onCancel;
  final bool isLoading;

  @override
  State<StaffProfileForm> createState() => _StaffProfileFormState();
}

class _StaffProfileFormState extends State<StaffProfileForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _specializationController;
  late final TextEditingController _qualificationController;
  late final TextEditingController _licenseController;
  late final TextEditingController _experienceController;
  late final TextEditingController _feeController;
  late final TextEditingController _notesController;

  String _department = StaffHelper.departments.first;
  String _shiftTiming = StaffHelper.shiftTimings.first;
  bool _isAvailable = true;

  UserModel? _selectedUser;
  bool _loadingUsers = true;
  List<UserModel> _eligibleUsers = [];

  @override
  void initState() {
    super.initState();

    final profile = widget.initialProfile;

    _specializationController = TextEditingController(text: profile?.specialization ?? '');
    _qualificationController = TextEditingController(text: profile?.qualification ?? '');
    _licenseController = TextEditingController(text: profile?.licenseNumber ?? '');
    _experienceController =
        TextEditingController(text: profile?.experienceYears?.toString() ?? '');
    _feeController = TextEditingController(
      text: profile == null ? '' : profile.consultationFee.toStringAsFixed(0),
    );
    _notesController = TextEditingController(text: profile?.notes ?? '');

    _department = profile?.department ?? StaffHelper.departments.first;
    _shiftTiming = profile?.shiftTiming ?? StaffHelper.shiftTimings.first;
    _isAvailable = profile?.isAvailable ?? true;

    _loadEligibleUsers();
  }

  Future<void> _loadEligibleUsers() async {
    final users = await UserRepository.instance.getAllUsers();
    final profiles = await StaffRepository.instance.getAllProfiles();

    final assignedUserIds = profiles
        .where((p) => p.id != widget.initialProfile?.id)
        .map((p) => p.userId)
        .toSet();

    if (!mounted) return;

    setState(() {
      _eligibleUsers = users
          .where((u) =>
              (u.role == 'Doctor' || u.role == 'Nurse') &&
              u.isActive &&
              !assignedUserIds.contains(u.id))
          .toList();

      if (widget.initialProfile != null) {
        final match = users.where((u) => u.id == widget.initialProfile!.userId);
        _selectedUser = match.isEmpty ? null : match.first;
      }

      _loadingUsers = false;
    });
  }

  @override
  void dispose() {
    _specializationController.dispose();
    _qualificationController.dispose();
    _licenseController.dispose();
    _experienceController.dispose();
    _feeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a Doctor or Nurse user account')),
      );
      return;
    }

    final profile = StaffProfileModel(
      id: widget.initialProfile?.id,
      userId: _selectedUser!.id!,
      staffName: _selectedUser!.fullName,
      role: _selectedUser!.role,
      specialization: _specializationController.text.trim(),
      department: _department,
      qualification:
          _qualificationController.text.trim().isEmpty ? null : _qualificationController.text.trim(),
      licenseNumber: _licenseController.text.trim().isEmpty ? null : _licenseController.text.trim(),
      experienceYears: int.tryParse(_experienceController.text.trim()),
      shiftTiming: _shiftTiming,
      consultationFee: double.tryParse(_feeController.text.trim()) ?? 0,
      isAvailable: _isAvailable,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      createdAt: widget.initialProfile?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    widget.onSave(profile);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initialProfile != null;

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
                  const Icon(Icons.badge_outlined, size: 60),
                  const SizedBox(height: 12),
                  Text(
                    isEdit ? 'Edit Staff Profile' : 'Add Clinical Staff Profile',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (_loadingUsers)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: LinearProgressIndicator(),
            )
          else if (isEdit)
            InputDecorator(
              decoration: const InputDecoration(
                labelText: 'User Account',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
              child: Text('${_selectedUser?.fullName ?? '—'}  (${_selectedUser?.role ?? ''})'),
            )
          else if (_eligibleUsers.isEmpty)
            const Card(
              color: Color(0x1AFFA726),
              elevation: 0,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'No available Doctor / Nurse user accounts to link. Create one in User Management first, or every existing Doctor/Nurse already has a profile.',
                ),
              ),
            )
          else
            DropdownButtonFormField<UserModel>(
              initialValue: _selectedUser,
              decoration: const InputDecoration(
                labelText: 'User Account (Doctor / Nurse)',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
              items: _eligibleUsers
                  .map(
                    (user) => DropdownMenuItem(
                      value: user,
                      child: Text('${user.fullName}  (${user.role})'),
                    ),
                  )
                  .toList(),
              onChanged: widget.isLoading
                  ? null
                  : (value) => setState(() => _selectedUser = value),
            ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _specializationController,
            decoration: const InputDecoration(
              labelText: 'Specialization',
              prefixIcon: Icon(Icons.local_hospital_outlined),
              border: OutlineInputBorder(),
            ),
            validator: (value) => AppValidators.requiredField(value, 'Specialization'),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _department,
            decoration: const InputDecoration(
              labelText: 'Department',
              prefixIcon: Icon(Icons.meeting_room_outlined),
              border: OutlineInputBorder(),
            ),
            items: StaffHelper.departments
                .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                .toList(),
            onChanged: widget.isLoading
                ? null
                : (value) {
                    if (value == null) return;
                    setState(() => _department = value);
                  },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _qualificationController,
            decoration: const InputDecoration(
              labelText: 'Qualification (optional)',
              prefixIcon: Icon(Icons.school_outlined),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _licenseController,
            decoration: const InputDecoration(
              labelText: 'License / Registration No (optional)',
              prefixIcon: Icon(Icons.badge_outlined),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _experienceController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Experience (years) (optional)',
              prefixIcon: Icon(Icons.timeline_outlined),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _shiftTiming,
            decoration: const InputDecoration(
              labelText: 'Shift Timing',
              prefixIcon: Icon(Icons.schedule_outlined),
              border: OutlineInputBorder(),
            ),
            items: StaffHelper.shiftTimings
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: widget.isLoading
                ? null
                : (value) {
                    if (value == null) return;
                    setState(() => _shiftTiming = value);
                  },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _feeController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Default Consultation Fee',
              prefixIcon: Icon(Icons.currency_rupee),
              border: OutlineInputBorder(),
            ),
            validator: (value) => AppValidators.requiredField(value, 'Consultation fee'),
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 0,
            child: SwitchListTile(
              value: _isAvailable,
              title: const Text('Currently Available'),
              subtitle: Text(_isAvailable ? 'Taking appointments' : 'Not available'),
              secondary: Icon(_isAvailable ? Icons.check_circle : Icons.cancel),
              onChanged: widget.isLoading
                  ? null
                  : (value) => setState(() => _isAvailable = value),
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
                  label: Text(isEdit ? 'Save Changes' : 'Add Profile'),
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
