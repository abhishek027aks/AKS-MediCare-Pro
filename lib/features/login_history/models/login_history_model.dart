class LoginHistoryModel {
  const LoginHistoryModel({
    this.id,
    required this.usernameAttempted,
    this.userId,
    this.userName,
    this.role,
    required this.device,
    required this.status,
    required this.timestamp,
  });

  final int? id;
  final String usernameAttempted;
  final int? userId;
  final String? userName;
  final String? role;
  final String device;
  final String status;
  final DateTime timestamp;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username_attempted': usernameAttempted,
      'user_id': userId,
      'user_name': userName,
      'role': role,
      'device': device,
      'status': status,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory LoginHistoryModel.fromMap(Map<String, dynamic> map) {
    return LoginHistoryModel(
      id: map['id'] as int?,
      usernameAttempted: map['username_attempted'] as String,
      userId: map['user_id'] as int?,
      userName: map['user_name'] as String?,
      role: map['role'] as String?,
      device: map['device'] as String,
      status: map['status'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }

  @override
  String toString() {
    return 'LoginHistoryModel(username: $usernameAttempted, status: $status, timestamp: $timestamp)';
  }
}
