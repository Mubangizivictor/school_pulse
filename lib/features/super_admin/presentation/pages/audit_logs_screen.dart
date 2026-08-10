import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/super_admin_bloc.dart';
import '../bloc/super_admin_event.dart';
import '../bloc/super_admin_state.dart';
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

class AuditLogsScreen extends StatefulWidget {
  const AuditLogsScreen({super.key});

  @override
  State<AuditLogsScreen> createState() => _AuditLogsScreenState();
}

class _AuditLogsScreenState extends State<AuditLogsScreen> {
  _AuditCategory _selected = _AuditCategory.all;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audit Logs'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () =>
                context.read<SuperAdminBloc>().add(const LoadAuditLogsEvent()),
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

          final logs = state.auditLogs;
          final filtered = _selected == _AuditCategory.all
              ? logs
              : logs.where((l) => _categoryOf(l) == _selected).toList();

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
                          onSelected: (_) =>
                              setState(() => _selected = category),
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
