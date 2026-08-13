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
import '../bloc/super_admin_bloc.dart';
import '../bloc/super_admin_event.dart';
import '../bloc/super_admin_state.dart';
import '../responsive.dart';
import '../../domain/entities/audit_log.dart';

/// Client-side categories bucketed heuristically from [AuditLog.action]
/// strings. No new backend calls — this only filters the already-fetched
/// `state.auditLogs` list.
enum _AuditCategory {
  all,
  schools,
  applications,
  payments,
  subscriptions,
  security,
}

extension on _AuditCategory {
  String get label => switch (this) {
    _AuditCategory.all => 'All',
    _AuditCategory.schools => 'Schools',
    _AuditCategory.applications => 'Applications',
    _AuditCategory.payments => 'Payments',
    _AuditCategory.subscriptions => 'Subscriptions',
    _AuditCategory.security => 'Security',
  };

  IconData get icon => switch (this) {
    _AuditCategory.all => Icons.grid_view_rounded,
    _AuditCategory.schools => Icons.account_balance_outlined,
    _AuditCategory.applications => Icons.description_outlined,
    _AuditCategory.payments => Icons.payments_outlined,
    _AuditCategory.subscriptions => Icons.subscriptions_outlined,
    _AuditCategory.security => Icons.shield_outlined,
  };
}

_AuditCategory _categoryOf(AuditLog log) {
  final action = log.action.toUpperCase();
  if (action.contains('PAYMENT')) return _AuditCategory.payments;
  if (action.contains('APPLICATION')) return _AuditCategory.applications;
  if (action.contains('PLAN')) return _AuditCategory.subscriptions;
  if (action.contains('SCHOOL') ||
      action.contains('SUSPEND') ||
      action.contains('REACTIVATE')) {
    return _AuditCategory.schools;
  }
  return _AuditCategory.security;
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

class AuditLogsScreen extends StatefulWidget {
  const AuditLogsScreen({super.key});

  @override
  State<AuditLogsScreen> createState() => _AuditLogsScreenState();
}

class _AuditLogsScreenState extends State<AuditLogsScreen> {
  _AuditCategory _selected = _AuditCategory.all;
  DateTimeRange? _dateRange;
  int _page = 0;
  int _rowsPerPage = 10;

  List<AuditLog> _filtered(List<AuditLog> logs) {
    var result = _selected == _AuditCategory.all
        ? logs
        : logs.where((l) => _categoryOf(l) == _selected).toList();

    if (_dateRange != null) {
      final start = _dateRange!.start;
      final end = _dateRange!.end.add(const Duration(days: 1));
      result = result
          .where((l) => l.timestamp.isAfter(start) && l.timestamp.isBefore(end))
          .toList();
    }

    return result;
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
      appBar: wide
          ? null
          : AppBar(
              title: const Text('Audit Logs'),
              actions: [
                IconButton(
                  tooltip: 'Refresh',
                  icon: const Icon(Icons.refresh_rounded),
                  onPressed: () => context.read<SuperAdminBloc>().add(
                    const LoadAuditLogsEvent(),
                  ),
                ),
                const SizedBox(width: AppSpacing.m),
              ],
            ),
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

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.x2l,
                  AppSpacing.xl,
                  AppSpacing.x2l,
                  AppSpacing.l,
                ),
                child: Text(
                  'Review platform activity and owner actions.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ),
              if (logs.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(
                    left: AppSpacing.x2l,
                    right: AppSpacing.x2l,
                    bottom: AppSpacing.l,
                  ),
                  child: SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _AuditCategory.values.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(width: AppSpacing.s),
                      itemBuilder: (context, index) {
                        final category = _AuditCategory.values[index];
                        final isSelected = category == _selected;
                        return FilterChip(
                          label: Text(category.label),
                          selected: isSelected,
                          onSelected: (_) => setState(() {
                            _selected = category;
                            _page = 0;
                          }),
                        );
                      },
                    ),
                  ),
                ),
              Expanded(
                child: logs.isEmpty
                    ? const EmptyState(
                        icon: Icons.history_outlined,
                        title: 'No audit logs found',
                        message:
                            'Owner actions on the platform will appear here as they happen.',
                      )
                    : filtered.isEmpty
                    ? EmptyState(
                        icon: Icons.filter_list_off_rounded,
                        title: 'No matching logs',
                        message:
                            'No audit logs match the "${_selected.label}" filter.',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.x2l,
                          0,
                          AppSpacing.x2l,
                          AppSpacing.x2l,
                        ),
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: AppSpacing.m),
                        itemBuilder: (context, index) {
                          final log = filtered[index];
                          return _AuditLogTile(log: log);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AuditLogTile extends StatelessWidget {
  const _AuditLogTile({required this.log});
  final AuditLog log;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      showShadow: false,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.m),
            decoration: BoxDecoration(
              color: AppColors.primary(context).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.history_rounded,
              color: AppColors.primary(context),
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.action,
                  style: AppTypography.labelLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'By ${log.ownerId} • ${log.device}',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
                ),
                if (log.reason != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Reason: ${log.reason}',
                    style: AppTypography.bodySmall.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.m),
          Text(
            DateFormat('MMM dd, HH:mm').format(log.timestamp),
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }
}

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
          color: AppColors.primary(context).withValues(alpha: 0.1),
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
          ? AppColors.primary(context).withValues(alpha: 0.1)
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
                    color: AppColors.primary(context).withValues(alpha: 0.1),
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
        _AuditCategory.payments => AppColors.success(context),
        _AuditCategory.applications => AppColors.information(context),
        _AuditCategory.subscriptions => AppColors.royalBlue,
        _AuditCategory.schools => AppColors.warning(context),
        _AuditCategory.security => AppColors.danger(context),
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
