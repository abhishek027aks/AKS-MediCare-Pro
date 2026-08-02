// ===========================================================
// AKS MediCare Pro
// Inventory Helper
//
// Shared lookup lists used across the General Inventory module
// (equipment, furniture, IT assets — non-pharmacy items).
// ===========================================================

class InventoryHelper {
  InventoryHelper._();

  static const List<String> categories = [
    'Medical Equipment',
    'Furniture',
    'IT Equipment',
    'Surgical Instruments',
    'Office Supplies',
    'Linen',
    'Other',
  ];

  static const List<String> units = [
    'Piece',
    'Set',
    'Box',
    'Pair',
    'Unit',
  ];

  static const List<String> conditions = [
    'New',
    'Good',
    'Fair',
    'Needs Repair',
    'Damaged',
  ];

  static const List<String> departments = [
    'General Ward',
    'ICU',
    'OPD',
    'Emergency',
    'Operation Theatre',
    'Laboratory',
    'Pharmacy',
    'Administration',
    'Reception',
    'Other',
  ];
}
