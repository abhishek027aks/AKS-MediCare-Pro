import 'package:flutter/material.dart';

import '../data/repositories/staff_repository.dart';
import '../models/staff_profile_model.dart';

class DeleteStaffProfileDialog extends StatefulWidget {
  const DeleteStaffProfileDialog({super.key, required this.profile});

  final StaffProfileModel profile;

  @override
  State<DeleteStaffProfileDialog> createState() => _DeleteStaffProfileDialogState();
}

class _DeleteStaffProfileDialogState extends State<DeleteStaffProfileDialog> {
  final StaffRepository _repository = StaffRepository.instance;
  bool _isLoading = false;

  Future<void> _delete() async {
    if (widget.profile.id == null) {
      Navigator.pop(context, false);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final rows = await _repository.deleteProfile(widget.profile.id!);

      if (!mounted) return;

      if (rows > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Staff profile deleted successfully.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to delete staff profile.')),
        );
        Navigator.pop(context, false);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
      Navigator.pop(context, false);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(Icons.warning_amber_rounded, size: 48, color: Colors.red),
      title: const Text('Delete Staff Profile'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Are you sure you want to delete this staff profile?',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.badge_outlined)),
            title: Text(widget.profile.staffName),
            subtitle: Text('${widget.profile.role}  •  ${widget.profile.department}'),
          ),
          const SizedBox(height: 10),
          const Text(
            'This does not delete the user account, only the clinical profile.',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          style: FilledButton.styleFrom(backgroundColor: Colors.red),
          onPressed: _isLoading ? null : _delete,
          icon: _isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.delete),
          label: const Text('Delete'),
        ),
      ],
    );
  }
}
