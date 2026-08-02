import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/staff_repository.dart';
import '../models/staff_profile_model.dart';

/// ===============================
/// Staff State
/// ===============================
class StaffState {
  final bool isLoading;
  final List<StaffProfileModel> profiles;
  final String? errorMessage;

  const StaffState({
    this.isLoading = false,
    this.profiles = const [],
    this.errorMessage,
  });

  StaffState copyWith({
    bool? isLoading,
    List<StaffProfileModel>? profiles,
    String? errorMessage,
  }) {
    return StaffState(
      isLoading: isLoading ?? this.isLoading,
      profiles: profiles ?? this.profiles,
      errorMessage: errorMessage,
    );
  }
}

/// ===============================
/// Staff Provider
/// ===============================
class StaffNotifier extends StateNotifier<StaffState> {
  StaffNotifier() : super(const StaffState()) {
    loadProfiles();
  }

  final StaffRepository _repository = StaffRepository.instance;

  Future<void> loadProfiles() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final profiles = await _repository.getAllProfiles();

      state = state.copyWith(isLoading: false, profiles: profiles);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<bool> addProfile(StaffProfileModel profile) async {
    try {
      await _repository.createProfile(profile);
      await loadProfiles();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateProfile(StaffProfileModel profile) async {
    try {
      await _repository.updateProfile(profile);
      await loadProfiles();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteProfile(int id) async {
    try {
      await _repository.deleteProfile(id);
      await loadProfiles();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> refresh() async {
    await loadProfiles();
  }
}

/// ===============================
/// Riverpod Provider
/// ===============================
final staffProvider = StateNotifierProvider<StaffNotifier, StaffState>(
  (ref) => StaffNotifier(),
);
