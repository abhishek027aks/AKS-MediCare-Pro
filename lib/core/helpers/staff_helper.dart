// ===========================================================
// AKS MediCare Pro
// Staff Helper
//
// Shared lookup lists used across the Doctor / Nursing
// (clinical staff profile) module.
// ===========================================================

class StaffHelper {
  StaffHelper._();

  static const List<String> departments = [
    'General Medicine',
    'Cardiology',
    'Orthopedics',
    'Pediatrics',
    'Gynecology',
    'Dermatology',
    'ENT',
    'Ophthalmology',
    'Neurology',
    'Emergency',
    'ICU',
    'Surgery',
    'Other',
  ];

  static const List<String> shiftTimings = [
    'Morning (8 AM - 2 PM)',
    'Evening (2 PM - 8 PM)',
    'Night (8 PM - 8 AM)',
    'Full Day (9 AM - 6 PM)',
    'Rotational',
  ];
}
