import 'dart:async';

import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/design_system/components/wizard_scaffold.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/structure/domain/repositories/structure_repository.dart';
import 'package:school_pulse/injection_container.dart' as di;

import '../add_staff_wizard_controller.dart';
import '../models/role_assignment_draft.dart';
import '../role_config/role_assignment_config_registry.dart';
import '../role_config/role_config_form.dart';

class Step06ConfigureRole extends StatefulWidget {
  const Step06ConfigureRole({super.key});

  @override
  State<Step06ConfigureRole> createState() => _Step06ConfigureRoleState();
}

class _Step06ConfigureRoleState extends State<Step06ConfigureRole> {
  final _structureRepository = di.sl<StructureRepository>();
  List<String> _classNames = [];
  List<String> _subjectNames = [];
  StreamSubscription? _classesSub;
  StreamSubscription? _subjectsSub;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    final schoolId = authState is AuthAuthenticated
        ? authState.user.schoolId
        : '';
    _classesSub = _structureRepository.watchClasses(schoolId).listen((classes) {
      if (mounted)
        setState(() => _classNames = classes.map((c) => c.name).toList());
    });
    _subjectsSub = _structureRepository.watchSubjects(schoolId).listen((
      subjects,
    ) {
      if (mounted)
        setState(() => _subjectNames = subjects.map((s) => s.name).toList());
    });
  }

  @override
  void dispose() {
    _classesSub?.cancel();
    _subjectsSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AddStaffWizardController>();
    final roles = controller.rolesNeedingConfig;

    if (roles.isEmpty) {
      // Guard against reaching this step with nothing to configure.
      WidgetsBinding.instance.addPostFrameCallback((_) => controller.next());
      return const Scaffold(body: Center(child: SchoolPulseLoader()));
    }

    final index = controller.configureRoleIndex.clamp(0, roles.length - 1);
    final role = roles[index];
    final spec = RoleAssignmentConfigRegistry.forRole(role);
    final draft = controller.draft.roleConfigs.putIfAbsent(
      role,
      () => RoleAssignmentDraft(role: role),
    );

    return WizardScaffold(
      title: 'Add Staff Member',
      currentStep: stepNumberFor(WizardStep.configureRole),
      totalSteps: kWizardTotalSteps,
      onBack: () => controller.back(),
      footer: WizardFooterButtons(
        onBack: () => controller.back(),
        nextLabel: index < roles.length - 1 ? 'Save & Next' : 'Save & Continue',
        onNext: () => controller.next(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WizardStepCaption(
            number: 5,
            title: 'Configure Role: ${UserRoleDisplay.name(role)}',
            subtitle:
                'Assign details for this role (${index + 1} of ${roles.length})',
          ),
          const SizedBox(height: 20),
          RoleConfigForm(
            draft: draft,
            spec: spec,
            classNames: _classNames,
            subjectNames: _subjectNames,
            academicYearId: null,
            onChanged: () => controller.notifyDraftChanged(),
          ),
        ],
      ),
    );
  }
}
