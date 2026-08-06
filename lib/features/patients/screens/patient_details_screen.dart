import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/helpers/date_helper.dart';
import '../../../core/helpers/patient_helper.dart';
import '../../../shared/services/pdf_service.dart';
import '../models/patient_model.dart';
import '../providers/patient_provider.dart';
import '../widgets/delete_patient_dialog.dart';
import '../widgets/patient_documents_section.dart';
import 'edit_patient_screen.dart';

class PatientDetailsScreen extends ConsumerWidget {
  const PatientDetailsScreen({
    super.key,
    required this.patient,
  });

  final PatientModel patient;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Details'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.badge_outlined),
            tooltip: 'Print ID Card',
            onPressed: () => PdfService.printPatientIdCard(patient),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                      backgroundImage: patient.photoPath != null
                          ? FileImage(File(patient.photoPath!))
                          : null,
                      child: patient.photoPath == null
                          ? Text(
                              PatientHelper.getInitials(patient.fullName),
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      patient.fullName,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'UHID : ${patient.uhid}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    Chip(
                      avatar: Icon(
                        patient.isActive
                            ? Icons.check_circle
                            : Icons.remove_circle_outline,
                        size: 18,
                      ),
                      label: Text(patient.isActive ? 'Active' : 'Inactive'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
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
                      'Personal Information',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    _InfoTile(
                      icon: Icons.wc,
                      title: 'Gender',
                      value: patient.gender,
                    ),
                    const Divider(),
                    _InfoTile(
                      icon: Icons.cake_outlined,
                      title: 'Date of Birth',
                      value:
                          '${AppDateHelper.formatDate(patient.dateOfBirth)} (${patient.age} Y)',
                    ),
                    const Divider(),
                    _InfoTile(
                      icon: Icons.bloodtype_outlined,
                      title: 'Blood Group',
                      value: patient.bloodGroup ?? '—',
                    ),
                    const Divider(),
                    _InfoTile(
                      icon: Icons.family_restroom_outlined,
                      title: 'Marital Status',
                      value: patient.maritalStatus ?? '—',
                    ),
                    const Divider(),
                    _InfoTile(
                      icon: Icons.work_outline,
                      title: 'Occupation',
                      value: patient.occupation ?? '—',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
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
                      'Contact Information',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    _InfoTile(
                      icon: Icons.phone_outlined,
                      title: 'Mobile',
                      value: patient.mobile,
                    ),
                    const Divider(),
                    _InfoTile(
                      icon: Icons.phone_forwarded_outlined,
                      title: 'Alternate Mobile',
                      value: patient.alternateMobile ?? '—',
                    ),
                    const Divider(),
                    _InfoTile(
                      icon: Icons.email_outlined,
                      title: 'Email',
                      value: patient.email ?? '—',
                    ),
                    const Divider(),
                    _InfoTile(
                      icon: Icons.home_outlined,
                      title: 'Address',
                      value: [
                        patient.address,
                        patient.city,
                        patient.state,
                        patient.pincode,
                      ].where((e) => e != null && e.isNotEmpty).join(', '),
                    ),
                    const Divider(),
                    _InfoTile(
                      icon: Icons.contact_emergency_outlined,
                      title: 'Emergency Contact',
                      value: [
                        patient.emergencyContactName,
                        patient.emergencyContactNumber,
                      ].where((e) => e != null && e.isNotEmpty).join(' — '),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
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
                      'Other Information',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    _InfoTile(
                      icon: Icons.recommend_outlined,
                      title: 'Referred By',
                      value: patient.referredBy ?? '—',
                    ),
                    const Divider(),
                    _InfoTile(
                      icon: Icons.notes_outlined,
                      title: 'Notes',
                      value: patient.notes ?? '—',
                    ),
                    const Divider(),
                    _InfoTile(
                      icon: Icons.event_available_outlined,
                      title: 'Registered On',
                      value: AppDateHelper.formatDateTime(patient.createdAt),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            PatientDocumentsSection(patientId: patient.id!),
            const SizedBox(height: 24),
            Text(
              'Actions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () async {
                  final updated = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditPatientScreen(patient: patient),
                    ),
                  );

                  if (updated == true && context.mounted) {
                    await ref.read(patientProvider.notifier).refresh();
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  }
                },
                icon: const Icon(Icons.edit),
                label: const Text('Edit Patient'),
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
                    builder: (_) => DeletePatientDialog(patient: patient),
                  );

                  if (deleted == true && context.mounted) {
                    await ref.read(patientProvider.notifier).refresh();
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  }
                },
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete Patient'),
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
        value.isEmpty ? '—' : value,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}
