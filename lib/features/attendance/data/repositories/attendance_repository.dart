import '../../../../database/database_service.dart';
import '../../../audit/data/repositories/audit_repository.dart';
import '../../models/attendance_model.dart';

class AttendanceRepository {
  AttendanceRepository._();

  static final AttendanceRepository instance = AttendanceRepository._();

  static const String _table = 'attendance';

  final DatabaseService _database = DatabaseService.instance;

  // ============================
  // CREATE RECORD
  // ============================

  Future<int> createRecord(AttendanceModel record) async {
    try {
      final id = await _database.insert(_table, record.toMap());

      AuditRepository.instance.logAction(
        module: 'Attendance',
        action: 'Create',
        description: 'Marked ${record.staffName} as ${record.status}',
      );

      return id;
    } catch (e) {
      throw Exception('Failed to mark attendance: $e');
    }
  }

  // ============================
  // GET ALL RECORDS
  // ============================

  Future<List<AttendanceModel>> getAllRecords() async {
    try {
      final result = await _database.rawQuery(
        'SELECT * FROM $_table ORDER BY date DESC',
      );

      return result.map(AttendanceModel.fromMap).toList();
    } catch (e) {
      throw Exception('Failed to load attendance: $e');
    }
  }

  // ============================
  // GET RECORDS FOR A STAFF MEMBER
  // ============================

  Future<List<AttendanceModel>> getRecordsForUser(int userId) async {
    try {
      final result = await _database.rawQuery(
        '''
        SELECT *
        FROM $_table
        WHERE user_id = ?
        ORDER BY date DESC
        ''',
        [userId],
      );

      return result.map(AttendanceModel.fromMap).toList();
    } catch (e) {
      throw Exception('Failed to load staff attendance: $e');
    }
  }

  // ============================
  // RECORD EXISTS FOR USER + DATE
  // ============================

  Future<bool> recordExists({
    required int userId,
    required DateTime date,
    int? excludingId,
  }) async {
    final dayStart = DateTime(date.year, date.month, date.day).toIso8601String();
    final dayEnd = DateTime(date.year, date.month, date.day, 23, 59, 59).toIso8601String();

    final result = await _database.rawQuery(
      '''
      SELECT id
      FROM $_table
      WHERE user_id = ?
      AND date >= ?
      AND date <= ?
      ${excludingId != null ? 'AND id != ?' : ''}
      LIMIT 1
      ''',
      excludingId != null
          ? [userId, dayStart, dayEnd, excludingId]
          : [userId, dayStart, dayEnd],
    );

    return result.isNotEmpty;
  }

  // ============================
  // SEARCH RECORDS
  // ============================

  Future<List<AttendanceModel>> searchRecords(String query) async {
    try {
      final result = await _database.rawQuery(
        '''
        SELECT *
        FROM $_table
        WHERE staff_name LIKE ?
        OR role LIKE ?
        ORDER BY date DESC
        ''',
        ['%$query%', '%$query%'],
      );

      return result.map(AttendanceModel.fromMap).toList();
    } catch (e) {
      throw Exception('Failed to search attendance: $e');
    }
  }

  // ============================
  // UPDATE RECORD
  // ============================

  Future<int> updateRecord(AttendanceModel record) async {
    if (record.id == null) {
      throw Exception('Attendance record ID cannot be null.');
    }

    try {
      final rows = await _database.update(_table, record.toMap(), 'id = ?', [record.id]);

      if (rows > 0) {
        AuditRepository.instance.logAction(
          module: 'Attendance',
          action: 'Update',
          description: 'Updated attendance for ${record.staffName}',
        );
      }

      return rows;
    } catch (e) {
      throw Exception('Failed to update attendance: $e');
    }
  }

  // ============================
  // DELETE RECORD
  // ============================

  Future<int> deleteRecord(int id) async {
    try {
      final rows = await _database.delete(_table, 'id = ?', [id]);

      if (rows > 0) {
        AuditRepository.instance.logAction(
          module: 'Attendance',
          action: 'Delete',
          description: 'Deleted attendance record (id: $id)',
        );
      }

      return rows;
    } catch (e) {
      throw Exception('Failed to delete attendance record: $e');
    }
  }
}
