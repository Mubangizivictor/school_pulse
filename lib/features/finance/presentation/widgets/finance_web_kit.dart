/// Desktop / web Bursar console primitives.
///
/// Built only on existing design-system tokens (`AppColors.*(context)`), so
/// every widget renders identically in light and dark. Strict monochrome:
/// white / soft-grey surfaces, near-black text and primary buttons, thin
/// neutral dividers; green only for paid/success, red only for
/// arrears/overdue/unmatched/rejected/deadline/risk.
library;

import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_radius.dart';
import 'package:school_pulse/features/finance/presentation/widgets/finance_kit.dart';

/// Max content width for a workspace body — keeps wide monitors readable.
const double kFinanceWorkspaceMaxWidth = 1360;

/// The shared desktop page frame: a header row (title + "updated" dot +
/// right-aligned primary/secondary actions) above a scrollable body capped
/// at [kFinanceWorkspaceMaxWidth].
class FinanceWorkspace extends StatelessWidget {
  final String title;
  final String? updatedLabel;
  final Widget? primaryAction;
  final List<Widget> secondaryActions;
  final Widget child;
  final EdgeInsetsGeometry padding;

  const FinanceWorkspace({
    super.key,
    required this.title,
    required this.child,
    this.updatedLabel,
    this.primaryAction,
    this.secondaryActions = const [],
    this.padding = const EdgeInsets.fromLTRB(32, 28, 32, 40),
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: kFinanceWorkspaceMaxWidth,
          ),
          child: Padding(
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeaderRow(
                  title: title,
                  updatedLabel: updatedLabel,
                  primaryAction: primaryAction,
                  secondaryActions: secondaryActions,
                ),
                const SizedBox(height: 24),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  final String title;
  final String? updatedLabel;
  final Widget? primaryAction;
  final List<Widget> secondaryActions;

  const _HeaderRow({
    required this.title,
    this.updatedLabel,
    this.primaryAction,
    this.secondaryActions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 16,
      runSpacing: 12,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                  color: AppColors.textPrimary(context),
                ),
              ),
            ),
            if (updatedLabel != null) ...[
              const SizedBox(width: 16),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.success(context),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                updatedLabel!,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted(context),
                ),
              ),
            ],
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final a in secondaryActions) ...[a, const SizedBox(width: 10)],
            ?primaryAction,
          ],
        ),
      ],
    );
  }
}

/// The console's primary button — filled near-black with a trailing "+"
/// affordance, matching the mockup's "Receive payment +".
class WorkspacePrimaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  const WorkspacePrimaryButton({
    super.key,
    required this.label,
    this.icon = Icons.add_rounded,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary(context),
        foregroundColor: AppColors.background(context),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.medium),
        textStyle: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Text(label), const SizedBox(width: 8), Icon(icon, size: 16)],
      ),
    );
  }
}

class WorkspaceSecondaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  const WorkspaceSecondaryButton({
    super.key,
    required this.label,
    this.icon = Icons.add_rounded,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary(context),
        side: BorderSide(color: AppColors.border(context)),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.medium),
        textStyle: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Text(label), const SizedBox(width: 8), Icon(icon, size: 16)],
      ),
    );
  }
}

/// A bordered white panel with an optional title row + "View all" link.
class WorkspaceCard extends StatelessWidget {
  final String? title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget child;
  final EdgeInsetsGeometry padding;

  const WorkspaceCard({
    super.key,
    this.title,
    this.actionLabel,
    this.onAction,
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated(context),
        borderRadius: AppRadius.large,
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
              child: Row(
                children: [
                  Text(
                    title!,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                  const Spacer(),
                  if (actionLabel != null)
                    InkWell(
                      onTap: onAction,
                      child: Text(
                        actionLabel!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.textMuted(context),
                          color: AppColors.textMuted(context),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          if (title != null)
            Divider(height: 1, color: AppColors.border(context)),
          Padding(padding: padding, child: child),
        ],
      ),
    );
  }
}

/// The dashboard KPI tile: label + info/person glyph top-right, a large
/// value (optionally green/red), and a small delta line ("↑ 12.4% vs
/// yesterday").
class MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final IconData glyph;
  final String? delta;
  final bool deltaUp;
  final Color? deltaColor;

  const MetricTile({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.glyph = Icons.info_outline_rounded,
    this.delta,
    this.deltaUp = true,
    this.deltaColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated(context),
        borderRadius: AppRadius.large,
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
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
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ),
              _GlyphChip(icon: glyph),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
              color: valueColor ?? AppColors.textPrimary(context),
            ),
          ),
          if (delta != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  deltaUp
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  size: 13,
                  color: deltaColor ?? AppColors.textMuted(context),
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    delta!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: deltaColor ?? AppColors.textMuted(context),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _GlyphChip extends StatelessWidget {
  final IconData icon;
  const _GlyphChip({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Icon(icon, size: 16, color: AppColors.textSecondary(context)),
    );
  }
}

/// A compact key/value row list used inside the dashboard side panels
/// (Pending approvals, Cash & bank balances).
class MiniListRow extends StatelessWidget {
  final Widget? leading;
  final String title;
  final String? subtitle;
  final String trailing;
  final Color? trailingColor;
  final VoidCallback? onTap;
  final bool showChevron;

  const MiniListRow({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    required this.trailing,
    this.trailingColor,
    this.onTap,
    this.showChevron = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11),
        child: Row(
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 12)],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
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
                        fontSize: 11.5,
                        color: AppColors.textMuted(context),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              trailing,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: trailingColor ?? AppColors.textPrimary(context),
              ),
            ),
            if (showChevron) ...[
              const SizedBox(width: 6),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: AppColors.textMuted(context),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A read-only data grid: header row + rows, optional row tap + selection
/// highlight, and a right-aligned "Showing X–Y of N" footer.
class FinanceDataTable<T> extends StatelessWidget {
  final List<T> rows;
  final List<FinanceColumn<T>> columns;
  final void Function(T)? onRowTap;
  final bool Function(T)? isSelected;
  final int? total;
  final int shownFrom;
  final String emptyMessage;

  const FinanceDataTable({
    super.key,
    required this.rows,
    required this.columns,
    this.onRowTap,
    this.isSelected,
    this.total,
    this.shownFrom = 1,
    this.emptyMessage = 'No records',
  });

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Text(
            emptyMessage,
            style: TextStyle(color: AppColors.textMuted(context)),
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Row(
          isHeader: true,
          cells: [
            for (final c in columns)
              _HeaderCell(label: c.label, flex: c.flex, align: c.align),
          ],
        ),
        Divider(height: 1, color: AppColors.border(context)),
        for (var i = 0; i < rows.length; i++) ...[
          if (i > 0) Divider(height: 1, color: AppColors.border(context)),
          InkWell(
            onTap: onRowTap == null ? null : () => onRowTap!(rows[i]),
            child: Container(
              color: (isSelected?.call(rows[i]) ?? false)
                  ? AppColors.surfaceContainer(context)
                  : null,
              child: _Row(
                isHeader: false,
                cells: [
                  for (final c in columns)
                    Expanded(
                      flex: c.flex,
                      child: Align(
                        alignment: c.align == TextAlign.right
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: c.cell(rows[i]),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
        if (total != null) ...[
          const SizedBox(height: 12),
          Text(
            'Showing $shownFrom–${shownFrom + rows.length - 1} of $total results',
            style: TextStyle(
              fontSize: 11.5,
              color: AppColors.textMuted(context),
            ),
          ),
        ],
      ],
    );
  }
}

class FinanceColumn<T> {
  final String label;
  final int flex;
  final TextAlign align;
  final Widget Function(T) cell;

  FinanceColumn({
    required this.label,
    required this.cell,
    this.flex = 1,
    this.align = TextAlign.left,
  });

  /// Convenience: a plain-text cell.
  factory FinanceColumn.text(
    String label,
    String Function(T) value, {
    int flex = 1,
    TextAlign align = TextAlign.left,
    bool bold = false,
  }) {
    return FinanceColumn<T>(
      label: label,
      flex: flex,
      align: align,
      cell: (row) => Builder(
        builder: (context) => Text(
          value(row),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: align,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            color: AppColors.textPrimary(context),
          ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final bool isHeader;
  final List<Widget> cells;
  const _Row({required this.isHeader, required this.cells});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 4,
        vertical: isHeader ? 10 : 13,
      ),
      child: Row(children: cells),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String label;
  final int flex;
  final TextAlign align;
  const _HeaderCell({
    required this.label,
    required this.flex,
    required this.align,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        textAlign: align,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
          color: AppColors.textMuted(context),
        ),
      ),
    );
  }
}

/// A list / detail split: the list takes the remaining width, the detail
/// panel animates in from the right at [detailWidth] with a left border.
class FinanceSplitPane extends StatelessWidget {
  final Widget list;
  final Widget? detail;
  final double detailWidth;

  const FinanceSplitPane({
    super.key,
    required this.list,
    this.detail,
    this.detailWidth = 420,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: list),
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          width: detail == null ? 0 : detailWidth,
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: AppColors.border(context))),
          ),
          clipBehavior: Clip.hardEdge,
          child: detail == null
              ? const SizedBox.shrink()
              : SingleChildScrollView(child: detail),
        ),
      ],
    );
  }
}

/// Re-export the small status chip so desktop screens don't need two imports.
typedef FinanceChip = FinanceStatusChip;
