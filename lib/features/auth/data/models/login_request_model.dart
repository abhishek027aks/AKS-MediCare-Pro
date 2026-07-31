import 'dart:convert';

/// ------------------------------------------------------------
/// LoginRequestModel
/// ------------------------------------------------------------
/// Represents user login credentials.
///
/// Used by:
/// - AuthRepository
/// - AuthenticationService
/// - LoginProvider
/// ------------------------------------------------------------
class LoginRequestModel {
  final String username;
  final String password;
  final bool rememberMe;

  const LoginRequestModel({
    required this.username,
    required this.password,
    this.rememberMe = false,
  });

  /// Empty model
  factory LoginRequestModel.empty() {
    return const LoginRequestModel(
      username: '',
      password: '',
      rememberMe: false,
    );
  }

  /// Copy with
  LoginRequestModel copyWith({
    String? username,
    String? password,
    bool? rememberMe,
  }) {
    return LoginRequestModel(
      username: username ?? this.username,
      password: password ?? this.password,
      rememberMe: rememberMe ?? this.rememberMe,
    );
  }

  /// Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'password': password,
      'rememberMe': rememberMe,
    };
  }

  /// Create from Map
  factory LoginRequestModel.fromMap(Map<String, dynamic> map) {
    return LoginRequestModel(
      username: map['username'] ?? '',
      password: map['password'] ?? '',
      rememberMe: map['rememberMe'] ?? false,
    );
  }

  /// Convert to JSON
  String toJson() => jsonEncode(toMap());

  /// Create from JSON
  factory LoginRequestModel.fromJson(String source) =>
      LoginRequestModel.fromMap(
        jsonDecode(source) as Map<String, dynamic>,
      );

  @override
  String toString() {
    return 'LoginRequestModel(username: $username, rememberMe: $rememberMe)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is LoginRequestModel &&
            runtimeType == other.runtimeType &&
            username == other.username &&
            password == other.password &&
            rememberMe == other.rememberMe;
  }

  @override
  int get hashCode =>
      username.hashCode ^
      password.hashCode ^
      rememberMe.hashCode;
}
