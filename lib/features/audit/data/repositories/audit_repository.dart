import '../../../../database/database_service.dart';
import '../../../auth/services/session_manager.dart';
import '../../models/audit_log_model.dart';

class AuditRepository {
  AuditRepository._();

  static final AuditRepository instance = AuditRepository._();

  static const String _table = 'audit_logs';

  final DatabaseService _database = DatabaseService.instance;

  // ============================
  // LOG ACTION (fire-and-forget)
  // ============================

  /// Records an audit entry for a create/update/delete action.
  ///
  /// Deliberately NOT awaited by callers — a failed or slow audit
  /// write must never block or break the primary operation it is
  /// logging. Any error here is swallowed rather than rethrown.
  void logAction({
    required String module,
    required String action,
    required String description,
  }) {
    _write(module: module, action: action, description: description);
  }

  Future<void> _write({
    required String module,
    required String action,
    required String description,
  }) async {
    try {
      final currentUser = await SessionManager.instance.getCurrentUser();

      await _database.insert(_table, {
        'user_id': currentUser?.id,
        'user_name': currentUser?.fullName ?? 'System',
        'action': action,
        'module': module,
        'description': description,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (_) {
      // Swallow — audit logging must never break the calling operation.
    }
  }

  // ============================
  // GET ALL LOGS (most recent first)
  // ============================

  Future<List<AuditLogModel>> getAllLogs({int limit = 500}) async {
    try {
      final result = await _database.rawQuery(
        '''
        SELECT *
        FROM $_table
        ORDER BY timestamp DESC
        LIMIT ?
        ''',
        [limit],
      );

      return result.map(AuditLogModel.fromMap).toList();
    } catch (e) {
      throw Exception('Failed to load audit logs: $e');
    }
  }

  // ============================
  // SEARCH LOGS
  // ============================

  Future<List<AuditLogModel>> searchLogs(String query) async {
    try {
      final result = await _database.rawQuery(
        '''
        SELECT *
        FROM $_table
        WHERE user_name LIKE ?
        OR module LIKE ?
        OR description LIKE ?
        ORDER BY timestamp DESC
        LIMIT 500
        ''',
        ['%$query%', '%$query%', '%$query%'],
      );

      return result.map(AuditLogModel.fromMap).toList();
    } catch (e) {
      throw Exception('Failed to search audit logs: $e');
    }
  }
}
