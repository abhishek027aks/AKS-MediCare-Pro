import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/appointment_repository.dart';
import '../models/appointment_model.dart';

/// ===============================
/// Appointment State
/// ===============================
class AppointmentState {
  final bool isLoading;
  final List<AppointmentModel> appointments;
  final String? errorMessage;

  const AppointmentState({
    this.isLoading = false,
    this.appointments = const [],
    this.errorMessage,
  });

  AppointmentState copyWith({
    bool? isLoading,
    List<AppointmentModel>? appointments,
    String? errorMessage,
  }) {
    return AppointmentState(
      isLoading: isLoading ?? this.isLoading,
      appointments: appointments ?? this.appointments,
      errorMessage: errorMessage,
    );
  }
}

/// ===============================
/// Appointment Provider
/// ===============================
class AppointmentNotifier extends StateNotifier<AppointmentState> {
  AppointmentNotifier() : super(const AppointmentState()) {
    loadAppointments();
  }

  final AppointmentRepository _repository = AppointmentRepository.instance;

  Future<void> loadAppointments() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final appointments = await _repository.getAllAppointments();

      state = state.copyWith(isLoading: false, appointments: appointments);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<bool> addAppointment(AppointmentModel appointment) async {
    try {
      await _repository.createAppointment(appointment);
      await loadAppointments();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateAppointment(AppointmentModel appointment) async {
    try {
      await _repository.updateAppointment(appointment);
      await loadAppointments();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteAppointment(int id) async {
    try {
      await _repository.deleteAppointment(id);
      await loadAppointments();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> refresh() async {
    await loadAppointments();
  }
}

/// ===============================
/// Riverpod Provider
/// ===============================
final appointmentProvider = StateNotifierProvider<AppointmentNotifier, AppointmentState>(
  (ref) => AppointmentNotifier(),
);
