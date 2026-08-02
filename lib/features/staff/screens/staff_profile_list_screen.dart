import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/staff_profile_model.dart';
import '../providers/staff_provider.dart';
import '../widgets/delete_staff_profile_dialog.dart';
import 'add_staff_profile_screen.dart';
import 'edit_staff_profile_screen.dart';
import 'staff_profile_details_screen.dart';

class StaffProfileListScreen extends ConsumerStatefulWidget {
  const StaffProfileListScreen({super.key});

  @override
  ConsumerState<StaffProfileListScreen> createState() => _StaffProfileListScreenState();
}

class _StaffProfileListScreenState extends ConsumerState<StaffProfileListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _roleFilter = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(staffProvider);
    final profiles = state.profiles;

    final filtered = profiles.where((profile) {
      final query = _searchQuery.toLowerCase();

      final matchesQuery = profile.staffName.toLowerCase().contains(query) ||
          profile.specialization.toLowerCase().contains(query) ||
          profile.department.toLowerCase().contains(query);

      final matchesRole = _roleFilter == 'All' || profile.role == _roleFilter;

      return matchesQuery && matchesRole;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Doctors & Nurses')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const AddStaffProfileScreen()),
          );

          if (result == true && mounted) {
            await ref.read(staffProvider.notifier).refresh();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Profile'),
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
                    hintText: 'Search by name, specialization or department...',
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
                    children: ['All', 'Doctor', 'Nurse'].map((role) {
                      final selected = _roleFilter == role;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(role),
                          selected: selected,
                          onSelected: (_) => setState(() => _roleFilter = role),
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
              onRefresh: () => ref.read(staffProvider.notifier).refresh(),
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
                        final StaffProfileModel profile = filtered[index];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => StaffProfileDetailsScreen(profile: profile)),
                              );
                              if (mounted) await ref.read(staffProvider.notifier).refresh();
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 26,
                                    backgroundColor: (profile.isAvailable ? Colors.green : Colors.red)
                                        .withValues(alpha: 0.15),
                                    child: Icon(
                                      Icons.badge_outlined,
                                      color: profile.isAvailable ? Colors.green : Colors.red,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          profile.staffName,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        ),
                                        const SizedBox(height: 4),
                                        Text('${profile.role}  •  ${profile.specialization}'),
                                        const SizedBox(height: 4),
                                        Text(profile.department),
                                        const SizedBox(height: 10),
                                        Chip(
                                          backgroundColor:
                                              (profile.isAvailable ? Colors.green : Colors.red).withValues(alpha: 0.15),
                                          label: Text(
                                            profile.isAvailable ? 'Available' : 'Not Available',
                                            style: TextStyle(
                                              color: profile.isAvailable ? Colors.green : Colors.red,
                                            ),
                                          ),
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
                                            MaterialPageRoute(builder: (_) => StaffProfileDetailsScreen(profile: profile)),
                                          );
                                          if (mounted) await ref.read(staffProvider.notifier).refresh();
                                          break;
                                        case 'edit':
                                          final updated = await Navigator.push<bool>(
                                            context,
                                            MaterialPageRoute(builder: (_) => EditStaffProfileScreen(profile: profile)),
                                          );
                                          if (updated == true && mounted) {
                                            await ref.read(staffProvider.notifier).refresh();
                                          }
                                          break;
                                        case 'delete':
                                          final deleted = await showDialog<bool>(
                                            context: context,
                                            builder: (_) => DeleteStaffProfileDialog(profile: profile),
                                          );
                                          if (deleted == true && mounted) {
                                            await ref.read(staffProvider.notifier).refresh();
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
            Icon(Icons.badge_outlined, size: 80),
            SizedBox(height: 20),
            Text('No staff profiles found', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Try changing your filters or add a new profile.', textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
