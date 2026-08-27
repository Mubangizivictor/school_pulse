import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/components/wizard_scaffold.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';

import '../link_parent_wizard_controller.dart';

/// Step 2 - Review before code generation: parent summary and linked
/// learners, with an Edit affordance back to step 1.
class LinkParentStepReview extends StatelessWidget {
  const LinkParentStepReview({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<LinkParentWizardController>();

    return WizardStageScaffold(
      title: 'Review invitation',
      stageLabels: kLinkParentStageLabels,
      currentStageIndex: linkParentStageIndexFor(LinkParentStage.review),
      onBack: () => controller.back(),
      footer: WizardFooterButtons(
        backLabel: 'Back',
        nextLabel: 'Generate access code',
        loading: controller.submitting,
        onBack: () => controller.back(),
        onNext: () => controller.submit(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const WizardStageHeading(
            title: 'Confirm before generating a code',
            subtitle:
                'Double-check the parent and learners. The code is single '
                'use and expires in 7 days.',
          ),
          const SizedBox(height: 20),
          if (controller.submitError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: AlertBanner(
                title: 'Could not create the access code',
                message: controller.submitError!,
                color: AppColors.danger(context),
              ),
            ),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.textPrimary(context),
                      child: Icon(
                        Icons.person_outline,
                        color: AppColors.background(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            controller.parentName,
                            style: TextStyle(
                              color: AppColors.textPrimary(context),
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            controller.e164Phone,
                            style: TextStyle(
                              color: AppColors.textMuted(context),
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () =>
                          controller.goToStage(LinkParentStage.details),
                      child: const Text('Edit'),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Text(
                  'Linked learners (${controller.selectedLearners.length})',
                  style: TextStyle(
                    color: AppColors.textSecondary(context),
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 8),
                ...controller.selectedLearners.map(
                  (learner) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 16,
                          color: AppColors.textMuted(context),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${learner.student.name} · ${learner.relationship}',
                            style: TextStyle(
                              color: AppColors.textPrimary(context),
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Text(
                          learner.student.studentCode,
                          style: TextStyle(
                            color: AppColors.textMuted(context),
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer(context),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: AppColors.textMuted(context),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'One parent can be linked to several learners. Each '
                    'learner may have up to two parents.',
                    style: TextStyle(
                      color: AppColors.textSecondary(context),
                      fontSize: 12.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
