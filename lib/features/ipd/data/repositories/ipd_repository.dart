import '../../../../database/database_service.dart';
import '../../../audit/data/repositories/audit_repository.dart';
import '../../models/ipd_admission_model.dart';

class IpdRepository {
  IpdRepository._();

  static final IpdRepository instance = IpdRepository._();

  static const String _table = 'ipd_admissions';

  final DatabaseService _database = DatabaseService.instance;

  // ============================
  // CREATE ADMISSION
  // ============================

  Future<int> createAdmission(IpdAdmissionModel admission) async {
    try {
      final id = await _database.insert(_table, admission.toMap());

      AuditRepository.instance.logAction(
        module: 'IPD',
        action: 'Create',
        description: 'Admitted patient ${admission.patientName} (${admission.admissionNo})',
      );

      return id;
    } catch (e) {
      throw Exception('Failed to create admission: $e');
    }
  }

  // ============================
  // GET ALL ADMISSIONS
  // ============================

  Future<List<IpdAdmissionModel>> getAllAdmissions() async {
    try {
      final result = await _database.rawQuery(
        'SELECT * FROM $_table ORDER BY admission_date DESC',
      );

      return result.map(IpdAdmissionModel.fromMap).toList();
    } catch (e) {
      throw Exception('Failed to load admissions: $e');
    }
  }

  // ============================
  // GET ADMISSIONS FOR A PATIENT
  // ============================

  Future<List<IpdAdmissionModel>> getAdmissionsForPatient(int patientId) async {
    try {
      final result = await _database.rawQuery(
        '''
        SELECT *
        FROM $_table
        WHERE patient_id = ?
        ORDER BY admission_date DESC
        ''',
        [patientId],
      );

      return result.map(IpdAdmissionModel.fromMap).toList();
    } catch (e) {
      throw Exception('Failed to load patient admissions: $e');
    }
  }

  // ============================
  // IS BED OCCUPIED
  // ============================

  Future<bool> isBedOccupied({
    required String ward,
    required String bedNumber,
    int? excludingAdmissionId,
  }) async {
    final result = await _database.rawQuery(
      '''
      SELECT id
      FROM $_table
      WHERE ward = ?
      AND bed_number = ?
      AND status = 'Admitted'
      ${excludingAdmissionId != null ? 'AND id != ?' : ''}
      LIMIT 1
      ''',
      excludingAdmissionId != null
          ? [ward, bedNumber, excludingAdmissionId]
          : [ward, bedNumber],
    );

    return result.isNotEmpty;
  }

  // ============================
  // SEARCH ADMISSIONS
  // ============================

  Future<List<IpdAdmissionModel>> searchAdmissions(String query) async {
    try {
      final result = await _database.rawQuery(
        '''
        SELECT *
        FROM $_table
        WHERE patient_name LIKE ?
        OR patient_uhid LIKE ?
        OR admission_no LIKE ?
        OR ward LIKE ?
        ORDER BY admission_date DESC
        ''',
        ['%$query%', '%$query%', '%$query%', '%$query%'],
      );

      return result.map(IpdAdmissionModel.fromMap).toList();
    } catch (e) {
      throw Exception('Failed to search admissions: $e');
    }
  }

  // ============================
  // UPDATE ADMISSION
  // ============================

  Future<int> updateAdmission(IpdAdmissionModel admission) async {
    if (admission.id == null) {
      throw Exception('Admission ID cannot be null.');
    }

    try {
      final rows = await _database.update(
        _table,
        admission.toMap(),
        'id = ?',
        [admission.id],
      );

      if (rows > 0) {
        AuditRepository.instance.logAction(
          module: 'IPD',
          action: 'Update',
          description: 'Updated admission ${admission.admissionNo} for ${admission.patientName}',
        );
      }

      return rows;
    } catch (e) {
      throw Exception('Failed to update admission: $e');
    }
  }

  // ============================
  // DELETE ADMISSION
  // ============================

  Future<int> deleteAdmission(int id) async {
    try {
      final rows = await _database.delete(_table, 'id = ?', [id]);

      if (rows > 0) {
        AuditRepository.instance.logAction(
          module: 'IPD',
          action: 'Delete',
          description: 'Deleted admission (id: $id)',
        );
      }

      return rows;
    } catch (e) {
      throw Exception('Failed to delete admission: $e');
    }
  }
}
