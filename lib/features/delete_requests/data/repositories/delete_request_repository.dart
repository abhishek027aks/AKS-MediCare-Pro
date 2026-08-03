import '../../../../database/database_service.dart';
import '../../../audit/data/repositories/audit_repository.dart';
import '../../../patients/data/repositories/patient_repository.dart';
import '../../models/delete_request_model.dart';

class DeleteRequestRepository {
  DeleteRequestRepository._();

  static final DeleteRequestRepository instance = DeleteRequestRepository._();

  static const String _table = 'delete_requests';

  final DatabaseService _database = DatabaseService.instance;

  /// Maps a module name to the function that actually performs the
  /// deletion once a request for it is approved. Only "Patients" is
  /// wired up for now — extending delete-request coverage to another
  /// module just means adding one more entry here plus a create-call
  /// at that module's delete site (see DeletePatientDialog for the
  /// pattern to follow).
  static final Map<String, Future<int> Function(int id)> _deleteDispatch = {
    'Patients': (id) => PatientRepository.instance.deletePatient(id),
  };

  // ============================
  // CREATE REQUEST
  // ============================

  Future<int> createRequest(DeleteRequestModel request) async {
    final id = await _database.insert(_table, request.toMap());

    AuditRepository.instance.logAction(
      module: 'Delete Requests',
      action: 'Create',
      description: '${request.requestedByName} requested deletion of ${request.module} record '
          '"${request.recordLabel}"',
    );

    return id;
  }

  // ============================
  // GET ALL REQUESTS
  // ============================

  Future<List<DeleteRequestModel>> getAllRequests() async {
    final result = await _database.rawQuery('SELECT * FROM $_table ORDER BY requested_at DESC');
    return result.map(DeleteRequestModel.fromMap).toList();
  }

  Future<List<DeleteRequestModel>> getPendingRequests() async {
    final result = await _database.rawQuery(
      "SELECT * FROM $_table WHERE status = 'Pending' ORDER BY requested_at DESC",
    );
    return result.map(DeleteRequestModel.fromMap).toList();
  }

  // ============================
  // APPROVE — actually deletes the underlying record
  // ============================

  Future<void> approve({
    required DeleteRequestModel request,
    required int reviewerId,
    required String reviewerName,
  }) async {
    final deleteFn = _deleteDispatch[request.module];

    if (deleteFn == null) {
      throw Exception('No delete handler registered for module "${request.module}".');
    }

    await deleteFn(request.recordId);

    await _database.update(
      _table,
      {
        'status': 'Approved',
        'reviewed_by_user_id': reviewerId,
        'reviewed_by_name': reviewerName,
        'reviewed_at': DateTime.now().toIso8601String(),
      },
      'id = ?',
      [request.id],
    );

    AuditRepository.instance.logAction(
      module: 'Delete Requests',
      action: 'Approve',
      description: '$reviewerName approved deletion of ${request.module} record "${request.recordLabel}"',
    );
  }

  // ============================
  // REJECT — record stays, request closed
  // ============================

  Future<void> reject({
    required DeleteRequestModel request,
    required int reviewerId,
    required String reviewerName,
  }) async {
    await _database.update(
      _table,
      {
        'status': 'Rejected',
        'reviewed_by_user_id': reviewerId,
        'reviewed_by_name': reviewerName,
        'reviewed_at': DateTime.now().toIso8601String(),
      },
      'id = ?',
      [request.id],
    );

    AuditRepository.instance.logAction(
      module: 'Delete Requests',
      action: 'Reject',
      description: '$reviewerName rejected deletion of ${request.module} record "${request.recordLabel}"',
    );
  }
}
