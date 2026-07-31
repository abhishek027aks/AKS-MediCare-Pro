import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/auth_state_model.dart';
import 'auth_provider.dart';

/// Complete authentication state
final authStateProvider = Provider<AuthStateModel>(
  (ref) {
    return ref.watch(authProvider);
  },
);

/// Current logged-in user
final currentUserProvider = Provider(
  (ref) {
    return ref.watch(authProvider).user;
  },
);

/// Authentication status
final isAuthenticatedProvider = Provider<bool>(
  (ref) {
    return ref.watch(authProvider).isAuthenticated;
  },
);

/// Loading state
final authLoadingProvider = Provider<bool>(
  (ref) {
    return ref.watch(authProvider).isLoading;
  },
);

/// Error message
final authErrorProvider = Provider<String>(
  (ref) {
    return ref.watch(authProvider).errorMessage;
  },
);