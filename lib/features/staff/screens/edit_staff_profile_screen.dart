import 'package:flutter/material.dart';

import '../data/repositories/staff_repository.dart';
import '../models/staff_profile_model.dart';
import '../widgets/staff_profile_form.dart';

class EditStaffProfileScreen extends StatefulWidget {
  const EditStaffProfileScreen({super.key, required this.profile});

  final StaffProfileModel profile;

  @override
  State<EditStaffProfileScreen> createState() => _EditStaffProfileScreenState();
}

class _EditStaffProfileScreenState extends State<EditStaffProfileScreen> {
  final StaffRepository _repository = StaffRepository.instance;
  bool _isLoading = false;

  Future<void> _saveProfile(StaffProfileModel profile) async {
    setState(() => _isLoading = true);

    try {
      final rows = await _repository.updateProfile(profile);

      if (!mounted) return;

      if (rows > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Staff profile updated successfully.'),
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
      appBar: AppBar(title: const Text('Edit Staff Profile'), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: StaffProfileForm(
            initialProfile: widget.profile,
            isLoading: _isLoading,
            onSave: _saveProfile,
            onCancel: () => Navigator.pop(context),
          ),
        ),
      ),
    );
  }
}
