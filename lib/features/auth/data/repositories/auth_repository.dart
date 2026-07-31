import '../../../user_management/models/user_model.dart';
import '../../services/authentication_service.dart';
import '../../services/session_manager.dart';

/// ------------------------------------------------------------
/// AuthRepository
/// ------------------------------------------------------------
/// Wrapper repository for authentication-related operations.
///
/// NOTE:
/// This repository follows the existing singleton architecture
/// used throughout the project.
/// ------------------------------------------------------------
class AuthRepository {
  AuthRepository._();

  static final AuthRepository instance = AuthRepository._();

  final AuthenticationService _auth =
      AuthenticationService.instance;

  final SessionManager _session =
      SessionManager.instance;

  /// Login
  Future<UserModel?> login({
    required String username,
    required String password,
  }) async {
    return _auth.login(
      username: username,
      password: password,
    );
  }

  /// Logout
  Future<void> logout() async {
    await _auth.logout();
  }

  /// Restore Previous Session
  Future<bool> restoreSession() async {
    return _auth.restoreSession();
  }

  /// Clear Session
  Future<void> clearSession() async {
    await _auth.clearSession();
  }

  /// Check Login Status
  Future<bool> isLoggedIn() async {
    return _session.isLoggedIn();
  }

  /// Current Logged In User
  Future<UserModel?> getCurrentUser() async {
    return _session.getCurrentUser();
  }

  /// Authentication State
  bool get isAuthenticated =>
      _auth.isLoggedIn;

  /// Current User (Memory)
  UserModel? get currentUser =>
      _auth.currentUser;
}
