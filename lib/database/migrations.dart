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

    // ==========================================================
    // Patients Table
    // ==========================================================

    await db.execute('''
      CREATE TABLE patients(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uhid TEXT NOT NULL UNIQUE,
        full_name TEXT NOT NULL,
        gender TEXT NOT NULL,
        date_of_birth TEXT NOT NULL,
        blood_group TEXT,
        marital_status TEXT,
        mobile TEXT NOT NULL,
        alternate_mobile TEXT,
        email TEXT,
        address TEXT,
        city TEXT,
        state TEXT,
        pincode TEXT,
        occupation TEXT,
        emergency_contact_name TEXT,
        emergency_contact_number TEXT,
        referred_by TEXT,
        notes TEXT,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_patients_uhid ON patients(uhid)
    ''');

    await db.execute('''
      CREATE INDEX idx_patients_mobile ON patients(mobile)
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
