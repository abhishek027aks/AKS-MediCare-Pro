import '../../user_management/models/user_model.dart';
import '../data/repositories/user_repository.dart';
import 'session_manager.dart';

class AuthenticationService {
  AuthenticationService._();

  static final AuthenticationService instance =
      AuthenticationService._();

  final UserRepository _repository =
      UserRepository.instance;

  final SessionManager _session =
      SessionManager.instance;

  UserModel? _currentUser;

  /// ==========================
  /// CURRENT USER
  /// ==========================

  UserModel? get currentUser => _currentUser;

  bool get isLoggedIn => _currentUser != null;

  /// ==========================
  /// LOGIN
  /// ==========================

  Future<UserModel?> login({
    required String username,
    required String password,
  }) async {
    final user = await _repository.login(
      username: username,
      password: password,
    );

    if (user != null) {
      _currentUser = user;
      await _session.saveSession(user);
    }

    return user;
  }

  /// ==========================
  /// LOGOUT
  /// ==========================

  Future<void> logout() async {
    _currentUser = null;
    await _session.clearSession();
  }

  /// ==========================
  /// RESTORE SESSION
  /// ==========================

  Future<bool> restoreSession() async {
    final user = await _session.restoreSession();

    if (user != null) {
      _currentUser = user;
      return true;
    }

    return false;
  }

  /// ==========================
  /// CLEAR SESSION
  /// ==========================

  Future<void> clearSession() async {
    _currentUser = null;
    await _session.clearSession();
  }

  /// ==========================
  /// REGISTER USER
  /// ==========================

  Future<int> registerUser(
    UserModel user,
  ) {
    return _repository.createUser(user);
  }

  /// ==========================
  /// USER EXISTS
  /// ==========================

  Future<bool> userExists(
    String username,
  ) {
    return _repository.userExists(username);
  }

  /// ==========================
  /// CHANGE PASSWORD
  /// ==========================

  Future<int> changePassword({
    required int userId,
    required String password,
  }) {
    return _repository.changePassword(
      userId: userId,
      password: password,
    );
  }

  /// ==========================
  /// UPDATE USER
  /// ==========================

  Future<int> updateUser(
    UserModel user,
  ) {
    return _repository.updateUser(user);
  }

  /// ==========================
  /// DELETE USER
  /// ==========================

  Future<int> deleteUser(
    int id,
  ) {
    return _repository.deleteUser(id);
  }

  /// ==========================
  /// GET USER BY ID
  /// ==========================

  Future<UserModel?> getUserById(
    int id,
  ) {
    return _repository.getUserById(id);
  }

  /// ==========================
  /// GET USER BY USERNAME
  /// ==========================

  Future<UserModel?> getUserByUsername(
    String username,
  ) {
    return _repository.getUserByUsername(
      username,
    );
  }

  /// ==========================
  /// GET ALL USERS
  /// ==========================

  Future<List<UserModel>> getAllUsers() {
    return _repository.getAllUsers();
  }

  /// ==========================
  /// USER STATUS
  /// ==========================

  Future<int> setUserStatus({
    required int userId,
    required bool isActive,
  }) {
    return _repository.setUserStatus(
      userId: userId,
      isActive: isActive,
    );
  }
}