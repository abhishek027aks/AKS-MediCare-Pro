import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/branch_repository.dart';
import '../models/branch_model.dart';

class BranchState {
  final bool isLoading;
  final List<BranchModel> branches;

  const BranchState({this.isLoading = false, this.branches = const []});

  BranchState copyWith({bool? isLoading, List<BranchModel>? branches}) {
    return BranchState(
      isLoading: isLoading ?? this.isLoading,
      branches: branches ?? this.branches,
    );
  }
}

class BranchNotifier extends StateNotifier<BranchState> {
  BranchNotifier() : super(const BranchState()) {
    load();
  }

  final BranchRepository _repository = BranchRepository.instance;

  Future<void> load() async {
    state = state.copyWith(isLoading: true);
    final branches = await _repository.getAllBranches();
    state = state.copyWith(isLoading: false, branches: branches);
  }

  Future<void> addBranch(BranchModel branch) async {
    await _repository.createBranch(branch);
    await load();
  }

  Future<void> updateBranch(BranchModel branch) async {
    await _repository.updateBranch(branch);
    await load();
  }

  Future<void> deleteBranch(int id) async {
    await _repository.deleteBranch(id);
    await load();
  }

  Future<void> refresh() async {
    await load();
  }
}

final branchProvider = StateNotifierProvider<BranchNotifier, BranchState>(
  (ref) => BranchNotifier(),
);
