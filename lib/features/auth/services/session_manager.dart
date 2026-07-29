import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../data/models/user_model.dart';

class SessionManager {
  SessionManager._();

  static final SessionManager instance = SessionManager._();

  static const String _userKey = 'current_user';
  static const String _loginKey = 'is_logged_in';

  /// Save logged in user
  Future<void> saveSession(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_loginKey, true);
    await prefs.setString(
      _userKey,
      jsonEncode(user.toMap()),
    );
  }

  /// Restore logged in user
  Future<UserModel?> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();

    final isLoggedIn =
        prefs.getBool(_loginKey) ?? false;

    if (!isLoggedIn) {
      return null;
    }

    final json = prefs.getString(_userKey);

    if (json == null || json.isEmpty) {
      return null;
    }

    return UserModel.fromMap(
      Map<String, dynamic>.from(
        jsonDecode(json),
      ),
    );
  }

  /// Check login status
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getBool(_loginKey) ?? false;
  }

  /// Get current user
  Future<UserModel?> getCurrentUser() async {
    return restoreSession();
  }

  /// Logout
  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_loginKey);
    await prefs.remove(_userKey);
  }

  /// Save only login status
  Future<void> setLoginStatus(bool value) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_loginKey, value);
  }
}