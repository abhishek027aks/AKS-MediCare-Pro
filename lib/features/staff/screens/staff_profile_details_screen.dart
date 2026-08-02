import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/staff_profile_model.dart';
import '../providers/staff_provider.dart';
import '../widgets/delete_staff_profile_dialog.dart';
import 'edit_staff_profile_screen.dart';

class StaffProfileDetailsScreen extends ConsumerWidget {
  const StaffProfileDetailsScreen({super.key, required this.profile});

  final StaffProfileModel profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Staff Profile'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Icon(Icons.badge_outlined, size: 52),
                    const SizedBox(height: 12),
                    Text(
                      profile.staffName,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text('${profile.role}  •  ${profile.specialization}'),
                    const SizedBox(height: 16),
                    Chip(
                      backgroundColor:
                          (profile.isAvailable ? Colors.green : Colors.red).withValues(alpha: 0.15),
                      avatar: Icon(
                        profile.isAvailable ? Icons.check_circle : Icons.cancel,
                        size: 18,
                        color: profile.isAvailable ? Colors.green : Colors.red,
                      ),
                      label: Text(profile.isAvailable ? 'Available' : 'Not Available'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Professional Details', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    _InfoTile(icon: Icons.meeting_room_outlined, title: 'Department', value: profile.department),
                    const Divider(),
                    _InfoTile(icon: Icons.school_outlined, title: 'Qualification', value: profile.qualification ?? '—'),
                    const Divider(),
                    _InfoTile(icon: Icons.badge_outlined, title: 'License / Reg. No', value: profile.licenseNumber ?? '—'),
                    const Divider(),
                    _InfoTile(
                      icon: Icons.timeline_outlined,
                      title: 'Experience',
                      value: profile.experienceYears == null ? '—' : '${profile.experienceYears} years',
                    ),
                    const Divider(),
                    _InfoTile(icon: Icons.schedule_outlined, title: 'Shift Timing', value: profile.shiftTiming),
                    const Divider(),
                    _InfoTile(
                      icon: Icons.currency_rupee,
                      title: 'Consultation Fee',
                      value: '₹${profile.consultationFee.toStringAsFixed(2)}',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Notes', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    Text(profile.notes ?? '—'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Actions', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () async {
                  final updated = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(builder: (_) => EditStaffProfileScreen(profile: profile)),
                  );

                  if (updated == true && context.mounted) {
                    await ref.read(staffProvider.notifier).refresh();
                    if (context.mounted) Navigator.pop(context);
                  }
                },
                icon: const Icon(Icons.edit),
                label: const Text('Edit Profile'),
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
                onPressed: () async {
                  final deleted = await showDialog<bool>(
                    context: context,
                    builder: (_) => DeleteStaffProfileDialog(profile: profile),
                  );

                  if (deleted == true && context.mounted) {
                    await ref.read(staffProvider.notifier).refresh();
                    if (context.mounted) Navigator.pop(context);
                  }
                },
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete Profile'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoTile({required this.icon, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(
        value.isEmpty ? '—' : value,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}
