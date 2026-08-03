// ===========================================================
// AKS MediCare Pro
// Permission Helper
//
// The list of modules covered by the Roles & Permissions
// matrix, and the default permission set generated for each
// role the first time the app runs.
// ===========================================================

import 'role_helper.dart';

class PermissionHelper {
  PermissionHelper._();

  static const List<String> modules = [
    'Patients',
    'Appointments',
    'OPD',
    'IPD',
    'Laboratory',
    'Pharmacy',
    'Billing',
    'Inventory',
    'HR',
    'Staff',
    'Reports',
    'Users',
    'Settings',
  ];

  /// Generates a full default permission set (every role × every
  /// module) the first time the app runs. Hospital Head and
  /// Administrator get full access everywhere; every other role
  /// gets a reasonable starting point for their day-to-day modules
  /// and nothing elsewhere. All of this is editable afterward from
  /// the Roles & Permissions screen — these are just sane defaults,
  /// not a hard-coded policy.
  static List<Map<String, dynamic>> generateDefaults() {
    const roleModuleAccess = <String, List<String>>{
      RoleHelper.doctor: ['Patients', 'Appointments', 'OPD', 'IPD', 'Laboratory'],
      RoleHelper.nurse: ['Patients', 'Appointments', 'OPD', 'IPD'],
      RoleHelper.pharmacist: ['Patients', 'Pharmacy'],
      RoleHelper.labTechnician: ['Patients', 'Laboratory'],
      RoleHelper.radiologist: ['Patients', 'Laboratory'],
      RoleHelper.accountant: ['Patients', 'Billing', 'Reports'],
      RoleHelper.receptionist: ['Patients', 'Appointments', 'OPD', 'Billing'],
      RoleHelper.storeManager: ['Pharmacy', 'Inventory'],
      RoleHelper.emergencyDesk: ['Patients', 'OPD', 'IPD'],
      RoleHelper.itAdministrator: ['Users', 'Settings'],
    };

    final rows = <Map<String, dynamic>>[];

    for (final role in RoleHelper.allRoles) {
      final isFullAccess = RoleHelper.isPrivileged(role);
      final accessibleModules = roleModuleAccess[role] ?? const [];

      for (final module in modules) {
        final hasAccess = isFullAccess || accessibleModules.contains(module);

        // Delete and Approve stay off by default for every non-privileged
        // role, even on modules they otherwise have access to — those
        // actions are meant to be switched on deliberately per hospital
        // policy, not assumed. Receptionist doesn't get direct delete on
        // Patients even though they can view/add/edit it — that's what
        // the Delete Request workflow is for.
        rows.add({
          'role': role,
          'module': module,
          'can_view': hasAccess,
          'can_add': hasAccess,
          'can_edit': hasAccess,
          'can_delete': isFullAccess,
          'can_approve': isFullAccess,
        });
      }
    }

    return rows;
  }
}
