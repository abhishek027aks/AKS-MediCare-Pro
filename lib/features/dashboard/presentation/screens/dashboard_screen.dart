import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/helpers/role_helper.dart';
import '../../../appointments/screens/appointment_management_screen.dart';
import '../../../attendance/screens/hr_management_screen.dart';
import '../../../audit/screens/audit_log_screen.dart';
import '../../../auth/presentation/providers/auth_state_provider.dart';
import '../../../billing/screens/billing_management_screen.dart';
import '../../../delete_requests/providers/delete_request_provider.dart';
import '../../../delete_requests/screens/delete_request_list_screen.dart';
import '../../../inventory/screens/inventory_management_screen.dart';
import '../../../ipd/screens/ipd_management_screen.dart';
import '../../../lab/screens/lab_management_screen.dart';
import '../../../login_history/screens/login_history_screen.dart';
import '../../../notifications/screens/notifications_screen.dart';
import '../../../opd/screens/opd_management_screen.dart';
import '../../../patients/screens/patient_management_screen.dart';
import '../../../permissions/providers/permission_provider.dart';
import '../../../permissions/screens/permissions_screen.dart';
import '../../../pharmacy/screens/pharmacy_management_screen.dart';
import '../../../reminders/screens/reminders_screen.dart';
import '../../../reports/screens/reports_screen.dart';
import '../../../settings/screens/settings_screen.dart';
import '../../../staff/screens/staff_management_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final permissions = ref.watch(currentUserPermissionsProvider.notifier);
    final isPrivileged = RoleHelper.isPrivileged(currentUser?.role);
    final pendingDeleteRequests = ref.watch(deleteRequestProvider).pendingCount;

    bool canView(String module) => isPrivileged || permissions.can(module, action: 'view');

    final allTiles = <_TileSpec>[
      _TileSpec('Patients', Icons.personal_injury_outlined, Colors.teal, const PatientManagementScreen()),
      _TileSpec('Appointments', Icons.event_available_outlined, Colors.blueAccent, const AppointmentManagementScreen()),
      _TileSpec('OPD', Icons.local_hospital_outlined, Colors.blue, const OpdManagementScreen()),
      _TileSpec('IPD', Icons.bed_outlined, Colors.deepPurple, const IpdManagementScreen()),
      _TileSpec('Laboratory', Icons.biotech_outlined, Colors.cyan, const LabManagementScreen()),
      _TileSpec('Billing', Icons.receipt_long_outlined, Colors.indigo, const BillingManagementScreen()),
      _TileSpec('Pharmacy', Icons.medication_outlined, Colors.green, const PharmacyManagementScreen()),
      _TileSpec('Staff', Icons.badge_outlined, Colors.pink, const StaffManagementScreen(), label: 'Doctors & Nurses'),
      _TileSpec('Inventory', Icons.inventory_2_outlined, Colors.brown, const InventoryManagementScreen()),
      _TileSpec('HR', Icons.groups_outlined, Colors.deepOrange, const HrManagementScreen()),
      _TileSpec('Reports', Icons.bar_chart_outlined, Colors.blueGrey, const ReportsScreen()),
    ];

    final visibleTiles = allTiles.where((tile) => canView(tile.module)).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            tooltip: 'Reminders',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RemindersScreen()),
            ),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.campaign_outlined),
                tooltip: 'Notifications',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                ),
              ),
              if (pendingDeleteRequests > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    child: Text(
                      '$pendingDeleteRequests',
                      style: const TextStyle(color: Colors.white, fontSize: 9),
                    ),
                  ),
                ),
            ],
          ),
          if (isPrivileged) ...[
            IconButton(
              icon: const Icon(Icons.admin_panel_settings_outlined),
              tooltip: 'Roles & Permissions',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PermissionsScreen()),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Delete Requests',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DeleteRequestListScreen()),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.history_edu_outlined),
              tooltip: 'Login History',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginHistoryScreen()),
              ),
            ),
          ],
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Audit Log',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AuditLogScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: visibleTiles.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No modules are visible for your role yet.\nAsk an administrator to grant access from Roles & Permissions.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: visibleTiles
                    .map(
                      (tile) => _DashboardTile(
                        icon: tile.icon,
                        title: tile.label ?? tile.module,
                        color: tile.color,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => tile.screen),
                          );
                        },
                      ),
                    )
                    .toList(),
              ),
            ),
    );
  }
}

class _TileSpec {
  const _TileSpec(this.module, this.icon, this.color, this.screen, {this.label});

  final String module;
  final IconData icon;
  final Color color;
  final Widget screen;
  final String? label;
}

class _DashboardTile extends StatelessWidget {
  const _DashboardTile({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 42, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
