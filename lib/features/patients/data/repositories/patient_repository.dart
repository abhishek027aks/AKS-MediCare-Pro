import '../../../../database/database_service.dart';
import '../../../audit/data/repositories/audit_repository.dart';
import '../../models/patient_model.dart';

class PatientRepository {
  PatientRepository._();

  static final PatientRepository instance = PatientRepository._();

  static const String _table = 'patients';

  final DatabaseService _database = DatabaseService.instance;

  // ============================
  // CREATE PATIENT
  // ============================

  Future<int> createPatient(PatientModel patient) async {
    try {
      final id = await _database.insert(
        _table,
        patient.toMap(),
      );

      AuditRepository.instance.logAction(
        module: 'Patients',
        action: 'Create',
        description: 'Registered patient ${patient.fullName} (${patient.uhid})',
      );

      return id;
    } catch (e) {
      throw Exception('Failed to register patient: $e');
    }
  }

  // ============================
  // GET ALL PATIENTS
  // ============================

  Future<List<PatientModel>> getAllPatients() async {
    try {
      final result = await _database.getAll(_table);

      return result.map(PatientModel.fromMap).toList();
    } catch (e) {
      throw Exception('Failed to load patients: $e');
    }
  }

  // ============================
  // GET PATIENT BY ID
  // ============================

  Future<PatientModel?> getPatientById(int id) async {
    try {
      final result = await _database.getById(_table, 'id', id);

      if (result == null) {
        return null;
      }

      return PatientModel.fromMap(result);
    } catch (e) {
      throw Exception('Failed to get patient: $e');
    }
  }

  // ============================
  // GET PATIENT BY UHID
  // ============================

  Future<PatientModel?> getPatientByUhid(String uhid) async {
    try {
      final result = await _database.rawQuery(
        '''
        SELECT *
        FROM $_table
        WHERE uhid = ?
        LIMIT 1
        ''',
        [uhid],
      );

      if (result.isEmpty) {
        return null;
      }

      return PatientModel.fromMap(result.first);
    } catch (e) {
      throw Exception('Failed to find patient: $e');
    }
  }

  // ============================
  // SEARCH PATIENTS
  // ============================

  Future<List<PatientModel>> searchPatients(String query) async {
    try {
      final result = await _database.rawQuery(
        '''
        SELECT *
        FROM $_table
        WHERE full_name LIKE ?
        OR uhid LIKE ?
        OR mobile LIKE ?
        ORDER BY created_at DESC
        ''',
        [
          '%$query%',
          '%$query%',
          '%$query%',
        ],
      );

      return result.map(PatientModel.fromMap).toList();
    } catch (e) {
      throw Exception('Failed to search patients: $e');
    }
  }

  // ============================
  // MOBILE EXISTS
  // ============================

  Future<bool> mobileExists(String mobile) async {
    final result = await _database.rawQuery(
      '''
      SELECT id
      FROM $_table
      WHERE mobile = ?
      LIMIT 1
      ''',
      [mobile],
    );

    return result.isNotEmpty;
  }

  // ============================
  // UPDATE PATIENT
  // ============================

  Future<int> updatePatient(PatientModel patient) async {
    if (patient.id == null) {
      throw Exception('Patient ID cannot be null.');
    }

    try {
      final rows = await _database.update(
        _table,
        patient.toMap(),
        'id = ?',
        [patient.id],
      );

      if (rows > 0) {
        AuditRepository.instance.logAction(
          module: 'Patients',
          action: 'Update',
          description: 'Updated patient ${patient.fullName} (${patient.uhid})',
        );
      }

      return rows;
    } catch (e) {
      throw Exception('Failed to update patient: $e');
    }
  }

  // ============================
  // DELETE PATIENT
  // ============================

  Future<int> deletePatient(int id) async {
    try {
      final rows = await _database.delete(
        _table,
        'id = ?',
        [id],
      );

      if (rows > 0) {
        AuditRepository.instance.logAction(
          module: 'Patients',
          action: 'Delete',
          description: 'Deleted patient (id: $id)',
        );
      }

      return rows;
    } catch (e) {
      throw Exception('Failed to delete patient: $e');
    }
  }

  // ============================
  // ACTIVATE / DEACTIVATE PATIENT
  // ============================

  Future<int> setPatientStatus({
    required int patientId,
    required bool isActive,
  }) async {
    try {
      return await _database.update(
        _table,
        {
          'is_active': isActive ? 1 : 0,
        },
        'id = ?',
        [patientId],
      );
    } catch (e) {
      throw Exception('Failed to update patient status: $e');
    }
  }
}
