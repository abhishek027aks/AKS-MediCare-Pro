import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/helpers/attendance_helper.dart';
import '../../auth/data/repositories/user_repository.dart';
import '../../user_management/models/user_model.dart';
import '../data/repositories/attendance_repository.dart';
import '../models/attendance_model.dart';

class AttendanceForm extends StatefulWidget {
  const AttendanceForm({
    super.key,
    this.initialRecord,
    required this.onSave,
    this.onCancel,
    this.isLoading = false,
  });

  final AttendanceModel? initialRecord;
  final ValueChanged<AttendanceModel> onSave;
  final VoidCallback? onCancel;
  final bool isLoading;

  @override
  State<AttendanceForm> createState() => _AttendanceFormState();
}

class _AttendanceFormState extends State<AttendanceForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _checkInController;
  late final TextEditingController _checkOutController;
  late final TextEditingController _notesController;

  UserModel? _selectedUser;
  bool _loadingUsers = true;
  List<UserModel> _staffUsers = [];

  DateTime _date = DateTime.now();
  String _status = AttendanceHelper.statuses.first;

  @override
  void initState() {
    super.initState();

    final record = widget.initialRecord;

    _checkInController = TextEditingController(text: record?.checkInTime ?? '');
    _checkOutController = TextEditingController(text: record?.checkOutTime ?? '');
    _notesController = TextEditingController(text: record?.notes ?? '');

    _date = record?.date ?? DateTime.now();
    _status = record?.status ?? AttendanceHelper.statuses.first;

    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final users = await UserRepository.instance.getAllUsers();

    if (!mounted) return;

    setState(() {
      _staffUsers = users.where((u) => u.isActive).toList();

      if (widget.initialRecord != null) {
        final match = users.where((u) => u.id == widget.initialRecord!.userId);
        _selectedUser = match.isEmpty ? null : match.first;
      }

      _loadingUsers = false;
    });
  }

  @override
  void dispose() {
    _checkInController.dispose();
    _checkOutController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a staff member')),
      );
      return;
    }

    final duplicate = await AttendanceRepository.instance.recordExists(
      userId: _selectedUser!.id!,
      date: _date,
      excludingId: widget.initialRecord?.id,
    );

    if (duplicate) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Attendance for ${_selectedUser!.fullName} on ${DateFormat('dd/MM/yyyy').format(_date)} is already marked.',
          ),
        ),
      );
      return;
    }

    final record = AttendanceModel(
      id: widget.initialRecord?.id,
      userId: _selectedUser!.id!,
      staffName: _selectedUser!.fullName,
      role: _selectedUser!.role,
      date: _date,
      status: _status,
      checkInTime: _checkInController.text.trim().isEmpty ? null : _checkInController.text.trim(),
      checkOutTime: _checkOutController.text.trim().isEmpty ? null : _checkOutController.text.trim(),
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      createdAt: widget.initialRecord?.createdAt ?? DateTime.now(),
    );

    widget.onSave(record);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initialRecord != null;

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
                  const Icon(Icons.fact_check_outlined, size: 60),
                  const SizedBox(height: 12),
                  Text(
                    isEdit ? 'Edit Attendance' : 'Mark Attendance',
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
                labelText: 'Staff Member',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
              child: Text('${_selectedUser?.fullName ?? '—'}  (${_selectedUser?.role ?? ''})'),
            )
          else
            DropdownButtonFormField<UserModel>(
              initialValue: _selectedUser,
              decoration: const InputDecoration(
                labelText: 'Staff Member',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
              items: _staffUsers
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
          InkWell(
            onTap: widget.isLoading ? null : _pickDate,
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Date',
                prefixIcon: Icon(Icons.event_outlined),
                suffixIcon: Icon(Icons.arrow_drop_down),
                border: OutlineInputBorder(),
              ),
              child: Text(DateFormat('dd/MM/yyyy').format(_date)),
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
            items: AttendanceHelper.statuses
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: widget.isLoading
                ? null
                : (value) {
                    if (value == null) return;
                    setState(() => _status = value);
                  },
          ),
          if (_status == 'Present' || _status == 'Half Day') ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _checkInController,
                    decoration: const InputDecoration(
                      labelText: 'Check-in (e.g. 09:00 AM)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _checkOutController,
                    decoration: const InputDecoration(
                      labelText: 'Check-out (e.g. 06:00 PM)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
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
                      : Icon(isEdit ? Icons.save : Icons.check_circle_outline),
                  label: Text(isEdit ? 'Save Changes' : 'Mark Attendance'),
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
