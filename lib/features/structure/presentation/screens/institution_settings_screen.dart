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
    this.wizardMode = false,
  });

  final int? wizardStep;
  final int? wizardTotal;
  final String wizardStepId;
  final GlobalKey<InstitutionTabState>? tabKey;
  final bool showAppBar;
  final bool wizardMode;

  @override
  Widget build(BuildContext context) {
    final tab = InstitutionTab(key: tabKey, wizardMode: wizardMode);
    if (!showAppBar) {
      // No app bar means this is embedded inside another Scaffold (the
      // wizard step shell). Nesting a second Scaffold here used to give the
      // form's LayoutBuilder a zero-height constraint in some layouts -
      // returning the body directly avoids that entirely.
      //
      // The background must be opaque, not transparent: this widget sits on
      // top of a full-screen page pushed over the admin dashboard shell, and
      // a transparent gap here let that shell's sidebar show through behind
      // the form on web.
      return ColoredBox(color: Colors.white, child: tab);
    }
    return Scaffold(
      appBar: AdminAppBar(
        title: 'Institution Settings',
        bottom: wizardStep == null || wizardTotal == null
            ? null
            : StructureWizardBanner(
                stepId: wizardStepId,
                stepNumber: wizardStep!,
                totalSteps: wizardTotal!,
              ),
      ),
      body: tab,
    );
  }
}
