import 'package:flutter/material.dart';

/// STUB — the original implementation of this screen was accidentally
/// deleted (uncommitted, unrecoverable) while working on an unrelated task.
/// This placeholder exists only so `/staff/admin/school-setup` keeps
/// compiling; it needs to be rebuilt with its real content.
class SchoolSetupScreen extends StatelessWidget {
  const SchoolSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('School setup')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'This screen needs to be rebuilt — its previous implementation '
            'was lost before being committed.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
