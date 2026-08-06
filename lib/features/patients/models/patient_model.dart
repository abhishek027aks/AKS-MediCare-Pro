import '../../../core/helpers/date_helper.dart';

class PatientModel {
  const PatientModel({
    this.id,
    required this.uhid,
    required this.fullName,
    required this.gender,
    required this.dateOfBirth,
    this.bloodGroup,
    this.maritalStatus,
    required this.mobile,
    this.alternateMobile,
    this.email,
    this.address,
    this.city,
    this.state,
    this.pincode,
    this.occupation,
    this.emergencyContactName,
    this.emergencyContactNumber,
    this.referredBy,
    this.notes,
    this.photoPath,
    this.branchId,
    this.branchName,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  final int? id;
  final String uhid;
  final String fullName;
  final String gender;
  final DateTime dateOfBirth;
  final String? bloodGroup;
  final String? maritalStatus;
  final String mobile;
  final String? alternateMobile;
  final String? email;
  final String? address;
  final String? city;
  final String? state;
  final String? pincode;
  final String? occupation;
  final String? emergencyContactName;
  final String? emergencyContactNumber;
  final String? referredBy;
  final String? notes;
  final String? photoPath;
  final int? branchId;
  final String? branchName;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Age in completed years, computed from [dateOfBirth]
  int get age => AppDateHelper.calculateAge(dateOfBirth);

  PatientModel copyWith({
    int? id,
    String? uhid,
    String? fullName,
    String? gender,
    DateTime? dateOfBirth,
    String? bloodGroup,
    String? maritalStatus,
    String? mobile,
    String? alternateMobile,
    String? email,
    String? address,
    String? city,
    String? state,
    String? pincode,
    String? occupation,
    String? emergencyContactName,
    String? emergencyContactNumber,
    String? referredBy,
    String? notes,
    String? photoPath,
    int? branchId,
    String? branchName,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PatientModel(
      id: id ?? this.id,
      uhid: uhid ?? this.uhid,
      fullName: fullName ?? this.fullName,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      mobile: mobile ?? this.mobile,
      alternateMobile: alternateMobile ?? this.alternateMobile,
      email: email ?? this.email,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      occupation: occupation ?? this.occupation,
      emergencyContactName:
          emergencyContactName ?? this.emergencyContactName,
      emergencyContactNumber:
          emergencyContactNumber ?? this.emergencyContactNumber,
      referredBy: referredBy ?? this.referredBy,
      notes: notes ?? this.notes,
      photoPath: photoPath ?? this.photoPath,
      branchId: branchId ?? this.branchId,
      branchName: branchName ?? this.branchName,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uhid': uhid,
      'full_name': fullName,
      'gender': gender,
      'date_of_birth': dateOfBirth.toIso8601String(),
      'blood_group': bloodGroup,
      'marital_status': maritalStatus,
      'mobile': mobile,
      'alternate_mobile': alternateMobile,
      'email': email,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      'occupation': occupation,
      'emergency_contact_name': emergencyContactName,
      'emergency_contact_number': emergencyContactNumber,
      'referred_by': referredBy,
      'notes': notes,
      'photo_path': photoPath,
      'branch_id': branchId,
      'branch_name': branchName,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory PatientModel.fromMap(Map<String, dynamic> map) {
    return PatientModel(
      id: map['id'] as int?,
      uhid: map['uhid'] as String,
      fullName: map['full_name'] as String,
      gender: map['gender'] as String,
      dateOfBirth: DateTime.parse(map['date_of_birth'] as String),
      bloodGroup: map['blood_group'] as String?,
      maritalStatus: map['marital_status'] as String?,
      mobile: map['mobile'] as String,
      alternateMobile: map['alternate_mobile'] as String?,
      email: map['email'] as String?,
      address: map['address'] as String?,
      city: map['city'] as String?,
      state: map['state'] as String?,
      pincode: map['pincode'] as String?,
      occupation: map['occupation'] as String?,
      emergencyContactName: map['emergency_contact_name'] as String?,
      emergencyContactNumber: map['emergency_contact_number'] as String?,
      referredBy: map['referred_by'] as String?,
      notes: map['notes'] as String?,
      photoPath: map['photo_path'] as String?,
      branchId: map['branch_id'] as int?,
      branchName: map['branch_name'] as String?,
      isActive: (map['is_active'] as int? ?? 1) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel.fromMap(json);
  }

  @override
  String toString() {
    return '''
PatientModel(
  id: $id,
  uhid: $uhid,
  fullName: $fullName,
  gender: $gender,
  mobile: $mobile,
  isActive: $isActive
)
''';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is PatientModel &&
            id == other.id &&
            uhid == other.uhid &&
            fullName == other.fullName &&
            gender == other.gender &&
            dateOfBirth == other.dateOfBirth &&
            bloodGroup == other.bloodGroup &&
            maritalStatus == other.maritalStatus &&
            mobile == other.mobile &&
            alternateMobile == other.alternateMobile &&
            email == other.email &&
            address == other.address &&
            city == other.city &&
            state == other.state &&
            pincode == other.pincode &&
            occupation == other.occupation &&
            emergencyContactName == other.emergencyContactName &&
            emergencyContactNumber == other.emergencyContactNumber &&
            referredBy == other.referredBy &&
            notes == other.notes &&
            photoPath == other.photoPath &&
            branchId == other.branchId &&
            branchName == other.branchName &&
            isActive == other.isActive &&
            createdAt == other.createdAt &&
            updatedAt == other.updatedAt;
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        uhid,
        fullName,
        gender,
        dateOfBirth,
        bloodGroup,
        maritalStatus,
        mobile,
        alternateMobile,
        email,
        address,
        city,
        state,
        pincode,
        occupation,
        emergencyContactName,
        emergencyContactNumber,
        referredBy,
        notes,
        photoPath,
        branchId,
        branchName,
        isActive,
        createdAt,
        updatedAt,
      ]);
}
