import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../user_management/models/user_model.dart';
import '../../services/authentication_service.dart';

/// ===============================
/// Login State
/// ===============================
class LoginState {
  final bool isLoading;
  final bool isLoggedIn;
  final String? errorMessage;
  final UserModel? user;

  const LoginState({
    this.isLoading = false,
    this.isLoggedIn = false,
    this.errorMessage,
    this.user,
  });

  LoginState copyWith({
    bool? isLoading,
    bool? isLoggedIn,
    String? errorMessage,
    UserModel? user,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      errorMessage: errorMessage,
      user: user ?? this.user,
    );
  }
}

/// ===============================
/// Login Provider
/// ===============================
class LoginNotifier extends StateNotifier<LoginState> {
  LoginNotifier() : super(const LoginState());

  final AuthenticationService _auth =
      AuthenticationService.instance;

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
    );

    try {
      if (username.trim().isEmpty) {
        throw Exception('Username is required');
      }

      if (password.trim().isEmpty) {
        throw Exception('Password is required');
      }

      final user = await _auth.login(
        username: username.trim(),
        password: password,
      );

      if (user == null) {
        state = state.copyWith(
          isLoading: false,
          isLoggedIn: false,
          errorMessage: 'Invalid username or password',
        );

        return false;
      }

      state = state.copyWith(
        isLoading: false,
        isLoggedIn: true,
        user: user,
        errorMessage: null,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoggedIn: false,
        errorMessage: e.toString(),
      );

      return false;
    }
  }

  Future<void> logout() async {
    await _auth.logout();

    state = const LoginState();
  }

  void clearError() {
    state = state.copyWith(
      errorMessage: null,
    );
  }
}

/// ===============================
/// Riverpod Provider
/// ===============================
final loginProvider =
    StateNotifierProvider<LoginNotifier, LoginState>(
  (ref) => LoginNotifier(),
);