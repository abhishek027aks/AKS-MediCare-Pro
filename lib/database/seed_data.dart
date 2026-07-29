import 'package:sqflite/sqflite.dart';

class SeedData {
  SeedData._();

  /// Insert default data
  static Future<void> insert(Database db) async {
    await db.insert(
      'users',
      {
        'full_name': 'System Administrator',
        'username': 'admin',
        'password': 'admin123',
        'role': 'Administrator',
        'is_active': 1,
        'created_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }
}