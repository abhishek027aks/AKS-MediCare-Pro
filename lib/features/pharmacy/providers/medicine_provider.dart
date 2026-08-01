import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/medicine_repository.dart';
import '../models/medicine_model.dart';

/// ===============================
/// Medicine State
/// ===============================
class MedicineState {
  final bool isLoading;
  final List<MedicineModel> medicines;
  final String? errorMessage;

  const MedicineState({
    this.isLoading = false,
    this.medicines = const [],
    this.errorMessage,
  });

  MedicineState copyWith({
    bool? isLoading,
    List<MedicineModel>? medicines,
    String? errorMessage,
  }) {
    return MedicineState(
      isLoading: isLoading ?? this.isLoading,
      medicines: medicines ?? this.medicines,
      errorMessage: errorMessage,
    );
  }
}

/// ===============================
/// Medicine Provider
/// ===============================
class MedicineNotifier extends StateNotifier<MedicineState> {
  MedicineNotifier() : super(const MedicineState()) {
    loadMedicines();
  }

  final MedicineRepository _repository = MedicineRepository.instance;

  Future<void> loadMedicines() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final medicines = await _repository.getAllMedicines();

      state = state.copyWith(isLoading: false, medicines: medicines);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<bool> addMedicine(MedicineModel medicine) async {
    try {
      await _repository.createMedicine(medicine);
      await loadMedicines();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateMedicine(MedicineModel medicine) async {
    try {
      await _repository.updateMedicine(medicine);
      await loadMedicines();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteMedicine(int id) async {
    try {
      await _repository.deleteMedicine(id);
      await loadMedicines();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> refresh() async {
    await loadMedicines();
  }
}

/// ===============================
/// Riverpod Provider
/// ===============================
final medicineProvider = StateNotifierProvider<MedicineNotifier, MedicineState>(
  (ref) => MedicineNotifier(),
);
