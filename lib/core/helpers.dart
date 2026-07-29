import 'package:intl/intl.dart';

/// ===========================================================
/// AKS MediCare Pro
/// Helper Methods
/// ===========================================================

class AppHelpers {
  AppHelpers._();

  /// Format Date
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  /// Format Date & Time
  static String formatDateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy hh:mm a').format(date);
  }

  /// Greeting
  static String greeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return 'Good Morning';
    }

    if (hour < 17) {
      return 'Good Afternoon';
    }

    return 'Good Evening';
  }

  /// Generate Patient ID
  static String generatePatientId(int id) {
    return 'PAT-${id.toString().padLeft(6, '0')}';
  }

  /// Generate Bill Number
  static String generateBillNo(int id) {
    return 'BILL-${id.toString().padLeft(6, '0')}';
  }

  /// Get Initials
  static String getInitials(String name) {
    if (name.trim().isEmpty) return '';

    final parts = name.trim().split(' ');

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return (parts.first.substring(0, 1) +
            parts.last.substring(0, 1))
        .toUpperCase();
  }
}