import 'package:flutter/material.dart';

import '../../features/auth/data/repositories/user_repository.dart';
import '../../features/user_management/models/user_model.dart';

/// A dropdown of active users with the "Doctor" role, sourced from
/// the existing User Management module. Used by OPD and IPD forms.
class DoctorDropdownField extends StatefulWidget {
  const DoctorDropdownField({
    super.key,
    required this.selectedDoctorId,
    required this.selectedDoctorName,
    required this.onChanged,
    this.enabled = true,
  });

  final int? selectedDoctorId;
  final String selectedDoctorName;
  final void Function(int? doctorId, String doctorName) onChanged;
  final bool enabled;

  @override
  State<DoctorDropdownField> createState() => _DoctorDropdownFieldState();
}

class _DoctorDropdownFieldState extends State<DoctorDropdownField> {
  List<UserModel> _doctors = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    final users = await UserRepository.instance.getAllUsers();

    if (!mounted) return;

    setState(() {
      _doctors = users
          .where((user) => user.role == 'Doctor' && user.isActive)
          .toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const InputDecorator(
        decoration: InputDecoration(
          labelText: 'Doctor',
          prefixIcon: Icon(Icons.medical_services_outlined),
          border: OutlineInputBorder(),
        ),
        child: SizedBox(
          height: 20,
          child: LinearProgressIndicator(),
        ),
      );
    }

    // If no Doctor-role users exist yet, fall back to a free-text
    // field so the module remains usable regardless of setup order.
    if (_doctors.isEmpty) {
      return TextFormField(
        initialValue: widget.selectedDoctorName,
        enabled: widget.enabled,
        decoration: const InputDecoration(
          labelText: 'Doctor Name',
          helperText: 'No "Doctor" role users found — enter name manually',
          prefixIcon: Icon(Icons.medical_services_outlined),
          border: OutlineInputBorder(),
        ),
        onChanged: (value) => widget.onChanged(null, value),
      );
    }

    final validIds = _doctors.map((d) => d.id).toSet();
    final currentValue =
        validIds.contains(widget.selectedDoctorId) ? widget.selectedDoctorId : null;

    return DropdownButtonFormField<int>(
      initialValue: currentValue,
      decoration: const InputDecoration(
        labelText: 'Doctor',
        prefixIcon: Icon(Icons.medical_services_outlined),
        border: OutlineInputBorder(),
      ),
      items: _doctors
          .map(
            (doctor) => DropdownMenuItem(
              value: doctor.id,
              child: Text(doctor.fullName),
            ),
          )
          .toList(),
      onChanged: widget.enabled
          ? (value) {
              final doctor = _doctors.firstWhere((d) => d.id == value);
              widget.onChanged(doctor.id, doctor.fullName);
            }
          : null,
    );
  }
}
