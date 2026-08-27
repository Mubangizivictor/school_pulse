import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';

/// Shared header/progress-bar chrome for multi-step wizards (e.g. Add Staff Member).
class WizardScaffold extends StatelessWidget {
  final String title;
  final int currentStep;
  final int totalSteps;
  final VoidCallback onBack;
  final Widget child;
  final Widget? footer;

  const WizardScaffold({
    super.key,
    required this.title,
    required this.currentStep,
    required this.totalSteps,
    required this.onBack,
    required this.child,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: onBack,
                    icon: Icon(
                      Icons.arrow_back,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: AppColors.textPrimary(context),
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Step $currentStep of $totalSteps',
                    style: TextStyle(
                      color: AppColors.textMuted(context),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: currentStep / totalSteps,
                      minHeight: 4,
                      backgroundColor: AppColors.surfaceContainer(context),
                      valueColor: AlwaysStoppedAnimation(
                        AppColors.electricBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: child,
              ),
            ),
            if (footer != null)
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                  child: footer!,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A section header ("3  Personal Information / Enter staff personal details") shown
/// beneath each step's scaffold card, matching the reference design's numbered captions.
class WizardStepCaption extends StatelessWidget {
  final int number;
  final String title;
  final String subtitle;

  const WizardStepCaption({
    super.key,
    required this.number,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: AppColors.electricBlue,
          child: Text(
            '$number',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: AppColors.textMuted(context),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Footer with Back/Next (or custom labelled) buttons, matching the reference's bottom bar.
class WizardFooterButtons extends StatelessWidget {
  final String backLabel;
  final String nextLabel;
  final VoidCallback? onBack;
  final VoidCallback? onNext;
  final bool nextIsPrimary;
  final bool loading;

  const WizardFooterButtons({
    super.key,
    this.backLabel = 'Back',
    this.nextLabel = 'Next',
    this.onBack,
    this.onNext,
    this.nextIsPrimary = true,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (onBack != null)
          Expanded(
            child: OutlinedButton(
              onPressed: loading ? null : onBack,
              child: Text(backLabel),
            ),
          ),
        if (onBack != null) const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: FilledButton(
            onPressed: loading ? null : onNext,
            child: loading
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(nextLabel),
          ),
        ),
      ],
    );
  }
}

/// The five-stage numbered progress stepper shown at the top of the Add
/// Staff wizard: Profile -> Work -> Roles -> Access -> Review. The current
/// stage renders filled black; completed stages show a checkmark; future
/// stages are outlined. Matches the black-and-white reference design -
/// deliberately not reused by other wizards, which keep WizardScaffold's
/// linear "Step N of M" progress bar instead.
class WizardStageStepper extends StatelessWidget {
  final List<String> stageLabels;
  final int currentIndex;

  const WizardStageStepper({
    super.key,
    required this.stageLabels,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    final black = AppColors.textPrimary(context);
    final muted = AppColors.textMuted(context);
    final border = AppColors.border(context);
    return Row(
      children: List.generate(stageLabels.length * 2 - 1, (i) {
        if (i.isOdd) {
          final leftIndex = i ~/ 2;
          final connectorDone = leftIndex < currentIndex;
          return Expanded(
            child: Container(
              height: 1,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              color: connectorDone ? black : border,
            ),
          );
        }
        final index = i ~/ 2;
        final isDone = index < currentIndex;
        final isCurrent = index == currentIndex;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 26,
              height: 26,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (isDone || isCurrent) ? black : Colors.transparent,
                border: Border.all(
                  color: (isDone || isCurrent) ? black : border,
                  width: 1.4,
                ),
              ),
              child: isDone
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isCurrent
                            ? Theme.of(context).colorScheme.onPrimary
                            : muted,
                      ),
                    ),
            ),
            const SizedBox(height: 4),
            Text(
              stageLabels[index],
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                color: isCurrent ? black : muted,
              ),
            ),
          ],
        );
      }),
    );
  }
}

/// Top chrome for a wizard stage: back arrow, title, "Save draft" action,
/// and the 5-stage numbered stepper - matches the black-and-white reference.
/// The app's bottom navigation is not part of this widget; callers must
/// ensure it's hidden while the wizard route is on top (it already is, since
/// the wizard is pushed as its own route outside the shell's bottom nav).
class WizardStageScaffold extends StatelessWidget {
  final String title;
  final List<String> stageLabels;
  final int currentStageIndex;
  final VoidCallback onBack;
  final VoidCallback? onSaveDraft;
  final Widget child;
  final Widget? footer;
  final EdgeInsetsGeometry contentPadding;

  const WizardStageScaffold({
    super.key,
    required this.title,
    required this.stageLabels,
    required this.currentStageIndex,
    required this.onBack,
    required this.child,
    this.onSaveDraft,
    this.footer,
    this.contentPadding = const EdgeInsets.fromLTRB(20, 0, 20, 24),
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: onBack,
                    icon: Icon(
                      Icons.arrow_back,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textPrimary(context),
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (onSaveDraft != null)
                    TextButton(
                      onPressed: onSaveDraft,
                      child: Text(
                        'Save draft',
                        style: TextStyle(
                          color: AppColors.textPrimary(context),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 64),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: WizardStageStepper(
                stageLabels: stageLabels,
                currentIndex: currentStageIndex,
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: SingleChildScrollView(
                padding: contentPadding,
                child: child,
              ),
            ),
            if (footer != null)
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: AppColors.border(context)),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                    child: footer!,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Compact heading used at the top of each stage's content ("Tell us about
/// the person" / "Add the basic details..."), matching the reference design.
class WizardStageHeading extends StatelessWidget {
  final String title;
  final String? subtitle;

  const WizardStageHeading({super.key, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColors.textPrimary(context),
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: TextStyle(
              color: AppColors.textMuted(context),
              fontSize: 13.5,
            ),
          ),
        ],
      ],
    );
  }
}

/// Label-above-field section title used within a stage ("Contact &
/// emergency", "Emergency contact"), matching the reference's compact
/// section headers.
class WizardSectionLabel extends StatelessWidget {
  final String label;
  final String? helper;

  const WizardSectionLabel({super.key, required this.label, this.helper});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.textPrimary(context),
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (helper != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                helper!,
                style: TextStyle(
                  color: AppColors.textMuted(context),
                  fontSize: 12.5,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
