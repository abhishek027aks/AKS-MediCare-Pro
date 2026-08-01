import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/medicine_model.dart';
import '../providers/medicine_provider.dart';
import '../widgets/delete_medicine_dialog.dart';
import 'add_medicine_screen.dart';
import 'edit_medicine_screen.dart';
import 'medicine_details_screen.dart';

class MedicineListScreen extends ConsumerStatefulWidget {
  const MedicineListScreen({super.key});

  @override
  ConsumerState<MedicineListScreen> createState() => _MedicineListScreenState();
}

class _MedicineListScreenState extends ConsumerState<MedicineListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _filter = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(medicineProvider);
    final medicines = state.medicines;

    final filtered = medicines.where((medicine) {
      final query = _searchQuery.toLowerCase();

      final matchesQuery = medicine.name.toLowerCase().contains(query) ||
          (medicine.genericName ?? '').toLowerCase().contains(query) ||
          medicine.category.toLowerCase().contains(query);

      final matchesFilter = switch (_filter) {
        'Low Stock' => medicine.isLowStock,
        'Expiring Soon' => medicine.isExpiringSoon && !medicine.isExpired,
        'Expired' => medicine.isExpired,
        _ => true,
      };

      return matchesQuery && matchesFilter;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Pharmacy Inventory')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const AddMedicineScreen()),
          );

          if (result == true && mounted) {
            await ref.read(medicineProvider.notifier).refresh();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Medicine'),
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
                    hintText: 'Search by name, generic name or category...',
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
                    children: ['All', 'Low Stock', 'Expiring Soon', 'Expired'].map((filter) {
                      final selected = _filter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(filter),
                          selected: selected,
                          onSelected: (_) => setState(() => _filter = filter),
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
              onRefresh: () => ref.read(medicineProvider.notifier).refresh(),
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
                        final MedicineModel medicine = filtered[index];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => MedicineDetailsScreen(medicine: medicine)),
                              );
                              if (mounted) await ref.read(medicineProvider.notifier).refresh();
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 26,
                                    backgroundColor: medicine.isLowStock
                                        ? Colors.orange.withValues(alpha: 0.15)
                                        : Theme.of(context).colorScheme.primaryContainer,
                                    child: Icon(
                                      Icons.medication_outlined,
                                      color: medicine.isLowStock ? Colors.orange : null,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          medicine.name,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        ),
                                        const SizedBox(height: 4),
                                        Text('${medicine.category}  •  ${medicine.unit}'),
                                        const SizedBox(height: 4),
                                        Text('Stock : ${medicine.stockQuantity}   Price : ₹${medicine.unitPrice.toStringAsFixed(2)}'),
                                        const SizedBox(height: 10),
                                        Wrap(
                                          spacing: 6,
                                          children: [
                                            if (medicine.isLowStock)
                                              const Chip(
                                                label: Text('Low Stock', style: TextStyle(color: Colors.orange)),
                                                backgroundColor: Color(0x1AFFA726),
                                              ),
                                            if (medicine.isExpired)
                                              const Chip(
                                                label: Text('Expired', style: TextStyle(color: Colors.red)),
                                                backgroundColor: Color(0x1AF44336),
                                              )
                                            else if (medicine.isExpiringSoon)
                                              const Chip(
                                                label: Text('Expiring Soon', style: TextStyle(color: Colors.orange)),
                                                backgroundColor: Color(0x1AFFA726),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  PopupMenuButton<String>(
                                    onSelected: (value) async {
                                      switch (value) {
                                        case 'view':
                                          await Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (_) => MedicineDetailsScreen(medicine: medicine)),
                                          );
                                          if (mounted) await ref.read(medicineProvider.notifier).refresh();
                                          break;
                                        case 'edit':
                                          final updated = await Navigator.push<bool>(
                                            context,
                                            MaterialPageRoute(builder: (_) => EditMedicineScreen(medicine: medicine)),
                                          );
                                          if (updated == true && mounted) {
                                            await ref.read(medicineProvider.notifier).refresh();
                                          }
                                          break;
                                        case 'delete':
                                          final deleted = await showDialog<bool>(
                                            context: context,
                                            builder: (_) => DeleteMedicineDialog(medicine: medicine),
                                          );
                                          if (deleted == true && mounted) {
                                            await ref.read(medicineProvider.notifier).refresh();
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
            Icon(Icons.medication_outlined, size: 80),
            SizedBox(height: 20),
            Text('No medicines found', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Try changing your filters or add a new medicine.', textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
