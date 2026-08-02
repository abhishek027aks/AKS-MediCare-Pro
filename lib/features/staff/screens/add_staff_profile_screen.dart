import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/staff_repository.dart';
import '../models/staff_profile_model.dart';
import '../widgets/staff_profile_form.dart';

class AddStaffProfileScreen extends ConsumerStatefulWidget {
  const AddStaffProfileScreen({super.key});

  @override
  ConsumerState<AddStaffProfileScreen> createState() => _AddStaffProfileScreenState();
}

class _AddStaffProfileScreenState extends ConsumerState<AddStaffProfileScreen> {
  bool _isSaving = false;

  Future<void> _saveProfile(StaffProfileModel profile) async {
    setState(() => _isSaving = true);

    try {
      final repository = StaffRepository.instance;

      final exists = await repository.profileExistsForUser(profile.userId);

      if (exists) {
        throw Exception('This user already has a staff profile.');
      }

      await repository.createProfile(profile);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Staff profile added successfully.'),
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
      appBar: AppBar(title: const Text('Add Staff Profile'), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: StaffProfileForm(
            onSave: _saveProfile,
            isLoading: _isSaving,
            onCancel: () => Navigator.pop(context),
          ),
        ),
      ),
    );
  }
}
