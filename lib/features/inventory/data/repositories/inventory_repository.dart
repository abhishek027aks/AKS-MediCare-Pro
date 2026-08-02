import '../../../../database/database_service.dart';
import '../../../audit/data/repositories/audit_repository.dart';
import '../../models/inventory_item_model.dart';

class InventoryRepository {
  InventoryRepository._();

  static final InventoryRepository instance = InventoryRepository._();

  static const String _table = 'inventory_items';

  final DatabaseService _database = DatabaseService.instance;

  // ============================
  // CREATE ITEM
  // ============================

  Future<int> createItem(InventoryItemModel item) async {
    try {
      final id = await _database.insert(_table, item.toMap());

      AuditRepository.instance.logAction(
        module: 'Inventory',
        action: 'Create',
        description: 'Added inventory item ${item.itemName} (qty: ${item.quantity})',
      );

      return id;
    } catch (e) {
      throw Exception('Failed to add inventory item: $e');
    }
  }

  // ============================
  // GET ALL ITEMS
  // ============================

  Future<List<InventoryItemModel>> getAllItems() async {
    try {
      final result = await _database.rawQuery(
        'SELECT * FROM $_table ORDER BY item_name ASC',
      );

      return result.map(InventoryItemModel.fromMap).toList();
    } catch (e) {
      throw Exception('Failed to load inventory: $e');
    }
  }

  // ============================
  // SEARCH ITEMS
  // ============================

  Future<List<InventoryItemModel>> searchItems(String query) async {
    try {
      final result = await _database.rawQuery(
        '''
        SELECT *
        FROM $_table
        WHERE item_name LIKE ?
        OR category LIKE ?
        OR department LIKE ?
        OR serial_number LIKE ?
        ORDER BY item_name ASC
        ''',
        ['%$query%', '%$query%', '%$query%', '%$query%'],
      );

      return result.map(InventoryItemModel.fromMap).toList();
    } catch (e) {
      throw Exception('Failed to search inventory: $e');
    }
  }

  // ============================
  // UPDATE ITEM
  // ============================

  Future<int> updateItem(InventoryItemModel item) async {
    if (item.id == null) {
      throw Exception('Inventory item ID cannot be null.');
    }

    try {
      final rows = await _database.update(_table, item.toMap(), 'id = ?', [item.id]);

      if (rows > 0) {
        AuditRepository.instance.logAction(
          module: 'Inventory',
          action: 'Update',
          description: 'Updated inventory item ${item.itemName}',
        );
      }

      return rows;
    } catch (e) {
      throw Exception('Failed to update inventory item: $e');
    }
  }

  // ============================
  // DELETE ITEM
  // ============================

  Future<int> deleteItem(int id) async {
    try {
      final rows = await _database.delete(_table, 'id = ?', [id]);

      if (rows > 0) {
        AuditRepository.instance.logAction(
          module: 'Inventory',
          action: 'Delete',
          description: 'Deleted inventory item (id: $id)',
        );
      }

      return rows;
    } catch (e) {
      throw Exception('Failed to delete inventory item: $e');
    }
  }
}
