import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/teacher/domain/entities/canonical_report_card.dart';

import '../../bloc/report_queue/dean_report_queue_bloc.dart';
import '../../../../headteacher/presentation/bloc/headteacher_report_queue_bloc.dart';

enum ReportCardPreviewRole { dean, headteacher }

/// The full report preview every sign/return action must go through - "no
/// approval button may operate without preview access." Shows subject
/// results, totals, grade, position, attendance/conduct, class-teacher
/// comment, and the approval timeline so far, then the actions available
/// to the given role.
class ReportCardPreviewSheet extends StatelessWidget {
  const ReportCardPreviewSheet({
    super.key,
    required this.card,
    required this.role,
  });

  final CanonicalReportCard card;
  final ReportCardPreviewRole role;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: .92,
      minChildSize: .5,
      maxChildSize: .95,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(AppSpacing.xl),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.l),
                decoration: BoxDecoration(
                  color: AppColors.border(context),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(card.studentName, style: AppTypography.titleLarge),
            const SizedBox(height: 4),
            Text(
              '${card.classId} • Term ${card.termId} • v${card.version}',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textMuted(context),
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            if (card.hasIncompleteSubjects) _IncompleteWarning(card: card),
            const SizedBox(height: AppSpacing.l),
            _SummaryRow(card: card),
            const SizedBox(height: AppSpacing.xl),
            Text('Subjects', style: AppTypography.titleSmall),
            const SizedBox(height: AppSpacing.s),
            for (final subject in card.subjectResults)
              _SubjectRow(subject: subject),
            const SizedBox(height: AppSpacing.xl),
            Text('Attendance & conduct', style: AppTypography.titleSmall),
            const SizedBox(height: AppSpacing.s),
            Text(
              card.attendanceVerified
                  ? 'Attendance verified by the class teacher'
                  : 'Attendance not yet verified',
              style: AppTypography.bodyMedium,
            ),
            if (card.overallConductCode != null)
              Text(
                'Conduct: ${card.overallConductCode}',
                style: AppTypography.bodyMedium,
              ),
            if (card.classTeacherComment != null &&
                card.classTeacherComment!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xl),
              Text('Class teacher comment', style: AppTypography.titleSmall),
              const SizedBox(height: AppSpacing.s),
              Text(card.classTeacherComment!, style: AppTypography.bodyMedium),
            ],
            const SizedBox(height: AppSpacing.xl),
            Text('Approval timeline', style: AppTypography.titleSmall),
            const SizedBox(height: AppSpacing.s),
            if (card.approvalHistory.isEmpty)
              Text(
                'No decisions recorded yet.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textMuted(context),
                ),
              )
            else
              for (final entry in card.approvalHistory)
                _TimelineEntry(entry: entry),
            const SizedBox(height: AppSpacing.x3l),
            _Actions(card: card, role: role),
          ],
        ),
      ),
    );
  }
}

class _IncompleteWarning extends StatelessWidget {
  const _IncompleteWarning({required this.card});
  final CanonicalReportCard card;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(AppSpacing.m),
    decoration: BoxDecoration(
      color: AppColors.warning(context),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(
      '${card.incompleteSubjects.length} subject(s) are incomplete: '
      '${card.incompleteSubjects.map((s) => s.subjectId).join(', ')}',
      style: AppTypography.bodySmall.copyWith(
        color: AppColors.warning(context),
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.card});
  final CanonicalReportCard card;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      _SummaryTile(
        label: 'Average',
        value: card.average?.toStringAsFixed(1) ?? '-',
      ),
      _SummaryTile(label: 'Grade', value: card.overallGrade ?? '-'),
      _SummaryTile(
        label: 'Position',
        value: card.isRanked ? '${card.position}' : 'Unranked',
      ),
    ],
  );
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Text(value, style: AppTypography.titleMedium),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textMuted(context),
          ),
        ),
      ],
    ),
  );
}

class _SubjectRow extends StatelessWidget {
  const _SubjectRow({required this.subject});
  final SubjectResultSnapshot subject;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(subject.subjectId, style: AppTypography.bodyMedium),
        Text(
          subject.isComplete
              ? '${subject.average?.toStringAsFixed(1) ?? '-'} '
                    '(${subject.grade ?? '-'})'
              : subject.incompleteReason ?? 'Incomplete',
          style: AppTypography.bodyMedium.copyWith(
            color: subject.isComplete ? null : AppColors.warning(context),
          ),
        ),
      ],
    ),
  );
}

class _TimelineEntry extends StatelessWidget {
  const _TimelineEntry({required this.entry});
  final ApprovalHistoryEntry entry;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${entry.actorDisplayName} — ${_actionLabel(entry.action)}',
          style: AppTypography.bodyMedium,
        ),
        if (entry.reason != null && entry.reason!.isNotEmpty)
          Text(
            entry.reason!,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textMuted(context),
            ),
          ),
      ],
    ),
  );

  String _actionLabel(String action) => switch (action) {
    'classTeacher.submittedToDean' => 'submitted to Dean',
    'dean.signed' => 'signed',
    'dean.returned' => 'returned',
    'dean.forwardedToHeadteacher' => 'forwarded to Headteacher',
    'headteacher.signed' => 'signed and finalized',
    'headteacher.returned' => 'returned',
    _ => action,
  };
}

class _Actions extends StatelessWidget {
  const _Actions({required this.card, required this.role});
  final CanonicalReportCard card;
  final ReportCardPreviewRole role;

  @override
  Widget build(BuildContext context) {
    if (role == ReportCardPreviewRole.dean) {
      if (!card.academicStatus.isPendingDean) return const SizedBox.shrink();
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _showReturnDialog(context),
              child: const Text('Return'),
            ),
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: FilledButton(
              onPressed: () {
                Navigator.pop(context);
                context.read<DeanReportQueueBloc>().add(
                  DeanReportCardSigned(card),
                );
              },
              child: const Text('Sign & forward'),
            ),
          ),
        ],
      );
    }

    if (!card.academicStatus.isPendingHeadteacher) {
      return const SizedBox.shrink();
    }
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => _showReturnDialog(context),
            child: const Text('Return'),
          ),
        ),
        const SizedBox(width: AppSpacing.m),
        Expanded(
          child: FilledButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<HeadteacherReportQueueBloc>().add(
                HeadteacherReportCardSigned(card),
              );
            },
            child: const Text('Sign & finalize'),
          ),
        ),
      ],
    );
  }

  Future<void> _showReturnDialog(BuildContext context) async {
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Return this report'),
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
          TextButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isEmpty) return;
              Navigator.pop(dialogContext, text);
            },
            child: const Text('Return'),
          ),
        ],
      ),
    );
    if (reason == null || reason.isEmpty || !context.mounted) return;
    Navigator.pop(context);
    if (role == ReportCardPreviewRole.dean) {
      context.read<DeanReportQueueBloc>().add(
        DeanReportCardReturned(reportCardId: card.reportCardId, reason: reason),
      );
    } else {
      context.read<HeadteacherReportQueueBloc>().add(
        HeadteacherReportCardReturned(
          reportCardId: card.reportCardId,
          reason: reason,
          academicContentChanged: true,
        ),
      );
    }
  }
}
