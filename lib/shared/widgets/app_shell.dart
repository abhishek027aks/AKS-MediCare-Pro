import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/providers/auth_state_provider.dart';

/// Wraps every routed screen (via MaterialApp.router's `builder`) to
/// provide two things every screen gets automatically, without any
/// per-screen wiring:
///
/// 1. Pressing Esc pops the current screen — the desktop equivalent
///    of the Android system back button, which already works for
///    free because every screen in this app uses standard
///    Navigator.push/MaterialPageRoute. Uses HardwareKeyboard's
///    global handler rather than a focus-scoped listener, so it
///    fires regardless of which widget currently has focus.
/// 2. After [_inactivityTimeout] of no pointer or keyboard activity
///    while logged in, the session is force-logged-out and the app
///    returns to Role Selection.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  static const Duration _inactivityTimeout = Duration(minutes: 15);

  Timer? _inactivityTimer;

  @override
  void initState() {
    super.initState();
    _resetInactivityTimer();
    HardwareKeyboard.instance.addHandler(_handleKeyEvent);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
    _inactivityTimer?.cancel();
    super.dispose();
  }

  bool _handleKeyEvent(KeyEvent event) {
    _resetInactivityTimer();

    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.escape) {
      final navigator = Navigator.of(context);
      if (navigator.canPop()) {
        navigator.maybePop();
      }
    }

    // Never consume the event — other widgets (text fields, etc.)
    // must still see it normally.
    return false;
  }

  void _resetInactivityTimer() {
    _inactivityTimer?.cancel();

    final isAuthenticated = ref.read(isAuthenticatedProvider);
    if (!isAuthenticated) return;

    _inactivityTimer = Timer(_inactivityTimeout, _handleTimeout);
  }

  Future<void> _handleTimeout() async {
    if (!mounted) return;

    final isAuthenticated = ref.read(isAuthenticatedProvider);
    if (!isAuthenticated) return;

    await ref.read(authProvider.notifier).logout();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Signed out due to inactivity.')),
    );

    context.go('/role-selection');
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _resetInactivityTimer(),
      onPointerMove: (_) => _resetInactivityTimer(),
      child: widget.child,
    );
  }
}
