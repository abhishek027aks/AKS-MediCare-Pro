import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/login_history_repository.dart';
import '../models/login_history_model.dart';

class LoginHistoryState {
  final bool isLoading;
  final List<LoginHistoryModel> history;

  const LoginHistoryState({this.isLoading = false, this.history = const []});

  LoginHistoryState copyWith({bool? isLoading, List<LoginHistoryModel>? history}) {
    return LoginHistoryState(
      isLoading: isLoading ?? this.isLoading,
      history: history ?? this.history,
    );
  }
}

class LoginHistoryNotifier extends StateNotifier<LoginHistoryState> {
  LoginHistoryNotifier() : super(const LoginHistoryState()) {
    load();
  }

  final LoginHistoryRepository _repository = LoginHistoryRepository.instance;

  Future<void> load() async {
    state = state.copyWith(isLoading: true);
    final history = await _repository.getAllHistory();
    state = state.copyWith(isLoading: false, history: history);
  }

  Future<void> refresh() async {
    await load();
  }
}

final loginHistoryProvider = StateNotifierProvider<LoginHistoryNotifier, LoginHistoryState>(
  (ref) => LoginHistoryNotifier(),
);
