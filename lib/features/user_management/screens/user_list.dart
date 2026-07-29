import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_model.dart';
import '../providers/user_provider.dart';

import 'add_user.dart';
import 'edit_user.dart';
import 'user_details.dart';
import '../widgets/delete_user_dialog.dart';

class UserListScreen extends ConsumerStatefulWidget {
  const UserListScreen({super.key});

  @override
  ConsumerState<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends ConsumerState<UserListScreen> {
  // 1. Search Controller & Query state
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  String _sortBy = 'Name';

  // 2. Memory leak prevention
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Step 2: Refreshed Method connected to Riverpod
  Future<void> _refreshUsers() async {
    await ref.read(userProvider.notifier).refresh();
  }

  // Step 3: Sort Method updated for UserModel properties
  void _sortUsers(List<UserModel> usersList, String value) {
    setState(() {
      _sortBy = value;

      switch (value) {
        case 'Name':
          usersList.sort(
            (a, b) => a.fullName.compareTo(b.fullName),
          );
          break;

        case 'Employee ID':
          usersList.sort(
            (a, b) => a.username.compareTo(b.username),
          );
          break;

        case 'Department':
          usersList.sort(
            (a, b) => a.role.compareTo(b.role),
          );
          break;
      }
    });
  }

  // Step 4: Filter Bottom Sheet
  void _showFilterSheet(List<UserModel> usersList) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.sort_by_alpha),
                title: const Text('Sort by Name'),
                selected: _sortBy == 'Name',
                onTap: () {
                  Navigator.pop(context);
                  _sortUsers(usersList, 'Name');
                },
              ),
              ListTile(
                leading: const Icon(Icons.badge),
                title: const Text('Sort by Employee ID'),
                selected: _sortBy == 'Employee ID',
                onTap: () {
                  Navigator.pop(context);
                  _sortUsers(usersList, 'Employee ID');
                },
              ),
              ListTile(
                leading: const Icon(Icons.business),
                title: const Text('Sort by Department'),
                selected: _sortBy == 'Department',
                onTap: () {
                  Navigator.pop(context);
                  _sortUsers(usersList, 'Department');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Step 3: Read state from userProvider
    final state = ref.watch(userProvider);
    final users = state.users;

    // Step 5: Dynamic search filter logic using UserModel fields
    final filteredUsers = users.where((user) {
      final query = _searchQuery.toLowerCase();

      return user.fullName.toLowerCase().contains(query) ||
          user.username.toLowerCase().contains(query) ||
          user.role.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterSheet(users),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => const AddUserScreen(),
            ),
          );

          if (result == true && mounted) {
            await ref.read(userProvider.notifier).refresh();
          }
        },
        icon: const Icon(Icons.person_add),
        label: const Text('Add User'),
      ),
      body: Column(
        children: [
          // Step 4: Loading Indicator connected to Riverpod state
          if (state.isLoading) const LinearProgressIndicator(),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search user...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Total Users : ${filteredUsers.length}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
          ),

          // Step 6: Wrapped ListView with RefreshIndicator
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshUsers,
              child: filteredUsers.isEmpty
                  ? const SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: 400,
                        child: _EmptyState(),
                      ),
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredUsers.length,
                      itemBuilder: (context, index) {
                        final user = filteredUsers[index];
                        final bool isActive = user.isActive;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  child: Text(
                                    user.fullName
                                        .split(' ')
                                        .take(2)
                                        .map((e) => e.isNotEmpty ? e[0] : '')
                                        .join(),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user.fullName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Employee ID : ${user.username}",
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Role : ${user.role}",
                                      ),
                                      const SizedBox(height: 10),
                                      Chip(
                                        avatar: Icon(
                                          isActive
                                              ? Icons.check_circle
                                              : Icons.cancel,
                                          size: 18,
                                          color: isActive
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                        label: Text(
                                          isActive ? "Active" : "Inactive",
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
                                          MaterialPageRoute(
                                            builder: (_) => UserDetailsScreen(
                                              userId: user.id.toString(),
                                            ),
                                          ),
                                        );
                                        break;

                                      case 'edit':
                                        final updated =
                                            await Navigator.push<bool>(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                EditUserScreen(user: user),
                                          ),
                                        );

                                        if (updated == true && mounted) {
                                          await ref
                                              .read(userProvider.notifier)
                                              .refresh();
                                        }
                                        break;

                                      case 'delete':
                                        final deleted =
                                            await showDialog<bool>(
                                          context: context,
                                          builder: (_) =>
                                              DeleteUserDialog(user: user),
                                        );

                                        if (deleted == true && mounted) {
                                          await ref
                                              .read(userProvider.notifier)
                                              .refresh();
                                        }
                                        break;
                                    }
                                  },
                                  itemBuilder: (_) => const [
                                    PopupMenuItem(
                                      value: 'view',
                                      child: Text('View'),
                                    ),
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: Text('Edit'),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Text('Delete'),
                                    ),
                                  ],
                                ),
                              ],
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

// Standalone Empty State Component
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.people_outline,
              size: 80,
            ),
            SizedBox(height: 20),
            Text(
              'No users found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Try changing your search or add a new user.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}