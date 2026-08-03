import '../../../../database/database_service.dart';
import '../../../audit/data/repositories/audit_repository.dart';
import '../../models/permission_model.dart';
import '../../../../core/helpers/permission_helper.dart';

class PermissionRepository {
  PermissionRepository._();

  static final PermissionRepository instance = PermissionRepository._();

  static const String _table = 'role_permissions';

  final DatabaseService _database = DatabaseService.instance;

  // ============================
  // SEED DEFAULTS (idempotent)
  // ============================

  /// Populates the permission matrix with sensible defaults the
  /// first time the app runs. Safe to call repeatedly — it only
  /// inserts rows for (role, module) pairs that don't already exist,
  /// so it never clobbers permissions someone has already edited.
  Future<void> ensureSeeded() async {
    final existing = await _database.rawQuery('SELECT role, module FROM $_table');
    final existingKeys = existing.map((r) => '${r['role']}::${r['module']}').toSet();

    for (final row in PermissionHelper.generateDefaults()) {
      final key = '${row['role']}::${row['module']}';
      if (!existingKeys.contains(key)) {
        await _database.insert(_table, row);
      }
    }
  }

  // ============================
  // GET ALL PERMISSIONS
  // ============================

  Future<List<PermissionModel>> getAllPermissions() async {
    final result = await _database.rawQuery('SELECT * FROM $_table ORDER BY role, module');
    return result.map(PermissionModel.fromMap).toList();
  }

  // ============================
  // GET PERMISSIONS FOR A ROLE
  // ============================

  Future<List<PermissionModel>> getPermissionsForRole(String role) async {
    final result = await _database.rawQuery(
      'SELECT * FROM $_table WHERE role = ? ORDER BY module',
      [role],
    );
    return result.map(PermissionModel.fromMap).toList();
  }

  // ============================
  // GET SINGLE PERMISSION
  // ============================

  Future<PermissionModel?> getPermission(String role, String module) async {
    final result = await _database.rawQuery(
      'SELECT * FROM $_table WHERE role = ? AND module = ? LIMIT 1',
      [role, module],
    );

    if (result.isEmpty) return null;
    return PermissionModel.fromMap(result.first);
  }

  // ============================
  // UPDATE PERMISSION
  // ============================

  Future<void> updatePermission(PermissionModel permission) async {
    if (permission.id == null) {
      throw Exception('Permission ID cannot be null.');
    }

    await _database.update(_table, permission.toMap(), 'id = ?', [permission.id]);

    AuditRepository.instance.logAction(
      module: 'Permissions',
      action: 'Update',
      description: 'Updated ${permission.module} permissions for ${permission.role}',
    );
  }
}
