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
                    icon: Icon(Icons.arrow_back, color: AppColors.textPrimary(context)),
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
                    style: TextStyle(color: AppColors.textMuted(context), fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: currentStep / totalSteps,
                      minHeight: 4,
                      backgroundColor: AppColors.surfaceContainer(context),
                      valueColor: AlwaysStoppedAnimation(AppColors.electricBlue),
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
          child: Text('$number', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: AppColors.textPrimary(context), fontWeight: FontWeight.w600)),
              Text(subtitle, style: TextStyle(color: AppColors.textMuted(context), fontSize: 12)),
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
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Text(nextLabel),
          ),
        ),
      ],
    );
  }
}
