import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/inventory_item_model.dart';
import '../providers/inventory_provider.dart';
import '../widgets/delete_inventory_item_dialog.dart';
import 'add_inventory_item_screen.dart';
import 'edit_inventory_item_screen.dart';
import 'inventory_item_details_screen.dart';

class InventoryItemListScreen extends ConsumerStatefulWidget {
  const InventoryItemListScreen({super.key});

  @override
  ConsumerState<InventoryItemListScreen> createState() => _InventoryItemListScreenState();
}

class _InventoryItemListScreenState extends ConsumerState<InventoryItemListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _conditionFilter = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(inventoryProvider);
    final items = state.items;

    final filtered = items.where((item) {
      final query = _searchQuery.toLowerCase();

      final matchesQuery = item.itemName.toLowerCase().contains(query) ||
          item.category.toLowerCase().contains(query) ||
          item.department.toLowerCase().contains(query);

      final matchesCondition = _conditionFilter == 'All' || item.condition == _conditionFilter;

      return matchesQuery && matchesCondition;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Inventory')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const AddInventoryItemScreen()),
          );

          if (result == true && mounted) {
            await ref.read(inventoryProvider.notifier).refresh();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Item'),
      ),
      body: Column(
        children: [
          if (state.isLoading) const LinearProgressIndicator(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by name, category or department...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      'All',
                      'New',
                      'Good',
                      'Fair',
                      'Needs Repair',
                      'Damaged',
                    ].map((condition) {
                      final selected = _conditionFilter == condition;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(condition),
                          selected: selected,
                          onSelected: (_) => setState(() => _conditionFilter = condition),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.read(inventoryProvider.notifier).refresh(),
              child: filtered.isEmpty
                  ? const SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      child: SizedBox(height: 400, child: _EmptyState()),
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final InventoryItemModel item = filtered[index];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => InventoryItemDetailsScreen(item: item)),
                              );
                              if (mounted) await ref.read(inventoryProvider.notifier).refresh();
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 26,
                                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                    child: const Icon(Icons.inventory_2_outlined),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.itemName,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        ),
                                        const SizedBox(height: 4),
                                        Text('${item.category}  •  ${item.department}'),
                                        const SizedBox(height: 4),
                                        Text('Qty : ${item.quantity} ${item.unit}'),
                                        const SizedBox(height: 10),
                                        Chip(label: Text(item.condition)),
                                      ],
                                    ),
                                  ),
                                  PopupMenuButton<String>(
                                    onSelected: (value) async {
                                      switch (value) {
                                        case 'view':
                                          await Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (_) => InventoryItemDetailsScreen(item: item)),
                                          );
                                          if (mounted) await ref.read(inventoryProvider.notifier).refresh();
                                          break;
                                        case 'edit':
                                          final updated = await Navigator.push<bool>(
                                            context,
                                            MaterialPageRoute(builder: (_) => EditInventoryItemScreen(item: item)),
                                          );
                                          if (updated == true && mounted) {
                                            await ref.read(inventoryProvider.notifier).refresh();
                                          }
                                          break;
                                        case 'delete':
                                          final deleted = await showDialog<bool>(
                                            context: context,
                                            builder: (_) => DeleteInventoryItemDialog(item: item),
                                          );
                                          if (deleted == true && mounted) {
                                            await ref.read(inventoryProvider.notifier).refresh();
                                          }
                                          break;
                                      }
                                    },
                                    itemBuilder: (_) => const [
                                      PopupMenuItem(value: 'view', child: Text('View')),
                                      PopupMenuItem(value: 'edit', child: Text('Edit')),
                                      PopupMenuItem(value: 'delete', child: Text('Delete')),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 80),
            SizedBox(height: 20),
            Text('No inventory items found', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Try changing your filters or add a new item.', textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
