import 'package:flutter/material.dart';

class SnackbarService {
  SnackbarService._();

  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static void hide() {
    messengerKey.currentState?.hideCurrentSnackBar();
  }

  static void showSuccess(String message) {
    _show(
      message: message,
      backgroundColor: Colors.green,
      icon: Icons.check_circle,
    );
  }

  static void showError(String message) {
    _show(
      message: message,
      backgroundColor: Colors.red,
      icon: Icons.error,
    );
  }

  static void showWarning(String message) {
    _show(
      message: message,
      backgroundColor: Colors.orange,
      icon: Icons.warning,
    );
  }

  static void showInfo(String message) {
    _show(
      message: message,
      backgroundColor: Colors.blue,
      icon: Icons.info,
    );
  }

  static void _show({
    required String message,
    required Color backgroundColor,
    required IconData icon,
  }) {
    messengerKey.currentState?.hideCurrentSnackBar();

    messengerKey.currentState?.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 3),
        content: Row(
          children: [
            Icon(
              icon,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}