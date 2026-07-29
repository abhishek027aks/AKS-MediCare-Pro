import 'package:sqflite/sqflite.dart';

import 'database_helper.dart';

class DatabaseService {
  DatabaseService._();

  static final DatabaseService instance = DatabaseService._();

  Future<Database> get _db async => DatabaseHelper.instance.database;

  // ============================
  // INSERT
  // ============================

  Future<int> insert(
    String table,
    Map<String, dynamic> values,
  ) async {
    final db = await _db;

    return db.insert(
      table,
      values,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ============================
  // UPDATE
  // ============================

  Future<int> update(
    String table,
    Map<String, dynamic> values,
    String where,
    List<Object?> whereArgs,
  ) async {
    final db = await _db;

    return db.update(
      table,
      values,
      where: where,
      whereArgs: whereArgs,
    );
  }

  // ============================
  // DELETE
  // ============================

  Future<int> delete(
    String table,
    String where,
    List<Object?> whereArgs,
  ) async {
    final db = await _db;

    return db.delete(
      table,
      where: where,
      whereArgs: whereArgs,
    );
  }

  // ============================
  // GET ALL
  // ============================

  Future<List<Map<String, dynamic>>> getAll(
    String table,
  ) async {
    final db = await _db;

    return db.query(table);
  }

  // ============================
  // GET BY ID
  // ============================

  Future<Map<String, dynamic>?> getById(
    String table,
    String idColumn,
    Object id,
  ) async {
    final db = await _db;

    final result = await db.query(
      table,
      where: '$idColumn = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return result.first;
  }

  // ============================
  // RAW QUERY
  // ============================

  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<Object?>? arguments,
  ]) async {
    final db = await _db;

    return db.rawQuery(sql, arguments);
  }

  // ============================
  // EXECUTE SQL
  // ============================

  Future<void> execute(String sql) async {
    final db = await _db;

    await db.execute(sql);
  }
}