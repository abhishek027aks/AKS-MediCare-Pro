import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/helpers/date_helper.dart';
import '../../appointments/providers/appointment_provider.dart';
import '../../appointments/screens/appointment_details_screen.dart';
import '../../opd/providers/opd_provider.dart';
import '../../opd/screens/opd_visit_details_screen.dart';

/// In-app aggregation of upcoming OPD follow-ups and appointments.
///
/// This is NOT a push-notification feature — it's a read-only view
/// that pulls together dates already stored on OPD visits and
/// Appointments, for staff to scan at a glance. Adding real OS-level
/// notifications would need a new dependency (flutter_local_notifications)
/// and platform setup, which is a separate, larger piece of work.
class RemindersScreen extends ConsumerWidget {
  const RemindersScreen({super.key});

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);

    final visits = ref.watch(opdProvider).visits;
    final appointments = ref.watch(appointmentProvider).appointments;

    final followUps = visits.where((v) => v.followUpDate != null).toList()
      ..sort((a, b) => a.followUpDate!.compareTo(b.followUpDate!));

    final overdueFollowUps = followUps.where((v) => v.followUpDate!.isBefore(todayStart)).toList();
    final upcomingFollowUps = followUps.where((v) => !v.followUpDate!.isBefore(todayStart)).toList();

    final upcomingAppointments = appointments
        .where((a) =>
            (a.status == 'Scheduled' || a.status == 'Confirmed') &&
            !a.appointmentDate.isBefore(todayStart))
        .toList()
      ..sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));

    return Scaffold(
      appBar: AppBar(title: const Text('Reminders')),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(opdProvider.notifier).refresh();
          await ref.read(appointmentProvider.notifier).refresh();
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            if (overdueFollowUps.isEmpty && upcomingFollowUps.isEmpty && upcomingAppointments.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 80),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.notifications_none, size: 64),
                      SizedBox(height: 16),
                      Text('Nothing due — you\'re all caught up.'),
                    ],
                  ),
                ),
              ),
            if (overdueFollowUps.isNotEmpty) ...[
              Text(
                'Overdue Follow-ups',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.red),
              ),
              const SizedBox(height: 12),
              ...overdueFollowUps.map(
                (visit) => Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  elevation: 0,
                  color: Colors.red.withValues(alpha: 0.06),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: ListTile(
                    leading: const Icon(Icons.warning_amber_rounded, color: Colors.red),
                    title: Text(visit.patientName),
                    subtitle: Text(
                      'Was due ${AppDateHelper.formatDate(visit.followUpDate!)}  •  Dr. ${visit.doctorName}',
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => OpdVisitDetailsScreen(visit: visit)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
            if (upcomingFollowUps.isNotEmpty) ...[
              Text('Upcoming Follow-ups', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              ...upcomingFollowUps.map((visit) {
                final isToday = _isSameDay(visit.followUpDate!, today);

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  elevation: 0,
                  color: isToday ? Colors.orange.withValues(alpha: 0.08) : null,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: ListTile(
                    leading: Icon(Icons.event_repeat_outlined, color: isToday ? Colors.orange : null),
                    title: Text(visit.patientName),
                    subtitle: Text(
                      '${isToday ? "Today" : AppDateHelper.formatDate(visit.followUpDate!)}  •  Dr. ${visit.doctorName}',
                    ),
                    trailing: isToday ? const Chip(label: Text('Today')) : null,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => OpdVisitDetailsScreen(visit: visit)),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 20),
            ],
            if (upcomingAppointments.isNotEmpty) ...[
              Text('Upcoming Appointments', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              ...upcomingAppointments.map((appointment) {
                final isToday = _isSameDay(appointment.appointmentDate, today);

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  elevation: 0,
                  color: isToday ? Colors.blue.withValues(alpha: 0.06) : null,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: ListTile(
                    leading: Icon(Icons.event_available_outlined, color: isToday ? Colors.blue : null),
                    title: Text(appointment.patientName),
                    subtitle: Text(
                      '${isToday ? "Today" : AppDateHelper.formatDate(appointment.appointmentDate)}, '
                      '${appointment.appointmentTime}  •  Dr. ${appointment.doctorName}',
                    ),
                    trailing: isToday ? const Chip(label: Text('Today')) : null,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AppointmentDetailsScreen(appointment: appointment)),
                    ),
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}
