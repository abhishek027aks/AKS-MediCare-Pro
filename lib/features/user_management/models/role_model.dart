import 'package:flutter/foundation.dart';

@immutable
class RoleModel {
  final int? id;

  /// Unique UUID for future LAN / Cloud Sync
  final String uuid;

  /// Role Name
  final String name;

  /// Description
  final String description;

  /// System Role (cannot be deleted)
  final bool isSystem;

  /// Active / Inactive
  final bool isActive;

  /// Audit Fields
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Future Sync Support
  final bool isSynced;

  const RoleModel({
    this.id,
    required this.uuid,
    required this.name,
    required this.description,
    this.isSystem = false,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
  });

  RoleModel copyWith({
    int? id,
    String? uuid,
    String? name,
    String? description,
    bool? isSystem,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
  }) {
    return RoleModel(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      description: description ?? this.description,
      isSystem: isSystem ?? this.isSystem,
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
      'description': description,
      'is_system': isSystem ? 1 : 0,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_synced': isSynced ? 1 : 0,
    };
  }

  factory RoleModel.fromMap(Map<String, dynamic> map) {
    return RoleModel(
      id: map['id'] as int?,
      uuid: map['uuid'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      isSystem: (map['is_system'] ?? 0) == 1,
      isActive: (map['is_active'] ?? 1) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      isSynced: (map['is_synced'] ?? 0) == 1,
    );
  }

  @override
  String toString() {
    return 'RoleModel(id: $id, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RoleModel &&
        other.id == id &&
        other.uuid == uuid &&
        other.name == name &&
        other.description == description &&
        other.isSystem == isSystem &&
        other.isActive == isActive &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.isSynced == isSynced;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      uuid,
      name,
      description,
      isSystem,
      isActive,
      createdAt,
      updatedAt,
      isSynced,
    );
  }
}