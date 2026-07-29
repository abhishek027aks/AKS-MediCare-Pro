import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// ===========================================================
/// AKS MediCare Pro
/// Extensions
/// ===========================================================

extension StringExtension on String {
  /// Check Empty
  bool get isBlank => trim().isEmpty;

  /// Capitalize First Letter
  String get capitalize {
    if (trim().isEmpty) return '';

    return this[0].toUpperCase() + substring(1).toLowerCase();
  }
}

extension DateExtension on DateTime {
  /// Format Date
  String get formatDate {
    return DateFormat('dd/MM/yyyy').format(this);
  }

  /// Format Date Time
  String get formatDateTime {
    return DateFormat('dd/MM/yyyy hh:mm a').format(this);
  }
}

extension ContextExtension on BuildContext {
  ThemeData get theme => Theme.of(this);

  ColorScheme get colors => Theme.of(this).colorScheme;

  TextTheme get textTheme => Theme.of(this).textTheme;
}

extension NumberExtension on num {
  String get currency {
    return NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
    ).format(this);
  }
}