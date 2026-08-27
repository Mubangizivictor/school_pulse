import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';

import 'add_staff_wizard_controller.dart';
import 'steps/stage_01_profile.dart';
import 'steps/stage_02_work.dart';
import 'steps/stage_03_roles.dart';
import 'steps/stage_04_access.dart';
import 'steps/stage_05_review.dart';

/// Hosts the full Add Staff Member wizard as five visual stages - Profile,
/// Work, Roles, Access, Review - matching the black-and-white reference
/// design. A single route; the current stage is internal state on
/// AddStaffWizardController, not encoded in the URL. Pushed as its own
/// route (not part of the shell's bottom-nav'd tree), so the app's bottom
/// navigation is already hidden while this is on screen.
class AddStaffWizardPage extends StatefulWidget {
  const AddStaffWizardPage({super.key});

  @override
  State<AddStaffWizardPage> createState() => _AddStaffWizardPageState();
}

class _AddStaffWizardPageState extends State<AddStaffWizardPage> {
  late final AddStaffWizardController _controller;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    final schoolId = authState is AuthAuthenticated
        ? authState.user.schoolId
        : '';
    final adminUid = authState is AuthAuthenticated ? authState.user.id : '';

    _controller = AddStaffWizardController(
      schoolId: schoolId,
      adminUid: adminUid,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final restored = await _controller.restoreDraftIfPresent();
      if (restored && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Resumed your in-progress staff draft.'),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AddStaffWizardController>.value(
      value: _controller,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          _handleBack(context);
        },
        child: Consumer<AddStaffWizardController>(
          builder: (context, controller, _) {
            return _buildStage(controller.stage);
          },
        ),
      ),
    );
  }

  void _handleBack(BuildContext context) {
    final controller = context.read<AddStaffWizardController>();
    if (controller.stage == WizardStage.profile) {
      Navigator.of(context).maybePop();
    } else {
      controller.back();
    }
  }

  void _saveDraft(BuildContext context) {
    final controller = context.read<AddStaffWizardController>();
    controller.notifyDraftChanged();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Draft saved.')));
  }

  Widget _buildStage(WizardStage stage) {
    switch (stage) {
      case WizardStage.profile:
        return Stage01Profile(onSaveDraft: () => _saveDraft(context));
      case WizardStage.work:
        return Stage02Work(onSaveDraft: () => _saveDraft(context));
      case WizardStage.roles:
        return Stage03Roles(onSaveDraft: () => _saveDraft(context));
      case WizardStage.access:
        return Stage04Access(onSaveDraft: () => _saveDraft(context));
      case WizardStage.review:
      case WizardStage.success:
        return Stage05Review(onSaveDraft: () => _saveDraft(context));
    }
  }
}
