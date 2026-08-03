import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/helpers/role_helper.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  static const Map<String, IconData> _roleIcons = {
    RoleHelper.hospitalHead: Icons.workspace_premium_outlined,
    RoleHelper.administrator: Icons.admin_panel_settings_outlined,
    RoleHelper.doctor: Icons.medical_services_outlined,
    RoleHelper.nurse: Icons.local_hospital_outlined,
    RoleHelper.pharmacist: Icons.medication_outlined,
    RoleHelper.labTechnician: Icons.biotech_outlined,
    RoleHelper.radiologist: Icons.camera_outlined,
    RoleHelper.accountant: Icons.calculate_outlined,
    RoleHelper.receptionist: Icons.support_agent_outlined,
    RoleHelper.storeManager: Icons.inventory_2_outlined,
    RoleHelper.emergencyDesk: Icons.emergency_outlined,
    RoleHelper.itAdministrator: Icons.dns_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 700;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F8),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isDesktop ? 720 : double.infinity),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Text(
                    'Select Your Role',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Select your role to continue to secure login',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 28),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: isDesktop ? 4 : 3,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 1,
                    children: RoleHelper.allRoles.map((role) {
                      return _RoleCard(
                        role: role,
                        icon: _roleIcons[role] ?? Icons.person_outline,
                        onTap: () => context.go('/login', extra: role),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({required this.role, required this.icon, required this.onTap});

  final String role;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 30, color: const Color(0xFF00695C)),
              const SizedBox(height: 10),
              Text(
                role,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
