import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/helpers/date_helper.dart';
import '../../opd/screens/add_opd_visit_screen.dart';
import '../../patients/models/patient_model.dart';
import '../models/appointment_model.dart';
import '../providers/appointment_provider.dart';
import '../widgets/delete_appointment_dialog.dart';
import 'edit_appointment_screen.dart';

class AppointmentDetailsScreen extends ConsumerWidget {
  const AppointmentDetailsScreen({super.key, required this.appointment});

  final AppointmentModel appointment;

  Color _statusColor(String status) {
    switch (status) {
      case 'Confirmed':
        return Colors.blue;
      case 'Completed':
        return Colors.green;
      case 'Cancelled':
      case 'No Show':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Appointment Details'), centerTitle: true),
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
                    const Icon(Icons.event_available_outlined, size: 52),
                    const SizedBox(height: 12),
                    Text(
                      appointment.patientName,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text('UHID : ${appointment.patientUhid}'),
                    Text('Appointment No : ${appointment.appointmentNo}'),
                    const SizedBox(height: 16),
                    Chip(
                      backgroundColor: _statusColor(appointment.status).withValues(alpha: 0.15),
                      label: Text(
                        appointment.status,
                        style: TextStyle(color: _statusColor(appointment.status)),
                      ),
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
                    Text('Appointment Information', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    _InfoTile(icon: Icons.medical_services_outlined, title: 'Doctor', value: appointment.doctorName),
                    const Divider(),
                    _InfoTile(icon: Icons.event_outlined, title: 'Date', value: AppDateHelper.formatDate(appointment.appointmentDate)),
                    const Divider(),
                    _InfoTile(icon: Icons.access_time_outlined, title: 'Time Slot', value: appointment.appointmentTime),
                    const Divider(),
                    _InfoTile(icon: Icons.description_outlined, title: 'Reason for Visit', value: appointment.reasonForVisit ?? '—'),
                    const Divider(),
                    _InfoTile(icon: Icons.notes_outlined, title: 'Notes', value: appointment.notes ?? '—'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Actions', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            if (appointment.status != 'Completed' && appointment.status != 'Cancelled') ...[
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddOpdVisitScreen(
                          prefillPatient: PatientModel(
                            id: appointment.patientId,
                            uhid: appointment.patientUhid,
                            fullName: appointment.patientName,
                            gender: '',
                            dateOfBirth: DateTime(1970),
                            mobile: '',
                            createdAt: DateTime.now(),
                            updatedAt: DateTime.now(),
                          ),
                          prefillDoctorId: appointment.doctorId,
                          prefillDoctorName: appointment.doctorName,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.how_to_reg_outlined),
                  label: const Text('Check In (Create OPD Visit)'),
                ),
              ),
              const SizedBox(height: 12),
            ],
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final updated = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(builder: (_) => EditAppointmentScreen(appointment: appointment)),
                  );

                  if (updated == true && context.mounted) {
                    await ref.read(appointmentProvider.notifier).refresh();
                    if (context.mounted) Navigator.pop(context);
                  }
                },
                icon: const Icon(Icons.edit),
                label: const Text('Edit Appointment'),
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
                    builder: (_) => DeleteAppointmentDialog(appointment: appointment),
                  );

                  if (deleted == true && context.mounted) {
                    await ref.read(appointmentProvider.notifier).refresh();
                    if (context.mounted) Navigator.pop(context);
                  }
                },
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete Appointment'),
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
