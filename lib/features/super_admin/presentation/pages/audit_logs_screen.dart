import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_radius.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../bloc/super_admin_bloc.dart';
import '../bloc/super_admin_event.dart';
import '../bloc/super_admin_state.dart';
import '../responsive.dart';
import '../../domain/entities/audit_log.dart';

/// Client-side categories bucketed heuristically from [AuditLog.action]
/// strings. No new backend calls — this only filters the already-fetched
/// `state.auditLogs` list. Applications/Subscriptions fold into Billing and
/// System covers everything left over (data imports, plan creation, etc.)
/// to match the compact All/Schools/Billing/Security/System chip row.
enum _AuditCategory { all, schools, billing, security, system }

extension on _AuditCategory {
  String get label => switch (this) {
    _AuditCategory.all => 'All',
    _AuditCategory.schools => 'Schools',
    _AuditCategory.billing => 'Billing',
    _AuditCategory.security => 'Security',
    _AuditCategory.system => 'System',
  };

  IconData get icon => switch (this) {
    _AuditCategory.all => Icons.grid_view_rounded,
    _AuditCategory.schools => Icons.school_outlined,
    _AuditCategory.billing => Icons.credit_card_outlined,
    _AuditCategory.security => Icons.shield_outlined,
    _AuditCategory.system => Icons.settings_outlined,
  };
}

_AuditCategory _categoryOf(AuditLog log) {
  final action = log.action.toUpperCase();
  if (action.contains('PAYMENT') ||
      action.contains('PLAN') ||
      action.contains('SUBSCRIPTION')) {
    return _AuditCategory.billing;
  }
  if (action.contains('SIGN_IN') ||
      action.contains('SIGNIN') ||
      action.contains('BLOCK') ||
      action.contains('SECURITY')) {
    return _AuditCategory.security;
  }
  if (action.contains('SCHOOL') ||
      action.contains('APPLICATION') ||
      action.contains('SUSPEND') ||
      action.contains('REACTIVATE') ||
      action.contains('ADMIN')) {
    return _AuditCategory.schools;
  }
  return _AuditCategory.system;
}

/// Turns a machine event id like `APPROVE_INITIAL_SUBSCRIPTION_PAYMENT`
/// into `Approve Initial Subscription Payment` for display. The raw
/// [AuditLog.action] value is never altered — only this presentation
/// label is derived from it.
String _titleCaseAction(String action) => action
    .split('_')
    .where((w) => w.isNotEmpty)
    .map((w) => '${w[0]}${w.substring(1).toLowerCase()}')
    .join(' ');

/// Some audit entries were written with a raw FCM/device token in
/// [AuditLog.ownerId] instead of a user id or email (an upstream data
/// issue, not something this screen can correct at the source). Rather
/// than show that token verbatim, fall back to the signed-in owner's real
/// name/email — the same fallback the desktop table already uses.
String _actorLabel(String ownerId) {
  final looksLikeToken = ownerId.length > 40 && !ownerId.contains('@');
  if (!looksLikeToken) return ownerId;
  final user = FirebaseAuth.instance.currentUser;
  final name = user?.displayName?.trim();
  if (name?.isNotEmpty ?? false) return name!;
  final email = user?.email?.trim();
  if (email?.isNotEmpty ?? false) return email!;
  return 'SaaS Owner';
}

class AuditLogsScreen extends StatefulWidget {
  const AuditLogsScreen({super.key});

  @override
  State<AuditLogsScreen> createState() => _AuditLogsScreenState();
}

enum _Period { today, thisWeek, thisMonth, all }

extension on _Period {
  String get label => switch (this) {
    _Period.today => 'Today',
    _Period.thisWeek => 'This week',
    _Period.thisMonth => 'This month',
    _Period.all => 'All time',
  };

  bool includes(DateTime date) {
    final now = DateTime.now();
    switch (this) {
      case _Period.today:
        return date.year == now.year &&
            date.month == now.month &&
            date.day == now.day;
      case _Period.thisWeek:
        final startOfWeek = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(Duration(days: now.weekday - 1));
        return !date.isBefore(startOfWeek);
      case _Period.thisMonth:
        return date.year == now.year && date.month == now.month;
      case _Period.all:
        return true;
    }
  }
}

class _AuditLogsScreenState extends State<AuditLogsScreen> {
  _AuditCategory _selected = _AuditCategory.all;
  _Period _period = _Period.today;
  DateTimeRange? _dateRange;
  int _page = 0;
  int _rowsPerPage = 10;

  List<AuditLog> _filtered(List<AuditLog> logs) {
    var result = _selected == _AuditCategory.all
        ? logs
        : logs.where((l) => _categoryOf(l) == _selected).toList();
    result = result.where((l) => _period.includes(l.timestamp)).toList();

    if (_dateRange != null) {
      final start = _dateRange!.start;
      final end = _dateRange!.end.add(const Duration(days: 1));
      result = result
          .where((l) => l.timestamp.isAfter(start) && l.timestamp.isBefore(end))
          .toList();
    }

    return result;
  }

  Future<void> _exportAudit(List<AuditLog> logs) async {
    final buffer = StringBuffer('Event,Actor,Category,Timestamp,Reason\n');
    for (final log in logs) {
      String escape(String value) => '"${value.replaceAll('"', '""')}"';
      buffer.writeln(
        [
          escape(log.action),
          escape(log.ownerId),
          escape(_categoryOf(log).label),
          escape(log.timestamp.toIso8601String()),
          escape(log.reason ?? ''),
        ].join(','),
      );
    }
    final bytes = utf8.encode(buffer.toString());
    final name =
        'audit_log_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.csv';
    await Share.shareXFiles([
      XFile.fromData(bytes, name: name, mimeType: 'text/csv'),
    ], subject: 'School Pulse audit log export');
  }

  Future<void> _pickDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
    );
    if (picked == null) return;
    setState(() {
      _dateRange = picked;
      _page = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final wide = isSuperAdminWide(context);
    return Scaffold(
      backgroundColor: wide ? null : AppColors.background(context),
      body: BlocBuilder<SuperAdminBloc, SuperAdminState>(
        builder: (context, state) {
          if (state.status == SuperAdminStatus.loading &&
              state.auditLogs.isEmpty) {
            return const Center(child: SchoolPulseLoader());
          }

          final logs = List<AuditLog>.from(state.auditLogs)
            ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
          final filtered = _filtered(logs);

          if (wide) {
            return _DesktopAuditLogsBody(
              logs: logs,
              filtered: filtered,
              selected: _selected,
              dateRange: _dateRange,
              page: _page,
              rowsPerPage: _rowsPerPage,
              onSelectCategory: (c) => setState(() {
                _selected = c;
                _page = 0;
              }),
              onPickDateRange: () => _pickDateRange(context),
              onClearDateRange: () => setState(() {
                _dateRange = null;
                _page = 0;
              }),
              onRefresh: () => context.read<SuperAdminBloc>().add(
                const LoadAuditLogsEvent(),
              ),
              onPageChanged: (p) => setState(() => _page = p),
              onRowsPerPageChanged: (n) => setState(() {
                _rowsPerPage = n;
                _page = 0;
              }),
            );
          }

          final grouped = _groupByDay(filtered);

          return SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Activity', style: _pageTitle(context)),
                      const Spacer(),
                      if (logs.isNotEmpty) ...[
                        _IconAction(
                          icon: Icons.ios_share_rounded,
                          tooltip: 'Export audit',
                          onTap: () => _exportAudit(filtered),
                        ),
                        const SizedBox(width: 8),
                      ],
                      _IconAction(
                        icon: Icons.refresh_rounded,
                        tooltip: 'Refresh activity',
                        onTap: () => context.read<SuperAdminBloc>().add(
                          const LoadAuditLogsEvent(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _PeriodPicker(
                        period: _period,
                        onChanged: (value) => setState(() {
                          _period = value;
                          _page = 0;
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (logs.isNotEmpty)
                    SizedBox(
                      height: 34,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _AuditCategory.values.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final category = _AuditCategory.values[index];
                          final isSelected = category == _selected;
                          return _CompactChip(
                            label: category.label,
                            isSelected: isSelected,
                            onTap: () => setState(() {
                              _selected = category;
                              _page = 0;
                            }),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 12),
                  if (logs.isEmpty)
                    const _CompactState(
                      icon: Icons.history_outlined,
                      title: 'No audit logs found',
                      message:
                          'Owner actions on the platform will appear here as they happen.',
                    )
                  else if (filtered.isEmpty)
                    _CompactState(
                      icon: Icons.filter_list_off_rounded,
                      title: 'No matching logs',
                      message:
                          'No audit logs match the "${_selected.label}" filter for ${_period.label.toLowerCase()}.',
                    )
                  else
                    for (final group in grouped) ...[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6, top: 4),
                        child: Text(group.label, style: _groupLabel(context)),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated(context),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border(context)),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Column(
                          children: [
                            for (final (i, log) in group.logs.indexed) ...[
                              if (i > 0)
                                Divider(
                                  height: 1,
                                  color: AppColors.border(context),
                                ),
                              AuditActivityRow(log: log),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LogGroup {
  const _LogGroup(this.label, this.logs);
  final String label;
  final List<AuditLog> logs;
}

List<_LogGroup> _groupByDay(List<AuditLog> logs) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final buckets = <String, List<AuditLog>>{};
  final order = <String>[];
  for (final log in logs) {
    final day = DateTime(
      log.timestamp.year,
      log.timestamp.month,
      log.timestamp.day,
    );
    final key = day == today
        ? 'Today'
        : day == yesterday
        ? 'Yesterday'
        : DateFormat('MMMM d, y').format(day);
    if (!buckets.containsKey(key)) order.add(key);
    buckets.putIfAbsent(key, () => []).add(log);
  }
  return [for (final key in order) _LogGroup(key, buckets[key]!)];
}

/// Compact single-row rendering of one audit event: icon/status colour by
/// category, an event sentence, actor/target, and relative time. Reused by
/// the mobile Today/Yesterday grouped list.
class AuditActivityRow extends StatelessWidget {
  const AuditActivityRow({super.key, required this.log});
  final AuditLog log;

  @override
  Widget build(BuildContext context) {
    final category = _categoryOf(log);
    final color = switch (category) {
      _AuditCategory.billing => AppColors.information(context),
      _AuditCategory.schools => AppColors.success(context),
      _AuditCategory.security => AppColors.danger(context),
      _AuditCategory.system => AppColors.warning(context),
      _AuditCategory.all => AppColors.textSecondary(context),
    };
    final icon = switch (category) {
      _AuditCategory.billing => Icons.credit_card_rounded,
      _AuditCategory.schools => Icons.school_rounded,
      _AuditCategory.security => Icons.shield_rounded,
      _AuditCategory.system => Icons.settings_rounded,
      _AuditCategory.all => Icons.circle_notifications_rounded,
    };
    return InkWell(
      onTap: () => _showLogDetail(context, log),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: color.withValues(alpha: .14),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 17, color: color),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _titleCaseAction(log.action),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.textPrimary(context),
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'by ${_actorLabel(log.ownerId)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary(context),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _relativeTime(log.timestamp),
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textMuted(context),
                fontSize: 11.5,
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: AppColors.textMuted(context),
            ),
          ],
        ),
      ),
    );
  }

  String _relativeTime(DateTime timestamp) {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  void _showLogDetail(BuildContext context, AuditLog log) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _titleCaseAction(log.action),
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'By ${_actorLabel(log.ownerId)} • ${log.device}',
              style: AppTypography.bodySmall,
            ),
            const SizedBox(height: 6),
            Text(
              DateFormat('MMM d, yyyy • h:mm a').format(log.timestamp),
              style: AppTypography.bodySmall,
            ),
            if (log.reason != null) ...[
              const SizedBox(height: 6),
              Text('Reason: ${log.reason}', style: AppTypography.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border(context)),
          ),
          child: Icon(icon, size: 20, color: AppColors.textPrimary(context)),
        ),
      ),
    ),
  );
}

class _PeriodPicker extends StatelessWidget {
  const _PeriodPicker({required this.period, required this.onChanged});
  final _Period period;
  final ValueChanged<_Period> onChanged;
  @override
  Widget build(BuildContext context) => PopupMenuButton<_Period>(
    tooltip: 'Select period',
    onSelected: onChanged,
    itemBuilder: (_) => [
      for (final option in _Period.values)
        PopupMenuItem(value: option, child: Text(option.label)),
    ],
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 16,
            color: AppColors.textSecondary(context),
          ),
          const SizedBox(width: 7),
          Text(
            period.label,
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 18,
            color: AppColors.textSecondary(context),
          ),
        ],
      ),
    ),
  );
}

class _CompactChip extends StatelessWidget {
  const _CompactChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final color = isSelected
        ? AppColors.information(context)
        : AppColors.textSecondary(context);
    return Material(
      color: isSelected
          ? AppColors.informationSurface(context)
          : AppColors.surfaceElevated(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: isSelected
              ? AppColors.information(context)
              : AppColors.border(context),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Center(
            child: Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 12.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CompactState extends StatelessWidget {
  const _CompactState({
    required this.icon,
    required this.title,
    required this.message,
  });
  final IconData icon;
  final String title, message;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 40),
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 28, color: AppColors.textMuted(context)),
          const SizedBox(height: 8),
          Text(
            title,
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textPrimary(context),
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary(context),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

TextStyle _pageTitle(BuildContext c) => AppTypography.headlineMedium.copyWith(
  color: AppColors.textPrimary(c),
  fontSize: 24,
  fontWeight: FontWeight.w800,
);
TextStyle _groupLabel(BuildContext c) => AppTypography.titleMedium.copyWith(
  color: AppColors.textPrimary(c),
  fontSize: 15,
  fontWeight: FontWeight.w800,
);

/// Desktop table layout matching the reference: flat header with Refresh /
/// Filters, category pill row, search + date range, an EVENT/ACTOR/
/// CATEGORY/DATE & TIME table, and client-side pagination over the
/// already-fetched `state.auditLogs` list (the repository has no server
/// cursor to page against yet).
class _DesktopAuditLogsBody extends StatelessWidget {
  const _DesktopAuditLogsBody({
    required this.logs,
    required this.filtered,
    required this.selected,
    required this.dateRange,
    required this.page,
    required this.rowsPerPage,
    required this.onSelectCategory,
    required this.onPickDateRange,
    required this.onClearDateRange,
    required this.onRefresh,
    required this.onPageChanged,
    required this.onRowsPerPageChanged,
  });

  final List<AuditLog> logs;
  final List<AuditLog> filtered;
  final _AuditCategory selected;
  final DateTimeRange? dateRange;
  final int page;
  final int rowsPerPage;
  final ValueChanged<_AuditCategory> onSelectCategory;
  final VoidCallback onPickDateRange;
  final VoidCallback onClearDateRange;
  final VoidCallback onRefresh;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onRowsPerPageChanged;

  @override
  Widget build(BuildContext context) {
    final totalPages = filtered.isEmpty
        ? 1
        : (filtered.length / rowsPerPage).ceil();
    final clampedPage = page.clamp(0, totalPages - 1);
    final start = clampedPage * rowsPerPage;
    final end = (start + rowsPerPage).clamp(0, filtered.length);
    final pageItems = filtered.isEmpty
        ? const <AuditLog>[]
        : filtered.sublist(start, end);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.x2l,
        AppSpacing.xl,
        AppSpacing.x2l,
        AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Audit Logs',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.headlineMedium.copyWith(
                        color: AppColors.textPrimary(context),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Review platform activity and owner actions.',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Refresh'),
              ),
              const SizedBox(width: AppSpacing.m),
              OutlinedButton.icon(
                onPressed: onPickDateRange,
                icon: const Icon(Icons.filter_alt_outlined, size: 18),
                label: const Text('Filters'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.l),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _AuditCategory.values.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.s),
              itemBuilder: (context, index) {
                final category = _AuditCategory.values[index];
                final isSelected = category == selected;
                return _CategoryPill(
                  label: category.label,
                  icon: category.icon,
                  isSelected: isSelected,
                  onTap: () => onSelectCategory(category),
                );
              },
            ),
          ),
          if (dateRange != null) ...[
            const SizedBox(height: AppSpacing.l),
            _ActiveDateRangeChip(
              dateRange: dateRange!,
              onClear: onClearDateRange,
            ),
          ],
          const SizedBox(height: AppSpacing.l),
          Expanded(
            child: logs.isEmpty
                ? const EmptyState(
                    icon: Icons.history_outlined,
                    title: 'No audit logs found',
                    message:
                        'Owner actions on the platform will appear here as they happen.',
                  )
                : filtered.isEmpty
                ? const EmptyState(
                    icon: Icons.filter_list_off_rounded,
                    title: 'No matching logs',
                    message: 'Try a different search, category or date range.',
                  )
                : Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated(context),
                      borderRadius: AppRadius.large,
                      border: Border.all(color: AppColors.border(context)),
                    ),
                    child: Column(
                      children: [
                        _AuditTableHeader(),
                        const Divider(height: 1),
                        Expanded(
                          child: ListView.separated(
                            itemCount: pageItems.length,
                            separatorBuilder: (_, _) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) =>
                                _AuditTableRow(log: pageItems[index]),
                          ),
                        ),
                        const Divider(height: 1),
                        _AuditPaginationBar(
                          totalItems: filtered.length,
                          page: clampedPage,
                          totalPages: totalPages,
                          rowsPerPage: rowsPerPage,
                          onPageChanged: onPageChanged,
                          onRowsPerPageChanged: onRowsPerPageChanged,
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Shown under the category pills only while a date range filter is
/// active, so "Filters" (which opens the date range picker) has a clear,
/// dismissible indicator of the current filter state.
class _ActiveDateRangeChip extends StatelessWidget {
  const _ActiveDateRangeChip({required this.dateRange, required this.onClear});

  final DateTimeRange dateRange;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.m,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: AppColors.primary(context),
          borderRadius: AppRadius.full,
          border: Border.all(color: AppColors.primary(context)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 14,
              color: AppColors.primary(context),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              '${DateFormat('MMM d').format(dateRange.start)} - ${DateFormat('MMM d').format(dateRange.end)}',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.primary(context),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            InkWell(
              onTap: onClear,
              borderRadius: AppRadius.full,
              child: Icon(
                Icons.close_rounded,
                size: 16,
                color: AppColors.primary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  const _CategoryPill({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected
        ? AppColors.primary(context)
        : AppColors.textSecondary(context);
    return Material(
      color: isSelected
          ? AppColors.primary(context)
          : AppColors.surfaceElevated(context),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.medium,
        side: BorderSide(
          color: isSelected
              ? AppColors.primary(context)
              : AppColors.border(context),
        ),
      ),
      child: InkWell(
        borderRadius: AppRadius.medium,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: AppSpacing.s),
              Text(
                label,
                style: AppTypography.labelMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuditTableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.l,
        vertical: AppSpacing.m,
      ),
      child: Row(
        children: [
          _headCell(context, 'Event', flex: 4),
          _headCell(context, 'Actor', flex: 3),
          _headCell(context, 'Category', flex: 2),
          _headCell(context, 'Date & Time', flex: 2),
        ],
      ),
    );
  }

  Widget _headCell(BuildContext context, String label, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Text(
        label.toUpperCase(),
        style: AppTypography.labelSmall.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary(context),
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _AuditTableRow extends StatelessWidget {
  const _AuditTableRow({required this.log});

  final AuditLog log;

  @override
  Widget build(BuildContext context) {
    final category = _categoryOf(log);
    final user = FirebaseAuth.instance.currentUser;
    final actorName = (user?.displayName?.trim().isNotEmpty ?? false)
        ? user!.displayName!.trim()
        : 'SaaS Owner';
    final actorEmail = user?.email?.trim().isNotEmpty ?? false
        ? user!.email!.trim()
        : log.ownerId;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.l,
        vertical: AppSpacing.m,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary(context),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.history_rounded,
                    color: AppColors.primary(context),
                    size: 16,
                  ),
                ),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _titleCaseAction(log.action),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.labelLarge.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        log.action,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                      if (log.reason != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Reason: ${log.reason}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.danger(context),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: AppColors.primary(context),
                  child: Text(
                    'MG',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.s),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        actorName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                      Text(
                        actorEmail,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: StatusBadge(
                label: category.label,
                color: _categoryColor(context, category),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat(
                    'MMM d, yyyy HH:mm',
                  ).format(log.timestamp.toLocal()),
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textPrimary(context),
                  ),
                ),
                Text(
                  _relativeTime(log.timestamp),
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _categoryColor(BuildContext context, _AuditCategory category) =>
      switch (category) {
        _AuditCategory.billing => AppColors.information(context),
        _AuditCategory.schools => AppColors.success(context),
        _AuditCategory.security => AppColors.danger(context),
        _AuditCategory.system => AppColors.warning(context),
        _AuditCategory.all => AppColors.textSecondary(context),
      };

  String _relativeTime(DateTime timestamp) {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} minutes ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    return '${diff.inDays} days ago';
  }
}

class _AuditPaginationBar extends StatelessWidget {
  const _AuditPaginationBar({
    required this.totalItems,
    required this.page,
    required this.totalPages,
    required this.rowsPerPage,
    required this.onPageChanged,
    required this.onRowsPerPageChanged,
  });

  final int totalItems;
  final int page;
  final int totalPages;
  final int rowsPerPage;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onRowsPerPageChanged;

  @override
  Widget build(BuildContext context) {
    final start = totalItems == 0 ? 0 : page * rowsPerPage + 1;
    final end = ((page + 1) * rowsPerPage).clamp(0, totalItems);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.l,
        vertical: AppSpacing.m,
      ),
      child: Row(
        children: [
          Text(
            'Showing $start to $end of $totalItems logs',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary(context),
            ),
          ),
          const Spacer(),
          IconButton(
            tooltip: 'Previous page',
            icon: const Icon(Icons.chevron_left_rounded),
            onPressed: page > 0 ? () => onPageChanged(page - 1) : null,
          ),
          Text(
            '${page + 1} / $totalPages',
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary(context),
            ),
          ),
          IconButton(
            tooltip: 'Next page',
            icon: const Icon(Icons.chevron_right_rounded),
            onPressed: page < totalPages - 1
                ? () => onPageChanged(page + 1)
                : null,
          ),
          const SizedBox(width: AppSpacing.m),
          DropdownButton<int>(
            value: rowsPerPage,
            underline: const SizedBox.shrink(),
            items: const [10, 25, 50]
                .map(
                  (n) => DropdownMenuItem(value: n, child: Text('$n per page')),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) onRowsPerPageChanged(value);
            },
          ),
        ],
      ),
    );
  }
}
