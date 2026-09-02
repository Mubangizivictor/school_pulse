import 'package:flutter/material.dart';

export 'school_overview_screen.dart' show SchoolDetailScreen;

/// Shared suspend/reactivate confirmation dialog. Reused by the Schools
/// list's quick actions and Screen D's administrative actions so the
/// wording and behavior stay in one place.
void confirmSchoolStatusChange(
  BuildContext context, {
  required String action,
  required String message,
  required Color color,
  required VoidCallback onConfirm,
}) {
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text('$action School?'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: color),
          onPressed: () {
            onConfirm();
            Navigator.pop(dialogContext);
          },
          child: Text(action),
        ),
      ],
    ),
  );
}
