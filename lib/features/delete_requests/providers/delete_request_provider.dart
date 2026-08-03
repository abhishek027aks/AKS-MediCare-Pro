import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/delete_request_repository.dart';
import '../models/delete_request_model.dart';

class DeleteRequestState {
  final bool isLoading;
  final List<DeleteRequestModel> requests;

  const DeleteRequestState({this.isLoading = false, this.requests = const []});

  DeleteRequestState copyWith({bool? isLoading, List<DeleteRequestModel>? requests}) {
    return DeleteRequestState(
      isLoading: isLoading ?? this.isLoading,
      requests: requests ?? this.requests,
    );
  }

  int get pendingCount => requests.where((r) => r.status == 'Pending').length;
}

class DeleteRequestNotifier extends StateNotifier<DeleteRequestState> {
  DeleteRequestNotifier() : super(const DeleteRequestState()) {
    load();
  }

  final DeleteRequestRepository _repository = DeleteRequestRepository.instance;

  Future<void> load() async {
    state = state.copyWith(isLoading: true);
    final requests = await _repository.getAllRequests();
    state = state.copyWith(isLoading: false, requests: requests);
  }

  Future<void> refresh() async {
    await load();
  }
}

final deleteRequestProvider = StateNotifierProvider<DeleteRequestNotifier, DeleteRequestState>(
  (ref) => DeleteRequestNotifier(),
);
