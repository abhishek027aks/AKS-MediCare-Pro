import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/opd_repository.dart';
import '../models/opd_visit_model.dart';

/// ===============================
/// OPD State
/// ===============================
class OpdState {
  final bool isLoading;
  final List<OpdVisitModel> visits;
  final String? errorMessage;

  const OpdState({
    this.isLoading = false,
    this.visits = const [],
    this.errorMessage,
  });

  OpdState copyWith({
    bool? isLoading,
    List<OpdVisitModel>? visits,
    String? errorMessage,
  }) {
    return OpdState(
      isLoading: isLoading ?? this.isLoading,
      visits: visits ?? this.visits,
      errorMessage: errorMessage,
    );
  }
}

/// ===============================
/// OPD Provider
/// ===============================
class OpdNotifier extends StateNotifier<OpdState> {
  OpdNotifier() : super(const OpdState()) {
    loadVisits();
  }

  final OpdRepository _repository = OpdRepository.instance;

  Future<void> loadVisits() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final visits = await _repository.getAllVisits();

      state = state.copyWith(isLoading: false, visits: visits);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<bool> addVisit(OpdVisitModel visit) async {
    try {
      await _repository.createVisit(visit);
      await loadVisits();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateVisit(OpdVisitModel visit) async {
    try {
      await _repository.updateVisit(visit);
      await loadVisits();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteVisit(int id) async {
    try {
      await _repository.deleteVisit(id);
      await loadVisits();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> refresh() async {
    await loadVisits();
  }
}

/// ===============================
/// Riverpod Provider
/// ===============================
final opdProvider = StateNotifierProvider<OpdNotifier, OpdState>(
  (ref) => OpdNotifier(),
);
