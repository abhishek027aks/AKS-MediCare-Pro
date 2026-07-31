// ===========================================================
// AKS MediCare Pro
// Patient Helper
//
// Shared lookup lists and display helpers used across the
// Patient Registration module.
// ===========================================================

class PatientHelper {
  PatientHelper._();

  static const List<String> genders = [
    'Male',
    'Female',
    'Other',
  ];

  static const List<String> bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
    'Unknown',
  ];

  static const List<String> maritalStatuses = [
    'Single',
    'Married',
    'Divorced',
    'Widowed',
  ];

  /// Initials used for CircleAvatar (e.g. "Ramesh Kumar" -> "RK")
  static String getInitials(String fullName) {
    final parts = fullName.trim().split(RegExp(r'\s+'));

    return parts
        .take(2)
        .map((e) => e.isNotEmpty ? e[0].toUpperCase() : '')
        .join();
  }

  /// Combined "Age / Gender" label, e.g. "32 Y / Male"
  static String genderAgeLabel(String gender, int age) {
    return '$age Y / $gender';
  }
}
