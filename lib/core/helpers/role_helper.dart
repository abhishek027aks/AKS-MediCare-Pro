// ===========================================================
// AKS MediCare Pro
// Role Helper
//
// The canonical list of staff roles used across Role Selection,
// User Management, and the Roles & Permissions matrix. Keeping
// this in one place means every screen that lists roles stays
// in sync automatically.
// ===========================================================

class RoleHelper {
  RoleHelper._();

  static const String hospitalHead = 'Hospital Head';
  static const String administrator = 'Administrator';
  static const String doctor = 'Doctor';
  static const String nurse = 'Nurse';
  static const String pharmacist = 'Pharmacist';
  static const String labTechnician = 'Lab Technician';
  static const String radiologist = 'Radiologist';
  static const String accountant = 'Accountant';
  static const String receptionist = 'Receptionist';
  static const String storeManager = 'Store Manager';
  static const String emergencyDesk = 'Emergency Desk';
  static const String itAdministrator = 'IT Administrator';

  static const List<String> allRoles = [
    hospitalHead,
    administrator,
    doctor,
    nurse,
    pharmacist,
    labTechnician,
    radiologist,
    accountant,
    receptionist,
    storeManager,
    emergencyDesk,
    itAdministrator,
  ];

  /// Roles allowed to manage Users and the Roles & Permissions matrix.
  static const List<String> privilegedRoles = [hospitalHead, administrator];

  static bool isPrivileged(String? role) {
    if (role == null) return false;
    return privilegedRoles.contains(role);
  }
}
