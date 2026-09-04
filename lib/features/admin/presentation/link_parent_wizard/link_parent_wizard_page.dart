import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:school_pulse/features/admin/parent_access_workspace/domain/repositories/parent_access_repository.dart';
import 'package:school_pulse/injection_container.dart' as di;
import 'link_parent_wizard_controller.dart';
import 'steps/step_01_details.dart';
import 'steps/step_02_review.dart';
import 'steps/step_03_code.dart';

/// Entry point for the "Link parent to learners" + "Create parent access
/// code" admin flow. Pushed as its own route, outside the bottom-nav shell,
/// matching the Add Staff wizard convention.
class LinkParentWizardPage extends StatefulWidget {
  final String schoolId;

  const LinkParentWizardPage({super.key, required this.schoolId});

  @override
  State<LinkParentWizardPage> createState() => _LinkParentWizardPageState();
}

class _LinkParentWizardPageState extends State<LinkParentWizardPage> {
  late final LinkParentWizardController _controller;

  @override
  void initState() {
    super.initState();
    _controller = LinkParentWizardController(
      schoolId: widget.schoolId,
      repository: di.sl<ParentAccessRepository>(),
    );
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
      child: Consumer<LinkParentWizardController>(
        builder: (context, controller, _) {
          switch (controller.stage) {
            case LinkParentStage.details:
              return const LinkParentStepDetails();
            case LinkParentStage.review:
              return const LinkParentStepReview();
            case LinkParentStage.code:
              return const LinkParentStepCode();
          }
        },
      ),
    );
  }
}
