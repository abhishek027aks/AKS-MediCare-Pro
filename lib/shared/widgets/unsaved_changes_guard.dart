import 'package:flutter/material.dart';

/// Wrap a form screen's body with this to get a confirmation dialog
/// whenever the user tries to leave (back button, system back, Esc)
/// while [hasUnsavedChanges] returns true.
///
/// Usage:
/// ```dart
/// bool _dirty = false;
/// // ...set _dirty = true in onChanged callbacks...
///
/// Scaffold(
///   body: UnsavedChangesGuard(
///     hasUnsavedChanges: () => _dirty,
///     child: Form(...),
///   ),
/// )
/// ```
///
/// This is applied to a representative set of the app's highest-traffic
/// forms (Patient, OPD) as the demonstrated pattern — extending it to
/// every add/edit screen in the app is mechanical (wrap the body, track
/// one bool) but wasn't done exhaustively across all ~60 forms.
class UnsavedChangesGuard extends StatelessWidget {
  const UnsavedChangesGuard({
    super.key,
    required this.hasUnsavedChanges,
    required this.child,
  });

  final bool Function() hasUnsavedChanges;
  final Widget child;

  Future<bool> _confirmDiscard(BuildContext context) async {
    if (!hasUnsavedChanges()) return true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 44),
        title: const Text('Discard changes?'),
        content: const Text('You have unsaved changes. Leaving now will lose them.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep Editing'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final shouldPop = await _confirmDiscard(context);
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: child,
    );
  }
}
