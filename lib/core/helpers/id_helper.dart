import '../../database/database_service.dart';

// ===========================================================
// AKS MediCare Pro
// ID / Code Generator Helper
//
// Generates sequential, human-readable document numbers used
// across the app: Patient UHID, OPD Visit No, IPD Admission No,
// Invoice No, etc.
// ===========================================================

class IdHelper {
  IdHelper._();

  static final DatabaseService _database = DatabaseService.instance;

  /// Generate a Unique Health ID (UHID) for patient registration.
  ///
  /// Format: AKS-YY-000001 (two-digit year, six-digit sequence)
  /// Example: AKS-26-000001
  static Future<String> generateUHID() {
    return _generateSequentialId(
      prefix: 'AKS',
      table: 'patients',
      column: 'uhid',
    );
  }

  /// Generate an OPD Visit Number.
  ///
  /// Format: OPD-YY-000001
  static Future<String> generateVisitNumber() {
    return _generateSequentialId(
      prefix: 'OPD',
      table: 'opd_visits',
      column: 'visit_no',
    );
  }

  /// Generate an IPD Admission Number.
  ///
  /// Format: IPD-YY-000001
  static Future<String> generateAdmissionNumber() {
    return _generateSequentialId(
      prefix: 'IPD',
      table: 'ipd_admissions',
      column: 'admission_no',
    );
  }

  /// Generate a Billing Invoice Number.
  ///
  /// Format: INV-YY-000001
  static Future<String> generateInvoiceNumber() {
    return _generateSequentialId(
      prefix: 'INV',
      table: 'bills',
      column: 'invoice_no',
    );
  }

  /// Generate a Laboratory Test Number.
  ///
  /// Format: LAB-YY-000001
  static Future<String> generateTestNumber() {
    return _generateSequentialId(
      prefix: 'LAB',
      table: 'lab_tests',
      column: 'test_no',
    );
  }

  /// Generic sequential ID generator shared by every module.
  ///
  /// Queries the row count of [table] to derive the next sequence
  /// number, then defensively checks [column] for uniqueness before
  /// returning (regenerating on a collision, e.g. after a deletion).
  static Future<String> _generateSequentialId({
    required String prefix,
    required String table,
    required String column,
  }) async {
    final year = DateTime.now().year.toString().substring(2);

    String id;
    int attempt = 0;

    do {
      final total = await _rowCount(table);
      final sequence = (total + 1 + attempt).toString().padLeft(6, '0');

      id = '$prefix-$year-$sequence';
      attempt++;
    } while (await _valueExists(table, column, id));

    return id;
  }

  static Future<int> _rowCount(String table) async {
    final result = await _database.rawQuery(
      'SELECT COUNT(*) as total FROM $table',
    );

    return (result.first['total'] as int?) ?? 0;
  }

  static Future<bool> _valueExists(
    String table,
    String column,
    String value,
  ) async {
    final result = await _database.rawQuery(
      'SELECT id FROM $table WHERE $column = ? LIMIT 1',
      [value],
    );

    return result.isNotEmpty;
  }
}
