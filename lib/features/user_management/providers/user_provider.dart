import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/data/repositories/user_repository.dart';
import '../models/user_model.dart';

/// ===============================
/// User State
/// ===============================
class UserState {
  final bool isLoading;
  final List<UserModel> users;
  final String? errorMessage;

  const UserState({
    this.isLoading = false,
    this.users = const [],
    this.errorMessage,
  });

  UserState copyWith({
    bool? isLoading,
    List<UserModel>? users,
    String? errorMessage,
  }) {
    return UserState(
      isLoading: isLoading ?? this.isLoading,
      users: users ?? this.users,
      errorMessage: errorMessage,
    );
  }
}

/// ===============================
/// User Provider
/// ===============================
class UserNotifier extends StateNotifier<UserState> {
  UserNotifier() : super(const UserState()) {
    loadUsers();
  }

  final UserRepository _repository =
      UserRepository.instance;

  /// Load Users
  Future<void> loadUsers() async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
    );

    try {
      final users =
          await _repository.getAllUsers();

      state = state.copyWith(
        isLoading: false,
        users: users,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Add User
  Future<bool> addUser(
    UserModel user,
  ) async {
    try {
      await _repository.createUser(user);
      await loadUsers();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Update User
  Future<bool> updateUser(
    UserModel user,
  ) async {
    try {
      await _repository.updateUser(user);
      await loadUsers();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Delete User
  Future<bool> deleteUser(
    int id,
  ) async {
    try {
      await _repository.deleteUser(id);
      await loadUsers();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Refresh
  Future<void> refresh() async {
    await loadUsers();
  }
}

/// ===============================
/// Riverpod Provider
/// ===============================
final userProvider =
    StateNotifierProvider<UserNotifier, UserState>(
  (ref) => UserNotifier(),
);