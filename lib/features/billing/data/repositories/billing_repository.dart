import '../../../../database/database_service.dart';
import '../../../audit/data/repositories/audit_repository.dart';
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
      final id = await _database.insert(_table, bill.toMap());

      AuditRepository.instance.logAction(
        module: 'Billing',
        action: 'Create',
        description: 'Created bill ${bill.invoiceNo} for ${bill.patientName} (₹${bill.totalAmount.toStringAsFixed(2)})',
      );

      return id;
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
      final rows = await _database.update(_table, bill.toMap(), 'id = ?', [bill.id]);

      if (rows > 0) {
        AuditRepository.instance.logAction(
          module: 'Billing',
          action: 'Update',
          description: 'Updated bill ${bill.invoiceNo} for ${bill.patientName}',
        );
      }

      return rows;
    } catch (e) {
      throw Exception('Failed to update bill: $e');
    }
  }

  // ============================
  // DELETE BILL
  // ============================

  Future<int> deleteBill(int id) async {
    try {
      final rows = await _database.delete(_table, 'id = ?', [id]);

      if (rows > 0) {
        AuditRepository.instance.logAction(
          module: 'Billing',
          action: 'Delete',
          description: 'Deleted bill (id: $id)',
        );
      }

      return rows;
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
