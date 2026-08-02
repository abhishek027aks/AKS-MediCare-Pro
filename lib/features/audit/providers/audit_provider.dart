import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/audit_repository.dart';
import '../models/audit_log_model.dart';

/// ===============================
/// Audit State
/// ===============================
class AuditState {
  final bool isLoading;
  final List<AuditLogModel> logs;
  final String? errorMessage;

  const AuditState({
    this.isLoading = false,
    this.logs = const [],
    this.errorMessage,
  });

  AuditState copyWith({
    bool? isLoading,
    List<AuditLogModel>? logs,
    String? errorMessage,
  }) {
    return AuditState(
      isLoading: isLoading ?? this.isLoading,
      logs: logs ?? this.logs,
      errorMessage: errorMessage,
    );
  }
}

/// ===============================
/// Audit Provider
/// ===============================
class AuditNotifier extends StateNotifier<AuditState> {
  AuditNotifier() : super(const AuditState()) {
    loadLogs();
  }

  final AuditRepository _repository = AuditRepository.instance;

  Future<void> loadLogs() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final logs = await _repository.getAllLogs();

      state = state.copyWith(isLoading: false, logs: logs);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> refresh() async {
    await loadLogs();
  }
}

/// ===============================
/// Riverpod Provider
/// ===============================
final auditProvider = StateNotifierProvider<AuditNotifier, AuditState>(
  (ref) => AuditNotifier(),
);
