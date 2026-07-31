import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'authentication_service.dart';

class LogoutService {
  LogoutService._();

  static final LogoutService instance =
      LogoutService._();

  final AuthenticationService _auth =
      AuthenticationService.instance;

  Future<void> logout(
    BuildContext context,
  ) async {
    await _auth.logout();

    if (!context.mounted) {
      return;
    }

    context.go('/login');
  }
}
