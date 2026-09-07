import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/components/wizard_scaffold.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';

import '../link_parent_wizard_controller.dart';

/// Step 2 - Review: editable summary of guardian details + linked learners
/// (relationship, primary contact) + the invitation choice. Detects a
/// tenant-scoped duplicate parent and offers linking to it instead.
class LinkParentStepReview extends StatelessWidget {
  const LinkParentStepReview({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<LinkParentWizardController>();
    final dupe = controller.duplicateMatch;

    return WizardStageScaffold(
      title: 'Link parent to learners',
      stageLabels: kLinkParentStageLabels,
      currentStageIndex: linkParentStageIndexFor(LinkParentStage.review),
      onBack: () => controller.back(),
      footer: WizardFooterButtons(
        backLabel: 'Back',
        nextLabel: dupe != null
            ? 'Link to existing parent'
            : 'Generate & send invitation',
        loading: controller.submitting,
        onBack: () => controller.back(),
        onNext: () => dupe != null
            ? controller.submitLinkToExisting()
            : controller.submitNewParent(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const WizardStageHeading(
            title: 'Review invitation',
            subtitle:
                'Check the guardian and learners. The invitation link and '
                'one-time code are single use and expire in 7 days.',
          ),
          const SizedBox(height: 16),
          if (controller.submitError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: AlertBanner(
                title: 'Could not complete',
                message: controller.submitError!,
                color: AppColors.danger(context),
              ),
            ),
          if (dupe != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warningSurface(context),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.merge_type,
                      size: 18, color: AppColors.warning(context)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'A parent with this phone/email already exists in your '
                      'school (${dupe.parentName}, ${dupe.maskedPhone}, '
                      '${dupe.learnerCount} learner(s)). The selected learners '
                      'will be linked to that existing parent instead of '
                      'creating a duplicate record.',
                      style: TextStyle(
                        color: AppColors.warning(context),
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.textPrimary(context),
                      child: Icon(Icons.person_outline,
                          color: AppColors.background(context)),
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
                            '${controller.relationship} · '
                            '${controller.e164Phone}'
                            '${controller.email.isEmpty ? '' : ' · ${controller.email}'}',
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
                        Icon(Icons.person_outline,
                            size: 16, color: AppColors.textMuted(context)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${learner.student.name} · ${learner.relationship}'
                            '${learner.isPrimaryContact ? ' · Primary contact' : ''}',
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
          if (dupe == null)
            _InviteChoice(
              value: controller.sendInvitation,
              hasEmail: controller.email.isNotEmpty,
              onChanged: (v) {
                controller.sendInvitation = v;
              },
            ),
        ],
      ),
    );
  }
}

class _InviteChoice extends StatelessWidget {
  final bool value;
  final bool hasEmail;
  final ValueChanged<bool> onChanged;

  const _InviteChoice({
    required this.value,
    required this.hasEmail,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.informationSurface(context),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Invitation & access',
            style: TextStyle(
              color: AppColors.information(context),
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            hasEmail
                ? 'A verified, single-use invitation link is emailed to the '
                    'parent, and a one-time code is shown here as a fallback. '
                    'No password is ever set or stored.'
                : 'No email on file - a one-time code is shown here to share '
                    'with the parent directly. Add an email on the previous '
                    'step to email a verified link instead.',
            style: TextStyle(
              color: AppColors.information(context),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
