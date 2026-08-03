import 'package:flutter/material.dart';

import '../../../core/helpers/role_helper.dart';
import '../models/user_model.dart';

class UserForm extends StatefulWidget {
  const UserForm({
    super.key,
    this.initialUser,
    required this.onSave,
    this.onCancel,
    this.isLoading = false,
  });

  final UserModel? initialUser;

  final ValueChanged<UserModel> onSave;

  final VoidCallback? onCancel;

  final bool isLoading;

  @override
  State<UserForm> createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _fullNameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;

  bool _isActive = true;

  String _selectedRole = RoleHelper.receptionist;

  final List<String> _roles = RoleHelper.allRoles;

  @override
  void initState() {
    super.initState();

    final user = widget.initialUser;

    _fullNameController = TextEditingController(
      text: user?.fullName ?? '',
    );

    _usernameController = TextEditingController(
      text: user?.username ?? '',
    );

    _passwordController = TextEditingController(
      text: user?.password ?? '',
    );

    _selectedRole = user?.role ?? RoleHelper.receptionist;

    _isActive = user?.isActive ?? true;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final user = UserModel(
      id: widget.initialUser?.id,
      fullName: _fullNameController.text.trim(),
      username: _usernameController.text.trim(),
      password: _passwordController.text,
      role: _selectedRole,
      isActive: _isActive,
      createdAt:
          widget.initialUser?.createdAt ??
          DateTime.now(),
    );

    widget.onSave(user);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding:
                  const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(
                    Icons.person,
                    size: 70,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.initialUser == null
                        ? 'Add User'
                        : 'Edit User',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          TextFormField(
            controller:
                _fullNameController,
            textInputAction:
                TextInputAction.next,
            decoration:
                const InputDecoration(
              labelText: 'Full Name',
              prefixIcon:
                  Icon(Icons.person),
              border:
                  OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null ||
                  value.trim().isEmpty) {
                return 'Enter full name';
              }

              if (value.trim().length < 3) {
                return 'Minimum 3 characters';
              }

              return null;
            },
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller:
                _usernameController,
            textInputAction:
                TextInputAction.next,
            decoration:
                const InputDecoration(
              labelText: 'Username',
              prefixIcon:
                  Icon(Icons.account_circle),
              border:
                  OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null ||
                  value.trim().isEmpty) {
                return 'Enter username';
              }

              if (value.length < 4) {
                return 'Minimum 4 characters';
              }

              return null;
            },
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller:
                _passwordController,
            obscureText: true,
            decoration:
                const InputDecoration(
              labelText: 'Password',
              prefixIcon:
                  Icon(Icons.lock),
              border:
                  OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null ||
                  value.isEmpty) {
                return 'Enter password';
              }

              if (value.length < 6) {
                return 'Minimum 6 characters';
              }

              return null;
            },
          ),
                    const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            initialValue: _selectedRole,
            decoration: const InputDecoration(
              labelText: 'Role',
              prefixIcon: Icon(Icons.badge),
              border: OutlineInputBorder(),
            ),
            items: _roles
                .map(
                  (role) => DropdownMenuItem(
                    value: role,
                    child: Text(role),
                  ),
                )
                .toList(),
            onChanged: widget.isLoading
                ? null
                : (value) {
                    if (value == null) return;

                    setState(() {
                      _selectedRole = value;
                    });
                  },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Select role';
              }

              return null;
            },
          ),

          const SizedBox(height: 20),

          Card(
            elevation: 0,
            child: SwitchListTile(
              value: _isActive,
              title: const Text(
                'Active User',
              ),
              subtitle: Text(
                _isActive
                    ? 'User can login'
                    : 'User cannot login',
              ),
              secondary: Icon(
                _isActive
                    ? Icons.check_circle
                    : Icons.cancel,
              ),
              onChanged: widget.isLoading
                  ? null
                  : (value) {
                      setState(() {
                        _isActive = value;
                      });
                    },
            ),
          ),

          const SizedBox(height: 28),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: widget.isLoading
                      ? null
                      : widget.onCancel ??
                          () {
                            Navigator.of(
                              context,
                            ).maybePop();
                          },
                  icon: const Icon(
                    Icons.close,
                  ),
                  label: const Text(
                    'Cancel',
                  ),
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: FilledButton.icon(
                  onPressed: widget.isLoading
                      ? null
                      : _submit,
                  icon: widget.isLoading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : Icon(
                          widget.initialUser == null
                              ? Icons.person_add
                              : Icons.save,
                        ),
                  label: Text(
                    widget.initialUser == null
                        ? 'Create User'
                        : 'Save Changes',
                  ),
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