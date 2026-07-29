import 'package:intl/intl.dart';

/// ===========================================================
/// AKS MediCare Pro
/// Utility Functions
/// ===========================================================

class AppUtils {
  AppUtils._();

  /// Currency Formatter
  static String formatCurrency(num amount) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 2,
    );

    return formatter.format(amount);
  }

  /// Calculate Age
  static int calculateAge(DateTime birthDate) {
    final today = DateTime.now();

    int age = today.year - birthDate.year;

    if (today.month < birthDate.month ||
        (today.month == birthDate.month &&
            today.day < birthDate.day)) {
      age--;
    }

    return age;
  }

  /// Check Null or Empty
  static bool isNullOrEmpty(String? value) {
    return value == null || value.trim().isEmpty;
  }

  /// Capitalize First Letter
  static String capitalize(String text) {
    if (text.trim().isEmpty) {
      return '';
    }

    return text[0].toUpperCase() +
        text.substring(1).toLowerCase();
  }

  /// Mask Mobile Number
  static String maskMobile(String mobile) {
    if (mobile.length != 10) {
      return mobile;
    }

    return '${mobile.substring(0, 2)}******${mobile.substring(8)}';
  }

  /// Generate Timestamp
  static String timestamp() {
    return DateFormat(
      'yyyyMMddHHmmss',
    ).format(DateTime.now());
  }
}