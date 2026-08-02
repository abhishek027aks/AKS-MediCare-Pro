import '../../../../database/database_service.dart';
import '../../../audit/data/repositories/audit_repository.dart';
import '../../models/lab_test_model.dart';

class LabRepository {
  LabRepository._();

  static final LabRepository instance = LabRepository._();

  static const String _table = 'lab_tests';

  final DatabaseService _database = DatabaseService.instance;

  // ============================
  // CREATE TEST
  // ============================

  Future<int> createTest(LabTestModel test) async {
    try {
      final id = await _database.insert(_table, test.toMap());

      AuditRepository.instance.logAction(
        module: 'Laboratory',
        action: 'Create',
        description: 'Ordered ${test.testName} for ${test.patientName} (${test.testNo})',
      );

      return id;
    } catch (e) {
      throw Exception('Failed to order lab test: $e');
    }
  }

  // ============================
  // GET ALL TESTS
  // ============================

  Future<List<LabTestModel>> getAllTests() async {
    try {
      final result = await _database.rawQuery(
        'SELECT * FROM $_table ORDER BY order_date DESC',
      );

      return result.map(LabTestModel.fromMap).toList();
    } catch (e) {
      throw Exception('Failed to load lab tests: $e');
    }
  }

  // ============================
  // GET TESTS FOR A PATIENT
  // ============================

  Future<List<LabTestModel>> getTestsForPatient(int patientId) async {
    try {
      final result = await _database.rawQuery(
        '''
        SELECT *
        FROM $_table
        WHERE patient_id = ?
        ORDER BY order_date DESC
        ''',
        [patientId],
      );

      return result.map(LabTestModel.fromMap).toList();
    } catch (e) {
      throw Exception('Failed to load patient lab tests: $e');
    }
  }

  // ============================
  // SEARCH TESTS
  // ============================

  Future<List<LabTestModel>> searchTests(String query) async {
    try {
      final result = await _database.rawQuery(
        '''
        SELECT *
        FROM $_table
        WHERE patient_name LIKE ?
        OR patient_uhid LIKE ?
        OR test_no LIKE ?
        OR test_name LIKE ?
        ORDER BY order_date DESC
        ''',
        ['%$query%', '%$query%', '%$query%', '%$query%'],
      );

      return result.map(LabTestModel.fromMap).toList();
    } catch (e) {
      throw Exception('Failed to search lab tests: $e');
    }
  }

  // ============================
  // UPDATE TEST
  // ============================

  Future<int> updateTest(LabTestModel test) async {
    if (test.id == null) {
      throw Exception('Test ID cannot be null.');
    }

    try {
      final rows = await _database.update(_table, test.toMap(), 'id = ?', [test.id]);

      if (rows > 0) {
        AuditRepository.instance.logAction(
          module: 'Laboratory',
          action: 'Update',
          description: 'Updated lab test ${test.testNo} for ${test.patientName}',
        );
      }

      return rows;
    } catch (e) {
      throw Exception('Failed to update lab test: $e');
    }
  }

  // ============================
  // DELETE TEST
  // ============================

  Future<int> deleteTest(int id) async {
    try {
      final rows = await _database.delete(_table, 'id = ?', [id]);

      if (rows > 0) {
        AuditRepository.instance.logAction(
          module: 'Laboratory',
          action: 'Delete',
          description: 'Deleted lab test (id: $id)',
        );
      }

      return rows;
    } catch (e) {
      throw Exception('Failed to delete lab test: $e');
    }
  }
}
