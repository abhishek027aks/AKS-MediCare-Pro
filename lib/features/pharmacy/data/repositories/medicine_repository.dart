import '../../../../database/database_service.dart';
import '../../models/medicine_model.dart';

class MedicineRepository {
  MedicineRepository._();

  static final MedicineRepository instance = MedicineRepository._();

  static const String _table = 'medicines';

  final DatabaseService _database = DatabaseService.instance;

  // ============================
  // CREATE MEDICINE
  // ============================

  Future<int> createMedicine(MedicineModel medicine) async {
    try {
      return await _database.insert(_table, medicine.toMap());
    } catch (e) {
      throw Exception('Failed to add medicine: $e');
    }
  }

  // ============================
  // GET ALL MEDICINES
  // ============================

  Future<List<MedicineModel>> getAllMedicines() async {
    try {
      final result = await _database.rawQuery(
        'SELECT * FROM $_table ORDER BY name ASC',
      );

      return result.map(MedicineModel.fromMap).toList();
    } catch (e) {
      throw Exception('Failed to load medicines: $e');
    }
  }

  // ============================
  // SEARCH MEDICINES
  // ============================

  Future<List<MedicineModel>> searchMedicines(String query) async {
    try {
      final result = await _database.rawQuery(
        '''
        SELECT *
        FROM $_table
        WHERE name LIKE ?
        OR generic_name LIKE ?
        OR category LIKE ?
        OR batch_number LIKE ?
        ORDER BY name ASC
        ''',
        ['%$query%', '%$query%', '%$query%', '%$query%'],
      );

      return result.map(MedicineModel.fromMap).toList();
    } catch (e) {
      throw Exception('Failed to search medicines: $e');
    }
  }

  // ============================
  // NAME EXISTS
  // ============================

  Future<bool> nameExists(String name, {int? excludingId}) async {
    final result = await _database.rawQuery(
      '''
      SELECT id
      FROM $_table
      WHERE LOWER(name) = LOWER(?)
      ${excludingId != null ? 'AND id != ?' : ''}
      LIMIT 1
      ''',
      excludingId != null ? [name, excludingId] : [name],
    );

    return result.isNotEmpty;
  }

  // ============================
  // UPDATE MEDICINE
  // ============================

  Future<int> updateMedicine(MedicineModel medicine) async {
    if (medicine.id == null) {
      throw Exception('Medicine ID cannot be null.');
    }

    try {
      return await _database.update(
        _table,
        medicine.toMap(),
        'id = ?',
        [medicine.id],
      );
    } catch (e) {
      throw Exception('Failed to update medicine: $e');
    }
  }

  // ============================
  // ADJUST STOCK
  // ============================

  Future<int> adjustStock({
    required int medicineId,
    required int newQuantity,
  }) async {
    try {
      return await _database.update(
        _table,
        {
          'stock_quantity': newQuantity,
          'updated_at': DateTime.now().toIso8601String(),
        },
        'id = ?',
        [medicineId],
      );
    } catch (e) {
      throw Exception('Failed to adjust stock: $e');
    }
  }

  // ============================
  // DELETE MEDICINE
  // ============================

  Future<int> deleteMedicine(int id) async {
    try {
      return await _database.delete(_table, 'id = ?', [id]);
    } catch (e) {
      throw Exception('Failed to delete medicine: $e');
    }
  }
}
