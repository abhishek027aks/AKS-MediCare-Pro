import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/helpers/permission_helper.dart';
import '../../../core/helpers/role_helper.dart';
import '../models/permission_model.dart';
import '../providers/permission_provider.dart';

class PermissionsScreen extends ConsumerStatefulWidget {
  const PermissionsScreen({super.key});

  @override
  ConsumerState<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends ConsumerState<PermissionsScreen> {
  String _selectedRole = RoleHelper.doctor;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(permissionMatrixProvider);

    final rolePermissions = {
      for (final p in state.permissions.where((p) => p.role == _selectedRole)) p.module: p,
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Roles & Permissions')),
      body: Column(
        children: [
          if (state.isLoading) const LinearProgressIndicator(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<String>(
              initialValue: _selectedRole,
              decoration: const InputDecoration(
                labelText: 'Role',
                prefixIcon: Icon(Icons.badge_outlined),
                border: OutlineInputBorder(),
              ),
              items: RoleHelper.allRoles
                  .map((role) => DropdownMenuItem(value: role, child: Text(role)))
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() => _selectedRole = value);
              },
            ),
          ),
          if (RoleHelper.isPrivileged(_selectedRole))
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                color: Colors.blue.withValues(alpha: 0.08),
                elevation: 0,
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'This role always has full access — permissions here are informational and cannot be reduced.',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: PermissionHelper.modules.map((module) {
                final permission = rolePermissions[module];

                if (permission == null) {
                  return const SizedBox.shrink();
                }

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(module, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        ),
                        Wrap(
                          spacing: 4,
                          children: [
                            _permissionChip(
                              label: 'View',
                              value: permission.canView,
                              onChanged: (v) => _update(permission.copyWith(canView: v)),
                            ),
                            _permissionChip(
                              label: 'Add',
                              value: permission.canAdd,
                              onChanged: (v) => _update(permission.copyWith(canAdd: v)),
                            ),
                            _permissionChip(
                              label: 'Edit',
                              value: permission.canEdit,
                              onChanged: (v) => _update(permission.copyWith(canEdit: v)),
                            ),
                            _permissionChip(
                              label: 'Delete',
                              value: permission.canDelete,
                              onChanged: (v) => _update(permission.copyWith(canDelete: v)),
                            ),
                            _permissionChip(
                              label: 'Approve',
                              value: permission.canApprove,
                              onChanged: (v) => _update(permission.copyWith(canApprove: v)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _permissionChip({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final locked = RoleHelper.isPrivileged(_selectedRole);

    return FilterChip(
      label: Text(label),
      selected: value,
      onSelected: locked ? null : onChanged,
      selectedColor: Colors.green.withValues(alpha: 0.2),
      checkmarkColor: Colors.green,
    );
  }

  Future<void> _update(PermissionModel updated) async {
    await ref.read(permissionMatrixProvider.notifier).updatePermission(updated);
  }
}
