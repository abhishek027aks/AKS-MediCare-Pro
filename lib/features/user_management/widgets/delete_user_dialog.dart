import 'package:flutter/material.dart';

import '../../auth/data/repositories/user_repository.dart';
import '../models/user_model.dart';

class DeleteUserDialog extends StatefulWidget {
  const DeleteUserDialog({
    super.key,
    required this.user,
  });

  final UserModel user;

  @override
  State<DeleteUserDialog> createState() =>
      _DeleteUserDialogState();
}

class _DeleteUserDialogState
    extends State<DeleteUserDialog> {
  final UserRepository _repository =
      UserRepository.instance;

  bool _isLoading = false;

  Future<void> _deleteUser() async {
    if (widget.user.id == null) {
      Navigator.pop(context, false);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final rows = await _repository.deleteUser(
        widget.user.id!,
      );

      if (!mounted) return;

      if (rows > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'User deleted successfully.',
            ),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Unable to delete user.',
            ),
          ),
        );

        Navigator.pop(context, false);
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );

      Navigator.pop(context, false);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(
        Icons.warning_amber_rounded,
        size: 48,
        color: Colors.red,
      ),
      title: const Text(
        'Delete User',
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Are you sure you want to delete this user?',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.person),
            ),
            title: Text(
              widget.user.fullName,
            ),
            subtitle: Text(
              '@${widget.user.username}',
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'This action cannot be undone.',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading
              ? null
              : () => Navigator.pop(
                    context,
                    false,
                  ),
          child: const Text(
            'Cancel',
          ),
        ),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          onPressed:
              _isLoading ? null : _deleteUser,
          icon: _isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child:
                      CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(
                  Icons.delete,
                ),
          label: const Text(
            'Delete',
          ),
        ),
      ],
    );
  }
}