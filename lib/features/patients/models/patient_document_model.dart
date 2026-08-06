class PatientDocumentModel {
  const PatientDocumentModel({
    this.id,
    required this.patientId,
    required this.filePath,
    required this.documentName,
    required this.uploadedAt,
  });

  final int? id;
  final int patientId;
  final String filePath;
  final String documentName;
  final DateTime uploadedAt;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patient_id': patientId,
      'file_path': filePath,
      'document_name': documentName,
      'uploaded_at': uploadedAt.toIso8601String(),
    };
  }

  factory PatientDocumentModel.fromMap(Map<String, dynamic> map) {
    return PatientDocumentModel(
      id: map['id'] as int?,
      patientId: map['patient_id'] as int,
      filePath: map['file_path'] as String,
      documentName: map['document_name'] as String,
      uploadedAt: DateTime.parse(map['uploaded_at'] as String),
    );
  }
}
