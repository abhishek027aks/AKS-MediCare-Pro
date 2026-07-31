import '../../../user_management/models/user_model.dart';

class RoleGuard {
  RoleGuard._();

  /// Check if the user has the required role
  static bool hasRole(
    UserModel? user,
    String role,
  ) {
    if (user == null) {
      return false;
    }

    return user.role.toLowerCase() ==
        role.toLowerCase();
  }

  /// Admin
  static bool isAdmin(UserModel? user) {
    return hasRole(user, 'Admin');
  }

  /// Super Admin
  static bool isSuperAdmin(UserModel? user) {
    return hasRole(user, 'Super Admin');
  }

  /// Doctor
  static bool isDoctor(UserModel? user) {
    return hasRole(user, 'Doctor');
  }

  /// Receptionist
  static bool isReceptionist(UserModel? user) {
    return hasRole(user, 'Receptionist');
  }

  /// Pharmacist
  static bool isPharmacist(UserModel? user) {
    return hasRole(user, 'Pharmacist');
  }

  /// Lab Technician
  static bool isLabTechnician(UserModel? user) {
    return hasRole(user, 'Lab Technician');
  }

  /// Accountant
  static bool isAccountant(UserModel? user) {
    return hasRole(user, 'Accountant');
  }

  /// Multiple Roles
  static bool hasAnyRole(
    UserModel? user,
    List<String> roles,
  ) {
    if (user == null) {
      return false;
    }

    return roles.any(
      (role) =>
          role.toLowerCase() ==
          user.role.toLowerCase(),
    );
  }
}
