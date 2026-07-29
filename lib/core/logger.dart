import 'dart:developer' as developer;

/// ===========================================================
/// AKS MediCare Pro
/// Logger
/// ===========================================================

class AppLogger {
  AppLogger._();

  static const String _tag = 'AKS MediCare Pro';

  /// Debug Log
  static void debug(String message) {
    developer.log(
      message,
      name: _tag,
      level: 500,
    );
  }

  /// Information Log
  static void info(String message) {
    developer.log(
      message,
      name: _tag,
      level: 800,
    );
  }

  /// Warning Log
  static void warning(String message) {
    developer.log(
      message,
      name: _tag,
      level: 900,
    );
  }

  /// Error Log
  static void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    developer.log(
      message,
      name: _tag,
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
  }
}