/// Shared Bursar/Finance UI kit.
///
/// Reference-matched primitives (see the locked iPhone screenshots) built
/// only on the existing design-system tokens - `AppColors.*(context)` and the
/// `SemanticColors` ThemeExtension - so every screen renders identically in
/// light and dark with no literal colours. No blue, no gradients, no
/// colourful icon backgrounds: black/white/grey surfaces, near-black
/// typography and primary buttons, green only for paid/success, red only for
/// overdue/high-risk/unmatched/rejected/deadline.
library;

import 'package:flutter/material.dart';
import 'package:school_pulse/core/utils.dart' show CurrencyFormatter;
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_radius.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';

/// Standard page chrome for every Bursar screen pushed on top of a shell tab:
/// centered title, back affordance, optional `…` overflow menu, mono
/// background, an optional pinned bottom action bar, and a slot the caller
/// fills with content (already wrapped in a [SafeArea]).
class FinanceScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;

  /// Shown pinned above the bottom safe area (e.g. a [PrimaryActionBar]).
  final Widget? bottomBar;

  /// When true a slim offline banner is shown under the app bar.
  final bool isOffline;
  final bool showBack;
  final VoidCallback? onBack;

  const FinanceScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.bottomBar,
    this.isOffline = false,
    this.showBack = true,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.background(context),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: showBack
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                onPressed: onBack ?? () => Navigator.of(context).maybePop(),
              )
            : null,
        automaticallyImplyLeading: showBack,
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 17,
            color: AppColors.textPrimary(context),
          ),
        ),
        actions: actions,
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            if (isOffline) const FinanceOfflineBanner(),
            Expanded(child: body),
          ],
        ),
      ),
      bottomNavigationBar: bottomBar == null
          ? null
          : SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.l,
                  AppSpacing.m,
                  AppSpacing.l,
                  AppSpacing.l,
                ),
                child: bottomBar,
              ),
            ),
    );
  }
}

/// Slim inline "you're offline" banner shown under a [FinanceScaffold] app
/// bar. Red text/border so it reads as a problem state, no fabricated
/// timestamp.
class FinanceOfflineBanner extends StatelessWidget {
  const FinanceOfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.l,
        AppSpacing.m,
        AppSpacing.l,
        0,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.l,
        vertical: AppSpacing.m,
      ),
      decoration: BoxDecoration(
        color: AppColors.dangerSurface(context),
        borderRadius: BorderRadius.circular(AppRadius.m),
        border: Border.all(color: AppColors.danger(context)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.cloud_off_rounded,
            size: 16,
            color: AppColors.danger(context),
          ),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: Text(
              'Offline — showing saved data. Payments and approvals are '
              'disabled until you reconnect.',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.danger(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A plain bordered card - the single container primitive every finance
/// screen composes from (KPI tiles, list rows, sheets). No shadow, 1px
/// border, [AppRadius.large].
class FinanceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  const FinanceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.l),
    this.margin,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated(context),
        borderRadius: AppRadius.large,
        border: Border.all(color: AppColors.border(context)),
      ),
      child: child,
    );
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: onTap == null
          ? card
          : InkWell(borderRadius: AppRadius.large, onTap: onTap, child: card),
    );
  }
}

/// A UGX money value rendered consistently everywhere (`CurrencyFormatter.ugx`).
/// Accepts an `int` (minor-unit-free whole UGX) or a `double`.
class MoneyText extends StatelessWidget {
  final num amount;
  final TextStyle? style;
  final Color? color;
  final bool bold;

  const MoneyText(
    this.amount, {
    super.key,
    this.style,
    this.color,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    final base =
        style ??
        TextStyle(
          fontSize: 15,
          color: color ?? AppColors.textPrimary(context),
          fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
        );
    return Text(
      CurrencyFormatter.ugx(amount.toDouble()),
      style: color != null ? base.copyWith(color: color) : base,
    );
  }
}

/// Fee/payment status pill. Green for settled states, red for problem
/// states, neutral grey for in-progress - contrast is AA in both themes
/// because the tokens carry a per-brightness value.
enum FinanceStatusTone { positive, negative, neutral }

class FinanceStatusChip extends StatelessWidget {
  final String label;
  final FinanceStatusTone tone;

  const FinanceStatusChip({super.key, required this.label, required this.tone});

  /// Maps common textual statuses to a tone. `paid`/`compliant`/`released`
  /// → positive; `overdue`/`rejected`/`unmatched`/`high risk` → negative;
  /// everything else neutral.
  factory FinanceStatusChip.forStatus(String status) {
    final s = status.toLowerCase().trim();
    const positive = {
      'paid',
      'compliant',
      'released',
      'confirmed',
      'approved',
      'settled',
      'matched',
      'success',
    };
    const negative = {
      'overdue',
      'rejected',
      'unmatched',
      'high risk',
      'high-risk',
      'failed',
      'revoked',
      'reversed',
      'held',
    };
    final tone = positive.contains(s)
        ? FinanceStatusTone.positive
        : negative.contains(s)
        ? FinanceStatusTone.negative
        : FinanceStatusTone.neutral;
    return FinanceStatusChip(label: status, tone: tone);
  }

  @override
  Widget build(BuildContext context) {
    late final Color fg;
    late final Color bg;
    switch (tone) {
      case FinanceStatusTone.positive:
        fg = AppColors.success(context);
        bg = AppColors.successSurface(context);
      case FinanceStatusTone.negative:
        fg = AppColors.danger(context);
        bg = AppColors.dangerSurface(context);
      case FinanceStatusTone.neutral:
        fg = AppColors.textSecondary(context);
        bg = AppColors.surfaceContainer(context);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.s),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}

/// A small titled KPI tile as seen on the Finance home band ("Today's
/// collections", "Fee arrears" …). [emphasisColor] tints only the value,
/// used sparingly for arrears (red) / collections (green).
class FinanceStatTile extends StatelessWidget {
  final String label;
  final String value;
  final String? caption;
  final IconData? icon;
  final Color? emphasisColor;
  final VoidCallback? onTap;

  const FinanceStatTile({
    super.key,
    required this.label,
    required this.value,
    this.caption,
    this.icon,
    this.emphasisColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FinanceCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ),
              if (icon != null)
                Icon(icon, size: 16, color: AppColors.textMuted(context)),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: emphasisColor ?? AppColors.textPrimary(context),
            ),
          ),
          if (caption != null) ...[
            const SizedBox(height: 2),
            Text(
              caption!,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textMuted(context),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// A tappable list row: leading icon in a bordered square, title + subtitle,
/// trailing amount (+ optional chevron). The workhorse of the Students,
/// Approvals, Cash & Bank, and ledger lists.
class FinanceListRow extends StatelessWidget {
  final IconData? leadingIcon;
  final Widget? leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final String? trailingText;
  final Color? trailingColor;
  final bool showChevron;
  final VoidCallback? onTap;

  const FinanceListRow({
    super.key,
    this.leadingIcon,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.trailingText,
    this.trailingColor,
    this.showChevron = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FinanceCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: AppSpacing.m),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.l,
        vertical: AppSpacing.l,
      ),
      child: Row(
        children: [
          if (leading != null)
            leading!
          else if (leadingIcon != null) ...[
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.m),
                border: Border.all(color: AppColors.border(context)),
              ),
              child: Icon(
                leadingIcon,
                size: 18,
                color: AppColors.textPrimary(context),
              ),
            ),
          ],
          if (leading != null || leadingIcon != null)
            const SizedBox(width: AppSpacing.l),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted(context),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null)
            trailing!
          else if (trailingText != null)
            Text(
              trailingText!,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: trailingColor ?? AppColors.textPrimary(context),
              ),
            ),
          if (showChevron && onTap != null) ...[
            const SizedBox(width: AppSpacing.s),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppColors.textMuted(context),
            ),
          ],
        ],
      ),
    );
  }
}

/// A left-label / right-value row used inside statement and voucher cards.
class KeyValueRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool bold;
  final bool dense;

  const KeyValueRow(
    this.label,
    this.value, {
    super.key,
    this.valueColor,
    this.bold = false,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    final weight = bold ? FontWeight.w800 : FontWeight.w500;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: dense ? 3 : 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: weight,
                color: bold
                    ? AppColors.textPrimary(context)
                    : AppColors.textSecondary(context),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.l),
          Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 13,
              fontWeight: weight,
              color: valueColor ?? AppColors.textPrimary(context),
            ),
          ),
        ],
      ),
    );
  }
}

/// A titled section wrapper: bold label above a [FinanceCard].
class SectionCard extends StatelessWidget {
  final String? title;
  final Widget child;
  final Widget? action;
  final EdgeInsetsGeometry padding;

  const SectionCard({
    super.key,
    this.title,
    required this.child,
    this.action,
    this.padding = const EdgeInsets.all(AppSpacing.l),
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Row(
            children: [
              Expanded(
                child: Text(
                  title!,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textSecondary(context),
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              ?action,
            ],
          ),
          const SizedBox(height: AppSpacing.m),
        ],
        FinanceCard(padding: padding, child: child),
      ],
    );
  }
}

/// Full-width pinned black primary button (with an optional secondary
/// outline button to its left), matching the screenshots' bottom action
/// bars ("Record payment", "Submit for approval", "Save draft").
class PrimaryActionBar extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  const PrimaryActionBar({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.secondaryLabel,
    this.onSecondary,
  });

  @override
  Widget build(BuildContext context) {
    final primary = SizedBox(
      height: 52,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary(context),
          foregroundColor: AppColors.background(context),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.medium),
        ),
        onPressed: loading ? null : onPressed,
        child: loading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.background(context),
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
      ),
    );

    if (secondaryLabel == null) {
      return SizedBox(width: double.infinity, child: primary);
    }
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 52,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary(context),
                side: BorderSide(color: AppColors.border(context)),
                shape: RoundedRectangleBorder(borderRadius: AppRadius.medium),
              ),
              onPressed: loading ? null : onSecondary,
              child: Text(
                secondaryLabel!,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.m),
        Expanded(child: primary),
      ],
    );
  }
}

/// Shared loading / error / empty presenters so every finance screen shows
/// the same states.
class FinanceStates {
  const FinanceStates._();

  static Widget loading() => const Center(child: SchoolPulseLoader());

  static Widget error(
    BuildContext context,
    String message, {
    VoidCallback? onRetry,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.x3l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 40,
              color: AppColors.danger(context),
            ),
            const SizedBox(height: AppSpacing.l),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary(context)),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.l),
              OutlinedButton(
                onPressed: onRetry,
                child: const Text('Try again'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static Widget empty(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? message,
    Widget? action,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.x3l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 44, color: AppColors.textMuted(context)),
            const SizedBox(height: AppSpacing.l),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary(context),
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.s),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textMuted(context),
                ),
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: AppSpacing.l),
              action,
            ],
          ],
        ),
      ),
    );
  }

  /// A "this part isn't wired up yet" placeholder for Phase-1 tabs whose
  /// backend lands in a later phase (Cash & Bank, Petty Cash, Suppliers …).
  static Widget comingSoon(
    BuildContext context, {
    required String feature,
    String? detail,
  }) {
    return empty(
      context,
      icon: Icons.hourglass_empty_rounded,
      title: '$feature is coming soon',
      message:
          detail ??
          'This area is being built. Your existing finance data is safe and '
              'nothing here has changed.',
    );
  }
}

/// Segmented method selector (Cash / Mobile Money / Bank) matching the
/// Receive Payment screenshot - filled black for the active segment.
class MethodSegments extends StatelessWidget {
  final List<({String value, String label})> options;
  final String selected;
  final ValueChanged<String> onChanged;

  const MethodSegments({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer(context),
        borderRadius: BorderRadius.circular(AppRadius.m),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Row(
        children: [
          for (final opt in options)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(opt.value),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: opt.value == selected
                        ? AppColors.primary(context)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadius.s),
                  ),
                  child: Text(
                    opt.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: opt.value == selected
                          ? AppColors.background(context)
                          : AppColors.textSecondary(context),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
