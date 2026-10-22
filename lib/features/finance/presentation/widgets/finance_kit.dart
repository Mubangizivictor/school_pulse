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

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/core/utils.dart' show CurrencyFormatter;
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:school_pulse/design_system/responsive/app_responsive_content.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_radius.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_tokens.g.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/messages/presentation/widgets/messages_nav_icon.dart';
import 'package:school_pulse/features/messages/presentation/screens/messages_list_screen.dart';
import 'package:school_pulse/features/notifications/presentation/notification_bell_button.dart';
import 'package:school_pulse/features/notifications/presentation/screens/notification_list_screen.dart';

/// The Bursar module's top bar for the tab roots (Home, Students, Approvals,
/// Cash and Bank, More).
///
/// Matches the reference: a round initials avatar + the user's name and a
/// "Bursar and the school name" caption on the left, and two circular icon
/// buttons on the right - the messages icon and the notification bell, each
/// carrying its own live unread badge (the exact same
/// [MessagesNavIcon] / [NotificationBellButton] the admin/staff dashboards
/// use). Over a hairline bottom divider. Mono only.
PreferredSizeWidget bursarAppBar(BuildContext context) {
  return const PreferredSize(
    preferredSize: Size.fromHeight(60),
    child: _BursarAppBar(),
  );
}

class _BursarAppBar extends StatelessWidget {
  const _BursarAppBar();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    final name = auth is AuthAuthenticated ? auth.user.name : 'Bursar';
    final school = auth is AuthAuthenticated
        ? (auth.user.schoolName ?? 'School Pulse')
        : 'School Pulse';
    final initials = name.trim().isEmpty
        ? 'B'
        : name
              .trim()
              .split(RegExp(r'\s+'))
              .take(2)
              .map((w) => w[0].toUpperCase())
              .join();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background(context),
        border: Border(bottom: BorderSide(color: AppColors.border(context))),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 12, 10),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surfaceContainer(context),
                  border: Border.all(color: AppColors.border(context)),
                ),
                child: Text(
                  initials,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary(context),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      'Bursar · $school',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted(context),
                      ),
                    ),
                  ],
                ),
              ),
              _CircleAction(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const MessagesListScreen()),
                ),
                child: const MessagesNavIcon(
                  icon: Icons.chat_bubble_outline_rounded,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              _CircleAction(
                child: NotificationBellButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const NotificationListScreen(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A 38px circular outline shell around one of the shared badge widgets, so
/// the messages icon and the bell read as a matched pair in the app bar.
class _CircleAction extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _CircleAction({required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.border(context)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Center(child: child),
        ),
      ),
    );
  }
}

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

  /// Caps the body width on tablet/desktop/web so a phone-shaped screen
  /// rendered directly in the wide console content pane (Budget, Audit,
  /// Reports, Clearance policy) doesn't stretch edge-to-edge. No-op on
  /// mobile. Screens with their own responsive split-pane leave this off.
  final bool constrainWidth;

  const FinanceScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.bottomBar,
    this.isOffline = false,
    this.showBack = true,
    this.onBack,
    this.constrainWidth = false,
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
            Expanded(
              child: constrainWidth
                  ? AppResponsiveContent(maxWidth: 960, child: body)
                  : body,
            ),
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

/// A minimal weekly cash-flow line: a curved series over N buckets with
/// exactly one x-label per bucket (fl_chart otherwise labels every tick, so
/// a 7-point series renders "S S S M M M ..."). Monochrome, no gridlines,
/// no touch tooltip - a glanceable trend, not a data table. With
/// [showYAxis], a symmetric ±peak scale and 5 left-hand value labels
/// (peak / half / 0 / -half / -peak) plus a dashed zero line, matching the
/// reference dashboard.
class FinanceTrendLine extends StatelessWidget {
  final List<double> values;
  final List<String> labels;
  final double height;
  final bool showYAxis;

  const FinanceTrendLine({
    super.key,
    required this.values,
    required this.labels,
    this.height = 120,
    this.showYAxis = false,
  });

  String _compact(double v) {
    final a = v.abs();
    final sign = v < 0 ? '-' : '';
    if (a >= 1000000) return '$sign${(a / 1000000).toStringAsFixed(1)}M';
    if (a >= 1000) return '$sign${(a / 1000).toStringAsFixed(0)}K';
    return '$sign${a.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final line = AppColors.primary(context);
    final peak = values.fold<double>(0, (m, v) => v.abs() > m ? v.abs() : m);
    final top = peak <= 0 ? 1.0 : peak * 1.15;

    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: (values.length - 1).toDouble(),
          minY: showYAxis ? -top : 0,
          maxY: top,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          lineTouchData: const LineTouchData(enabled: false),
          extraLinesData: showYAxis
              ? ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(
                      y: 0,
                      color: AppColors.border(context),
                      strokeWidth: 1,
                      dashArray: [4, 4],
                    ),
                  ],
                )
              : const ExtraLinesData(),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: showYAxis,
                interval: top / 2,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  if (value > meta.max || value < meta.min) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Text(
                      _compact(value),
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textMuted(context),
                      ),
                    ),
                  );
                },
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                reservedSize: 22,
                getTitlesWidget: (value, meta) {
                  final i = value.round();
                  if ((value - i).abs() > 0.01 || i < 0 || i >= labels.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      labels[i],
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textMuted(context),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: [
                for (var i = 0; i < values.length; i++)
                  FlSpot(i.toDouble(), values[i]),
              ],
              isCurved: true,
              preventCurveOverShooting: true,
              color: line,
              barWidth: 2,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, bar, index) =>
                    FlDotCirclePainter(radius: 3, color: line, strokeWidth: 0),
              ),
              belowBarData: BarAreaData(show: false),
            ),
          ],
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
enum FinanceStatusTone { positive, warning, negative, neutral }

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
    final tokens = Theme.of(context).extension<AppColors>()!;
    late final Color fg;
    late final Color bg;
    switch (tone) {
      case FinanceStatusTone.positive:
        fg = tokens.success;
        bg = tokens.successSoft;
      case FinanceStatusTone.warning:
        fg = tokens.warning;
        bg = tokens.warningSoft;
      case FinanceStatusTone.negative:
        fg = tokens.error;
        bg = tokens.errorSoft;
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
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.l,
        vertical: AppSpacing.m,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ),
              if (icon != null)
                Icon(icon, size: 14, color: AppColors.textMuted(context)),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: emphasisColor ?? AppColors.textPrimary(context),
            ),
          ),
          if (caption != null)
            Text(
              caption!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.5,
                color: AppColors.textMuted(context),
              ),
            ),
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
