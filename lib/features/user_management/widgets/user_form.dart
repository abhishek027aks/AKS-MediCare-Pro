import 'package:flutter/material.dart';

import '../../../core/helpers/credential_helper.dart';
import '../../../core/helpers/role_helper.dart';
import '../../../core/helpers/staff_helper.dart';
import '../../branches/data/repositories/branch_repository.dart';
import '../../branches/models/branch_model.dart';
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
  bool _obscurePassword = true;

  String _selectedRole = RoleHelper.receptionist;
  String? _selectedDepartment;
  int? _selectedBranchId;
  String? _selectedBranchName;

  List<BranchModel> _branches = [];

  final List<String> _roles = RoleHelper.allRoles;
  final List<String> _departments = StaffHelper.departments;

  bool get _isEdit => widget.initialUser != null;

  @override
  void initState() {
    super.initState();

    final user = widget.initialUser;

    _fullNameController = TextEditingController(text: user?.fullName ?? '');
    _usernameController = TextEditingController(text: user?.username ?? '');
    _passwordController = TextEditingController(text: user?.password ?? '');

    _selectedRole = user?.role ?? RoleHelper.receptionist;
    _selectedDepartment = user?.department;
    _selectedBranchId = user?.branchId;
    _selectedBranchName = user?.branchName;
    _isActive = user?.isActive ?? true;

    _loadBranches();
  }

  Future<void> _loadBranches() async {
    final branches = await BranchRepository.instance.getActiveBranches();
    if (!mounted) return;
    setState(() => _branches = branches);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _generateUsername() {
    if (_fullNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter the full name first')),
      );
      return;
    }

    setState(() {
      _usernameController.text = CredentialHelper.suggestUsername(_fullNameController.text);
    });
  }

  void _generatePassword() {
    setState(() {
      _passwordController.text = CredentialHelper.generateTemporaryPassword();
      _obscurePassword = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Temporary password generated — share it securely with the employee.')),
    );
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
      department: _selectedDepartment,
      branchId: _selectedBranchId,
      branchName: _selectedBranchName,
      isActive: _isActive,
      // New accounts must change their password on first login. On
      // edit, whatever the account's current flag is stays as-is —
      // this form doesn't clear or set it (use "Reset Password" for
      // that from the user list instead).
      mustChangePassword: _isEdit ? widget.initialUser!.mustChangePassword : true,
      createdAt: widget.initialUser?.createdAt ?? DateTime.now(),
    );

    widget.onSave(user);
  }

  @override
  Widget build(BuildContext context) {
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
                  const Icon(Icons.person, size: 70),
                  const SizedBox(height: 12),
                  Text(
                    _isEdit ? 'Edit User' : 'Add User',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _fullNameController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) return 'Enter full name';
              if (value.trim().length < 3) return 'Minimum 3 characters';
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _usernameController,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: 'Username',
              prefixIcon: const Icon(Icons.account_circle),
              suffixIcon: _isEdit
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.auto_fix_high_outlined),
                      tooltip: 'Suggest from name',
                      onPressed: widget.isLoading ? null : _generateUsername,
                    ),
              border: const OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) return 'Enter username';
              if (value.length < 4) return 'Minimum 4 characters';
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: _isEdit ? 'Password' : 'Temporary Password',
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  if (!_isEdit)
                    IconButton(
                      icon: const Icon(Icons.casino_outlined),
                      tooltip: 'Generate temporary password',
                      onPressed: widget.isLoading ? null : _generatePassword,
                    ),
                ],
              ),
              border: const OutlineInputBorder(),
              helperText: _isEdit ? null : 'Employee will be required to change this on first login',
              helperMaxLines: 2,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Enter password';

              // Only enforce the strong-password policy for brand new
              // accounts — retroactively rejecting an existing user's
              // already-set password on an unrelated edit would be a
              // surprising way to fail a save.
              if (!_isEdit) {
                return CredentialHelper.validateStrength(value);
              }

              if (value.length < 6) return 'Minimum 6 characters';
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
            items: _roles.map((role) => DropdownMenuItem(value: role, child: Text(role))).toList(),
            onChanged: widget.isLoading
                ? null
                : (value) {
                    if (value == null) return;
                    setState(() => _selectedRole = value);
                  },
            validator: (value) {
              if (value == null || value.isEmpty) return 'Select role';
              return null;
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _selectedDepartment,
            decoration: const InputDecoration(
              labelText: 'Department (optional)',
              prefixIcon: Icon(Icons.meeting_room_outlined),
              border: OutlineInputBorder(),
            ),
            items: _departments
                .map((dept) => DropdownMenuItem(value: dept, child: Text(dept)))
                .toList(),
            onChanged: widget.isLoading
                ? null
                : (value) => setState(() => _selectedDepartment = value),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<int>(
            initialValue: _branches.any((b) => b.id == _selectedBranchId) ? _selectedBranchId : null,
            decoration: const InputDecoration(
              labelText: 'Branch (optional)',
              prefixIcon: Icon(Icons.storefront_outlined),
              border: OutlineInputBorder(),
            ),
            items: _branches
                .map((branch) => DropdownMenuItem(value: branch.id, child: Text(branch.name)))
                .toList(),
            onChanged: widget.isLoading
                ? null
                : (value) {
                    final branch = _branches.where((b) => b.id == value);
                    setState(() {
                      _selectedBranchId = value;
                      _selectedBranchName = branch.isEmpty ? null : branch.first.name;
                    });
                  },
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 0,
            child: SwitchListTile(
              value: _isActive,
              title: const Text('Active User'),
              subtitle: Text(_isActive ? 'User can login' : 'User cannot login'),
              secondary: Icon(_isActive ? Icons.check_circle : Icons.cancel),
              onChanged: widget.isLoading
                  ? null
                  : (value) => setState(() => _isActive = value),
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
                      : Icon(_isEdit ? Icons.save : Icons.person_add),
                  label: Text(_isEdit ? 'Save Changes' : 'Create User'),
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
