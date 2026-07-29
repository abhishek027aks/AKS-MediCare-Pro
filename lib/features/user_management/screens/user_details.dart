import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ==========================================
// 1. Data Model
// ==========================================

class User {
  final String id;
  final String name;
  final String employeeId;
  final String username;
  final String gender;
  final String dob;
  final String mobile;
  final String email;
  final String department;
  final String designation;
  final String role;
  final String joiningDate;
  final String qualification;
  final bool isSystemUser;
  final String accountStatus;

  const User({
    required this.id,
    required this.name,
    required this.employeeId,
    required this.username,
    required this.gender,
    required this.dob,
    required this.mobile,
    required this.email,
    required this.department,
    required this.designation,
    required this.role,
    required this.joiningDate,
    required this.qualification,
    required this.isSystemUser,
    required this.accountStatus,
  });

  /// Helper to copy instance with updated fields
  User copyWith({
    String? id,
    String? name,
    String? employeeId,
    String? username,
    String? gender,
    String? dob,
    String? mobile,
    String? email,
    String? department,
    String? designation,
    String? role,
    String? joiningDate,
    String? qualification,
    bool? isSystemUser,
    String? accountStatus,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      employeeId: employeeId ?? this.employeeId,
      username: username ?? this.username,
      gender: gender ?? this.gender,
      dob: dob ?? this.dob,
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
      department: department ?? this.department,
      designation: designation ?? this.designation,
      role: role ?? this.role,
      joiningDate: joiningDate ?? this.joiningDate,
      qualification: qualification ?? this.qualification,
      isSystemUser: isSystemUser ?? this.isSystemUser,
      accountStatus: accountStatus ?? this.accountStatus,
    );
  }
}

// ==========================================
// 2. Riverpod AsyncNotifier & Provider
// ==========================================

class UserDetailsNotifier extends FamilyAsyncNotifier<User?, String> {
  @override
  Future<User?> build(String arg) async {
    return _fetchUserDetails(arg);
  }

  /// Simulates fetching user details from API / Repository
  Future<User?> _fetchUserDetails(String userId) async {
    await Future.delayed(const Duration(seconds: 1));

    if (userId == '404') {
      return null; // Empty View
    }

    if (userId == 'error') {
      throw Exception('Failed to load user details'); // Error View
    }

    return const User(
      id: 'EMP001',
      name: 'Dr. Rajesh Kumar',
      employeeId: 'EMP001',
      username: 'rajeshkumar',
      gender: 'Male',
      dob: '10 Jan 1988',
      mobile: '+91 9876543210',
      email: 'doctor@hospital.com',
      department: 'Administration',
      designation: 'Hospital Administrator',
      role: 'Administrator',
      joiningDate: '15 July 2024',
      qualification: 'MBBS, MBA Hospital Management',
      isSystemUser: true,
      accountStatus: 'Active',
    );
  }

  /// Refreshes state on Retry action
  Future<void> refreshUser() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchUserDetails(arg));
  }

  /// Handles user deactivation
  Future<void> deactivateUser() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await Future.delayed(const Duration(milliseconds: 800));
      final currentUser = state.value;
      if (currentUser == null) return null;

      return currentUser.copyWith(accountStatus: 'Inactive');
    });
  }
}

final userDetailsProvider =
    AsyncNotifierProvider.family<UserDetailsNotifier, User?, String>(
  UserDetailsNotifier.new,
);

// ==========================================
// 3. User Details Screen (ConsumerWidget)
// ==========================================

class UserDetailsScreen extends ConsumerWidget {
  final String userId;

  const UserDetailsScreen({
    super.key,
    this.userId = 'EMP001',
  });

  /// Dialog for Deactivate Action
  Future<void> _showDeactivateDialog(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Deactivate User'),
          content: const Text(
            'Are you sure you want to deactivate this user?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Deactivate'),
            ),
          ],
        );
      },
    );

    if (result == true && context.mounted) {
      await ref.read(userDetailsProvider(userId).notifier).deactivateUser();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User deactivated successfully')),
        );
      }
    }
  }

  /// Dialog for Delete Action
  Future<void> _showDeleteDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete User'),
          content: const Text(
            'Are you sure you want to permanently delete this user? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (result == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User deleted successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsyncValue = ref.watch(userDetailsProvider(userId));

    return userAsyncValue.when(
      loading: () => const Scaffold(
        body: _LoadingView(),
      ),
      error: (error, stackTrace) => Scaffold(
        body: _ErrorView(
          onRetry: () {
            ref.read(userDetailsProvider(userId).notifier).refreshUser();
          },
        ),
      ),
      data: (user) {
        if (user == null) {
          return const Scaffold(
            body: _EmptyView(),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('User Details'),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// ==========================
                /// Profile Header
                /// ==========================
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 52,
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          child: Icon(
                            Icons.person,
                            size: 56,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user.name,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Employee ID : ${user.employeeId}",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        Chip(
                          avatar: Icon(
                            user.accountStatus == 'Active'
                                ? Icons.check_circle
                                : Icons.remove_circle_outline,
                            size: 18,
                          ),
                          label: Text(user.accountStatus),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                /// ==========================
                /// Personal Information Card
                /// ==========================
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Personal Information",
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        _InfoTile(
                          icon: Icons.person_outline,
                          title: "Full Name",
                          value: user.name,
                        ),
                        const Divider(),
                        _InfoTile(
                          icon: Icons.account_circle_outlined,
                          title: "Username",
                          value: user.username,
                        ),
                        const Divider(),
                        _InfoTile(
                          icon: Icons.wc,
                          title: "Gender",
                          value: user.gender,
                        ),
                        const Divider(),
                        _InfoTile(
                          icon: Icons.cake_outlined,
                          title: "Date of Birth",
                          value: user.dob,
                        ),
                        const Divider(),
                        _InfoTile(
                          icon: Icons.phone_outlined,
                          title: "Mobile",
                          value: user.mobile,
                        ),
                        const Divider(),
                        _InfoTile(
                          icon: Icons.email_outlined,
                          title: "Email",
                          value: user.email,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// ==========================
                /// Professional Information Card
                /// ==========================
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Professional Information",
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        _InfoTile(
                          icon: Icons.business,
                          title: "Department",
                          value: user.department,
                        ),
                        const Divider(),
                        _InfoTile(
                          icon: Icons.work_outline,
                          title: "Designation",
                          value: user.designation,
                        ),
                        const Divider(),
                        _InfoTile(
                          icon: Icons.admin_panel_settings_outlined,
                          title: "Role",
                          value: user.role,
                        ),
                        const Divider(),
                        _InfoTile(
                          icon: Icons.event,
                          title: "Joining Date",
                          value: user.joiningDate,
                        ),
                        const Divider(),
                        _InfoTile(
                          icon: Icons.school_outlined,
                          title: "Qualification",
                          value: user.qualification,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// ==========================
                /// Account Information Card
                /// ==========================
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Account Information",
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        _InfoTile(
                          icon: Icons.verified_user_outlined,
                          title: "System User",
                          value: user.isSystemUser ? "Yes" : "No",
                        ),
                        const Divider(),
                        _InfoTile(
                          icon: Icons.security,
                          title: "Account Status",
                          value: user.accountStatus,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                /// ==========================
                /// Actions Section
                /// ==========================
                Text(
                  'Actions',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit User'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.lock_reset),
                    label: const Text('Reset Password'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.tonalIcon(
                    onPressed: () => _showDeactivateDialog(context, ref),
                    icon: const Icon(Icons.person_off),
                    label: const Text('Deactivate User'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                    onPressed: () => _showDeleteDialog(context),
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Delete User'),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ==========================================
// 4. Auxiliary & State Views
// ==========================================

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(
        value,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.person_search,
              size: 80,
            ),
            SizedBox(height: 16),
            Text(
              'User not found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'The requested user information is unavailable.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorView({
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Unable to load user details.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}