import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/inventory_repository.dart';
import '../models/inventory_item_model.dart';

/// ===============================
/// Inventory State
/// ===============================
class InventoryState {
  final bool isLoading;
  final List<InventoryItemModel> items;
  final String? errorMessage;

  const InventoryState({
    this.isLoading = false,
    this.items = const [],
    this.errorMessage,
  });

  InventoryState copyWith({
    bool? isLoading,
    List<InventoryItemModel>? items,
    String? errorMessage,
  }) {
    return InventoryState(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      errorMessage: errorMessage,
    );
  }
}

/// ===============================
/// Inventory Provider
/// ===============================
class InventoryNotifier extends StateNotifier<InventoryState> {
  InventoryNotifier() : super(const InventoryState()) {
    loadItems();
  }

  final InventoryRepository _repository = InventoryRepository.instance;

  Future<void> loadItems() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final items = await _repository.getAllItems();

      state = state.copyWith(isLoading: false, items: items);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<bool> addItem(InventoryItemModel item) async {
    try {
      await _repository.createItem(item);
      await loadItems();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateItem(InventoryItemModel item) async {
    try {
      await _repository.updateItem(item);
      await loadItems();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteItem(int id) async {
    try {
      await _repository.deleteItem(id);
      await loadItems();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> refresh() async {
    await loadItems();
  }
}

/// ===============================
/// Riverpod Provider
/// ===============================
final inventoryProvider = StateNotifierProvider<InventoryNotifier, InventoryState>(
  (ref) => InventoryNotifier(),
);
