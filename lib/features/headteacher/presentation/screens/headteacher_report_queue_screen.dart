import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/dean/presentation/screens/approvals/report_card_preview_sheet.dart';
import 'package:school_pulse/features/teacher/domain/entities/canonical_report_card.dart';
import 'package:school_pulse/injection_container.dart';

import '../bloc/headteacher_report_queue_bloc.dart';

/// The Headteacher's report-card approval queue - the terminal academic
/// stage before a report is finalized. No Headteacher dashboard/shell
/// existed in this app before; this screen is deliberately minimal and
/// scoped to report-card approval for this phase.
class HeadteacherReportQueueScreen extends StatefulWidget {
  const HeadteacherReportQueueScreen({super.key});

  @override
  State<HeadteacherReportQueueScreen> createState() =>
      _HeadteacherReportQueueScreenState();
}

class _HeadteacherReportQueueScreenState
    extends State<HeadteacherReportQueueScreen> {
  final Set<String> _selected = {};

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final schoolId = authState is AuthAuthenticated
        ? authState.user.schoolId
        : '';

    return BlocProvider(
      create: (context) =>
          sl<HeadteacherReportQueueBloc>()
            ..add(HeadteacherReportQueueRequested(schoolId)),
      child: Scaffold(
        backgroundColor: AppColors.background(context),
        appBar: AppBar(title: const Text('Report Card Approvals')),
        body:
            BlocConsumer<
              HeadteacherReportQueueBloc,
              HeadteacherReportQueueState
            >(
              listener: (context, state) {
                if (state.successMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.successMessage!)),
                  );
                  setState(_selected.clear);
                  context.read<HeadteacherReportQueueBloc>().add(
                    const HeadteacherReportQueueFeedbackCleared(),
                  );
                }
                if (state.errorMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.errorMessage!),
                      backgroundColor: AppColors.danger(context),
                    ),
                  );
                  context.read<HeadteacherReportQueueBloc>().add(
                    const HeadteacherReportQueueFeedbackCleared(),
                  );
                }
              },
              builder: (context, state) {
                if (state.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.pending.isEmpty && state.finalized.isEmpty) {
                  return const EmptyState(
                    icon: Icons.fact_check_outlined,
                    title: 'Nothing awaiting your review',
                    message:
                        'Report cards signed by the Dean of Studies will '
                        'appear here.',
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
                    if (state.finalized.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xl),
                      _SectionHeader(
                        title: 'Academically finalized',
                        count: state.finalized.length,
                      ),
                      const SizedBox(height: AppSpacing.m),
                      for (final card in state.finalized)
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
    final bloc = context.read<HeadteacherReportQueueBloc>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => BlocProvider.value(
        value: bloc,
        child: ReportCardPreviewSheet(
          card: card,
          role: ReportCardPreviewRole.headteacher,
        ),
      ),
    );
  }

  Future<void> _confirmBulkSign(
    BuildContext context,
    HeadteacherReportQueueState state,
  ) async {
    final cards = state.pending
        .where((c) => _selected.contains(c.reportCardId))
        .toList();
    final bloc = context.read<HeadteacherReportQueueBloc>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Finalize ${cards.length} report cards?'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              const Text(
                'Each report will be academically finalized. A report '
                'that has changed since you reviewed it, or whose Dean '
                'signature is no longer current, will be skipped.',
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
            child: const Text('Finalize all'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    bloc.add(HeadteacherReportCardsSigned(cards));
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
          : Checkbox(
              value: selected,
              onChanged: (v) => onSelectedChanged!(v ?? false),
            ),
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
      trailing: Icon(Icons.chevron_right, color: AppColors.textMuted(context)),
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
      label: Text('Finalize $count selected'),
    ),
  );
}
