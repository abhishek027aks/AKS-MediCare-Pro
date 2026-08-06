class UserModel {
  const UserModel({
    this.id,
    required this.fullName,
    required this.username,
    required this.password,
    required this.role,
    this.department,
    this.branchId,
    this.branchName,
    required this.isActive,
    this.mustChangePassword = false,
    required this.createdAt,
  });

  final int? id;
  final String fullName;
  final String username;
  final String password;
  final String role;
  final String? department;
  final int? branchId;
  final String? branchName;
  final bool isActive;
  final bool mustChangePassword;
  final DateTime createdAt;

  UserModel copyWith({
    int? id,
    String? fullName,
    String? username,
    String? password,
    String? role,
    String? department,
    int? branchId,
    String? branchName,
    bool? isActive,
    bool? mustChangePassword,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      password: password ?? this.password,
      role: role ?? this.role,
      department: department ?? this.department,
      branchId: branchId ?? this.branchId,
      branchName: branchName ?? this.branchName,
      isActive: isActive ?? this.isActive,
      mustChangePassword: mustChangePassword ?? this.mustChangePassword,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'username': username,
      'password': password,
      'role': role,
      'department': department,
      'branch_id': branchId,
      'branch_name': branchName,
      'is_active': isActive ? 1 : 0,
      'must_change_password': mustChangePassword ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int?,
      fullName: map['full_name'] as String,
      username: map['username'] as String,
      password: map['password'] as String,
      role: map['role'] as String,
      department: map['department'] as String?,
      branchId: map['branch_id'] as int?,
      branchName: map['branch_name'] as String?,
      isActive: (map['is_active'] as int) == 1,
      mustChangePassword: (map['must_change_password'] as int? ?? 0) == 1,
      createdAt: DateTime.parse(
        map['created_at'] as String,
      ),
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory UserModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return UserModel.fromMap(json);
  }

  @override
  String toString() {
    return '''
UserModel(
  id: $id,
  fullName: $fullName,
  username: $username,
  role: $role,
  department: $department,
  branchName: $branchName,
  isActive: $isActive,
  mustChangePassword: $mustChangePassword
)
''';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is UserModel &&
            id == other.id &&
            fullName == other.fullName &&
            username == other.username &&
            password == other.password &&
            role == other.role &&
            department == other.department &&
            branchId == other.branchId &&
            branchName == other.branchName &&
            isActive == other.isActive &&
            mustChangePassword == other.mustChangePassword &&
            createdAt == other.createdAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        fullName,
        username,
        password,
        role,
        department,
        branchId,
        branchName,
        isActive,
        mustChangePassword,
        createdAt,
      );
}
