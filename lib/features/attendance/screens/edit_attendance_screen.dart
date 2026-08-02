import 'package:flutter/material.dart';

import '../data/repositories/attendance_repository.dart';
import '../models/attendance_model.dart';
import '../widgets/attendance_form.dart';

class EditAttendanceScreen extends StatefulWidget {
  const EditAttendanceScreen({super.key, required this.record});

  final AttendanceModel record;

  @override
  State<EditAttendanceScreen> createState() => _EditAttendanceScreenState();
}

class _EditAttendanceScreenState extends State<EditAttendanceScreen> {
  final AttendanceRepository _repository = AttendanceRepository.instance;
  bool _isLoading = false;

  Future<void> _saveRecord(AttendanceModel record) async {
    setState(() => _isLoading = true);

    try {
      final rows = await _repository.updateRecord(record);

      if (!mounted) return;

      if (rows > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Attendance updated successfully.'),
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
      appBar: AppBar(title: const Text('Edit Attendance'), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: AttendanceForm(
            initialRecord: widget.record,
            isLoading: _isLoading,
            onSave: _saveRecord,
            onCancel: () => Navigator.pop(context),
          ),
        ),
      ),
    );
  }
}
