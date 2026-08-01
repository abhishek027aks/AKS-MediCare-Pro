import '../../../../database/database_service.dart';
import '../../models/opd_visit_model.dart';

class OpdRepository {
  OpdRepository._();

  static final OpdRepository instance = OpdRepository._();

  static const String _table = 'opd_visits';

  final DatabaseService _database = DatabaseService.instance;

  // ============================
  // CREATE VISIT
  // ============================

  Future<int> createVisit(OpdVisitModel visit) async {
    try {
      return await _database.insert(_table, visit.toMap());
    } catch (e) {
      throw Exception('Failed to create OPD visit: $e');
    }
  }

  // ============================
  // GET ALL VISITS
  // ============================

  Future<List<OpdVisitModel>> getAllVisits() async {
    try {
      final result = await _database.rawQuery(
        'SELECT * FROM $_table ORDER BY visit_date DESC',
      );

      return result.map(OpdVisitModel.fromMap).toList();
    } catch (e) {
      throw Exception('Failed to load OPD visits: $e');
    }
  }

  // ============================
  // GET VISITS FOR A PATIENT
  // ============================

  Future<List<OpdVisitModel>> getVisitsForPatient(int patientId) async {
    try {
      final result = await _database.rawQuery(
        '''
        SELECT *
        FROM $_table
        WHERE patient_id = ?
        ORDER BY visit_date DESC
        ''',
        [patientId],
      );

      return result.map(OpdVisitModel.fromMap).toList();
    } catch (e) {
      throw Exception('Failed to load patient visits: $e');
    }
  }

  // ============================
  // SEARCH VISITS
  // ============================

  Future<List<OpdVisitModel>> searchVisits(String query) async {
    try {
      final result = await _database.rawQuery(
        '''
        SELECT *
        FROM $_table
        WHERE patient_name LIKE ?
        OR patient_uhid LIKE ?
        OR visit_no LIKE ?
        OR doctor_name LIKE ?
        ORDER BY visit_date DESC
        ''',
        [
          '%$query%',
          '%$query%',
          '%$query%',
          '%$query%',
        ],
      );

      return result.map(OpdVisitModel.fromMap).toList();
    } catch (e) {
      throw Exception('Failed to search OPD visits: $e');
    }
  }

  // ============================
  // UPDATE VISIT
  // ============================

  Future<int> updateVisit(OpdVisitModel visit) async {
    if (visit.id == null) {
      throw Exception('Visit ID cannot be null.');
    }

    try {
      return await _database.update(
        _table,
        visit.toMap(),
        'id = ?',
        [visit.id],
      );
    } catch (e) {
      throw Exception('Failed to update OPD visit: $e');
    }
  }

  // ============================
  // DELETE VISIT
  // ============================

  Future<int> deleteVisit(int id) async {
    try {
      return await _database.delete(_table, 'id = ?', [id]);
    } catch (e) {
      throw Exception('Failed to delete OPD visit: $e');
    }
  }
}
