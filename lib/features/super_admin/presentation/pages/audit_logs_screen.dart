import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_radius.dart';
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
      action.contains('SUBSCRIPTION') ||
      action.contains('INVOICE')) {
    return _AuditCategory.billing;
  }
  if (action.contains('SIGN_IN') ||
      action.contains('SIGNIN') ||
      action.contains('LOGIN') ||
      action.contains('BLOCK') ||
      action.contains('DELETE') ||
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

/// A destructive or security-risk event — the only case where red chrome is
/// used. Everything else stays monochrome / semantic-green.
bool _isDestructive(AuditLog log) {
  final a = log.action.toUpperCase();
  return a.contains('DELETE') ||
      a.contains('REMOVE') ||
      a.contains('REVOKE') ||
      a.contains('SUSPEND') ||
      a.contains('BLOCK') ||
      a.contains('FAILED') ||
      a.contains('DENY') ||
      a.contains('REJECT');
}

/// A successful / verified event — rendered with the semantic green accent.
bool _isSuccess(AuditLog log) {
  final a = log.action.toUpperCase();
  return a.contains('SUCCESS') ||
      a.contains('APPROVE') ||
      a.contains('VERIFY') ||
      a.contains('VERIFIED') ||
      a.contains('ACTIVATE') ||
      a.contains('REACTIVATE') ||
      a.contains('CREATE') ||
      a.contains('ADD') ||
      a.contains('GRANT');
}

/// Meaningful glyph for an event, chosen from the action verb first and the
/// category second — never a blank avatar.
IconData _eventIcon(AuditLog log) {
  final a = log.action.toUpperCase();
  if (a.contains('LOGIN') || a.contains('SIGN_IN') || a.contains('SIGNIN')) {
    return a.contains('FAIL')
        ? Icons.gpp_bad_outlined
        : Icons.verified_user_outlined;
  }
  if (a.contains('DELETE') || a.contains('REMOVE')) {
    return Icons.delete_outline_rounded;
  }
  if (a.contains('SUSPEND') || a.contains('BLOCK')) return Icons.block_rounded;
  if (a.contains('REVOKE') || a.contains('DENY') || a.contains('REJECT')) {
    return Icons.gpp_bad_outlined;
  }
  if (a.contains('INVOICE')) return Icons.receipt_long_outlined;
  if (a.contains('PAYMENT')) return Icons.payments_outlined;
  if (a.contains('PLAN') || a.contains('SUBSCRIPTION')) {
    return Icons.workspace_premium_outlined;
  }
  if (a.contains('API') || a.contains('KEY')) return Icons.vpn_key_outlined;
  if (a.contains('ADMIN')) return Icons.person_add_alt_1_outlined;
  if (a.contains('SCHOOL') && (a.contains('CREATE') || a.contains('ADD'))) {
    return Icons.add_business_outlined;
  }
  if (a.contains('SCHOOL')) return Icons.school_outlined;
  if (a.contains('SETTING')) return Icons.tune_rounded;
  if (a.contains('IMPORT') || a.contains('EXPORT')) {
    return Icons.swap_vert_rounded;
  }
  return switch (_categoryOf(log)) {
    _AuditCategory.billing => Icons.credit_card_outlined,
    _AuditCategory.schools => Icons.school_outlined,
    _AuditCategory.security => Icons.shield_outlined,
    _AuditCategory.system => Icons.settings_outlined,
    _AuditCategory.all => Icons.bolt_outlined,
  };
}

/// Accent color for an event's icon and status dot. Green for verified,
/// red only for destructive / security-risk, otherwise near-black/white.
Color _eventAccent(BuildContext context, AuditLog log) {
  if (_isDestructive(log)) return AppColors.danger(context);
  if (_isSuccess(log)) return AppColors.success(context);
  return AppColors.textPrimary(context);
}

Color _categoryColor(BuildContext context, _AuditCategory category) =>
    switch (category) {
      _AuditCategory.billing => AppColors.information(context),
      _AuditCategory.schools => AppColors.success(context),
      _AuditCategory.security => AppColors.danger(context),
      _AuditCategory.system => AppColors.textSecondary(context),
      _AuditCategory.all => AppColors.textSecondary(context),
    };

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

/// Owner display name (never derived from an email local-part), used as the
/// primary actor line beside the avatar.
String _actorName() {
  final user = FirebaseAuth.instance.currentUser;
  final name = user?.displayName?.trim();
  if (name?.isNotEmpty ?? false) return name!;
  return 'SaaS Owner';
}

String _actorInitials() {
  final name = _actorName();
  final parts = name.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return 'SO';
  if (parts.length == 1) {
    return parts.first.substring(0, parts.first.length >= 2 ? 2 : 1)
        .toUpperCase();
  }
  return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
}

/// The target school / entity a log entry acted on. Uses [AuditLog.schoolId]
/// or [AuditLog.affectedUserId] when captured, otherwise an em dash — the
/// raw record is never mutated.
String _targetLabel(AuditLog log) {
  if (log.schoolId?.trim().isNotEmpty ?? false) return log.schoolId!.trim();
  if (log.affectedUserId?.trim().isNotEmpty ?? false) {
    return log.affectedUserId!.trim();
  }
  final meta = log.metadata;
  for (final key in const ['schoolName', 'targetName', 'school', 'target']) {
    final v = meta[key];
    if (v is String && v.trim().isNotEmpty) return v.trim();
  }
  return '—';
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

  final TextEditingController _searchController = TextEditingController();
  String _search = '';
  String? _actorFilter; // null == "All actors"
  AuditLog? _selectedLog;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _hasActiveFilters =>
      _search.isNotEmpty ||
      _dateRange != null ||
      _actorFilter != null ||
      _selected != _AuditCategory.all ||
      _period != _Period.today;

  int get _activeFilterCount {
    var n = 0;
    if (_search.isNotEmpty) n++;
    if (_dateRange != null) n++;
    if (_actorFilter != null) n++;
    if (_selected != _AuditCategory.all) n++;
    if (_period != _Period.today) n++;
    return n;
  }

  /// Applies every non-category filter (period, date range, search text,
  /// actor) to a list. Category is applied separately so the chip counts can
  /// each reflect "everything else, then this category".
  List<AuditLog> _applyNonCategory(List<AuditLog> logs) {
    var result = logs.where((l) => _period.includes(l.timestamp)).toList();

    if (_dateRange != null) {
      final start = _dateRange!.start;
      final end = _dateRange!.end.add(const Duration(days: 1));
      result = result
          .where((l) => l.timestamp.isAfter(start) && l.timestamp.isBefore(end))
          .toList();
    }

    if (_actorFilter != null) {
      result = result.where((l) => l.ownerId == _actorFilter).toList();
    }

    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      result = result.where((l) {
        return l.action.toLowerCase().contains(q) ||
            _titleCaseAction(l.action).toLowerCase().contains(q) ||
            _actorLabel(l.ownerId).toLowerCase().contains(q) ||
            _targetLabel(l).toLowerCase().contains(q) ||
            (l.reason?.toLowerCase().contains(q) ?? false) ||
            l.id.toLowerCase().contains(q);
      }).toList();
    }

    return result;
  }

  List<AuditLog> _filtered(List<AuditLog> logs) {
    final base = _applyNonCategory(logs);
    if (_selected == _AuditCategory.all) return base;
    return base.where((l) => _categoryOf(l) == _selected).toList();
  }

  Map<_AuditCategory, int> _categoryCounts(List<AuditLog> logs) {
    final base = _applyNonCategory(logs);
    final counts = {for (final c in _AuditCategory.values) c: 0};
    counts[_AuditCategory.all] = base.length;
    for (final log in base) {
      final c = _categoryOf(log);
      counts[c] = (counts[c] ?? 0) + 1;
    }
    return counts;
  }

  /// Distinct actor ids present in the already-fetched logs, for the
  /// "All actors" dropdown. In-memory only — no new query.
  List<String> _actorOptions(List<AuditLog> logs) {
    final seen = <String>{};
    for (final l in logs) {
      seen.add(l.ownerId);
    }
    final list = seen.toList()
      ..sort((a, b) => _actorLabel(a).toLowerCase().compareTo(
        _actorLabel(b).toLowerCase(),
      ));
    return list;
  }

  Future<void> _exportAudit(List<AuditLog> logs) async {
    final buffer = StringBuffer(
      'Event,EventCode,Actor,Target,Category,Timestamp,Reason\n',
    );
    for (final log in logs) {
      String escape(String value) => '"${value.replaceAll('"', '""')}"';
      buffer.writeln(
        [
          escape(_titleCaseAction(log.action)),
          escape(log.action),
          escape(_actorLabel(log.ownerId)),
          escape(_targetLabel(log)),
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

  void _clearFilters() {
    setState(() {
      _search = '';
      _searchController.clear();
      _dateRange = null;
      _actorFilter = null;
      _selected = _AuditCategory.all;
      _period = _Period.today;
      _page = 0;
    });
  }

  void _openInspector(AuditLog log, {required bool wide}) {
    if (wide) {
      setState(() => _selectedLog = log);
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: AppColors.background(context),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) => _AuditInspector(
          log: log,
          isSheet: true,
          onClose: () => Navigator.of(context).pop(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final wide = isSuperAdminWide(context);
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: BlocBuilder<SuperAdminBloc, SuperAdminState>(
        builder: (context, state) {
          if (state.status == SuperAdminStatus.loading &&
              state.auditLogs.isEmpty) {
            return const Center(child: SchoolPulseLoader());
          }

          final logs = List<AuditLog>.from(state.auditLogs)
            ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
          final filtered = _filtered(logs);
          final counts = _categoryCounts(logs);
          final actors = _actorOptions(logs);

          // Keep the desktop inspector selection valid against the current
          // filter set without ever discarding the underlying record.
          if (_selectedLog != null &&
              !filtered.any((l) => l.id == _selectedLog!.id)) {
            _selectedLog = null;
          }

          if (wide) {
            return _DesktopAuditLogsBody(
              logs: logs,
              filtered: filtered,
              counts: counts,
              actors: actors,
              selected: _selected,
              period: _period,
              dateRange: _dateRange,
              searchController: _searchController,
              actorFilter: _actorFilter,
              activeFilterCount: _activeFilterCount,
              hasActiveFilters: _hasActiveFilters,
              selectedLog: _selectedLog,
              page: _page,
              rowsPerPage: _rowsPerPage,
              onSearch: (v) => setState(() {
                _search = v;
                _page = 0;
              }),
              onSelectCategory: (c) => setState(() {
                _selected = c;
                _page = 0;
              }),
              onSelectPeriod: (p) => setState(() {
                _period = p;
                _page = 0;
              }),
              onSelectActor: (a) => setState(() {
                _actorFilter = a;
                _page = 0;
              }),
              onPickDateRange: () => _pickDateRange(context),
              onClearDateRange: () => setState(() {
                _dateRange = null;
                _page = 0;
              }),
              onClearFilters: _clearFilters,
              onExport: () => _exportAudit(filtered),
              onRefresh: () => context.read<SuperAdminBloc>().add(
                const LoadAuditLogsEvent(),
              ),
              onOpenLog: (l) => _openInspector(l, wide: true),
              onCloseInspector: () => setState(() => _selectedLog = null),
              onPageChanged: (p) => setState(() => _page = p),
              onRowsPerPageChanged: (n) => setState(() {
                _rowsPerPage = n;
                _page = 0;
              }),
            );
          }

          return _MobileAuditLogsBody(
            logs: logs,
            filtered: filtered,
            counts: counts,
            selected: _selected,
            period: _period,
            dateRange: _dateRange,
            searchController: _searchController,
            hasActiveFilters: _hasActiveFilters,
            onSearch: (v) => setState(() {
              _search = v;
              _page = 0;
            }),
            onSelectCategory: (c) => setState(() {
              _selected = c;
              _page = 0;
            }),
            onSelectPeriod: (p) => setState(() {
              _period = p;
              _page = 0;
            }),
            onPickDateRange: () => _pickDateRange(context),
            onClearDateRange: () => setState(() {
              _dateRange = null;
              _page = 0;
            }),
            onClearFilters: _clearFilters,
            onExport: () => _exportAudit(filtered),
            onRefresh: () => context.read<SuperAdminBloc>().add(
              const LoadAuditLogsEvent(),
            ),
            onOpenLog: (l) => _openInspector(l, wide: false),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared small pieces
// ---------------------------------------------------------------------------

String _relativeTime(DateTime timestamp) {
  final diff = DateTime.now().difference(timestamp);
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} minutes ago';
  if (diff.inHours < 24) return '${diff.inHours} hours ago';
  return '${diff.inDays} days ago';
}

String _absoluteTime(DateTime timestamp) =>
    DateFormat('MMM d, yyyy HH:mm:ss').format(timestamp.toLocal());

/// Small square action button used in the compact headers (Export CSV,
/// Refresh, Filters).
class _HeaderButton extends StatelessWidget {
  const _HeaderButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.badge,
    this.filled = false,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final int? badge;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final fg = filled
        ? AppColors.background(context)
        : AppColors.textPrimary(context);
    final bg = filled
        ? AppColors.information(context)
        : AppColors.surfaceElevated(context);
    return Material(
      color: bg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: filled
              ? AppColors.information(context)
              : AppColors.border(context),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: fg),
              const SizedBox(width: 7),
              Text(
                label,
                style: AppTypography.labelMedium.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                ),
              ),
              if (badge != null && badge! > 0) ...[
                const SizedBox(width: 7),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: filled
                        ? AppColors.background(context).withValues(alpha: .25)
                        : AppColors.textPrimary(context),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$badge',
                    style: AppTypography.labelSmall.copyWith(
                      color: filled
                          ? AppColors.background(context)
                          : AppColors.background(context),
                      fontWeight: FontWeight.w800,
                      fontSize: 10.5,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// A framed dropdown used by the dense filter toolbar (actor, category,
/// per-page). Thin border, 10px radius, no elevation.
class _FilterDropdown<T> extends StatelessWidget {
  const _FilterDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
    this.leading,
    this.width,
  });
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final IconData? leading;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated(context),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) ...[
            Icon(leading, size: 15, color: AppColors.textSecondary(context)),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                value: value,
                isDense: true,
                isExpanded: width != null,
                borderRadius: BorderRadius.circular(10),
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: AppColors.textSecondary(context),
                ),
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.textPrimary(context),
                  fontWeight: FontWeight.w600,
                  fontSize: 12.5,
                ),
                dropdownColor: AppColors.surfaceElevated(context),
                items: items,
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Category chip with a trailing count, e.g. "Billing 1,385".
class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.category,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });
  final _AuditCategory category;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = category == _AuditCategory.security
        ? AppColors.danger(context)
        : category == _AuditCategory.billing
        ? AppColors.information(context)
        : AppColors.textPrimary(context);
    final selectedBg = category == _AuditCategory.security
        ? AppColors.dangerSurface(context)
        : AppColors.informationSurface(context);
    return Material(
      color: isSelected ? selectedBg : AppColors.surfaceElevated(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isSelected ? accent : AppColors.border(context),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                category.icon,
                size: 15,
                color: isSelected
                    ? accent
                    : AppColors.textSecondary(context),
              ),
              const SizedBox(width: 7),
              Text(
                category.label,
                style: AppTypography.labelMedium.copyWith(
                  color: isSelected
                      ? AppColors.textPrimary(context)
                      : AppColors.textSecondary(context),
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                ),
              ),
              const SizedBox(width: 7),
              Text(
                NumberFormat.decimalPattern().format(count),
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textMuted(context),
                  fontWeight: FontWeight.w700,
                  fontSize: 11.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Copyable value row used inside the inspector.
class _CopyField extends StatelessWidget {
  const _CopyField({required this.label, required this.value, this.mono = false});
  final String label;
  final String value;
  final bool mono;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textMuted(context),
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 3),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SelectableText(
                value,
                style: (mono
                        ? AppTypography.bodySmall.copyWith(
                            fontFamily: 'monospace',
                          )
                        : AppTypography.bodyMedium)
                    .copyWith(color: AppColors.textPrimary(context)),
              ),
            ),
            if (value != '—')
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: value));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$label copied'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.copy_rounded,
                    size: 15,
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// A faithful, read-only projection of the audit record for the raw JSON
/// pane. Nothing here is written back.
Map<String, dynamic> _rawJson(AuditLog log) => {
  'id': log.id,
  'action': log.action,
  'ownerId': log.ownerId,
  'schoolId': log.schoolId,
  'affectedUserId': log.affectedUserId,
  'timestamp': log.timestamp.toIso8601String(),
  'device': log.device,
  'reason': log.reason,
  'metadata': log.metadata,
};

String? _metaValue(AuditLog log, List<String> keys) {
  for (final k in keys) {
    final v = log.metadata[k];
    if (v != null && '$v'.trim().isNotEmpty) return '$v';
  }
  return null;
}

/// The responsive audit-detail inspector. Rendered as a fixed right-hand
/// panel on desktop and as a scrollable bottom sheet on mobile. It is
/// strictly read-only — there is no control here that can edit or delete
/// an audit record.
class _AuditInspector extends StatefulWidget {
  const _AuditInspector({
    required this.log,
    required this.onClose,
    this.isSheet = false,
  });
  final AuditLog log;
  final VoidCallback onClose;
  final bool isSheet;

  @override
  State<_AuditInspector> createState() => _AuditInspectorState();
}

class _AuditInspectorState extends State<_AuditInspector> {
  int _tab = 0; // 0 = Details, 1 = Raw JSON

  AuditLog get log => widget.log;

  void _copy(String label, String value) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final category = _categoryOf(log);
    final accent = _eventAccent(context, log);
    final success = _isSuccess(log) && !_isDestructive(log);

    final body = ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      shrinkWrap: widget.isSheet,
      physics: widget.isSheet ? const ClampingScrollPhysics() : null,
      children: [
        if (widget.isSheet)
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: AppColors.border(context),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: .12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                success ? Icons.check_circle_rounded : _eventIcon(log),
                size: 18,
                color: accent,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _titleCaseAction(log.action),
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.textPrimary(context),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          log.action,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textMuted(context),
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      StatusBadge(
                        label: _isDestructive(log)
                            ? 'Risk'
                            : success
                            ? 'Success'
                            : category.label,
                        color: _isDestructive(log)
                            ? AppColors.danger(context)
                            : success
                            ? AppColors.success(context)
                            : _categoryColor(context, category),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Close',
              icon: const Icon(Icons.close_rounded, size: 18),
              onPressed: widget.onClose,
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Details / Raw JSON tabs -----------------------------------------
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: AppColors.background(context),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border(context)),
          ),
          child: Row(
            children: [
              _tabButton('Details', 0),
              _tabButton('Raw JSON', 1),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (_tab == 0) ..._detailsPane(context, category, success) else
          _rawJsonPane(context),
        const SizedBox(height: 16),
        Row(
          children: [
            Icon(
              Icons.lock_outline_rounded,
              size: 13,
              color: AppColors.textMuted(context),
            ),
            const SizedBox(width: 6),
            Text(
              'Immutable audit record · read-only',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textMuted(context),
              ),
            ),
          ],
        ),
      ],
    );

    if (widget.isSheet) {
      return SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.9,
          ),
          child: body,
        ),
      );
    }

    return Container(
      width: 380,
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated(context),
        borderRadius: AppRadius.large,
        border: Border.all(color: AppColors.border(context)),
      ),
      clipBehavior: Clip.antiAlias,
      child: body,
    );
  }

  Widget _tabButton(String label, int index) {
    final selected = _tab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.surfaceElevated(context)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: selected
                ? Border.all(color: AppColors.border(context))
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                color: selected
                    ? AppColors.textPrimary(context)
                    : AppColors.textSecondary(context),
                fontWeight: FontWeight.w700,
                fontSize: 12.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _detailsPane(
    BuildContext context,
    _AuditCategory category,
    bool success,
  ) {
    final ip = _metaValue(log, const ['ip', 'ip_address', 'ipAddress']);
    final correlation = _metaValue(log, const [
      'correlationId',
      'correlation_id',
    ]);
    final userAgent = _metaValue(log, const ['user_agent', 'userAgent']);

    // Key/value rows for the immutable metadata panel, mirroring the
    // reference. Always includes the record's own structural fields, then
    // every remaining metadata entry verbatim.
    final metaRows = <MapEntry<String, String>>[
      MapEntry('event_id', log.id),
      const MapEntry('event_version', '1'),
      if (ip != null) MapEntry('ip_address', ip),
      if (userAgent != null) MapEntry('user_agent', userAgent),
      MapEntry('device', log.device.trim().isNotEmpty ? log.device.trim() : '—'),
      MapEntry('success', '${success && !_isDestructive(log)}'),
      for (final e in log.metadata.entries)
        if (!const {
          'ip',
          'ip_address',
          'ipAddress',
          'user_agent',
          'userAgent',
        }.contains(e.key))
          MapEntry(e.key, '${e.value}'),
    ];

    return [
      _sectionLabel(context, 'Action summary'),
      const SizedBox(height: 6),
      Text(
        log.reason?.trim().isNotEmpty ?? false
            ? log.reason!.trim()
            : '${_actorLabel(log.ownerId)} performed '
                  '${_titleCaseAction(log.action).toLowerCase()}'
                  '${_targetLabel(log) != '—' ? ' on ${_targetLabel(log)}' : ''}.',
        style: AppTypography.bodyMedium.copyWith(
          color: AppColors.textPrimary(context),
        ),
      ),
      const SizedBox(height: 18),
      _CopyField(label: 'ACTOR', value: _actorLabel(log.ownerId)),
      const SizedBox(height: 14),
      _CopyField(label: 'TARGET', value: _targetLabel(log)),
      const SizedBox(height: 14),
      _CopyField(
        label: 'TIMESTAMP',
        value:
            '${_absoluteTime(log.timestamp)}  (${_relativeTime(log.timestamp)})',
      ),
      const SizedBox(height: 14),
      _CopyField(
        label: 'SOURCE / DEVICE',
        value: log.device.trim().isNotEmpty ? log.device.trim() : '—',
      ),
      if (ip != null) ...[
        const SizedBox(height: 14),
        _CopyField(label: 'IP ADDRESS', value: ip),
      ],
      if (correlation != null) ...[
        const SizedBox(height: 14),
        _CopyField(label: 'CORRELATION ID', mono: true, value: correlation),
      ],
      const SizedBox(height: 14),
      _CopyField(label: 'EVENT ID', value: log.id, mono: true),
      const SizedBox(height: 20),
      Row(
        children: [
          _sectionLabel(context, 'Metadata (immutable)'),
          const Spacer(),
          _inlineCopy(context, 'Copy JSON', () {
            _copy(
              'Raw JSON',
              const JsonEncoder.withIndent('  ').convert(_rawJson(log)),
            );
          }),
        ],
      ),
      const SizedBox(height: 8),
      Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.background(context),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border(context)),
        ),
        child: Column(
          children: [
            for (final (i, row) in metaRows.indexed) ...[
              if (i > 0)
                Divider(height: 1, color: AppColors.border(context)),
              _MetaKeyValueRow(
                name: row.key,
                value: row.value,
                onCopy: () => _copy(row.key, row.value),
              ),
            ],
          ],
        ),
      ),
    ];
  }

  Widget _rawJsonPane(BuildContext context) {
    final json = const JsonEncoder.withIndent('  ').convert(_rawJson(log));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _sectionLabel(context, 'Raw record (immutable)'),
            const Spacer(),
            _inlineCopy(context, 'Copy', () => _copy('Raw JSON', json)),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.background(context),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border(context)),
          ),
          child: SelectableText(
            json,
            style: AppTypography.bodySmall.copyWith(
              fontFamily: 'monospace',
              color: AppColors.textPrimary(context),
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }

  Widget _inlineCopy(BuildContext context, String label, VoidCallback onTap) =>
      InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              Icon(
                Icons.copy_rounded,
                size: 14,
                color: AppColors.textSecondary(context),
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textSecondary(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      );

  Widget _sectionLabel(BuildContext context, String text) => Text(
    text,
    style: AppTypography.labelSmall.copyWith(
      color: AppColors.textSecondary(context),
      fontWeight: FontWeight.w800,
      letterSpacing: 0.4,
    ),
  );
}

/// One `key → value` line inside the immutable metadata panel, with its own
/// copy control (matches the reference layout).
class _MetaKeyValueRow extends StatelessWidget {
  const _MetaKeyValueRow({
    required this.name,
    required this.value,
    required this.onCopy,
  });
  final String name;
  final String value;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 9, 8, 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 104,
            child: Text(
              name,
              style: AppTypography.labelSmall.copyWith(
                fontFamily: 'monospace',
                color: AppColors.textMuted(context),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: SelectableText(
              value,
              style: AppTypography.bodySmall.copyWith(
                fontFamily: 'monospace',
                color: AppColors.textPrimary(context),
                height: 1.4,
              ),
            ),
          ),
          if (value != '—')
            InkWell(
              borderRadius: BorderRadius.circular(6),
              onTap: onCopy,
              child: Padding(
                padding: const EdgeInsets.all(3),
                child: Icon(
                  Icons.copy_rounded,
                  size: 13,
                  color: AppColors.textSecondary(context),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Desktop
// ---------------------------------------------------------------------------

class _DesktopAuditLogsBody extends StatelessWidget {
  const _DesktopAuditLogsBody({
    required this.logs,
    required this.filtered,
    required this.counts,
    required this.actors,
    required this.selected,
    required this.period,
    required this.dateRange,
    required this.searchController,
    required this.actorFilter,
    required this.activeFilterCount,
    required this.hasActiveFilters,
    required this.selectedLog,
    required this.page,
    required this.rowsPerPage,
    required this.onSearch,
    required this.onSelectCategory,
    required this.onSelectPeriod,
    required this.onSelectActor,
    required this.onPickDateRange,
    required this.onClearDateRange,
    required this.onClearFilters,
    required this.onExport,
    required this.onRefresh,
    required this.onOpenLog,
    required this.onCloseInspector,
    required this.onPageChanged,
    required this.onRowsPerPageChanged,
  });

  final List<AuditLog> logs;
  final List<AuditLog> filtered;
  final Map<_AuditCategory, int> counts;
  final List<String> actors;
  final _AuditCategory selected;
  final _Period period;
  final DateTimeRange? dateRange;
  final TextEditingController searchController;
  final String? actorFilter;
  final int activeFilterCount;
  final bool hasActiveFilters;
  final AuditLog? selectedLog;
  final int page;
  final int rowsPerPage;
  final ValueChanged<String> onSearch;
  final ValueChanged<_AuditCategory> onSelectCategory;
  final ValueChanged<_Period> onSelectPeriod;
  final ValueChanged<String?> onSelectActor;
  final VoidCallback onPickDateRange;
  final VoidCallback onClearDateRange;
  final VoidCallback onClearFilters;
  final VoidCallback onExport;
  final VoidCallback onRefresh;
  final ValueChanged<AuditLog> onOpenLog;
  final VoidCallback onCloseInspector;
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
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Compact header ---------------------------------------------------
          Row(
            children: [
              Text(
                'Audit logs',
                style: AppTypography.headlineMedium.copyWith(
                  color: AppColors.textPrimary(context),
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated(context),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.border(context)),
                ),
                child: Text(
                  '${NumberFormat.decimalPattern().format(logs.length)} events',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondary(context),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              _HeaderButton(
                icon: Icons.file_upload_outlined,
                label: 'Export CSV',
                onTap: onExport,
              ),
              const SizedBox(width: 8),
              _HeaderButton(
                icon: Icons.refresh_rounded,
                label: 'Refresh',
                onTap: onRefresh,
              ),
              const SizedBox(width: 8),
              _HeaderButton(
                icon: Icons.filter_alt_outlined,
                label: 'Filters',
                filled: activeFilterCount > 0,
                badge: activeFilterCount,
                onTap: onPickDateRange,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Dense filter toolbar ------------------------------------------------
          Container(
            padding: const EdgeInsets.all(12),
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
                      flex: 3,
                      child: _SearchField(
                        controller: searchController,
                        onChanged: onSearch,
                      ),
                    ),
                    const SizedBox(width: 10),
                    _DateRangeButton(
                      dateRange: dateRange,
                      onPick: onPickDateRange,
                      onClear: onClearDateRange,
                    ),
                    const SizedBox(width: 10),
                    _FilterDropdown<_Period>(
                      leading: Icons.calendar_today_outlined,
                      value: period,
                      onChanged: (p) => p == null ? null : onSelectPeriod(p),
                      items: [
                        for (final p in _Period.values)
                          DropdownMenuItem(value: p, child: Text(p.label)),
                      ],
                    ),
                    const SizedBox(width: 10),
                    _FilterDropdown<String?>(
                      leading: Icons.person_outline_rounded,
                      value: actorFilter,
                      onChanged: onSelectActor,
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('All actors'),
                        ),
                        for (final a in actors)
                          DropdownMenuItem(
                            value: a,
                            child: Text(
                              _actorLabel(a),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 10),
                    _FilterDropdown<_AuditCategory>(
                      leading: Icons.category_outlined,
                      value: selected,
                      onChanged: (c) =>
                          c == null ? null : onSelectCategory(c),
                      items: [
                        for (final c in _AuditCategory.values)
                          DropdownMenuItem(
                            value: c,
                            child: Text(
                              c == _AuditCategory.all
                                  ? 'All categories'
                                  : c.label,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 10),
                    TextButton(
                      onPressed: hasActiveFilters ? onClearFilters : null,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.information(context),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      child: const Text('Clear filters'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 34,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _AuditCategory.values.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final c = _AuditCategory.values[index];
                      return _CategoryChip(
                        category: c,
                        count: counts[c] ?? 0,
                        isSelected: c == selected,
                        onTap: () => onSelectCategory(c),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Table + inspector ------------------------------------------------
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                          message:
                              'Try a different search, category or date range.',
                        )
                      : Container(
                          decoration: BoxDecoration(
                            color: AppColors.surfaceElevated(context),
                            borderRadius: AppRadius.large,
                            border: Border.all(
                              color: AppColors.border(context),
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            children: [
                              const _AuditTableHeader(),
                              Divider(
                                height: 1,
                                color: AppColors.border(context),
                              ),
                              Expanded(
                                child: ListView.separated(
                                  itemCount: pageItems.length,
                                  separatorBuilder: (_, _) => Divider(
                                    height: 1,
                                    color: AppColors.border(context),
                                  ),
                                  itemBuilder: (context, index) {
                                    final log = pageItems[index];
                                    return _AuditTableRow(
                                      log: log,
                                      selected: selectedLog?.id == log.id,
                                      onTap: () => onOpenLog(log),
                                    );
                                  },
                                ),
                              ),
                              Divider(
                                height: 1,
                                color: AppColors.border(context),
                              ),
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
                if (selectedLog != null) ...[
                  const SizedBox(width: 16),
                  _AuditInspector(
                    log: selectedLog!,
                    onClose: onCloseInspector,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: AppTypography.bodyMedium.copyWith(
        color: AppColors.textPrimary(context),
      ),
      decoration: InputDecoration(
        isDense: true,
        hintText: 'Search audit logs...',
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.textMuted(context),
        ),
        prefixIcon: Icon(
          Icons.search_rounded,
          size: 18,
          color: AppColors.textSecondary(context),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 38),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.close_rounded, size: 16),
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
              ),
        filled: true,
        fillColor: AppColors.background(context),
        contentPadding: const EdgeInsets.symmetric(vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.border(context)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.border(context)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.textPrimary(context)),
        ),
      ),
    );
  }
}

class _DateRangeButton extends StatelessWidget {
  const _DateRangeButton({
    required this.dateRange,
    required this.onPick,
    required this.onClear,
  });
  final DateTimeRange? dateRange;
  final VoidCallback onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final active = dateRange != null;
    final label = active
        ? '${DateFormat('MMM d, yyyy').format(dateRange!.start)}  –  ${DateFormat('MMM d, yyyy').format(dateRange!.end)}'
        : 'Date range';
    return Material(
      color: active
          ? AppColors.informationSurface(context)
          : AppColors.background(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: active
              ? AppColors.information(context)
              : AppColors.border(context),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onPick,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 15,
                color: active
                    ? AppColors.information(context)
                    : AppColors.textSecondary(context),
              ),
              const SizedBox(width: 7),
              Text(
                label,
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.textPrimary(context),
                  fontWeight: FontWeight.w600,
                  fontSize: 12.5,
                ),
              ),
              if (active) ...[
                const SizedBox(width: 6),
                InkWell(
                  onTap: onClear,
                  borderRadius: BorderRadius.circular(999),
                  child: Icon(
                    Icons.close_rounded,
                    size: 15,
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AuditTableHeader extends StatelessWidget {
  const _AuditTableHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          _headCell(context, 'Event', flex: 4),
          _headCell(context, 'Actor', flex: 3),
          _headCell(context, 'Target / School', flex: 3),
          _headCell(context, 'Category', flex: 2),
          _headCell(context, 'Date & time', flex: 3),
          const SizedBox(width: 24),
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
          color: AppColors.textMuted(context),
          letterSpacing: 0.5,
          fontSize: 10.5,
        ),
      ),
    );
  }
}

class _AuditTableRow extends StatelessWidget {
  const _AuditTableRow({
    required this.log,
    required this.selected,
    required this.onTap,
  });

  final AuditLog log;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final category = _categoryOf(log);
    final accent = _eventAccent(context, log);
    final success = _isSuccess(log) && !_isDestructive(log);
    final target = _targetLabel(log);

    return Material(
      color: selected
          ? AppColors.informationSurface(context)
          : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: selected
              ? BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: AppColors.information(context),
                      width: 3,
                    ),
                  ),
                )
              : null,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 4,
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: .12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        success
                            ? Icons.check_circle_rounded
                            : _eventIcon(log),
                        size: 16,
                        color: accent,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _titleCaseAction(log.action),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary(context),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            log.action,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textMuted(context),
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                            ),
                          ),
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
                    Container(
                      width: 26,
                      height: 26,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.textPrimary(context),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        _actorInitials(),
                        style: TextStyle(
                          color: AppColors.background(context),
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _actorName(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodySmall.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary(context),
                            ),
                          ),
                          Text(
                            _actorLabel(log.ownerId),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textMuted(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  target,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySmall.copyWith(
                    color: target == '—'
                        ? AppColors.textMuted(context)
                        : AppColors.textPrimary(context),
                    fontWeight: target == '—'
                        ? FontWeight.w400
                        : FontWeight.w600,
                  ),
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
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat(
                        'MMM d, yyyy HH:mm:ss',
                      ).format(log.timestamp.toLocal()),
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                    Text(
                      _relativeTime(log.timestamp),
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textMuted(context),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 24,
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: AppColors.textMuted(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Text(
            'Showing $start to $end of ${NumberFormat.decimalPattern().format(totalItems)} events',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary(context),
            ),
          ),
          const Spacer(),
          IconButton(
            tooltip: 'Previous page',
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.chevron_left_rounded, size: 20),
            onPressed: page > 0 ? () => onPageChanged(page - 1) : null,
          ),
          Text(
            '${page + 1} / $totalPages',
            style: AppTypography.bodySmall.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary(context),
            ),
          ),
          IconButton(
            tooltip: 'Next page',
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.chevron_right_rounded, size: 20),
            onPressed: page < totalPages - 1
                ? () => onPageChanged(page + 1)
                : null,
          ),
          const SizedBox(width: 8),
          _FilterDropdown<int>(
            value: rowsPerPage,
            onChanged: (v) => v == null ? null : onRowsPerPageChanged(v),
            items: const [10, 25, 50]
                .map(
                  (n) =>
                      DropdownMenuItem(value: n, child: Text('$n / page')),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Mobile
// ---------------------------------------------------------------------------

class _MobileAuditLogsBody extends StatelessWidget {
  const _MobileAuditLogsBody({
    required this.logs,
    required this.filtered,
    required this.counts,
    required this.selected,
    required this.period,
    required this.dateRange,
    required this.searchController,
    required this.hasActiveFilters,
    required this.onSearch,
    required this.onSelectCategory,
    required this.onSelectPeriod,
    required this.onPickDateRange,
    required this.onClearDateRange,
    required this.onClearFilters,
    required this.onExport,
    required this.onRefresh,
    required this.onOpenLog,
  });

  final List<AuditLog> logs;
  final List<AuditLog> filtered;
  final Map<_AuditCategory, int> counts;
  final _AuditCategory selected;
  final _Period period;
  final DateTimeRange? dateRange;
  final TextEditingController searchController;
  final bool hasActiveFilters;
  final ValueChanged<String> onSearch;
  final ValueChanged<_AuditCategory> onSelectCategory;
  final ValueChanged<_Period> onSelectPeriod;
  final VoidCallback onPickDateRange;
  final VoidCallback onClearDateRange;
  final VoidCallback onClearFilters;
  final VoidCallback onExport;
  final VoidCallback onRefresh;
  final ValueChanged<AuditLog> onOpenLog;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Audit logs',
                              style: AppTypography.headlineMedium.copyWith(
                                color: AppColors.textPrimary(context),
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${NumberFormat.decimalPattern().format(logs.length)} events',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                      _MobileIconButton(
                        icon: Icons.file_upload_outlined,
                        tooltip: 'Export CSV',
                        onTap: onExport,
                      ),
                      const SizedBox(width: 8),
                      _MobileIconButton(
                        icon: Icons.refresh_rounded,
                        tooltip: 'Refresh',
                        onTap: onRefresh,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _SearchField(
                    controller: searchController,
                    onChanged: onSearch,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _DateRangeButton(
                          dateRange: dateRange,
                          onPick: onPickDateRange,
                          onClear: onClearDateRange,
                        ),
                      ),
                      const SizedBox(width: 10),
                      _FilterDropdown<_Period>(
                        leading: Icons.calendar_today_outlined,
                        value: period,
                        onChanged: (p) => p == null ? null : onSelectPeriod(p),
                        items: [
                          for (final p in _Period.values)
                            DropdownMenuItem(value: p, child: Text(p.label)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 34,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _AuditCategory.values.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final c = _AuditCategory.values[index];
                        return _CategoryChip(
                          category: c,
                          count: counts[c] ?? 0,
                          isSelected: c == selected,
                          onTap: () => onSelectCategory(c),
                        );
                      },
                    ),
                  ),
                  if (hasActiveFilters) ...[
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: onClearFilters,
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.information(context),
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          minimumSize: const Size(0, 32),
                        ),
                        icon: const Icon(Icons.close_rounded, size: 15),
                        label: const Text('Clear filters'),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          if (logs.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                icon: Icons.history_outlined,
                title: 'No audit logs found',
                message:
                    'Owner actions on the platform will appear here as they happen.',
              ),
            )
          else if (filtered.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                icon: Icons.filter_list_off_rounded,
                title: 'No matching logs',
                message: 'Try a different search, category or date range.',
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverList.separated(
                itemCount: filtered.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) => _AuditCard(
                  log: filtered[index],
                  onTap: () => onOpenLog(filtered[index]),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MobileIconButton extends StatelessWidget {
  const _MobileIconButton({
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
      color: AppColors.surfaceElevated(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: AppColors.border(context)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(9),
          child: Icon(
            icon,
            size: 18,
            color: AppColors.textPrimary(context),
          ),
        ),
      ),
    ),
  );
}

/// Detailed mobile card for one audit entry — icon, title + code, actor,
/// target, category badge and precise timestamp. Tapping opens the
/// inspector bottom sheet.
class _AuditCard extends StatelessWidget {
  const _AuditCard({required this.log, required this.onTap});
  final AuditLog log;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final category = _categoryOf(log);
    final accent = _eventAccent(context, log);
    final success = _isSuccess(log) && !_isDestructive(log);
    final target = _targetLabel(log);

    return Material(
      color: AppColors.surfaceElevated(context),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border(context)),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      success
                          ? Icons.check_circle_rounded
                          : _eventIcon(log),
                      size: 17,
                      color: accent,
                    ),
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
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary(context),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          log.action,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textMuted(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  StatusBadge(
                    label: category.label,
                    color: _categoryColor(context, category),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _cardMeta(
                context,
                Icons.person_outline_rounded,
                'Actor',
                _actorLabel(log.ownerId),
              ),
              const SizedBox(height: 6),
              _cardMeta(
                context,
                Icons.apartment_rounded,
                'Target',
                target,
              ),
              const SizedBox(height: 6),
              _cardMeta(
                context,
                Icons.schedule_rounded,
                'Time',
                '${DateFormat('MMM d, yyyy HH:mm:ss').format(log.timestamp.toLocal())}  ·  ${_relativeTime(log.timestamp)}',
              ),
              if (log.reason?.trim().isNotEmpty ?? false) ...[
                const SizedBox(height: 6),
                _cardMeta(
                  context,
                  Icons.notes_rounded,
                  'Reason',
                  log.reason!.trim(),
                ),
              ],
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: AppColors.textMuted(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cardMeta(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: AppColors.textMuted(context)),
        const SizedBox(width: 8),
        SizedBox(
          width: 52,
          child: Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textMuted(context),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTypography.bodySmall.copyWith(
              color: value == '—'
                  ? AppColors.textMuted(context)
                  : AppColors.textPrimary(context),
            ),
          ),
        ),
      ],
    );
  }
}
