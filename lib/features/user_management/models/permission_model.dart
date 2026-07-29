import 'package:flutter/foundation.dart';

@immutable
class PermissionModel {
  final int? id;

  /// Unique UUID for future LAN / Cloud Sync
  final String uuid;

  /// Permission Name
  final String name;

  /// Permission Code (Example: patient.view)
  final String code;

  /// Module Name (Example: Patient Management)
  final String module;

  /// Description
  final String description;

  /// Active / Inactive
  final bool isActive;

  /// Audit Fields
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Future Sync Support
  final bool isSynced;

  const PermissionModel({
    this.id,
    required this.uuid,
    required this.name,
    required this.code,
    required this.module,
    required this.description,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
  });

  PermissionModel copyWith({
    int? id,
    String? uuid,
    String? name,
    String? code,
    String? module,
    String? description,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
  }) {
    return PermissionModel(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      code: code ?? this.code,
      module: module ?? this.module,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uuid': uuid,
      'name': name,
      'code': code,
      'module': module,
      'description': description,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_synced': isSynced ? 1 : 0,
    };
  }

  factory PermissionModel.fromMap(Map<String, dynamic> map) {
    return PermissionModel(
      id: map['id'] as int?,
      uuid: map['uuid'] as String,
      name: map['name'] as String,
      code: map['code'] as String,
      module: map['module'] as String,
      description: map['description'] as String,
      isActive: (map['is_active'] ?? 1) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      isSynced: (map['is_synced'] ?? 0) == 1,
    );
  }

  @override
  String toString() {
    return 'PermissionModel(id: $id, code: $code)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PermissionModel &&
        other.id == id &&
        other.uuid == uuid &&
        other.name == name &&
        other.code == code &&
        other.module == module &&
        other.description == description &&
        other.isActive == isActive &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.isSynced == isSynced;
  }

  @override
  int get hashCode => Object.hash(
        id,
        uuid,
        name,
        code,
        module,
        description,
        isActive,
        createdAt,
        updatedAt,
        isSynced,
      );
}