import '../../database/database_service.dart';

// ===========================================================
// AKS MediCare Pro
// ID / Code Generator Helper
//
// Generates sequential, human-readable IDs used across the
// app (Patient UHID, and future Invoice No, Admission No, etc.)
// ===========================================================

class IdHelper {
  IdHelper._();

  static final DatabaseService _database = DatabaseService.instance;

  /// Generate a Unique Health ID (UHID) for patient registration.
  ///
  /// Format: AKS-YY-000001 (two-digit year, six-digit sequence)
  /// Example: AKS-26-000001
  static Future<String> generateUHID() async {
    final year = DateTime.now().year.toString().substring(2);

    String uhid;
    int attempt = 0;

    do {
      final total = await _patientCount();
      final sequence = (total + 1 + attempt).toString().padLeft(6, '0');

      uhid = 'AKS-$year-$sequence';
      attempt++;
    } while (await _uhidExists(uhid));

    return uhid;
  }

  static Future<int> _patientCount() async {
    final result = await _database.rawQuery(
      'SELECT COUNT(*) as total FROM patients',
    );

    return (result.first['total'] as int?) ?? 0;
  }

  static Future<bool> _uhidExists(String uhid) async {
    final result = await _database.rawQuery(
      'SELECT id FROM patients WHERE uhid = ? LIMIT 1',
      [uhid],
    );

    return result.isNotEmpty;
  }
}
