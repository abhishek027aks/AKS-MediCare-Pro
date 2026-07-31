import 'package:intl/intl.dart';

// ===========================================================
// AKS MediCare Pro
// Date Helper
// ===========================================================

class AppDateHelper {
  AppDateHelper._();

  static const String displayFormat = 'dd/MM/yyyy';
  static const String displayDateTimeFormat = 'dd/MM/yyyy hh:mm a';

  /// Format a DateTime for display (dd/MM/yyyy)
  static String formatDate(DateTime date) {
    return DateFormat(displayFormat).format(date);
  }

  /// Format a DateTime with time (dd/MM/yyyy hh:mm a)
  static String formatDateTime(DateTime date) {
    return DateFormat(displayDateTimeFormat).format(date);
  }

  /// Calculate age (in completed years) from date of birth
  static int calculateAge(DateTime dateOfBirth) {
    final today = DateTime.now();

    int age = today.year - dateOfBirth.year;

    final hasHadBirthdayThisYear = (today.month > dateOfBirth.month) ||
        (today.month == dateOfBirth.month && today.day >= dateOfBirth.day);

    if (!hasHadBirthdayThisYear) {
      age--;
    }

    return age < 0 ? 0 : age;
  }

  /// Human readable age label, e.g. "32 Y"
  static String formatAge(DateTime dateOfBirth) {
    return '${calculateAge(dateOfBirth)} Y';
  }
}
