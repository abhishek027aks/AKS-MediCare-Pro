import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/helpers/date_helper.dart';
import '../../delete_requests/providers/delete_request_provider.dart';
import '../../delete_requests/screens/delete_request_list_screen.dart';
import '../../login_history/providers/login_history_provider.dart';
import '../../pharmacy/providers/medicine_provider.dart';
import '../../pharmacy/screens/medicine_details_screen.dart';
import '../../user_management/providers/user_provider.dart';

/// A live-computed alert panel — not a stored notifications table.
/// Every time this screen opens it re-derives "what needs attention"
/// from data that already exists: pending delete requests, low-stock
/// medicines, recent failed logins, and recently added users.
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingRequests = ref.watch(deleteRequestProvider).requests.where((r) => r.status == 'Pending').toList();
    final lowStockMeds = ref.watch(medicineProvider).medicines.where((m) => m.isLowStock).toList();

    final recentFailedLogins = ref
        .watch(loginHistoryProvider)
        .history
        .where((e) => e.status == 'Failed' && DateTime.now().difference(e.timestamp).inHours < 24)
        .toList();

    final recentUsers = ref
        .watch(userProvider)
        .users
        .where((u) => DateTime.now().difference(u.createdAt).inDays < 7)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final totalCount =
        pendingRequests.length + lowStockMeds.length + recentFailedLogins.length + recentUsers.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: totalCount == 0
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.notifications_none, size: 64),
                  SizedBox(height: 16),
                  Text('Nothing needs attention right now.'),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ...pendingRequests.map(
                  (request) => _NotificationTile(
                    icon: Icons.delete_outline,
                    iconColor: Colors.red,
                    title: 'New Delete Request',
                    subtitle: '${request.requestedByName} requested delete of "${request.recordLabel}"',
                    timestamp: request.requestedAt,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DeleteRequestListScreen()),
                    ),
                  ),
                ),
                ...recentFailedLogins.map(
                  (entry) => _NotificationTile(
                    icon: Icons.warning_amber_rounded,
                    iconColor: Colors.orange,
                    title: 'Failed Login Attempt',
                    subtitle: 'Unknown or invalid login for "${entry.usernameAttempted}"',
                    timestamp: entry.timestamp,
                  ),
                ),
                ...lowStockMeds.map(
                  (medicine) => _NotificationTile(
                    icon: Icons.medication_outlined,
                    iconColor: Colors.orange,
                    title: 'Low Stock Alert',
                    subtitle: '${medicine.name} stock is low (${medicine.stockQuantity} ${medicine.unit} left)',
                    timestamp: medicine.updatedAt,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => MedicineDetailsScreen(medicine: medicine)),
                    ),
                  ),
                ),
                ...recentUsers.map(
                  (user) => _NotificationTile(
                    icon: Icons.person_add_alt_outlined,
                    iconColor: Colors.green,
                    title: 'New User Registered',
                    subtitle: '${user.fullName} (${user.role}) added',
                    timestamp: user.createdAt,
                  ),
                ),
              ],
            ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.timestamp,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final DateTime timestamp;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: iconColor.withValues(alpha: 0.15),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('$subtitle\n${AppDateHelper.formatDateTime(timestamp)}'),
        isThreeLine: true,
        onTap: onTap,
      ),
    );
  }
}
