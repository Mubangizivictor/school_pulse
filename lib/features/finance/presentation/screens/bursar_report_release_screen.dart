import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/teacher/domain/entities/canonical_report_card.dart';
import 'package:school_pulse/injection_container.dart';

import '../bloc/report_release/bursar_report_release_bloc.dart';

/// The Bursar's Report Release area: shows academically finalized reports,
/// their current financial-access state, and lets the Bursar release/hold/
/// revoke access individually or in bulk, always with a mandatory reason.
/// Never touches marks, grades, comments or signatures - only
/// financialAccessStatus, via the trusted setReportCardFinancialAccess
/// Cloud Function.
class BursarReportReleaseScreen extends StatefulWidget {
  const BursarReportReleaseScreen({super.key});

  @override
  State<BursarReportReleaseScreen> createState() =>
      _BursarReportReleaseScreenState();
}

class _BursarReportReleaseScreenState extends State<BursarReportReleaseScreen> {
  final Set<String> _selected = {};

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final schoolId = authState is AuthAuthenticated
        ? authState.user.schoolId
        : '';

    return BlocProvider(
      create: (context) =>
          sl<BursarReportReleaseBloc>()
            ..add(BursarReportReleaseRequested(schoolId)),
      child: Scaffold(
        backgroundColor: AppColors.background(context),
        appBar: AppBar(title: const Text('Report Release')),
        body: BlocConsumer<BursarReportReleaseBloc, BursarReportReleaseState>(
          listener: (context, state) {
            if (state.successMessage != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.successMessage!)));
              setState(_selected.clear);
              context.read<BursarReportReleaseBloc>().add(
                const BursarReportReleaseFeedbackCleared(),
              );
            }
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: AppColors.danger(context),
                ),
              );
              context.read<BursarReportReleaseBloc>().add(
                const BursarReportReleaseFeedbackCleared(),
              );
            }
          },
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.reportCards.isEmpty) {
              return const EmptyState(
                icon: Icons.lock_open_outlined,
                title: 'No finalized reports yet',
                message:
                    'Academically finalized reports will appear here once '
                    'the Headteacher signs them.',
              );
            }
            return Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    children: [
                      if (state.held.isNotEmpty) ...[
                        _SectionHeader(title: 'Held', count: state.held.length),
                        const SizedBox(height: AppSpacing.m),
                        for (final card in state.held)
                          _ReportTile(
                            card: card,
                            selected: _selected.contains(card.reportCardId),
                            onSelectedChanged: (v) => setState(() {
                              if (v) {
                                _selected.add(card.reportCardId);
                              } else {
                                _selected.remove(card.reportCardId);
                              }
                            }),
                          ),
                      ],
                      if (state.released.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.xl),
                        _SectionHeader(
                          title: 'Released',
                          count: state.released.length,
                        ),
                        const SizedBox(height: AppSpacing.m),
                        for (final card in state.released)
                          _ReportTile(
                            card: card,
                            selected: _selected.contains(card.reportCardId),
                            onSelectedChanged: (v) => setState(() {
                              if (v) {
                                _selected.add(card.reportCardId);
                              } else {
                                _selected.remove(card.reportCardId);
                              }
                            }),
                          ),
                      ],
                      if (state.revoked.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.xl),
                        _SectionHeader(
                          title: 'Revoked',
                          count: state.revoked.length,
                        ),
                        const SizedBox(height: AppSpacing.m),
                        for (final card in state.revoked)
                          _ReportTile(
                            card: card,
                            selected: _selected.contains(card.reportCardId),
                            onSelectedChanged: (v) => setState(() {
                              if (v) {
                                _selected.add(card.reportCardId);
                              } else {
                                _selected.remove(card.reportCardId);
                              }
                            }),
                          ),
                      ],
                    ],
                  ),
                ),
                if (_selected.isNotEmpty)
                  _BulkActionBar(
                    count: _selected.length,
                    isActing: state.isActing,
                    onRelease: () => _actOnSelected(context, 'release'),
                    onHold: () => _actOnSelected(context, 'hold'),
                    onRevoke: () => _actOnSelected(context, 'revoke'),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _actOnSelected(BuildContext context, String action) async {
    final bloc = context.read<BursarReportReleaseBloc>();
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('${_actionLabel(action)} ${_selected.length} report(s)?'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Reason (required)'),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isEmpty) return;
              Navigator.pop(dialogContext, text);
            },
            child: Text(_actionLabel(action)),
          ),
        ],
      ),
    );
    if (reason == null || reason.isEmpty) return;
    bloc.add(
      BursarReportAccessChanged(
        reportCardIds: _selected.toList(),
        action: action,
        reason: reason,
      ),
    );
  }

  String _actionLabel(String action) => switch (action) {
    'release' => 'Release',
    'hold' => 'Hold',
    'revoke' => 'Revoke',
    _ => action,
  };
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.count});
  final String title;
  final int count;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(title, style: AppTypography.titleSmall),
      const SizedBox(width: AppSpacing.s),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer(context),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text('$count', style: AppTypography.labelSmall),
      ),
    ],
  );
}

class _ReportTile extends StatelessWidget {
  const _ReportTile({
    required this.card,
    required this.selected,
    required this.onSelectedChanged,
  });
  final CanonicalReportCard card;
  final bool selected;
  final ValueChanged<bool> onSelectedChanged;

  @override
  Widget build(BuildContext context) => AppCard(
    margin: const EdgeInsets.only(bottom: AppSpacing.m),
    child: ListTile(
      leading: Checkbox(
        value: selected,
        onChanged: (v) => onSelectedChanged(v ?? false),
      ),
      title: Text(card.studentName, style: AppTypography.titleSmall),
      subtitle: Text(
        '${card.classId} • ${card.termId} • '
        '${card.financialAccessStatus.label}',
        style: AppTypography.bodySmall.copyWith(
          color: AppColors.textMuted(context),
        ),
      ),
    ),
  );
}

class _BulkActionBar extends StatelessWidget {
  const _BulkActionBar({
    required this.count,
    required this.isActing,
    required this.onRelease,
    required this.onHold,
    required this.onRevoke,
  });
  final int count;
  final bool isActing;
  final VoidCallback onRelease;
  final VoidCallback onHold;
  final VoidCallback onRevoke;

  @override
  Widget build(BuildContext context) => SafeArea(
    minimum: const EdgeInsets.all(AppSpacing.l),
    child: Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: isActing ? null : onHold,
            child: const Text('Hold'),
          ),
        ),
        const SizedBox(width: AppSpacing.s),
        Expanded(
          child: OutlinedButton(
            onPressed: isActing ? null : onRevoke,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.danger(context),
            ),
            child: const Text('Revoke'),
          ),
        ),
        const SizedBox(width: AppSpacing.s),
        Expanded(
          child: FilledButton(
            onPressed: isActing ? null : onRelease,
            child: Text('Release ($count)'),
          ),
        ),
      ],
    ),
  );
}
