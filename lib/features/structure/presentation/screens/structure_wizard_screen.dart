import 'package:flutter/material.dart';

import 'structure_screen.dart';

/// Canonical entry point for `/staff/admin/structure`.
///
/// The previous implementation rendered an empty/loading shell and then tried
/// to push the current setup step on a second route. When that push was
/// delayed, rejected by routing, or a step had already been recorded as
/// pushed, the shell remained visible and Structure appeared blank.
///
/// Structure now renders the real sequential setup surface directly. The
/// setup screen itself owns Back / Save & Continue and mounts the active
/// editor inline, so there is no intermediary navigation state that can leave
/// the administrator on an empty page.
class StructureWizardScreen extends StatelessWidget {
  const StructureWizardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const StructureScreen();
  }
}
