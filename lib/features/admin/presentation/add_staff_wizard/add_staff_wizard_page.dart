import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';

import 'add_staff_wizard_controller.dart';
import 'steps/step_02_personal_info.dart';
import 'steps/step_03_contact_info.dart';
import 'steps/step_04_employment_info.dart';
import 'steps/step_05_select_roles.dart';
import 'steps/step_06_configure_role.dart';
import 'steps/step_07_roles_summary.dart';
import 'steps/step_08_access_preview.dart';
import 'steps/step_09_login_security.dart';
import 'steps/step_10_documents.dart';
import 'steps/step_11_review_confirm.dart';
import 'steps/step_12_success.dart';

/// Hosts the full Add Staff Member wizard. A single route; the current step
/// is internal state on AddStaffWizardController, not encoded in the URL.
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
            return _buildStep(controller.step);
          },
        ),
      ),
    );
  }

  void _handleBack(BuildContext context) {
    final controller = context.read<AddStaffWizardController>();
    if (controller.step == WizardStep.personalInfo) {
      Navigator.of(context).maybePop();
    } else {
      controller.back();
    }
  }

  Widget _buildStep(WizardStep step) {
    switch (step) {
      case WizardStep.personalInfo:
        return const Step02PersonalInfo();
      case WizardStep.contactInfo:
        return const Step03ContactInfo();
      case WizardStep.employmentInfo:
        return const Step04EmploymentInfo();
      case WizardStep.selectRoles:
        return const Step05SelectRoles();
      case WizardStep.configureRole:
        return const Step06ConfigureRole();
      case WizardStep.rolesSummary:
        return const Step07RolesSummary();
      case WizardStep.accessPreview:
        return const Step08AccessPreview();
      case WizardStep.loginSecurity:
        return const Step09LoginSecurity();
      case WizardStep.documents:
        return const Step10Documents();
      case WizardStep.reviewConfirm:
        return const Step11ReviewConfirm();
      case WizardStep.success:
        return const Step12Success();
    }
  }
}
