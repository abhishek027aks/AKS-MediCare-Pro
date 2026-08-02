import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/attendance_repository.dart';
import '../models/attendance_model.dart';
import '../widgets/attendance_form.dart';

class AddAttendanceScreen extends ConsumerStatefulWidget {
  const AddAttendanceScreen({super.key});

  @override
  ConsumerState<AddAttendanceScreen> createState() => _AddAttendanceScreenState();
}

class _AddAttendanceScreenState extends ConsumerState<AddAttendanceScreen> {
  bool _isSaving = false;

  Future<void> _saveRecord(AttendanceModel record) async {
    setState(() => _isSaving = true);

    try {
      await AttendanceRepository.instance.createRecord(record);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Attendance marked successfully.'),
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
      appBar: AppBar(title: const Text('Mark Attendance'), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: AttendanceForm(
            onSave: _saveRecord,
            isLoading: _isSaving,
            onCancel: () => Navigator.pop(context),
          ),
        ),
      ),
    );
  }
}
