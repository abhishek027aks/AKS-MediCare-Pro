import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

import '../../../../database/database_service.dart';
import '../../models/login_history_model.dart';

class LoginHistoryRepository {
  LoginHistoryRepository._();

  static final LoginHistoryRepository instance = LoginHistoryRepository._();

  static const String _table = 'login_history';

  final DatabaseService _database = DatabaseService.instance;

  static String get currentDeviceLabel {
    if (kIsWeb) return 'Web';
    try {
      return Platform.operatingSystem;
    } catch (_) {
      return 'Unknown';
    }
  }

  /// Records one login attempt. Called for both successes and
  /// failures — a failed attempt has no [userId]/[userName]/[role]
  /// since there's no authenticated user to attach it to.
  Future<void> recordAttempt({
    required String usernameAttempted,
    int? userId,
    String? userName,
    String? role,
    required bool success,
  }) async {
    try {
      await _database.insert(_table, {
        'username_attempted': usernameAttempted,
        'user_id': userId,
        'user_name': userName,
        'role': role,
        'device': currentDeviceLabel,
        'status': success ? 'Success' : 'Failed',
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (_) {
      // Never let login-history logging break the actual login flow.
    }
  }

  Future<List<LoginHistoryModel>> getAllHistory({int limit = 500}) async {
    final result = await _database.rawQuery(
      'SELECT * FROM $_table ORDER BY timestamp DESC LIMIT ?',
      [limit],
    );
    return result.map(LoginHistoryModel.fromMap).toList();
  }
}
