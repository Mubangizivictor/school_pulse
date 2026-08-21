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

import '../../bloc/report_queue/dean_report_queue_bloc.dart';
import 'report_card_preview_sheet.dart';

/// The Dean's report-card approval queue - the real, live-data replacement
/// for the unrouted/stubbed legacy ReportApprovalScreen. Every action here
/// goes through the trusted Cloud Functions (submitReportCardsToDean,
/// signReportCardAsDean, returnReportCardByDean, ...); nothing writes a
/// report card directly.
class DeanReportQueueScreen extends StatefulWidget {
  const DeanReportQueueScreen({super.key});

  @override
  State<DeanReportQueueScreen> createState() => _DeanReportQueueScreenState();
}

class _DeanReportQueueScreenState extends State<DeanReportQueueScreen> {
  final Set<String> _selected = {};

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final schoolId = authState is AuthAuthenticated
        ? authState.user.schoolId
        : '';

    return BlocProvider(
      create: (context) =>
          sl<DeanReportQueueBloc>()..add(DeanReportQueueRequested(schoolId)),
      child: Scaffold(
        backgroundColor: AppColors.background(context),
        body: BlocConsumer<DeanReportQueueBloc, DeanReportQueueState>(
          listener: (context, state) {
            if (state.successMessage != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.successMessage!)));
              setState(_selected.clear);
              context.read<DeanReportQueueBloc>().add(
                const DeanReportQueueFeedbackCleared(),
              );
            }
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: AppColors.danger(context),
                ),
              );
              context.read<DeanReportQueueBloc>().add(
                const DeanReportQueueFeedbackCleared(),
              );
            }
          },
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.pending.isEmpty && state.signed.isEmpty) {
              return const EmptyState(
                icon: Icons.fact_check_outlined,
                title: 'Nothing awaiting your review',
                message:
                    'Report cards submitted by class teachers will appear '
                    'here.',
              );
            }
            return ListView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              children: [
                if (state.pending.isNotEmpty) ...[
                  _SectionHeader(
                    title: 'Awaiting your signature',
                    count: state.pending.length,
                  ),
                  const SizedBox(height: AppSpacing.m),
                  for (final card in state.pending)
                    _ReportCardTile(
                      card: card,
                      selected: _selected.contains(card.reportCardId),
                      onSelectedChanged: (value) => setState(() {
                        if (value) {
                          _selected.add(card.reportCardId);
                        } else {
                          _selected.remove(card.reportCardId);
                        }
                      }),
                      onTap: () => _openPreview(context, card),
                    ),
                  if (_selected.length > 1) ...[
                    const SizedBox(height: AppSpacing.l),
                    _BulkSignButton(
                      count: _selected.length,
                      isActing: state.isActing,
                      onPressed: () => _confirmBulkSign(context, state),
                    ),
                  ],
                ],
                if (state.signed.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xl),
                  _SectionHeader(
                    title: 'Signed and forwarded',
                    count: state.signed.length,
                  ),
                  const SizedBox(height: AppSpacing.m),
                  for (final card in state.signed)
                    _ReportCardTile(
                      card: card,
                      selected: false,
                      onSelectedChanged: null,
                      onTap: () => _openPreview(context, card),
                    ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  void _openPreview(BuildContext context, CanonicalReportCard card) {
    final bloc = context.read<DeanReportQueueBloc>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => BlocProvider.value(
        value: bloc,
        child: ReportCardPreviewSheet(
          card: card,
          role: ReportCardPreviewRole.dean,
        ),
      ),
    );
  }

  Future<void> _confirmBulkSign(
    BuildContext context,
    DeanReportQueueState state,
  ) async {
    final cards = state.pending
        .where((c) => _selected.contains(c.reportCardId))
        .toList();
    final bloc = context.read<DeanReportQueueBloc>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Sign ${cards.length} report cards?'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              const Text(
                'Each report will be signed and forwarded to the '
                'Headteacher. A report that has changed since you '
                'reviewed it will be skipped, not silently signed.',
              ),
              const SizedBox(height: AppSpacing.m),
              for (final card in cards)
                Text('• ${card.studentName}', style: AppTypography.bodySmall),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Sign all'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    bloc.add(DeanReportCardsSignedAndForwarded(cards));
  }
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

class _ReportCardTile extends StatelessWidget {
  const _ReportCardTile({
    required this.card,
    required this.selected,
    required this.onSelectedChanged,
    required this.onTap,
  });
  final CanonicalReportCard card;
  final bool selected;
  final ValueChanged<bool>? onSelectedChanged;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => AppCard(
    margin: const EdgeInsets.only(bottom: AppSpacing.m),
    child: ListTile(
      onTap: onTap,
      leading: onSelectedChanged == null
          ? const Icon(Icons.description_outlined)
          : Checkbox(value: selected, onChanged: (v) => onSelectedChanged!(v ?? false)),
      title: Text(card.studentName, style: AppTypography.titleSmall),
      subtitle: Text(
        card.hasIncompleteSubjects
            ? '${card.incompleteSubjects.length} subject(s) incomplete'
            : 'Average ${card.average?.toStringAsFixed(1) ?? '-'} • '
                  '${card.overallGrade ?? '-'}',
        style: AppTypography.bodySmall.copyWith(
          color: card.hasIncompleteSubjects
              ? AppColors.warning(context)
              : AppColors.textMuted(context),
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: AppColors.textMuted(context),
      ),
    ),
  );
}

class _BulkSignButton extends StatelessWidget {
  const _BulkSignButton({
    required this.count,
    required this.isActing,
    required this.onPressed,
  });
  final int count;
  final bool isActing;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: FilledButton.icon(
      onPressed: isActing ? null : onPressed,
      icon: const Icon(Icons.verified_outlined),
      label: Text('Sign $count selected'),
    ),
  );
}
