class PermissionModel {
  const PermissionModel({
    this.id,
    required this.role,
    required this.module,
    required this.canView,
    required this.canAdd,
    required this.canEdit,
    required this.canDelete,
    required this.canApprove,
  });

  final int? id;
  final String role;
  final String module;
  final bool canView;
  final bool canAdd;
  final bool canEdit;
  final bool canDelete;
  final bool canApprove;

  PermissionModel copyWith({
    int? id,
    String? role,
    String? module,
    bool? canView,
    bool? canAdd,
    bool? canEdit,
    bool? canDelete,
    bool? canApprove,
  }) {
    return PermissionModel(
      id: id ?? this.id,
      role: role ?? this.role,
      module: module ?? this.module,
      canView: canView ?? this.canView,
      canAdd: canAdd ?? this.canAdd,
      canEdit: canEdit ?? this.canEdit,
      canDelete: canDelete ?? this.canDelete,
      canApprove: canApprove ?? this.canApprove,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'role': role,
      'module': module,
      'can_view': canView ? 1 : 0,
      'can_add': canAdd ? 1 : 0,
      'can_edit': canEdit ? 1 : 0,
      'can_delete': canDelete ? 1 : 0,
      'can_approve': canApprove ? 1 : 0,
    };
  }

  factory PermissionModel.fromMap(Map<String, dynamic> map) {
    return PermissionModel(
      id: map['id'] as int?,
      role: map['role'] as String,
      module: map['module'] as String,
      canView: (map['can_view'] as int? ?? 0) == 1,
      canAdd: (map['can_add'] as int? ?? 0) == 1,
      canEdit: (map['can_edit'] as int? ?? 0) == 1,
      canDelete: (map['can_delete'] as int? ?? 0) == 1,
      canApprove: (map['can_approve'] as int? ?? 0) == 1,
    );
  }

  @override
  String toString() {
    return 'PermissionModel(role: $role, module: $module, '
        'view: $canView, add: $canAdd, edit: $canEdit, delete: $canDelete, approve: $canApprove)';
  }
}
