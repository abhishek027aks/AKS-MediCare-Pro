import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_model.dart';
import '../../auth/data/repositories/user_repository.dart';
import '../widgets/user_form.dart';

class AddUserScreen extends ConsumerStatefulWidget {
  const AddUserScreen({super.key});

  @override
  ConsumerState<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends ConsumerState<AddUserScreen> {
  bool _isSaving = false;

  Future<void> _saveUser(UserModel user) async {
    try {
      setState(() {
        _isSaving = true;
      });

      final repository = UserRepository.instance;

      final exists = await repository.userExists(
        user.username,
      );

      if (exists) {
        throw Exception(
          'Username already exists.',
        );
      }

      await repository.createUser(user);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'User created successfully.',
          ),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add User'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: UserForm(
            onSave: _saveUser,
            isLoading: _isSaving,
            onCancel: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }
}