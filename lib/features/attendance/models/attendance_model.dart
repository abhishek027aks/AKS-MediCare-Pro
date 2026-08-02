class AttendanceModel {
  const AttendanceModel({
    this.id,
    required this.userId,
    required this.staffName,
    required this.role,
    required this.date,
    required this.status,
    this.checkInTime,
    this.checkOutTime,
    this.notes,
    required this.createdAt,
  });

  final int? id;
  final int userId;
  final String staffName;
  final String role;
  final DateTime date;
  final String status;
  final String? checkInTime;
  final String? checkOutTime;
  final String? notes;
  final DateTime createdAt;

  AttendanceModel copyWith({
    int? id,
    int? userId,
    String? staffName,
    String? role,
    DateTime? date,
    String? status,
    String? checkInTime,
    String? checkOutTime,
    String? notes,
    DateTime? createdAt,
  }) {
    return AttendanceModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      staffName: staffName ?? this.staffName,
      role: role ?? this.role,
      date: date ?? this.date,
      status: status ?? this.status,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'staff_name': staffName,
      'role': role,
      'date': date.toIso8601String(),
      'status': status,
      'check_in_time': checkInTime,
      'check_out_time': checkOutTime,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory AttendanceModel.fromMap(Map<String, dynamic> map) {
    return AttendanceModel(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      staffName: map['staff_name'] as String,
      role: map['role'] as String,
      date: DateTime.parse(map['date'] as String),
      status: map['status'] as String,
      checkInTime: map['check_in_time'] as String?,
      checkOutTime: map['check_out_time'] as String?,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel.fromMap(json);
  }

  @override
  String toString() {
    return '''
AttendanceModel(
  id: $id,
  staffName: $staffName,
  date: $date,
  status: $status
)
''';
  }
}
