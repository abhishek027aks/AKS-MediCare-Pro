import '../../../../database/database_service.dart';
import '../models/user_model.dart';

class UserRepository {
  UserRepository._();

  static final UserRepository instance = UserRepository._();

  static const String _table = 'users';

  final DatabaseService _database = DatabaseService.instance;

  // ============================
  // CREATE USER
  // ============================

  Future<int> createUser(UserModel user) async {
    try {
      return await _database.insert(
        _table,
        user.toMap(),
      );
    } catch (e) {
      throw Exception(
        'Failed to create user: $e',
      );
    }
  }

  // ============================
  // GET ALL USERS
  // ============================

  Future<List<UserModel>> getAllUsers() async {
    try {
      final result = await _database.getAll(
        _table,
      );

      return result
          .map(UserModel.fromMap)
          .toList();
    } catch (e) {
      throw Exception(
        'Failed to load users: $e',
      );
    }
  }

  // ============================
  // GET USER BY ID
  // ============================

  Future<UserModel?> getUserById(
    int id,
  ) async {
    try {
      final result = await _database.getById(
        _table,
        'id',
        id,
      );

      if (result == null) {
        return null;
      }

      return UserModel.fromMap(result);
    } catch (e) {
      throw Exception(
        'Failed to get user: $e',
      );
    }
  }

  // ============================
  // GET USER BY USERNAME
  // ============================

  Future<UserModel?> getUserByUsername(
    String username,
  ) async {
    try {
      final result = await _database.rawQuery(
        '''
        SELECT *
        FROM $_table
        WHERE username = ?
        LIMIT 1
        ''',
        [username],
      );

      if (result.isEmpty) {
        return null;
      }

      return UserModel.fromMap(
        result.first,
      );
    } catch (e) {
      throw Exception(
        'Failed to find user: $e',
      );
    }
  }
    // ============================
  // LOGIN
  // ============================

  Future<UserModel?> login({
    required String username,
    required String password,
  }) async {
    try {
      final result = await _database.rawQuery(
        '''
        SELECT *
        FROM $_table
        WHERE username = ?
        AND password = ?
        AND is_active = 1
        LIMIT 1
        ''',
        [
          username,
          password,
        ],
      );

      if (result.isEmpty) {
        return null;
      }

      return UserModel.fromMap(result.first);
    } catch (e) {
      throw Exception(
        'Login failed: $e',
      );
    }
  }

  // ============================
  // USER EXISTS
  // ============================

  Future<bool> userExists(
    String username,
  ) async {
    final user = await getUserByUsername(
      username,
    );

    return user != null;
  }

  // ============================
  // UPDATE USER
  // ============================

  Future<int> updateUser(
    UserModel user,
  ) async {
    if (user.id == null) {
      throw Exception(
        'User ID cannot be null.',
      );
    }

    try {
      return await _database.update(
        _table,
        user.toMap(),
        'id = ?',
        [
          user.id,
        ],
      );
    } catch (e) {
      throw Exception(
        'Failed to update user: $e',
      );
    }
  }

  // ============================
  // DELETE USER
  // ============================

  Future<int> deleteUser(
    int id,
  ) async {
    try {
      return await _database.delete(
        _table,
        'id = ?',
        [id],
      );
    } catch (e) {
      throw Exception(
        'Failed to delete user: $e',
      );
    }
  }

  // ============================
  // CHANGE PASSWORD
  // ============================

  Future<int> changePassword({
    required int userId,
    required String password,
  }) async {
    try {
      return await _database.update(
        _table,
        {
          'password': password,
        },
        'id = ?',
        [
          userId,
        ],
      );
    } catch (e) {
      throw Exception(
        'Failed to change password: $e',
      );
    }
  }

  // ============================
  // ACTIVATE / DEACTIVATE USER
  // ============================

  Future<int> setUserStatus({
    required int userId,
    required bool isActive,
  }) async {
    try {
      return await _database.update(
        _table,
        {
          'is_active': isActive ? 1 : 0,
        },
        'id = ?',
        [
          userId,
        ],
      );
    } catch (e) {
      throw Exception(
        'Failed to update user status: $e',
      );
    }
  }
}