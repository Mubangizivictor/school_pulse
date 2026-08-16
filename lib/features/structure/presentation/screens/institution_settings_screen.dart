import 'package:flutter/material.dart';
import 'package:school_pulse/features/admin/presentation/widgets/admin_app_bar.dart';
import '../widgets/institution_tab.dart';

/// Full-screen entry point for the tenant's editable identity, branding and
/// locale configuration. The same form can still be embedded elsewhere via
/// [InstitutionTab], but setup-roadmap links must land on an actual editor.
class InstitutionSettingsScreen extends StatelessWidget {
  const InstitutionSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) => const Scaffold(
    appBar: AdminAppBar(title: 'Institution Settings'),
    body: InstitutionTab(),
  );
}
