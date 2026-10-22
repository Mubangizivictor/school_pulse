import 'package:flutter/material.dart';

import 'package:school_pulse/design_system/app_components.dart';

/// One reusable shell for every step of the 16-step school-setup wizard.
///
/// Consolidates what were three near-duplicate shell implementations:
///  - the plain AppBar + `WizardStepProgress` treatment most steps used
///    (`_WizardStepScreen`, formerly in structure_screen.dart),
///  - the Institution profile step's compact header / step-rail / optional
///    "Save draft" treatment (`_InstitutionProfileStep` +
///    `_WizardCompactHeader` + `_WizardStepNavigator`, formerly in
///    structure_screen.dart),
///  - the Academic calendar step's inline compact header / step-rail
///    (`_CalendarStepShell` + `_CompactHeader` + `_StepRail`, formerly in
///    academic_calendar_step_screen.dart).
///
/// All three wanted the same superset of behaviour - back action, centered
/// title, "Step X of N" + percentage, a thin progress indicator, and a
/// sticky Back/Save & Continue footer - so this widget renders one
/// consistent look everywhere: a compact top bar (with an optional step
/// list rail on wide/web layouts, mirroring the widest of the three
/// original treatments) rather than reintroducing a full-width AppBar.
class SetupWizardShell extends StatelessWidget {
  const SetupWizardShell({
    super.key,
    required this.title,
    required this.stepIndex,
    required this.stepCount,
    required this.onBack,
    required this.onContinue,
    required this.body,
    this.stepTitles,
    this.continueLabel = 'Save & Continue',
    this.continueIcon = Icons.arrow_forward_rounded,
    this.continueEnabled = true,
    this.isSaving = false,
    this.onSaveDraft,
    this.onJumpToStep,
  });

  /// Title shown in the compact header and, on wide layouts, above the body.
  final String title;

  /// 0-based index of this step.
  final int stepIndex;

  /// Total number of steps in the wizard.
  final int stepCount;

  final Future<void> Function() onBack;
  final Future<void> Function() onContinue;
  final Widget body;

  /// When provided, a step-list rail is shown on wide/web layouts (>= 900
  /// logical pixels) listing every step title, with the current step
  /// highlighted. Omit for steps that don't need the full step list (the
  /// rail then shows only the percent/progress summary).
  final List<String>? stepTitles;

  final String continueLabel;
  final IconData continueIcon;
  final bool continueEnabled;

  /// True while an async save triggered by Back/Continue/Save-draft is in
  /// flight - disables the footer actions and shows a spinner in the
  /// pressed one.
  final bool isSaving;

  /// Optional "Save draft" action shown in the header (and, on wide
  /// layouts, also in the footer) - used by the Institution profile step,
  /// which is the only step with a meaningful "incomplete but saved" state.
  final Future<void> Function()? onSaveDraft;

  /// Optional callback to let a wide-layout step rail jump directly to
  /// another step. Only used together with [stepTitles].
  final ValueChanged<int>? onJumpToStep;

  bool get _isFirstStep => stepIndex <= 0;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 900;
            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _StepRail(
                    title: title,
                    stepIndex: stepIndex,
                    stepCount: stepCount,
                    stepTitles: stepTitles,
                    onSaveDraft: onSaveDraft == null || isSaving
                        ? null
                        : onSaveDraft,
                    onJumpToStep: onJumpToStep,
                  ),
                  VerticalDivider(width: 1, color: scheme.outlineVariant),
                  Expanded(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(32, 20, 32, 8),
                          child: Row(
                            children: [
                              if (!_isFirstStep)
                                TextButton.icon(
                                  onPressed: isSaving ? null : onBack,
                                  icon: const Icon(
                                    Icons.arrow_back_rounded,
                                    size: 18,
                                  ),
                                  label: const Text('Back'),
                                ),
                              if (!_isFirstStep) const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  title,
                                  style: TextStyle(
                                    color: scheme.onSurface,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(child: body),
                      ],
                    ),
                  ),
                ],
              );
            }
            return Column(
              children: [
                _CompactHeader(
                  title: title,
                  onBack: _isFirstStep || isSaving ? null : onBack,
                  onSaveDraft: onSaveDraft == null || isSaving
                      ? null
                      : onSaveDraft,
                  stepIndex: stepIndex,
                  stepCount: stepCount,
                ),
                Divider(height: 1, color: scheme.outlineVariant),
                Expanded(child: body),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: _Footer(
          isFirstStep: _isFirstStep,
          isSaving: isSaving,
          continueEnabled: continueEnabled,
          continueLabel: continueLabel,
          continueIcon: continueIcon,
          onBack: onBack,
          onContinue: onContinue,
        ),
      ),
    );
  }
}

/// Mobile/tablet sticky top bar: Back, centered title, optional Save draft,
/// then a slim "N of stepCount" progress row with a percentage and a single
/// filled progress bar.
class _CompactHeader extends StatelessWidget {
  const _CompactHeader({
    required this.title,
    required this.onBack,
    required this.onSaveDraft,
    required this.stepIndex,
    required this.stepCount,
  });

  final String title;
  final Future<void> Function()? onBack;
  final Future<void> Function()? onSaveDraft;
  final int stepIndex;
  final int stepCount;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final percent = (((stepIndex + 1) / stepCount) * 100).round();
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          child: Column(
            children: [
              Row(
                children: [
                  if (onBack != null)
                    IconButton(
                      onPressed: onBack,
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                      ),
                      color: scheme.onSurface,
                    )
                  else
                    const SizedBox(width: 48),
                  Expanded(
                    child: Text(
                      'School setup',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (onSaveDraft != null)
                    TextButton(
                      onPressed: onSaveDraft,
                      child: const Text('Save draft'),
                    )
                  else
                    const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${stepIndex + 1} of $stepCount · $title',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$percent%',
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: (stepIndex + 1) / stepCount,
                  minHeight: 5,
                  backgroundColor: scheme.primary.withValues(alpha: 0.15),
                  color: scheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Narrow left step navigator shown on wide/web layouts: a compact
/// "School setup" heading, overall percent, and (when [stepTitles] is
/// given) the full step list with the current step highlighted.
class _StepRail extends StatelessWidget {
  const _StepRail({
    required this.title,
    required this.stepIndex,
    required this.stepCount,
    required this.stepTitles,
    required this.onSaveDraft,
    required this.onJumpToStep,
  });

  final String title;
  final int stepIndex;
  final int stepCount;
  final List<String>? stepTitles;
  final Future<void> Function()? onSaveDraft;
  final ValueChanged<int>? onJumpToStep;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final percent = (((stepIndex + 1) / stepCount) * 100).round();
    return SizedBox(
      width: 260,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'School setup',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  stepTitles == null
                      ? '${stepIndex + 1} of $stepCount · $title'
                      : 'Complete your school profile to get started on '
                            'School Pulse.',
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '$percent% complete',
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontSize: 11.5,
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: (stepIndex + 1) / stepCount,
                    minHeight: 4,
                    backgroundColor: scheme.primary.withValues(alpha: 0.15),
                    color: scheme.primary,
                  ),
                ),
                if (onSaveDraft != null) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: onSaveDraft,
                      icon: const Icon(Icons.description_outlined, size: 16),
                      label: const Text(
                        'Save draft',
                        style: TextStyle(fontSize: 12.5),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (stepTitles != null)
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: stepTitles!.length,
                itemBuilder: (context, index) {
                  final isCurrent = index == stepIndex;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Material(
                      color: isCurrent
                          ? scheme.primary.withValues(alpha: 0.08)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: onJumpToStep == null
                            ? null
                            : () => onJumpToStep!(index),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 12,
                                backgroundColor: isCurrent
                                    ? scheme.primary
                                    : scheme.onSurface.withValues(alpha: 0.06),
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: isCurrent
                                        ? scheme.onPrimary
                                        : scheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  stepTitles![index],
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isCurrent
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: isCurrent
                                        ? scheme.primary
                                        : scheme.onSurface.withValues(
                                            alpha: 0.87,
                                          ),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          else
            const Spacer(),
        ],
      ),
    );
  }
}

/// Sticky Back / Save & Continue footer shared by every wizard step.
class _Footer extends StatelessWidget {
  const _Footer({
    required this.isFirstStep,
    required this.isSaving,
    required this.continueEnabled,
    required this.continueLabel,
    required this.continueIcon,
    required this.onBack,
    required this.onContinue,
  });

  final bool isFirstStep;
  final bool isSaving;
  final bool continueEnabled;
  final String continueLabel;
  final IconData continueIcon;
  final Future<void> Function() onBack;
  final Future<void> Function() onContinue;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(top: BorderSide(color: scheme.outlineVariant)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: Row(
                  children: [
                    if (!isFirstStep)
                      Expanded(
                        child: SecondaryButton(
                          label: 'Back',
                          onPressed: isSaving ? null : () => onBack(),
                        ),
                      ),
                    if (!isFirstStep) const SizedBox(width: 12),
                    Expanded(
                      child: PrimaryButton(
                        label: continueLabel,
                        icon: continueIcon,
                        onPressed: (continueEnabled && !isSaving)
                            ? () => onContinue()
                            : null,
                        isLoading: isSaving,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
