// ===========================================================
// AKS MediCare Pro
// Validators
// ===========================================================

class AppValidators {
  AppValidators._();

  /// Required Field
  static String? requiredField(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Mobile Number
  static String? mobile(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Mobile number is required';
    }

    final regex = RegExp(r'^[6-9]\d{9}$');

    if (!regex.hasMatch(value.trim())) {
      return 'Enter a valid mobile number';
    }

    return null;
  }

  /// Email
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    final regex = RegExp(
      r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$',
    );

    if (!regex.hasMatch(value.trim())) {
      return 'Enter a valid email';
    }

    return null;
  }

  /// Password
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  /// Age
  static String? age(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Age is required';
    }

    final age = int.tryParse(value);

    if (age == null) {
      return 'Invalid age';
    }

    if (age < 0 || age > 120) {
      return 'Age must be between 0 and 120';
    }

    return null;
  }
}