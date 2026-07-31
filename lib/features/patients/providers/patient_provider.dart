import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/patient_repository.dart';
import '../models/patient_model.dart';

/// ===============================
/// Patient State
/// ===============================
class PatientState {
  final bool isLoading;
  final List<PatientModel> patients;
  final String? errorMessage;

  const PatientState({
    this.isLoading = false,
    this.patients = const [],
    this.errorMessage,
  });

  PatientState copyWith({
    bool? isLoading,
    List<PatientModel>? patients,
    String? errorMessage,
  }) {
    return PatientState(
      isLoading: isLoading ?? this.isLoading,
      patients: patients ?? this.patients,
      errorMessage: errorMessage,
    );
  }
}

/// ===============================
/// Patient Provider
/// ===============================
class PatientNotifier extends StateNotifier<PatientState> {
  PatientNotifier() : super(const PatientState()) {
    loadPatients();
  }

  final PatientRepository _repository = PatientRepository.instance;

  /// Load Patients
  Future<void> loadPatients() async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
    );

    try {
      final patients = await _repository.getAllPatients();

      state = state.copyWith(
        isLoading: false,
        patients: patients,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Add Patient
  Future<bool> addPatient(PatientModel patient) async {
    try {
      await _repository.createPatient(patient);
      await loadPatients();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Update Patient
  Future<bool> updatePatient(PatientModel patient) async {
    try {
      await _repository.updatePatient(patient);
      await loadPatients();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Delete Patient
  Future<bool> deletePatient(int id) async {
    try {
      await _repository.deletePatient(id);
      await loadPatients();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Refresh
  Future<void> refresh() async {
    await loadPatients();
  }
}

/// ===============================
/// Riverpod Provider
/// ===============================
final patientProvider = StateNotifierProvider<PatientNotifier, PatientState>(
  (ref) => PatientNotifier(),
);
