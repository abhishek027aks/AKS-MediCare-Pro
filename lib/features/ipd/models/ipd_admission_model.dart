class IpdAdmissionModel {
  const IpdAdmissionModel({
    this.id,
    required this.admissionNo,
    required this.patientId,
    required this.patientName,
    required this.patientUhid,
    this.doctorId,
    required this.doctorName,
    required this.ward,
    required this.bedNumber,
    required this.admissionType,
    required this.admissionDate,
    this.diagnosis,
    required this.roomChargesPerDay,
    required this.status,
    this.dischargeDate,
    this.dischargeSummary,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  final int? id;
  final String admissionNo;
  final int patientId;
  final String patientName;
  final String patientUhid;
  final int? doctorId;
  final String doctorName;
  final String ward;
  final String bedNumber;
  final String admissionType;
  final DateTime admissionDate;
  final String? diagnosis;
  final double roomChargesPerDay;
  final String status;
  final DateTime? dischargeDate;
  final String? dischargeSummary;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  IpdAdmissionModel copyWith({
    int? id,
    String? admissionNo,
    int? patientId,
    String? patientName,
    String? patientUhid,
    int? doctorId,
    String? doctorName,
    String? ward,
    String? bedNumber,
    String? admissionType,
    DateTime? admissionDate,
    String? diagnosis,
    double? roomChargesPerDay,
    String? status,
    DateTime? dischargeDate,
    String? dischargeSummary,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return IpdAdmissionModel(
      id: id ?? this.id,
      admissionNo: admissionNo ?? this.admissionNo,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      patientUhid: patientUhid ?? this.patientUhid,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      ward: ward ?? this.ward,
      bedNumber: bedNumber ?? this.bedNumber,
      admissionType: admissionType ?? this.admissionType,
      admissionDate: admissionDate ?? this.admissionDate,
      diagnosis: diagnosis ?? this.diagnosis,
      roomChargesPerDay: roomChargesPerDay ?? this.roomChargesPerDay,
      status: status ?? this.status,
      dischargeDate: dischargeDate ?? this.dischargeDate,
      dischargeSummary: dischargeSummary ?? this.dischargeSummary,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'admission_no': admissionNo,
      'patient_id': patientId,
      'patient_name': patientName,
      'patient_uhid': patientUhid,
      'doctor_id': doctorId,
      'doctor_name': doctorName,
      'ward': ward,
      'bed_number': bedNumber,
      'admission_type': admissionType,
      'admission_date': admissionDate.toIso8601String(),
      'diagnosis': diagnosis,
      'room_charges_per_day': roomChargesPerDay,
      'status': status,
      'discharge_date': dischargeDate?.toIso8601String(),
      'discharge_summary': dischargeSummary,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory IpdAdmissionModel.fromMap(Map<String, dynamic> map) {
    return IpdAdmissionModel(
      id: map['id'] as int?,
      admissionNo: map['admission_no'] as String,
      patientId: map['patient_id'] as int,
      patientName: map['patient_name'] as String,
      patientUhid: map['patient_uhid'] as String,
      doctorId: map['doctor_id'] as int?,
      doctorName: map['doctor_name'] as String,
      ward: map['ward'] as String,
      bedNumber: map['bed_number'] as String,
      admissionType: map['admission_type'] as String,
      admissionDate: DateTime.parse(map['admission_date'] as String),
      diagnosis: map['diagnosis'] as String?,
      roomChargesPerDay: (map['room_charges_per_day'] as num).toDouble(),
      status: map['status'] as String,
      dischargeDate: map['discharge_date'] == null
          ? null
          : DateTime.parse(map['discharge_date'] as String),
      dischargeSummary: map['discharge_summary'] as String?,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory IpdAdmissionModel.fromJson(Map<String, dynamic> json) {
    return IpdAdmissionModel.fromMap(json);
  }

  @override
  String toString() {
    return '''
IpdAdmissionModel(
  id: $id,
  admissionNo: $admissionNo,
  patientName: $patientName,
  ward: $ward,
  bedNumber: $bedNumber,
  status: $status
)
''';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is IpdAdmissionModel &&
            id == other.id &&
            admissionNo == other.admissionNo &&
            patientId == other.patientId &&
            patientName == other.patientName &&
            patientUhid == other.patientUhid &&
            doctorId == other.doctorId &&
            doctorName == other.doctorName &&
            ward == other.ward &&
            bedNumber == other.bedNumber &&
            admissionType == other.admissionType &&
            admissionDate == other.admissionDate &&
            diagnosis == other.diagnosis &&
            roomChargesPerDay == other.roomChargesPerDay &&
            status == other.status &&
            dischargeDate == other.dischargeDate &&
            dischargeSummary == other.dischargeSummary &&
            notes == other.notes &&
            createdAt == other.createdAt &&
            updatedAt == other.updatedAt;
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        admissionNo,
        patientId,
        patientName,
        patientUhid,
        doctorId,
        doctorName,
        ward,
        bedNumber,
        admissionType,
        admissionDate,
        diagnosis,
        roomChargesPerDay,
        status,
        dischargeDate,
        dischargeSummary,
        notes,
        createdAt,
        updatedAt,
      ]);
}
