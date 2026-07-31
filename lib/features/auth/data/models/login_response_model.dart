import 'dart:convert';

import '../../../user_management/models/user_model.dart';

/// ------------------------------------------------------------
/// LoginResponseModel
/// ------------------------------------------------------------
/// Represents the response returned after user login.
/// ------------------------------------------------------------
class LoginResponseModel {
  final bool success;
  final String message;
  final String token;
  final DateTime loginTime;
  final UserModel? user;

  const LoginResponseModel({
    required this.success,
    required this.message,
    required this.token,
    required this.loginTime,
    this.user,
  });

  /// Empty Response
  factory LoginResponseModel.empty() {
    return LoginResponseModel(
      success: false,
      message: '',
      token: '',
      loginTime: DateTime.now(),
      user: null,
    );
  }

  /// CopyWith
  LoginResponseModel copyWith({
    bool? success,
    String? message,
    String? token,
    DateTime? loginTime,
    UserModel? user,
  }) {
    return LoginResponseModel(
      success: success ?? this.success,
      message: message ?? this.message,
      token: token ?? this.token,
      loginTime: loginTime ?? this.loginTime,
      user: user ?? this.user,
    );
  }

  /// To Map
  Map<String, dynamic> toMap() {
    return {
      'success': success,
      'message': message,
      'token': token,
      'loginTime': loginTime.toIso8601String(),
      'user': user?.toMap(),
    };
  }

  /// From Map
  factory LoginResponseModel.fromMap(Map<String, dynamic> map) {
    return LoginResponseModel(
      success: map['success'] ?? false,
      message: map['message'] ?? '',
      token: map['token'] ?? '',
      loginTime: DateTime.tryParse(map['loginTime'] ?? '') ?? DateTime.now(),
      user: map['user'] != null
          ? UserModel.fromMap(map['user'] as Map<String, dynamic>)
          : null,
    );
  }

  /// To JSON
  String toJson() => jsonEncode(toMap());

  /// From JSON
  factory LoginResponseModel.fromJson(String source) {
    return LoginResponseModel.fromMap(
      jsonDecode(source) as Map<String, dynamic>,
    );
  }

  @override
  String toString() {
    return 'LoginResponseModel(success: $success, message: $message, token: $token)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is LoginResponseModel &&
            runtimeType == other.runtimeType &&
            success == other.success &&
            message == other.message &&
            token == other.token &&
            loginTime == other.loginTime &&
            user == other.user;
  }

  @override
  int get hashCode {
    return success.hashCode ^
        message.hashCode ^
        token.hashCode ^
        loginTime.hashCode ^
        user.hashCode;
  }
}
