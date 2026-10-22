import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:school_pulse/features/admin/parent_access_workspace/domain/repositories/parent_access_repository.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/student/domain/entities/student.dart';
import 'package:school_pulse/features/student/domain/usecases/get_all_students.dart';
import 'package:school_pulse/injection_container.dart' as di;

import 'link_parent_wizard_controller.dart';
import 'steps/step_01_details.dart';
import 'steps/step_02_review.dart';
import 'steps/step_03_code.dart';

/// Entry point for the "Link parent to learners" admin flow. Rendered inside
/// AdminShell's content pane (via AdminParentsSectionBody) so the canonical
/// sidebar / bottom-nav Parents tab stays mounted across every step.
class LinkParentWizardPage extends StatefulWidget {
  final String schoolId;

  const LinkParentWizardPage({super.key, required this.schoolId});

  @override
  State<LinkParentWizardPage> createState() => _LinkParentWizardPageState();
}

class _LinkParentWizardPageState extends State<LinkParentWizardPage> {
  late final LinkParentWizardController _controller;
  List<Student> _roster = const [];

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthBloc>().state;
    final adminUid = auth is AuthAuthenticated ? auth.user.id : 'unknown';
    _controller = LinkParentWizardController(
      schoolId: widget.schoolId,
      adminUid: adminUid,
      repository: di.sl<ParentAccessRepository>(),
    );
    _controller.loadPolicy();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final result = await di.sl<GetAllStudents>()(schoolId: widget.schoolId);
    if (!mounted) return;
    result.fold((_) {}, (students) => setState(() => _roster = students));
    final restored = await _controller.restoreDraftIfPresent(
      (id) => _roster.where((s) => s.id == id).firstOrNull,
    );
    if (restored && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Resumed your in-progress parent draft.')),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LinkParentWizardController>.value(
      value: _controller,
      child: Provider<List<Student>>.value(
        value: _roster,
        child: Consumer<LinkParentWizardController>(
          builder: (context, controller, _) {
            switch (controller.stage) {
              case LinkParentStage.details:
                return LinkParentStepDetails(roster: _roster);
              case LinkParentStage.review:
                return const LinkParentStepReview();
              case LinkParentStage.sent:
                return const LinkParentStepSent();
            }
          },
        ),
      ),
    );
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
