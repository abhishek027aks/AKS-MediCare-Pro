// ===========================================================
// AKS MediCare Pro
// Billing Helper
//
// Shared lookup lists used across the Billing module.
// ===========================================================

class BillingHelper {
  BillingHelper._();

  static const List<String> billTypes = [
    'OPD',
    'IPD',
    'Pharmacy',
    'Laboratory',
    'Other',
  ];

  static const List<String> paymentModes = [
    'Cash',
    'Card',
    'UPI',
    'Insurance',
    'Other',
  ];

  /// Payment status is derived on BillModel (paidAmount vs
  /// totalAmount) rather than stored as free-form input — this list
  /// is kept only for filter chips in the list screen.
  static const List<String> paymentStatuses = [
    'Paid',
    'Partial',
    'Unpaid',
  ];
}
