import 'package:sqflite/sqflite.dart';

class DatabaseMigrations {
  DatabaseMigrations._();

  /// Create all database tables
  static Future<void> createTables(Database db) async {
    // ==========================================================
    // Users Table
    // ==========================================================

    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        full_name TEXT NOT NULL,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        role TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL
      )
    ''');
  }

  /// Future database upgrades
  static Future<void> upgradeDatabase(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // Version 2
    if (oldVersion < 2) {
      // Future migration
    }

    // Version 3
    if (oldVersion < 3) {
      // Future migration
    }
  }
}