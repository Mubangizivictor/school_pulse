import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/module_control/data/module_control_repository.dart';
import 'package:school_pulse/features/module_control/domain/module_registry.dart';

import '../../domain/entities/school.dart';

/// A single compact row on Screen C, bucketing one or more real
/// [ModuleRegistry] keys under the product-facing name the spec asks for.
/// Statuses/audit still come from the underlying keys' real
/// [ModuleConfiguration] docs - this is a display grouping only, not a new
/// entitlement system.
class _ModuleGroup {
  const _ModuleGroup({
    required this.label,
    required this.summary,
    required this.icon,
    required this.keys,
  });
  final String label;
  final String summary;
  final IconData icon;
  final List<String> keys;
}

const _kModuleGroups = <_ModuleGroup>[
  _ModuleGroup(
    label: 'Core learning',
    summary: 'Classes, subjects & lessons',
    icon: Icons.menu_book_outlined,
    keys: ['students', 'staff', 'structure'],
  ),
  _ModuleGroup(
    label: 'Attendance',
    summary: 'Student & staff attendance',
    icon: Icons.fact_check_outlined,
    keys: ['attendance'],
  ),
  _ModuleGroup(
    label: 'Finance',
    summary: 'Fees, invoices & payments',
    icon: Icons.account_balance_wallet_outlined,
    keys: ['finance'],
  ),
  _ModuleGroup(
    label: 'Examinations',
    summary: 'Assessments & results',
    icon: Icons.assignment_outlined,
    keys: ['assessments', 'reports'],
  ),
  _ModuleGroup(
    label: 'Parent engagement',
    summary: 'Communication & updates',
    icon: Icons.family_restroom_outlined,
    keys: ['messaging', 'appointments'],
  ),
  _ModuleGroup(
    label: 'Library',
    summary: 'Books, catalog & lending',
    icon: Icons.local_library_outlined,
    keys: ['library'],
  ),
];

/// Screen C - Modules. Reads real per-key ModuleConfiguration docs
/// (schools/{id}/module_configuration) via [ModuleControlRepository], the
/// only module system in this app with real entitlement gating + an audit
/// trail. `School.enabledFeatures` (the flat list the old raw-switch UI
/// used) is intentionally left untouched here - it is a separate, unaudited
/// field with other unrelated consumers.
class SchoolModulesScreen extends StatelessWidget {
  const SchoolModulesScreen({super.key, required this.school});
  final School school;

  @override
  Widget build(BuildContext context) {
    final repository = ModuleControlRepository();
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(title: Text(school.name, overflow: TextOverflow.ellipsis)),
      body: StreamBuilder<Map<String, ModuleConfiguration>>(
        stream: repository.watchModules(school.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: SchoolPulseLoader());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.l),
                child: Text(
                  'Unable to load modules for this school.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ),
            );
          }
          final configs = snapshot.data ?? const {};
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Changes are audited and apply after confirmation.',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
                ),
                const SizedBox(height: AppSpacing.l),
                AppCard(
                  padding: EdgeInsets.zero,
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _kModuleGroups.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final group = _kModuleGroups[index];
                      final state = _resolveGroupState(group, configs);
                      return ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primary(
                              context,
                            ).withValues(alpha: .12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            group.icon,
                            size: 20,
                            color: AppColors.primary(context),
                          ),
                        ),
                        title: Text(
                          group.label,
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary(context),
                          ),
                        ),
                        subtitle: Text(
                          group.summary,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary(context),
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            StatusBadge(
                              label: state.label,
                              color: state.color(context),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: AppColors.textMuted(context),
                            ),
                          ],
                        ),
                        onTap: () => _openConfirmation(
                          context,
                          repository: repository,
                          school: school,
                          group: group,
                          state: state,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.l),
                Center(
                  child: TextButton.icon(
                    onPressed: () => _openHistory(context, repository, school),
                    icon: const Icon(Icons.history_rounded, size: 18),
                    label: const Text('View module change history'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  _GroupState _resolveGroupState(
    _ModuleGroup group,
    Map<String, ModuleConfiguration> configs,
  ) {
    final configured = group.keys
        .map((key) => configs[key])
        .whereType<ModuleConfiguration>()
        .toList();
    if (configured.isEmpty || configured.every((c) => !c.entitled)) {
      return _GroupState.unavailable;
    }
    final allEnabled = configured.every((c) => c.entitled && c.enabled);
    if (allEnabled) return _GroupState.enabled;
    final anyEntitled = configured.any((c) => c.entitled);
    if (anyEntitled) return _GroupState.disabled;
    return _GroupState.unavailable;
  }

  void _openConfirmation(
    BuildContext context, {
    required ModuleControlRepository repository,
    required School school,
    required _ModuleGroup group,
    required _GroupState state,
  }) {
    if (state == _GroupState.unavailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${group.label} is not included in ${school.subscriptionPlanId.isEmpty ? 'this' : school.subscriptionPlanId.toUpperCase()} plan.',
          ),
        ),
      );
      return;
    }
    final targetEnable = state != _GroupState.enabled;
    final authState = context.read<AuthBloc>().state;
    final actorId = authState is AuthAuthenticated ? authState.user.id : '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => _ModuleConfirmationSheet(
        group: group,
        targetEnable: targetEnable,
        onConfirm: (reason) async {
          for (final key in group.keys) {
            await repository.setModuleEnabled(
              schoolId: school.id,
              moduleKey: key,
              enabled: targetEnable,
              actorId: actorId,
              reason: reason,
            );
          }
        },
      ),
    );
  }

  void _openHistory(
    BuildContext context,
    ModuleControlRepository repository,
    School school,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _ModuleHistoryScreen(repository: repository, school: school),
      ),
    );
  }
}

enum _GroupState { enabled, disabled, unavailable }

extension on _GroupState {
  String get label => switch (this) {
    _GroupState.enabled => 'Enabled',
    _GroupState.disabled => 'Disabled',
    _GroupState.unavailable => 'Unavailable',
  };

  Color color(BuildContext context) => switch (this) {
    _GroupState.enabled => AppColors.success(context),
    _GroupState.disabled => AppColors.textSecondary(context),
    _GroupState.unavailable => AppColors.warning(context),
  };
}

class _ModuleConfirmationSheet extends StatefulWidget {
  const _ModuleConfirmationSheet({
    required this.group,
    required this.targetEnable,
    required this.onConfirm,
  });
  final _ModuleGroup group;
  final bool targetEnable;
  final Future<void> Function(String reason) onConfirm;

  @override
  State<_ModuleConfirmationSheet> createState() =>
      _ModuleConfirmationSheetState();
}

class _ModuleConfirmationSheetState extends State<_ModuleConfirmationSheet> {
  final _reasonController = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final action = widget.targetEnable ? 'Enable' : 'Disable';
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.l,
        right: AppSpacing.l,
        top: AppSpacing.l,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.l,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$action ${widget.group.label}?',
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            widget.targetEnable
                ? 'Staff and admins with access to this area will regain '
                      'it immediately. Billing is unaffected - this only '
                      'changes what is switched on within the current plan.'
                : 'Staff and admins will immediately lose access to this '
                      'area\'s screens and data entry. This does not change '
                      'billing.',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary(context),
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          TextField(
            controller: _reasonController,
            minLines: 2,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Reason',
              hintText: 'e.g. Requested by school administrator',
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: AppSpacing.s),
            Text(
              _error!,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.danger(context),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.l),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _saving ? null : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: FilledButton(
                  onPressed: _saving
                      ? null
                      : () async {
                          final reason = _reasonController.text.trim();
                          if (reason.length < 3) {
                            setState(
                              () => _error =
                                  'Please enter a reason (min 3 characters).',
                            );
                            return;
                          }
                          setState(() {
                            _saving = true;
                            _error = null;
                          });
                          try {
                            await widget.onConfirm(reason);
                            if (context.mounted) Navigator.pop(context);
                          } catch (e) {
                            if (!mounted) return;
                            setState(() {
                              _saving = false;
                              _error = e
                                  .toString()
                                  .replaceFirst(RegExp(r'^\w+Error:\s*'), '');
                            });
                          }
                        },
                  child: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(action),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ModuleHistoryScreen extends StatelessWidget {
  const _ModuleHistoryScreen({required this.repository, required this.school});
  final ModuleControlRepository repository;
  final School school;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy • h:mm a');
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(title: const Text('Module change history')),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: repository.watchAudit(school.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: SchoolPulseLoader());
          }
          final events = snapshot.data ?? const [];
          if (events.isEmpty) {
            return Center(
              child: Text(
                'No module changes recorded yet.',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary(context),
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.l),
            itemCount: events.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.s),
            itemBuilder: (context, index) {
              final event = events[index];
              final moduleKey = event['moduleKey']?.toString() ?? '';
              final action = event['action']?.toString() ?? '';
              final reason = event['reason']?.toString() ?? '';
              final timestamp = event['timestamp'];
              final when = timestamp is Timestamp
                  ? dateFormat.format(timestamp.toDate())
                  : '';
              return AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      action == 'module_enabled'
                          ? '${_moduleName(moduleKey)} enabled'
                          : '${_moduleName(moduleKey)} disabled',
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                    if (reason.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        reason,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                    ],
                    if (when.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        when,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textMuted(context),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _moduleName(String key) {
    try {
      return ModuleRegistry.byKey(key).name;
    } catch (_) {
      return key;
    }
  }
}
