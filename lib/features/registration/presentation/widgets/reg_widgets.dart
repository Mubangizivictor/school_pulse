import 'package:flutter/material.dart';

import '../registration_theme.dart';

/// Compact top bar: hamburger + logo/title + help icon, matching the
/// reference screenshots' header on every registration screen.
class RegTopBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onBack;

  const RegTopBar({super.key, this.onBack});

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: const BoxDecoration(
        color: RegColors.background,
        border: Border(bottom: BorderSide(color: RegColors.border)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              onBack != null ? Icons.arrow_back : Icons.menu,
              color: RegColors.textPrimary,
            ),
            onPressed: onBack,
          ),
          const SizedBox(width: 4),
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: RegColors.blueSoft,
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: RegColors.blue, width: 1.2),
            ),
            child: const Icon(Icons.shield_outlined, color: RegColors.blue, size: 15),
          ),
          const SizedBox(width: 8),
          const Text(
            'School Pulse',
            style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700, color: RegColors.textPrimary),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.help_outline, color: RegColors.textMuted, size: 20),
            onPressed: () => showRegHelpSheet(context),
          ),
        ],
      ),
    );
  }
}

/// Compact 6-step circle progress indicator matching the reference wizard.
class RegStepDots extends StatelessWidget {
  final int currentStep; // 1-based
  final int totalSteps;

  const RegStepDots({super.key, required this.currentStep, this.totalSteps = 6});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(totalSteps * 2 - 1, (i) {
          if (i.isOdd) {
            final leftDone = (i ~/ 2) + 1 < currentStep;
            return Container(
              width: 18,
              height: 1.4,
              color: leftDone ? RegColors.blue : RegColors.border,
            );
          }
          final index = i ~/ 2;
          final stepNum = index + 1;
          final isDone = stepNum < currentStep;
          final isCurrent = stepNum == currentStep;
          return Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCurrent ? RegColors.blue : RegColors.surface,
              border: Border.all(
                color: isCurrent || isDone ? RegColors.blue : RegColors.border,
                width: 1.3,
              ),
            ),
            child: Text(
              '$stepNum',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isCurrent
                    ? Colors.white
                    : (isDone ? RegColors.blue : RegColors.textMuted),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// Standard scaffold shell for a wizard step: top bar, step dots, scrollable
/// body, sticky single bottom action bar. Matches the reference layout
/// exactly (16px padding, single action row, no duplicate buttons).
class RegStepScaffold extends StatelessWidget {
  final int step;
  final String title;
  final Widget body;
  final VoidCallback? onBack;
  final VoidCallback? onContinue;
  final String continueLabel;
  final bool continueEnabled;
  final bool loading;
  final Widget? infoBanner;

  const RegStepScaffold({
    super.key,
    required this.step,
    required this.title,
    required this.body,
    required this.onBack,
    required this.onContinue,
    this.continueLabel = 'Continue',
    this.continueEnabled = true,
    this.loading = false,
    this.infoBanner,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RegColors.background,
      appBar: RegTopBar(onBack: onBack),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            RegStepDots(currentStep: step),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Step $step of 6: $title',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: RegColors.textPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    body,
                    if (infoBanner != null) ...[
                      const SizedBox(height: 14),
                      infoBanner!,
                    ],
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              decoration: const BoxDecoration(
                color: RegColors.background,
                border: Border(top: BorderSide(color: RegColors.border)),
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    if (onBack != null) ...[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: loading ? null : onBack,
                          child: const Text('Back'),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      flex: 2,
                      child: FilledButton(
                        onPressed: (continueEnabled && !loading) ? onContinue : null,
                        child: loading
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(continueLabel),
                                  const SizedBox(width: 6),
                                  const Icon(Icons.arrow_forward, size: 17),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact info/amber banner used for hints ("You can update it later...").
class RegInfoBanner extends StatelessWidget {
  final String text;
  const RegInfoBanner(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: RegColors.amberSoft,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: RegColors.amber.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, size: 17, color: RegColors.amber),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 12.5, color: RegColors.textPrimary, height: 1.35)),
          ),
        ],
      ),
    );
  }
}

class RegFieldLabel extends StatelessWidget {
  final String label;
  const RegFieldLabel(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 14),
      child: Text(
        label,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: RegColors.textPrimary),
      ),
    );
  }
}

/// Status timeline used on submitted/approved/rejected/payment screens,
/// replacing the 6-step dots per the spec.
class RegStatusTimeline extends StatelessWidget {
  final List<String> labels;
  final int currentIndex; // index of the active/most-recent step
  final bool failed;

  const RegStatusTimeline({
    super.key,
    required this.labels,
    required this.currentIndex,
    this.failed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(labels.length, (i) {
        final isDone = i < currentIndex;
        final isCurrent = i == currentIndex;
        final isFailedStep = failed && isCurrent;
        final color = isFailedStep
            ? RegColors.red
            : (isDone
                ? RegColors.green
                : (isCurrent ? RegColors.amber : RegColors.border));
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: color, width: 1.6)),
                  child: isDone
                      ? Icon(Icons.check, size: 13, color: color)
                      : (isFailedStep
                          ? Icon(Icons.close, size: 13, color: color)
                          : (isCurrent
                              ? Icon(Icons.circle, size: 8, color: color)
                              : null)),
                ),
                if (i != labels.length - 1)
                  Container(width: 1.4, height: 30, color: isDone ? RegColors.green : RegColors.border),
              ],
            ),
            const SizedBox(width: 12),
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                labels[i],
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                  color: (isDone || isCurrent) ? RegColors.textPrimary : RegColors.textMuted,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

Future<void> showRegHelpSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: RegColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Need help?', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: RegColors.textPrimary)),
            const SizedBox(height: 10),
            const Text(
              'If you run into trouble registering your school, contact our support team and we\'ll help you get set up.',
              style: TextStyle(fontSize: 13.5, color: RegColors.textMuted, height: 1.4),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.headset_mic_outlined, size: 18),
                label: const Text('Contact support'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
