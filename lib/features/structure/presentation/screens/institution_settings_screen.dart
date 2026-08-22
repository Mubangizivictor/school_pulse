import 'package:flutter/material.dart';
import 'package:school_pulse/features/admin/presentation/widgets/admin_app_bar.dart';
import '../widgets/institution_tab.dart';
import '../widgets/structure_wizard_banner.dart';

/// Full-screen entry point for the tenant's editable identity, branding and
/// locale configuration. The same form can still be embedded elsewhere via
/// [InstitutionTab], but setup-roadmap links must land on an actual editor.
class InstitutionSettingsScreen extends StatelessWidget {
  const InstitutionSettingsScreen({
    super.key,
    this.wizardStep,
    this.wizardTotal,
    this.wizardStepId = 'institution-info',
    this.tabKey,
    this.showAppBar = true,
  });

  final int? wizardStep;
  final int? wizardTotal;
  final String wizardStepId;
  final GlobalKey<InstitutionTabState>? tabKey;
  final bool showAppBar;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: showAppBar
        ? AdminAppBar(
            title: 'Institution Settings',
            bottom: wizardStep == null || wizardTotal == null
                ? null
                : StructureWizardBanner(
                    stepId: wizardStepId,
                    stepNumber: wizardStep!,
                    totalSteps: wizardTotal!,
                  ),
          )
        : null,
    backgroundColor: showAppBar ? null : Colors.transparent,
    body: InstitutionTab(key: tabKey),
  );
}
