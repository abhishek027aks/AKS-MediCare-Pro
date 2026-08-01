import '../../../../database/database_service.dart';
import '../../models/bill_model.dart';

class BillingRepository {
  BillingRepository._();

  static final BillingRepository instance = BillingRepository._();

  static const String _table = 'bills';

  final DatabaseService _database = DatabaseService.instance;

  // ============================
  // CREATE BILL
  // ============================

  Future<int> createBill(BillModel bill) async {
    try {
      return await _database.insert(_table, bill.toMap());
    } catch (e) {
      throw Exception('Failed to create bill: $e');
    }
  }

  // ============================
  // GET ALL BILLS
  // ============================

  Future<List<BillModel>> getAllBills() async {
    try {
      final result = await _database.rawQuery(
        'SELECT * FROM $_table ORDER BY bill_date DESC',
      );

      return result.map(BillModel.fromMap).toList();
    } catch (e) {
      throw Exception('Failed to load bills: $e');
    }
  }

  // ============================
  // GET BILLS FOR A PATIENT
  // ============================

  Future<List<BillModel>> getBillsForPatient(int patientId) async {
    try {
      final result = await _database.rawQuery(
        '''
        SELECT *
        FROM $_table
        WHERE patient_id = ?
        ORDER BY bill_date DESC
        ''',
        [patientId],
      );

      return result.map(BillModel.fromMap).toList();
    } catch (e) {
      throw Exception('Failed to load patient bills: $e');
    }
  }

  // ============================
  // SEARCH BILLS
  // ============================

  Future<List<BillModel>> searchBills(String query) async {
    try {
      final result = await _database.rawQuery(
        '''
        SELECT *
        FROM $_table
        WHERE patient_name LIKE ?
        OR patient_uhid LIKE ?
        OR invoice_no LIKE ?
        ORDER BY bill_date DESC
        ''',
        ['%$query%', '%$query%', '%$query%'],
      );

      return result.map(BillModel.fromMap).toList();
    } catch (e) {
      throw Exception('Failed to search bills: $e');
    }
  }

  // ============================
  // UPDATE BILL
  // ============================

  Future<int> updateBill(BillModel bill) async {
    if (bill.id == null) {
      throw Exception('Bill ID cannot be null.');
    }

    try {
      return await _database.update(_table, bill.toMap(), 'id = ?', [bill.id]);
    } catch (e) {
      throw Exception('Failed to update bill: $e');
    }
  }

  // ============================
  // DELETE BILL
  // ============================

  Future<int> deleteBill(int id) async {
    try {
      return await _database.delete(_table, 'id = ?', [id]);
    } catch (e) {
      throw Exception('Failed to delete bill: $e');
    }
  }

  // ============================
  // TOTAL COLLECTED (ALL TIME)
  // ============================

  Future<double> getTotalCollected() async {
    final result = await _database.rawQuery(
      'SELECT SUM(paid_amount) as total FROM $_table',
    );

    return (result.first['total'] as num?)?.toDouble() ?? 0;
  }

  // ============================
  // TOTAL OUTSTANDING (ALL TIME)
  // ============================

  Future<double> getTotalOutstanding() async {
    final result = await _database.rawQuery(
      'SELECT SUM(balance_amount) as total FROM $_table',
    );

    return (result.first['total'] as num?)?.toDouble() ?? 0;
  }
}
