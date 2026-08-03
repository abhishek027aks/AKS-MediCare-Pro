class AppointmentModel {
  const AppointmentModel({
    this.id,
    required this.appointmentNo,
    required this.patientId,
    required this.patientName,
    required this.patientUhid,
    this.doctorId,
    required this.doctorName,
    required this.appointmentDate,
    required this.appointmentTime,
    this.reasonForVisit,
    required this.status,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  final int? id;
  final String appointmentNo;
  final int patientId;
  final String patientName;
  final String patientUhid;
  final int? doctorId;
  final String doctorName;
  final DateTime appointmentDate;
  final String appointmentTime;
  final String? reasonForVisit;
  final String status;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  AppointmentModel copyWith({
    int? id,
    String? appointmentNo,
    int? patientId,
    String? patientName,
    String? patientUhid,
    int? doctorId,
    String? doctorName,
    DateTime? appointmentDate,
    String? appointmentTime,
    String? reasonForVisit,
    String? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      appointmentNo: appointmentNo ?? this.appointmentNo,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      patientUhid: patientUhid ?? this.patientUhid,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      appointmentTime: appointmentTime ?? this.appointmentTime,
      reasonForVisit: reasonForVisit ?? this.reasonForVisit,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'appointment_no': appointmentNo,
      'patient_id': patientId,
      'patient_name': patientName,
      'patient_uhid': patientUhid,
      'doctor_id': doctorId,
      'doctor_name': doctorName,
      'appointment_date': appointmentDate.toIso8601String(),
      'appointment_time': appointmentTime,
      'reason_for_visit': reasonForVisit,
      'status': status,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory AppointmentModel.fromMap(Map<String, dynamic> map) {
    return AppointmentModel(
      id: map['id'] as int?,
      appointmentNo: map['appointment_no'] as String,
      patientId: map['patient_id'] as int,
      patientName: map['patient_name'] as String,
      patientUhid: map['patient_uhid'] as String,
      doctorId: map['doctor_id'] as int?,
      doctorName: map['doctor_name'] as String,
      appointmentDate: DateTime.parse(map['appointment_date'] as String),
      appointmentTime: map['appointment_time'] as String,
      reasonForVisit: map['reason_for_visit'] as String?,
      status: map['status'] as String,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel.fromMap(json);
  }

  @override
  String toString() {
    return '''
AppointmentModel(
  id: $id,
  appointmentNo: $appointmentNo,
  patientName: $patientName,
  status: $status
)
''';
  }
}
