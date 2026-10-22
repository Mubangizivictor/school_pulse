import 'package:flutter/material.dart';

/// Intercepts platform back (including iOS edge-back) while an owner form has
/// edits. The actual page is only popped after an explicit discard decision;
/// this keeps the platform Navigator history intact instead of replacing a
/// route with an index change.
class SuperAdminUnsavedChangesGuard extends StatefulWidget {
  const SuperAdminUnsavedChangesGuard({
    super.key,
    required this.hasUnsavedChanges,
    required this.child,
    this.message = 'Discard your unsaved changes?',
  });

  final bool hasUnsavedChanges;
  final Widget child;
  final String message;

  @override
  State<SuperAdminUnsavedChangesGuard> createState() =>
      _SuperAdminUnsavedChangesGuardState();
}

class _SuperAdminUnsavedChangesGuardState
    extends State<SuperAdminUnsavedChangesGuard> {
  bool _confirming = false;

  Future<void> _handleBlockedPop() async {
    if (_confirming) return;
    _confirming = true;
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard changes?'),
        content: Text(widget.message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep editing'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    _confirming = false;
    if (discard == true && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !widget.hasUnsavedChanges,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop && widget.hasUnsavedChanges) _handleBlockedPop();
    },
    child: widget.child,
  );
}
