import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/ipd_repository.dart';
import '../models/ipd_admission_model.dart';

/// ===============================
/// IPD State
/// ===============================
class IpdState {
  final bool isLoading;
  final List<IpdAdmissionModel> admissions;
  final String? errorMessage;

  const IpdState({
    this.isLoading = false,
    this.admissions = const [],
    this.errorMessage,
  });

  IpdState copyWith({
    bool? isLoading,
    List<IpdAdmissionModel>? admissions,
    String? errorMessage,
  }) {
    return IpdState(
      isLoading: isLoading ?? this.isLoading,
      admissions: admissions ?? this.admissions,
      errorMessage: errorMessage,
    );
  }
}

/// ===============================
/// IPD Provider
/// ===============================
class IpdNotifier extends StateNotifier<IpdState> {
  IpdNotifier() : super(const IpdState()) {
    loadAdmissions();
  }

  final IpdRepository _repository = IpdRepository.instance;

  Future<void> loadAdmissions() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final admissions = await _repository.getAllAdmissions();

      state = state.copyWith(isLoading: false, admissions: admissions);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<bool> addAdmission(IpdAdmissionModel admission) async {
    try {
      await _repository.createAdmission(admission);
      await loadAdmissions();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateAdmission(IpdAdmissionModel admission) async {
    try {
      await _repository.updateAdmission(admission);
      await loadAdmissions();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteAdmission(int id) async {
    try {
      await _repository.deleteAdmission(id);
      await loadAdmissions();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> refresh() async {
    await loadAdmissions();
  }
}

/// ===============================
/// Riverpod Provider
/// ===============================
final ipdProvider = StateNotifierProvider<IpdNotifier, IpdState>(
  (ref) => IpdNotifier(),
);
