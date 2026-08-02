import '../../../../database/database_service.dart';
import '../../../audit/data/repositories/audit_repository.dart';
import '../../models/staff_profile_model.dart';

class StaffRepository {
  StaffRepository._();

  static final StaffRepository instance = StaffRepository._();

  static const String _table = 'staff_profiles';

  final DatabaseService _database = DatabaseService.instance;

  // ============================
  // CREATE PROFILE
  // ============================

  Future<int> createProfile(StaffProfileModel profile) async {
    try {
      final id = await _database.insert(_table, profile.toMap());

      AuditRepository.instance.logAction(
        module: 'Staff',
        action: 'Create',
        description: 'Added staff profile for ${profile.staffName} (${profile.role})',
      );

      return id;
    } catch (e) {
      throw Exception('Failed to create staff profile: $e');
    }
  }

  // ============================
  // GET ALL PROFILES
  // ============================

  Future<List<StaffProfileModel>> getAllProfiles() async {
    try {
      final result = await _database.rawQuery(
        'SELECT * FROM $_table ORDER BY staff_name ASC',
      );

      return result.map(StaffProfileModel.fromMap).toList();
    } catch (e) {
      throw Exception('Failed to load staff profiles: $e');
    }
  }

  // ============================
  // SEARCH PROFILES
  // ============================

  Future<List<StaffProfileModel>> searchProfiles(String query) async {
    try {
      final result = await _database.rawQuery(
        '''
        SELECT *
        FROM $_table
        WHERE staff_name LIKE ?
        OR specialization LIKE ?
        OR department LIKE ?
        ORDER BY staff_name ASC
        ''',
        ['%$query%', '%$query%', '%$query%'],
      );

      return result.map(StaffProfileModel.fromMap).toList();
    } catch (e) {
      throw Exception('Failed to search staff profiles: $e');
    }
  }

  // ============================
  // PROFILE EXISTS FOR USER
  // ============================

  Future<bool> profileExistsForUser(int userId, {int? excludingId}) async {
    final result = await _database.rawQuery(
      '''
      SELECT id
      FROM $_table
      WHERE user_id = ?
      ${excludingId != null ? 'AND id != ?' : ''}
      LIMIT 1
      ''',
      excludingId != null ? [userId, excludingId] : [userId],
    );

    return result.isNotEmpty;
  }

  // ============================
  // UPDATE PROFILE
  // ============================

  Future<int> updateProfile(StaffProfileModel profile) async {
    if (profile.id == null) {
      throw Exception('Staff profile ID cannot be null.');
    }

    try {
      final rows = await _database.update(
        _table,
        profile.toMap(),
        'id = ?',
        [profile.id],
      );

      if (rows > 0) {
        AuditRepository.instance.logAction(
          module: 'Staff',
          action: 'Update',
          description: 'Updated staff profile for ${profile.staffName}',
        );
      }

      return rows;
    } catch (e) {
      throw Exception('Failed to update staff profile: $e');
    }
  }

  // ============================
  // DELETE PROFILE
  // ============================

  Future<int> deleteProfile(int id) async {
    try {
      final rows = await _database.delete(_table, 'id = ?', [id]);

      if (rows > 0) {
        AuditRepository.instance.logAction(
          module: 'Staff',
          action: 'Delete',
          description: 'Deleted staff profile (id: $id)',
        );
      }

      return rows;
    } catch (e) {
      throw Exception('Failed to delete staff profile: $e');
    }
  }
}
