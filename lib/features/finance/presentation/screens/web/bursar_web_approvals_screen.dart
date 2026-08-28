import 'package:flutter/material.dart';
import 'package:school_pulse/features/finance/presentation/screens/bursar_approvals_screen.dart';

/// The approval stream and decision surface are shared with mobile.  On wide
/// layouts the Bursar shell already supplies the persistent navigation; the
/// detail sheet expands naturally to the available workspace.
class BursarWebApprovalsScreen extends StatelessWidget {
  const BursarWebApprovalsScreen({super.key});

  @override
  Widget build(BuildContext context) => const BursarApprovalsScreen();
}
