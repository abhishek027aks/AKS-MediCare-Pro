import 'package:flutter/material.dart';

import '../../../core/helpers/credential_helper.dart';
import '../../auth/data/repositories/user_repository.dart';
import '../models/user_model.dart';

/// Generates a fresh temporary password for [user], sets it, and
/// forces a change on their next login — then shows the admin the
/// plaintext password once so it can be shared with the employee.
class ResetPasswordDialog extends StatefulWidget {
  const ResetPasswordDialog({super.key, required this.user});

  final UserModel user;

  @override
  State<ResetPasswordDialog> createState() => _ResetPasswordDialogState();
}

class _ResetPasswordDialogState extends State<ResetPasswordDialog> {
  bool _isLoading = false;
  String? _generatedPassword;

  Future<void> _reset() async {
    if (widget.user.id == null) return;

    setState(() => _isLoading = true);

    try {
      final temp = CredentialHelper.generateTemporaryPassword();

      await UserRepository.instance.resetPassword(
        userId: widget.user.id!,
        temporaryPassword: temp,
      );

      if (!mounted) return;
      setState(() => _generatedPassword = temp);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_generatedPassword != null) {
      return AlertDialog(
        icon: const Icon(Icons.check_circle_outline, color: Colors.green, size: 48),
        title: const Text('Password Reset'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('New temporary password for ${widget.user.fullName}:'),
            const SizedBox(height: 12),
            SelectableText(
              _generatedPassword!,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1),
            ),
            const SizedBox(height: 12),
            const Text(
              'Share this securely — they\'ll be required to change it on next login.',
              style: TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Done'),
          ),
        ],
      );
    }

    return AlertDialog(
      icon: const Icon(Icons.lock_reset_outlined, size: 48),
      title: const Text('Reset Password'),
      content: Text(
        'Generate a new temporary password for ${widget.user.fullName}? Their current password will stop working.',
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: _isLoading ? null : _reset,
          icon: _isLoading
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.lock_reset_outlined),
          label: const Text('Reset'),
        ),
      ],
    );
  }
}
