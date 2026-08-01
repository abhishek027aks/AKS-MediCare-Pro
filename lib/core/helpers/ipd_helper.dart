// ===========================================================
// AKS MediCare Pro
// IPD Helper
//
// Shared lookup lists used across the IPD (Inpatient) module.
// ===========================================================

class IpdHelper {
  IpdHelper._();

  static const List<String> wards = [
    'General Ward',
    'Private Ward',
    'Semi-Private Ward',
    'ICU',
    'NICU',
    'Maternity Ward',
    'Emergency Ward',
  ];

  static const List<String> admissionTypes = [
    'Planned',
    'Emergency',
    'Referral',
  ];

  static const List<String> statuses = [
    'Admitted',
    'Discharged',
  ];
}
