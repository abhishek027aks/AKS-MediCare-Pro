import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'migrations.dart';
import 'seed_data.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();

    final path = join(
      databasePath,
      'aks_medicare_pro.db',
    );

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await DatabaseMigrations.createTables(db);
        await SeedData.insert(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await DatabaseMigrations.upgradeDatabase(
          db,
          oldVersion,
          newVersion,
        );
      },
    );
  }

  /// Closes the current database connection and clears the cached
  /// instance so the next [database] access reopens it from disk.
  ///
  /// Used by the Backup / Restore feature: the underlying .db file
  /// must not be replaced while sqflite still holds it open.
  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
