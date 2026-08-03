import '../../../../database/database_service.dart';
import '../../../audit/data/repositories/audit_repository.dart';
import '../../models/appointment_model.dart';

class AppointmentRepository {
  AppointmentRepository._();

  static final AppointmentRepository instance = AppointmentRepository._();

  static const String _table = 'appointments';

  final DatabaseService _database = DatabaseService.instance;

  // ============================
  // CREATE APPOINTMENT
  // ============================

  Future<int> createAppointment(AppointmentModel appointment) async {
    try {
      final id = await _database.insert(_table, appointment.toMap());

      AuditRepository.instance.logAction(
        module: 'Appointments',
        action: 'Create',
        description:
            'Scheduled appointment for ${appointment.patientName} on '
            '${appointment.appointmentDate.toIso8601String().split('T').first} (${appointment.appointmentNo})',
      );

      return id;
    } catch (e) {
      throw Exception('Failed to schedule appointment: $e');
    }
  }

  // ============================
  // GET ALL APPOINTMENTS
  // ============================

  Future<List<AppointmentModel>> getAllAppointments() async {
    try {
      final result = await _database.rawQuery(
        'SELECT * FROM $_table ORDER BY appointment_date DESC',
      );

      return result.map(AppointmentModel.fromMap).toList();
    } catch (e) {
      throw Exception('Failed to load appointments: $e');
    }
  }

  // ============================
  // GET APPOINTMENTS FOR A PATIENT
  // ============================

  Future<List<AppointmentModel>> getAppointmentsForPatient(int patientId) async {
    try {
      final result = await _database.rawQuery(
        '''
        SELECT *
        FROM $_table
        WHERE patient_id = ?
        ORDER BY appointment_date DESC
        ''',
        [patientId],
      );

      return result.map(AppointmentModel.fromMap).toList();
    } catch (e) {
      throw Exception('Failed to load patient appointments: $e');
    }
  }

  // ============================
  // SEARCH APPOINTMENTS
  // ============================

  Future<List<AppointmentModel>> searchAppointments(String query) async {
    try {
      final result = await _database.rawQuery(
        '''
        SELECT *
        FROM $_table
        WHERE patient_name LIKE ?
        OR patient_uhid LIKE ?
        OR appointment_no LIKE ?
        OR doctor_name LIKE ?
        ORDER BY appointment_date DESC
        ''',
        ['%$query%', '%$query%', '%$query%', '%$query%'],
      );

      return result.map(AppointmentModel.fromMap).toList();
    } catch (e) {
      throw Exception('Failed to search appointments: $e');
    }
  }

  // ============================
  // UPDATE APPOINTMENT
  // ============================

  Future<int> updateAppointment(AppointmentModel appointment) async {
    if (appointment.id == null) {
      throw Exception('Appointment ID cannot be null.');
    }

    try {
      final rows = await _database.update(
        _table,
        appointment.toMap(),
        'id = ?',
        [appointment.id],
      );

      if (rows > 0) {
        AuditRepository.instance.logAction(
          module: 'Appointments',
          action: 'Update',
          description: 'Updated appointment ${appointment.appointmentNo} for ${appointment.patientName}',
        );
      }

      return rows;
    } catch (e) {
      throw Exception('Failed to update appointment: $e');
    }
  }

  // ============================
  // DELETE APPOINTMENT
  // ============================

  Future<int> deleteAppointment(int id) async {
    try {
      final rows = await _database.delete(_table, 'id = ?', [id]);

      if (rows > 0) {
        AuditRepository.instance.logAction(
          module: 'Appointments',
          action: 'Delete',
          description: 'Deleted appointment (id: $id)',
        );
      }

      return rows;
    } catch (e) {
      throw Exception('Failed to delete appointment: $e');
    }
  }
}
