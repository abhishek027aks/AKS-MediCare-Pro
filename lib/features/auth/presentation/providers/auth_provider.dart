import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/auth_state_model.dart';
import '../../data/repositories/auth_repository.dart';

/// ------------------------------------------------------------
/// Auth Provider
/// ------------------------------------------------------------

final authProvider =
    StateNotifierProvider<AuthNotifier, AuthStateModel>(
  (ref) => AuthNotifier(),
);

class AuthNotifier extends StateNotifier<AuthStateModel> {
  AuthNotifier()
      : _repository = AuthRepository.instance,
        super(AuthStateModel.initial());

  final AuthRepository _repository;

  /// -------------------------------
  /// Login
  /// -------------------------------
  Future<bool> login({
    required String username,
    required String password,
  }) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: '',
    );

    try {
      final user = await _repository.login(
        username: username,
        password: password,
      );

      if (user == null) {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: false,
          errorMessage: 'Invalid username or password.',
          clearUser: true,
          clearSession: true,
        );

        return false;
      }

      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: user,
        errorMessage: '',
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        errorMessage: e.toString(),
      );

      return false;
    }
  }

  /// -------------------------------
  /// Restore Session
  /// -------------------------------
  Future<void> restoreSession() async {
    final restored =
        await _repository.restoreSession();

    if (!restored) {
      state = AuthStateModel.initial();
      return;
    }

    final user =
        await _repository.getCurrentUser();

    state = state.copyWith(
      isAuthenticated: true,
      user: user,
      errorMessage: '',
    );
  }

  /// -------------------------------
  /// Logout
  /// -------------------------------
  Future<void> logout() async {
    await _repository.clearSession();

    state = AuthStateModel.initial();
  }

  /// -------------------------------
  /// Refresh User
  /// -------------------------------
  Future<void> refreshUser() async {
    final user =
        await _repository.getCurrentUser();

    state = state.copyWith(
      user: user,
    );
  }
}
