import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/providers/auth_state_provider.dart';
import '../../delete_requests/data/repositories/delete_request_repository.dart';
import '../../delete_requests/models/delete_request_model.dart';
import '../../permissions/providers/permission_provider.dart';
import '../data/repositories/patient_repository.dart';
import '../models/patient_model.dart';

class DeletePatientDialog extends ConsumerStatefulWidget {
  const DeletePatientDialog({
    super.key,
    required this.patient,
  });

  final PatientModel patient;

  @override
  ConsumerState<DeletePatientDialog> createState() => _DeletePatientDialogState();
}

class _DeletePatientDialogState extends ConsumerState<DeletePatientDialog> {
  final PatientRepository _repository = PatientRepository.instance;
  final TextEditingController _reasonController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _deleteDirectly() async {
    if (widget.patient.id == null) {
      Navigator.pop(context, false);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final rows = await _repository.deletePatient(widget.patient.id!);

      if (!mounted) return;

      if (rows > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Patient deleted successfully.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to delete patient.')),
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

  Future<void> _sendDeleteRequest() async {
    if (widget.patient.id == null) {
      Navigator.pop(context, false);
      return;
    }

    if (_reasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a reason for the request')),
      );
      return;
    }

    final user = ref.read(currentUserProvider);
    if (user?.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to request a deletion')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await DeleteRequestRepository.instance.createRequest(
        DeleteRequestModel(
          module: 'Patients',
          recordId: widget.patient.id!,
          recordLabel: '${widget.patient.fullName} (${widget.patient.uhid})',
          reason: _reasonController.text.trim(),
          status: 'Pending',
          requestedByUserId: user!.id!,
          requestedByName: user.fullName,
          requestedAt: DateTime.now(),
        ),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Delete request sent for approval.'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, false);
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
    final canDeleteDirectly =
        ref.watch(currentUserPermissionsProvider.notifier).can('Patients', action: 'delete');

    if (canDeleteDirectly) {
      return AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded, size: 48, color: Colors.red),
        title: const Text('Delete Patient'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Are you sure you want to delete this patient record?',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.personal_injury_outlined)),
              title: Text(widget.patient.fullName),
              subtitle: Text('UHID : ${widget.patient.uhid}'),
            ),
            const SizedBox(height: 10),
            const Text(
              'This action cannot be undone.',
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
            onPressed: _isLoading ? null : _deleteDirectly,
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

    // No direct delete permission — send a request for Hospital
    // Head / Administrator approval instead.
    return AlertDialog(
      icon: const Icon(Icons.forward_to_inbox_outlined, size: 48, color: Colors.orange),
      title: const Text('Request Deletion'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your role doesn\'t have direct delete access for Patients. '
              'This will send a request for approval instead.',
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(child: Icon(Icons.personal_injury_outlined)),
              title: Text(widget.patient.fullName),
              subtitle: Text('UHID : ${widget.patient.uhid}'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _reasonController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Reason for deletion',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: _isLoading ? null : _sendDeleteRequest,
          icon: _isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.send_outlined),
          label: const Text('Send Request'),
        ),
      ],
    );
  }
}
