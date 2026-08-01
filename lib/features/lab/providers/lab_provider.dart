import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/lab_repository.dart';
import '../models/lab_test_model.dart';

/// ===============================
/// Lab State
/// ===============================
class LabState {
  final bool isLoading;
  final List<LabTestModel> tests;
  final String? errorMessage;

  const LabState({
    this.isLoading = false,
    this.tests = const [],
    this.errorMessage,
  });

  LabState copyWith({
    bool? isLoading,
    List<LabTestModel>? tests,
    String? errorMessage,
  }) {
    return LabState(
      isLoading: isLoading ?? this.isLoading,
      tests: tests ?? this.tests,
      errorMessage: errorMessage,
    );
  }
}

/// ===============================
/// Lab Provider
/// ===============================
class LabNotifier extends StateNotifier<LabState> {
  LabNotifier() : super(const LabState()) {
    loadTests();
  }

  final LabRepository _repository = LabRepository.instance;

  Future<void> loadTests() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final tests = await _repository.getAllTests();

      state = state.copyWith(isLoading: false, tests: tests);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<bool> addTest(LabTestModel test) async {
    try {
      await _repository.createTest(test);
      await loadTests();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateTest(LabTestModel test) async {
    try {
      await _repository.updateTest(test);
      await loadTests();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteTest(int id) async {
    try {
      await _repository.deleteTest(id);
      await loadTests();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> refresh() async {
    await loadTests();
  }
}

/// ===============================
/// Riverpod Provider
/// ===============================
final labProvider = StateNotifierProvider<LabNotifier, LabState>(
  (ref) => LabNotifier(),
);
