class UserModel {
  const UserModel({
    this.id,
    required this.fullName,
    required this.username,
    required this.password,
    required this.role,
    required this.isActive,
    required this.createdAt,
  });

  final int? id;
  final String fullName;
  final String username;
  final String password;
  final String role;
  final bool isActive;
  final DateTime createdAt;

  UserModel copyWith({
    int? id,
    String? fullName,
    String? username,
    String? password,
    String? role,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      password: password ?? this.password,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
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
      'is_active': isActive ? 1 : 0,
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
      isActive: (map['is_active'] as int) == 1,
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
  isActive: $isActive
)
''';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is UserModel &&
            runtimeType == other.runtimeType &&
            id == other.id &&
            fullName == other.fullName &&
            username == other.username &&
            password == other.password &&
            role == other.role &&
            isActive == other.isActive &&
            createdAt == other.createdAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        fullName,
        username,
        password,
        role,
        isActive,
        createdAt,
      );
}