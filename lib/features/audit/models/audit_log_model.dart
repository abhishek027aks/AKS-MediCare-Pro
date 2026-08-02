class AuditLogModel {
  const AuditLogModel({
    this.id,
    this.userId,
    required this.userName,
    required this.action,
    required this.module,
    required this.description,
    required this.timestamp,
  });

  final int? id;
  final int? userId;
  final String userName;
  final String action;
  final String module;
  final String description;
  final DateTime timestamp;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'action': action,
      'module': module,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory AuditLogModel.fromMap(Map<String, dynamic> map) {
    return AuditLogModel(
      id: map['id'] as int?,
      userId: map['user_id'] as int?,
      userName: map['user_name'] as String,
      action: map['action'] as String,
      module: map['module'] as String,
      description: map['description'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory AuditLogModel.fromJson(Map<String, dynamic> json) {
    return AuditLogModel.fromMap(json);
  }

  @override
  String toString() {
    return '''
AuditLogModel(
  id: $id,
  userName: $userName,
  action: $action,
  module: $module
)
''';
  }
}
