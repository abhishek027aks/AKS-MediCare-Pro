import 'package:flutter/material.dart';

import '../../../attendance/screens/hr_management_screen.dart';
import '../../../audit/screens/audit_log_screen.dart';
import '../../../billing/screens/billing_management_screen.dart';
import '../../../inventory/screens/inventory_management_screen.dart';
import '../../../ipd/screens/ipd_management_screen.dart';
import '../../../lab/screens/lab_management_screen.dart';
import '../../../opd/screens/opd_management_screen.dart';
import '../../../patients/screens/patient_management_screen.dart';
import '../../../pharmacy/screens/pharmacy_management_screen.dart';
import '../../../reports/screens/reports_screen.dart';
import '../../../staff/screens/staff_management_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart_outlined),
            tooltip: 'Reports',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ReportsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Audit Log',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AuditLogScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _DashboardTile(
              icon: Icons.personal_injury_outlined,
              title: 'Patients',
              color: Colors.teal,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PatientManagementScreen(),
                  ),
                );
              },
            ),
            _DashboardTile(
              icon: Icons.local_hospital_outlined,
              title: 'OPD',
              color: Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const OpdManagementScreen(),
                  ),
                );
              },
            ),
            _DashboardTile(
              icon: Icons.bed_outlined,
              title: 'IPD',
              color: Colors.deepPurple,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const IpdManagementScreen(),
                  ),
                );
              },
            ),
            _DashboardTile(
              icon: Icons.biotech_outlined,
              title: 'Laboratory',
              color: Colors.cyan,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LabManagementScreen(),
                  ),
                );
              },
            ),
            _DashboardTile(
              icon: Icons.receipt_long_outlined,
              title: 'Billing',
              color: Colors.indigo,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const BillingManagementScreen(),
                  ),
                );
              },
            ),
            _DashboardTile(
              icon: Icons.medication_outlined,
              title: 'Pharmacy',
              color: Colors.green,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PharmacyManagementScreen(),
                  ),
                );
              },
            ),
            _DashboardTile(
              icon: Icons.badge_outlined,
              title: 'Doctors & Nurses',
              color: Colors.pink,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const StaffManagementScreen(),
                  ),
                );
              },
            ),
            _DashboardTile(
              icon: Icons.inventory_2_outlined,
              title: 'Inventory',
              color: Colors.brown,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const InventoryManagementScreen(),
                  ),
                );
              },
            ),
            _DashboardTile(
              icon: Icons.groups_outlined,
              title: 'HR',
              color: Colors.deepOrange,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const HrManagementScreen(),
                  ),
                );
              },
            ),
            _DashboardTile(
              icon: Icons.bar_chart_outlined,
              title: 'Reports',
              color: Colors.blueGrey,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ReportsScreen(),
                  ),
                );
              },
            ),
            _DashboardTile(
              icon: Icons.history,
              title: 'Audit Log',
              color: Colors.grey,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AuditLogScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
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
