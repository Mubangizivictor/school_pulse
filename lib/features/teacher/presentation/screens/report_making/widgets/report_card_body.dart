import 'package:flutter/material.dart';

import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/teacher/domain/entities/canonical_report_card.dart';

/// The canonical report-card content, shared by every role's preview
/// (Class Teacher, Dean, Headteacher, and later Bursar/Parent/Student). One
/// widget renders one snapshot the same way everywhere, so what a Class
/// Teacher sees before submission is exactly what a Dean and Headteacher
/// see when they sign it - never a second, independently-calculated view.
class ReportCardBody extends StatelessWidget {
  const ReportCardBody({super.key, required this.card});

  final CanonicalReportCard card;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          children: [
            Text(
              card.studentName.isEmpty ? card.studentId : card.studentName,
              style: AppTypography.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              '${card.classId}${card.streamId != null ? ' - ${card.streamId}' : ''} • '
              'Term ${card.termId} • v${card.version}',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textMuted(context),
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            Wrap(
              spacing: AppSpacing.s,
              runSpacing: AppSpacing.s,
              children: [
                _StatusChip(status: card.academicStatus),
                if (card.isFinalized) _FinancialAccessChip(card: card),
              ],
            ),
            const SizedBox(height: AppSpacing.l),
            if (card.hasIncompleteSubjects) _IncompleteWarning(card: card),
            if (card.hasIncompleteSubjects)
              const SizedBox(height: AppSpacing.l),
            _SummaryRow(card: card),
            const SizedBox(height: AppSpacing.xl),
            Text('Subjects', style: AppTypography.titleSmall),
            const SizedBox(height: AppSpacing.s),
            if (card.subjectResults.isEmpty)
              Text(
                'No subject results yet.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textMuted(context),
                ),
              )
            else
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
            Text('Signatures', style: AppTypography.titleSmall),
            const SizedBox(height: AppSpacing.s),
            _SignatureRow(
              label: 'Dean of Studies',
              decision: card.deanDecision,
            ),
            _SignatureRow(
              label: 'Headteacher',
              decision: card.headteacherDecision,
            ),
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
            const SizedBox(height: AppSpacing.x4l),
          ],
        ),
        if (!card.isFinalized)
          Positioned.fill(
            child: IgnorePointer(
              child: Center(
                child: Transform.rotate(
                  angle: -0.5,
                  child: Opacity(
                    opacity: 0.12,
                    child: Text(
                      card.academicStatus == AcademicWorkflowStatus.draft ||
                              card.academicStatus ==
                                  AcademicWorkflowStatus.generated ||
                              card.academicStatus ==
                                  AcademicWorkflowStatus.classTeacherReview
                          ? 'DRAFT — NOT OFFICIAL'
                          : 'AWAITING SIGNATURES',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        color: Colors.red,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final AcademicWorkflowStatus status;

  Color _color(BuildContext context) => switch (status) {
    AcademicWorkflowStatus.academicallyFinalized => AppColors.success(context),
    AcademicWorkflowStatus.returnedByDean ||
    AcademicWorkflowStatus.returnedByHeadteacher => AppColors.danger(context),
    AcademicWorkflowStatus.deanSigned ||
    AcademicWorkflowStatus.submittedToHeadteacher => AppColors.information(
      context,
    ),
    _ => AppColors.warning(context),
  };

  @override
  Widget build(BuildContext context) {
    final color = _color(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: .5)),
      ),
      child: Text(
        status.label,
        style: AppTypography.labelMedium.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Shown alongside the academic-status chip once a report is finalized -
/// Bursar-controlled financial access is an entirely separate axis from
/// academicStatus, so it needs its own visible indicator rather than being
/// folded into (or hidden behind) the academic one.
class _FinancialAccessChip extends StatelessWidget {
  const _FinancialAccessChip({required this.card});
  final CanonicalReportCard card;

  Color _color(BuildContext context) => switch (card.financialAccessStatus) {
    FinancialAccessStatus.released => AppColors.success(context),
    FinancialAccessStatus.revoked => AppColors.danger(context),
    FinancialAccessStatus.held => AppColors.warning(context),
  };

  @override
  Widget build(BuildContext context) {
    final color = _color(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: .5)),
      ),
      child: Text(
        card.financialAccessStatus.label,
        style: AppTypography.labelMedium.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
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
      color: AppColors.warning(context).withValues(alpha: .12),
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

class _SignatureRow extends StatelessWidget {
  const _SignatureRow({required this.label, required this.decision});
  final String label;
  final StageDecision? decision;
  @override
  Widget build(BuildContext context) {
    final signed = decision?.isSigned ?? false;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            signed ? Icons.verified : Icons.pending_outlined,
            size: 18,
            color: signed
                ? AppColors.success(context)
                : AppColors.textMuted(context),
          ),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: Text(
              signed
                  ? '$label: signed by ${decision!.actorDisplayName}'
                  : '$label: not yet signed',
              style: AppTypography.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
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
