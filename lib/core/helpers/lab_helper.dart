// ===========================================================
// AKS MediCare Pro
// Lab Helper
//
// Shared lookup lists used across the Laboratory module.
// ===========================================================

class LabHelper {
  LabHelper._();

  static const List<String> testCategories = [
    'Hematology',
    'Biochemistry',
    'Microbiology',
    'Pathology',
    'Radiology',
    'Serology',
    'Other',
  ];

  static const List<String> sampleTypes = [
    'Blood',
    'Urine',
    'Stool',
    'Sputum',
    'Swab',
    'Tissue',
    'Other',
  ];

  static const List<String> statuses = [
    'Ordered',
    'Sample Collected',
    'In Progress',
    'Completed',
    'Cancelled',
  ];
}
