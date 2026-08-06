import '../../../../database/database_service.dart';
import '../../../audit/data/repositories/audit_repository.dart';
import '../../models/patient_document_model.dart';

class PatientDocumentRepository {
  PatientDocumentRepository._();

  static final PatientDocumentRepository instance = PatientDocumentRepository._();

  static const String _table = 'patient_documents';

  final DatabaseService _database = DatabaseService.instance;

  Future<int> addDocument(PatientDocumentModel document) async {
    final id = await _database.insert(_table, document.toMap());

    AuditRepository.instance.logAction(
      module: 'Patients',
      action: 'Create',
      description: 'Attached document "${document.documentName}" to patient (id: ${document.patientId})',
    );

    return id;
  }

  Future<List<PatientDocumentModel>> getDocumentsForPatient(int patientId) async {
    final result = await _database.rawQuery(
      'SELECT * FROM $_table WHERE patient_id = ? ORDER BY uploaded_at DESC',
      [patientId],
    );
    return result.map(PatientDocumentModel.fromMap).toList();
  }

  Future<int> deleteDocument(int id) async {
    return _database.delete(_table, 'id = ?', [id]);
  }
}
