class OpdVisitModel {
  const OpdVisitModel({
    this.id,
    required this.visitNo,
    required this.patientId,
    required this.patientName,
    required this.patientUhid,
    this.doctorId,
    required this.doctorName,
    required this.visitDate,
    required this.visitType,
    this.chiefComplaint,
    this.diagnosis,
    this.prescription,
    required this.consultationFee,
    this.followUpDate,
    required this.status,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  final int? id;
  final String visitNo;
  final int patientId;
  final String patientName;
  final String patientUhid;
  final int? doctorId;
  final String doctorName;
  final DateTime visitDate;
  final String visitType;
  final String? chiefComplaint;
  final String? diagnosis;
  final String? prescription;
  final double consultationFee;
  final DateTime? followUpDate;
  final String status;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  OpdVisitModel copyWith({
    int? id,
    String? visitNo,
    int? patientId,
    String? patientName,
    String? patientUhid,
    int? doctorId,
    String? doctorName,
    DateTime? visitDate,
    String? visitType,
    String? chiefComplaint,
    String? diagnosis,
    String? prescription,
    double? consultationFee,
    DateTime? followUpDate,
    String? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OpdVisitModel(
      id: id ?? this.id,
      visitNo: visitNo ?? this.visitNo,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      patientUhid: patientUhid ?? this.patientUhid,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      visitDate: visitDate ?? this.visitDate,
      visitType: visitType ?? this.visitType,
      chiefComplaint: chiefComplaint ?? this.chiefComplaint,
      diagnosis: diagnosis ?? this.diagnosis,
      prescription: prescription ?? this.prescription,
      consultationFee: consultationFee ?? this.consultationFee,
      followUpDate: followUpDate ?? this.followUpDate,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'visit_no': visitNo,
      'patient_id': patientId,
      'patient_name': patientName,
      'patient_uhid': patientUhid,
      'doctor_id': doctorId,
      'doctor_name': doctorName,
      'visit_date': visitDate.toIso8601String(),
      'visit_type': visitType,
      'chief_complaint': chiefComplaint,
      'diagnosis': diagnosis,
      'prescription': prescription,
      'consultation_fee': consultationFee,
      'follow_up_date': followUpDate?.toIso8601String(),
      'status': status,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory OpdVisitModel.fromMap(Map<String, dynamic> map) {
    return OpdVisitModel(
      id: map['id'] as int?,
      visitNo: map['visit_no'] as String,
      patientId: map['patient_id'] as int,
      patientName: map['patient_name'] as String,
      patientUhid: map['patient_uhid'] as String,
      doctorId: map['doctor_id'] as int?,
      doctorName: map['doctor_name'] as String,
      visitDate: DateTime.parse(map['visit_date'] as String),
      visitType: map['visit_type'] as String,
      chiefComplaint: map['chief_complaint'] as String?,
      diagnosis: map['diagnosis'] as String?,
      prescription: map['prescription'] as String?,
      consultationFee: (map['consultation_fee'] as num).toDouble(),
      followUpDate: map['follow_up_date'] == null
          ? null
          : DateTime.parse(map['follow_up_date'] as String),
      status: map['status'] as String,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory OpdVisitModel.fromJson(Map<String, dynamic> json) {
    return OpdVisitModel.fromMap(json);
  }

  @override
  String toString() {
    return '''
OpdVisitModel(
  id: $id,
  visitNo: $visitNo,
  patientName: $patientName,
  doctorName: $doctorName,
  status: $status
)
''';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is OpdVisitModel &&
            id == other.id &&
            visitNo == other.visitNo &&
            patientId == other.patientId &&
            patientName == other.patientName &&
            patientUhid == other.patientUhid &&
            doctorId == other.doctorId &&
            doctorName == other.doctorName &&
            visitDate == other.visitDate &&
            visitType == other.visitType &&
            chiefComplaint == other.chiefComplaint &&
            diagnosis == other.diagnosis &&
            prescription == other.prescription &&
            consultationFee == other.consultationFee &&
            followUpDate == other.followUpDate &&
            status == other.status &&
            notes == other.notes &&
            createdAt == other.createdAt &&
            updatedAt == other.updatedAt;
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        visitNo,
        patientId,
        patientName,
        patientUhid,
        doctorId,
        doctorName,
        visitDate,
        visitType,
        chiefComplaint,
        diagnosis,
        prescription,
        consultationFee,
        followUpDate,
        status,
        notes,
        createdAt,
        updatedAt,
      ]);
}
