class StaffProfileModel {
  const StaffProfileModel({
    this.id,
    required this.userId,
    required this.staffName,
    required this.role,
    required this.specialization,
    required this.department,
    this.qualification,
    this.licenseNumber,
    this.experienceYears,
    required this.shiftTiming,
    required this.consultationFee,
    this.isAvailable = true,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  final int? id;
  final int userId;
  final String staffName;
  final String role;
  final String specialization;
  final String department;
  final String? qualification;
  final String? licenseNumber;
  final int? experienceYears;
  final String shiftTiming;
  final double consultationFee;
  final bool isAvailable;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  StaffProfileModel copyWith({
    int? id,
    int? userId,
    String? staffName,
    String? role,
    String? specialization,
    String? department,
    String? qualification,
    String? licenseNumber,
    int? experienceYears,
    String? shiftTiming,
    double? consultationFee,
    bool? isAvailable,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StaffProfileModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      staffName: staffName ?? this.staffName,
      role: role ?? this.role,
      specialization: specialization ?? this.specialization,
      department: department ?? this.department,
      qualification: qualification ?? this.qualification,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      experienceYears: experienceYears ?? this.experienceYears,
      shiftTiming: shiftTiming ?? this.shiftTiming,
      consultationFee: consultationFee ?? this.consultationFee,
      isAvailable: isAvailable ?? this.isAvailable,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'staff_name': staffName,
      'role': role,
      'specialization': specialization,
      'department': department,
      'qualification': qualification,
      'license_number': licenseNumber,
      'experience_years': experienceYears,
      'shift_timing': shiftTiming,
      'consultation_fee': consultationFee,
      'is_available': isAvailable ? 1 : 0,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory StaffProfileModel.fromMap(Map<String, dynamic> map) {
    return StaffProfileModel(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      staffName: map['staff_name'] as String,
      role: map['role'] as String,
      specialization: map['specialization'] as String,
      department: map['department'] as String,
      qualification: map['qualification'] as String?,
      licenseNumber: map['license_number'] as String?,
      experienceYears: map['experience_years'] as int?,
      shiftTiming: map['shift_timing'] as String,
      consultationFee: (map['consultation_fee'] as num).toDouble(),
      isAvailable: (map['is_available'] as int? ?? 1) == 1,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory StaffProfileModel.fromJson(Map<String, dynamic> json) {
    return StaffProfileModel.fromMap(json);
  }

  @override
  String toString() {
    return '''
StaffProfileModel(
  id: $id,
  staffName: $staffName,
  role: $role,
  department: $department
)
''';
  }
}
