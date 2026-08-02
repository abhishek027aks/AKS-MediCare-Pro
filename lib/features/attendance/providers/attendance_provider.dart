import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/attendance_repository.dart';
import '../models/attendance_model.dart';

/// ===============================
/// Attendance State
/// ===============================
class AttendanceState {
  final bool isLoading;
  final List<AttendanceModel> records;
  final String? errorMessage;

  const AttendanceState({
    this.isLoading = false,
    this.records = const [],
    this.errorMessage,
  });

  AttendanceState copyWith({
    bool? isLoading,
    List<AttendanceModel>? records,
    String? errorMessage,
  }) {
    return AttendanceState(
      isLoading: isLoading ?? this.isLoading,
      records: records ?? this.records,
      errorMessage: errorMessage,
    );
  }
}

/// ===============================
/// Attendance Provider
/// ===============================
class AttendanceNotifier extends StateNotifier<AttendanceState> {
  AttendanceNotifier() : super(const AttendanceState()) {
    loadRecords();
  }

  final AttendanceRepository _repository = AttendanceRepository.instance;

  Future<void> loadRecords() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final records = await _repository.getAllRecords();

      state = state.copyWith(isLoading: false, records: records);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<bool> addRecord(AttendanceModel record) async {
    try {
      await _repository.createRecord(record);
      await loadRecords();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateRecord(AttendanceModel record) async {
    try {
      await _repository.updateRecord(record);
      await loadRecords();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteRecord(int id) async {
    try {
      await _repository.deleteRecord(id);
      await loadRecords();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> refresh() async {
    await loadRecords();
  }
}

/// ===============================
/// Riverpod Provider
/// ===============================
final attendanceProvider = StateNotifierProvider<AttendanceNotifier, AttendanceState>(
  (ref) => AttendanceNotifier(),
);
