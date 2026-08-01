import 'package:flutter/material.dart';

import 'add_lab_test_screen.dart';
import 'lab_test_list_screen.dart';

class LabManagementScreen extends StatelessWidget {
  const LabManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Laboratory Module'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 0,
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.biotech_outlined)),
                title: const Text('Manage Lab Tests', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Order tests, track samples and record results.'),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _DashboardCard(
                    icon: Icons.list_alt_outlined,
                    title: 'Tests',
                    color: Colors.cyan,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LabTestListScreen()),
                    ),
                  ),
                  _DashboardCard(
                    icon: Icons.add_circle_outline,
                    title: 'Order Test',
                    color: Colors.green,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddLabTestScreen()),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _DashboardCard({required this.icon, required this.title, required this.color, required this.onTap});

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
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
