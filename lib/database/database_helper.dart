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
}