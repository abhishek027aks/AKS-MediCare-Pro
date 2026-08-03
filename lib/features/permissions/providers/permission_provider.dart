import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/providers/auth_state_provider.dart';
import '../../user_management/models/user_model.dart';
import '../data/repositories/permission_repository.dart';
import '../models/permission_model.dart';

/// ===============================
/// Permission Matrix State (all roles × all modules — Admin screen)
/// ===============================
class PermissionMatrixState {
  final bool isLoading;
  final List<PermissionModel> permissions;

  const PermissionMatrixState({this.isLoading = false, this.permissions = const []});

  PermissionMatrixState copyWith({bool? isLoading, List<PermissionModel>? permissions}) {
    return PermissionMatrixState(
      isLoading: isLoading ?? this.isLoading,
      permissions: permissions ?? this.permissions,
    );
  }
}

class PermissionMatrixNotifier extends StateNotifier<PermissionMatrixState> {
  PermissionMatrixNotifier() : super(const PermissionMatrixState()) {
    load();
  }

  final PermissionRepository _repository = PermissionRepository.instance;

  Future<void> load() async {
    state = state.copyWith(isLoading: true);
    await _repository.ensureSeeded();
    final permissions = await _repository.getAllPermissions();
    state = state.copyWith(isLoading: false, permissions: permissions);
  }

  Future<void> updatePermission(PermissionModel permission) async {
    await _repository.updatePermission(permission);
    await load();
  }

  Future<void> refresh() async {
    await load();
  }
}

final permissionMatrixProvider =
    StateNotifierProvider<PermissionMatrixNotifier, PermissionMatrixState>(
  (ref) => PermissionMatrixNotifier(),
);

/// ===============================
/// Current user's own permissions — reactive, for gating UI
/// ===============================
class CurrentUserPermissionsNotifier extends StateNotifier<List<PermissionModel>> {
  CurrentUserPermissionsNotifier() : super(const []);

  final PermissionRepository _repository = PermissionRepository.instance;

  Future<void> loadFor(UserModel? user) async {
    if (user == null) {
      state = const [];
      return;
    }

    await _repository.ensureSeeded();
    state = await _repository.getPermissionsForRole(user.role);
  }

  /// Whether the current user's role has [action] on [module].
  /// Unknown modules/roles default to false — a missing permission
  /// row is treated as "no access", never "full access".
  bool can(String module, {required String action}) {
    final match = state.where((p) => p.module == module);
    if (match.isEmpty) return false;

    final permission = match.first;

    switch (action) {
      case 'view':
        return permission.canView;
      case 'add':
        return permission.canAdd;
      case 'edit':
        return permission.canEdit;
      case 'delete':
        return permission.canDelete;
      case 'approve':
        return permission.canApprove;
      default:
        return false;
    }
  }
}

final currentUserPermissionsProvider =
    StateNotifierProvider<CurrentUserPermissionsNotifier, List<PermissionModel>>(
  (ref) {
    final notifier = CurrentUserPermissionsNotifier();
    final user = ref.watch(currentUserProvider);
    notifier.loadFor(user);
    return notifier;
  },
);
