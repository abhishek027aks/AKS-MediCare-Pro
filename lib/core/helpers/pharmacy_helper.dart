// ===========================================================
// AKS MediCare Pro
// Pharmacy Helper
//
// Shared lookup lists used across the Pharmacy (Inventory) module.
// ===========================================================

class PharmacyHelper {
  PharmacyHelper._();

  static const List<String> categories = [
    'Tablet',
    'Capsule',
    'Syrup',
    'Injection',
    'Ointment',
    'Drops',
    'Inhaler',
    'Surgical',
    'Other',
  ];

  static const List<String> units = [
    'Strip',
    'Bottle',
    'Box',
    'Vial',
    'Tube',
    'Piece',
  ];
}
