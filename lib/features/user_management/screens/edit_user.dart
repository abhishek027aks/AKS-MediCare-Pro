import 'package:flutter/material.dart';

import '../../auth/data/repositories/user_repository.dart';
import '../models/user_model.dart';
import '../widgets/user_form.dart';

class EditUserScreen extends StatefulWidget {
  const EditUserScreen({
    super.key,
    required this.user,
  });

  final UserModel user;

  @override
  State<EditUserScreen> createState() =>
      _EditUserScreenState();
}

class _EditUserScreenState
    extends State<EditUserScreen> {
  final UserRepository _repository =
      UserRepository.instance;

  bool _isLoading = false;

  Future<void> _saveUser(
    UserModel user,
  ) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final rows =
          await _repository.updateUser(user);

      if (!mounted) return;

      if (rows > 0) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          const SnackBar(
            content: Text(
              'User updated successfully.',
            ),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(
          context,
          true,
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          const SnackBar(
            content: Text(
              'No changes were saved.',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            'Error: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit User',
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.all(16),
          child: UserForm(
            initialUser: widget.user,
            isLoading: _isLoading,
            onSave: _saveUser,
            onCancel: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }
}