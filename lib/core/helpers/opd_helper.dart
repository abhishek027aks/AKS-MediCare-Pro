// ===========================================================
// AKS MediCare Pro
// OPD Helper
//
// Shared lookup lists used across the OPD (Outpatient) module.
// ===========================================================

class OpdHelper {
  OpdHelper._();

  static const List<String> visitTypes = [
    'New',
    'Follow-up',
  ];

  static const List<String> statuses = [
    'Waiting',
    'In Consultation',
    'Completed',
    'Cancelled',
  ];
}
