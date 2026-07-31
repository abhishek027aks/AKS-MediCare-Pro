import 'dart:convert';

import 'session_model.dart';
import '../../../user_management/models/user_model.dart';

/// ------------------------------------------------------------
/// AuthStateModel
/// ------------------------------------------------------------
/// Represents the current authentication state of the application.
/// ------------------------------------------------------------
class AuthStateModel {
  final bool isAuthenticated;
  final bool isLoading;
  final String errorMessage;
  final UserModel? user;
  final SessionModel? session;

  const AuthStateModel({
    required this.isAuthenticated,
    required this.isLoading,
    required this.errorMessage,
    this.user,
    this.session,
  });

  /// Initial state
  factory AuthStateModel.initial() {
    return const AuthStateModel(
      isAuthenticated: false,
      isLoading: false,
      errorMessage: '',
      user: null,
      session: null,
    );
  }

  /// CopyWith
  AuthStateModel copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? errorMessage,
    UserModel? user,
    SessionModel? session,
    bool clearUser = false,
    bool clearSession = false,
  }) {
    return AuthStateModel(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      user: clearUser ? null : (user ?? this.user),
      session: clearSession ? null : (session ?? this.session),
    );
  }

  /// Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'isAuthenticated': isAuthenticated,
      'isLoading': isLoading,
      'errorMessage': errorMessage,
      'user': user?.toMap(),
      'session': session?.toMap(),
    };
  }

  /// Create from Map
  factory AuthStateModel.fromMap(Map<String, dynamic> map) {
    return AuthStateModel(
      isAuthenticated: map['isAuthenticated'] ?? false,
      isLoading: map['isLoading'] ?? false,
      errorMessage: map['errorMessage'] ?? '',
      user: map['user'] != null
          ? UserModel.fromMap(map['user'] as Map<String, dynamic>)
          : null,
      session: map['session'] != null
          ? SessionModel.fromMap(map['session'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Convert to JSON
  String toJson() => jsonEncode(toMap());

  /// Create from JSON
  factory AuthStateModel.fromJson(String source) {
    return AuthStateModel.fromMap(
      jsonDecode(source) as Map<String, dynamic>,
    );
  }

  @override
  String toString() {
    return 'AuthStateModel(isAuthenticated: $isAuthenticated, isLoading: $isLoading)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AuthStateModel &&
            runtimeType == other.runtimeType &&
            isAuthenticated == other.isAuthenticated &&
            isLoading == other.isLoading &&
            errorMessage == other.errorMessage &&
            user == other.user &&
            session == other.session;
  }

  @override
  int get hashCode => Object.hash(
        isAuthenticated,
        isLoading,
        errorMessage,
        user,
        session,
      );
}
