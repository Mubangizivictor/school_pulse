import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:printing/printing.dart';

import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/teacher/domain/entities/active_responsibility_context.dart';
import 'package:school_pulse/features/teacher/domain/entities/canonical_report_card.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/report_card_preview/report_card_preview_bloc.dart';
import 'package:school_pulse/injection_container.dart';

import 'widgets/report_card_body.dart';

/// Router `extra` payload for the preview route - a full
/// ActiveResponsibilityContext doesn't fit in a path parameter.
class ClassReportCardPreviewArgs {
  final String reportCardId;
  final ActiveResponsibilityContext context;
  const ClassReportCardPreviewArgs({
    required this.reportCardId,
    required this.context,
  });
}

/// The real, complete report-card preview - what "View Report" actually
/// opens. Visible at every workflow stage, unsigned reports included: a
/// Class Teacher must always be able to see the report they just generated,
/// not be redirected away with only a snackbar.
class ClassReportCardPreviewScreen extends StatelessWidget {
  const ClassReportCardPreviewScreen({
    super.key,
    required this.reportCardId,
    required this.responsibilityContext,
  });

  final String reportCardId;
  final ActiveResponsibilityContext responsibilityContext;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ReportCardPreviewBloc>()
        ..add(
          ReportCardPreviewRequested(
            context: responsibilityContext,
            reportCardId: reportCardId,
          ),
        ),
      child: Scaffold(
        appBar: AppBar(title: const Text('Report Card')),
        body: BlocConsumer<ReportCardPreviewBloc, ReportCardPreviewState>(
          listener: (context, state) {
            if (state.successMessage != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.successMessage!)));
              context.read<ReportCardPreviewBloc>().add(
                const ReportCardPreviewFeedbackCleared(),
              );
            }
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: AppColors.danger(context),
                ),
              );
              context.read<ReportCardPreviewBloc>().add(
                const ReportCardPreviewFeedbackCleared(),
              );
            }
            if (state.pdfBytes != null) {
              Printing.layoutPdf(
                onLayout: (_) async => Uint8List.fromList(state.pdfBytes!),
              );
            }
          },
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            final card = state.card;
            if (card == null) {
              return EmptyState(
                icon: Icons.description_outlined,
                title: 'Report not available',
                message:
                    state.errorMessage ?? 'This report could not be loaded.',
                ctaLabel: 'Retry',
                onCtaPressed: () => context.read<ReportCardPreviewBloc>().add(
                  ReportCardPreviewRequested(
                    context: responsibilityContext,
                    reportCardId: reportCardId,
                  ),
                ),
              );
            }
            return Column(
              children: [
                Expanded(child: ReportCardBody(card: card)),
                _ActionBar(card: card, isActing: state.isActing),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({required this.card, required this.isActing});
  final CanonicalReportCard card;
  final bool isActing;

  @override
  Widget build(BuildContext context) {
    final canSubmit =
        card.academicStatus == AcademicWorkflowStatus.classTeacherReview ||
        card.academicStatus == AcademicWorkflowStatus.generated ||
        card.academicStatus == AcademicWorkflowStatus.returnedByDean ||
        card.academicStatus == AcademicWorkflowStatus.returnedByHeadteacher;

    return SafeArea(
      minimum: const EdgeInsets.all(AppSpacing.l),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: isActing
                  ? null
                  : () => context.read<ReportCardPreviewBloc>().add(
                      const ReportCardPreviewPdfRequested(),
                    ),
              icon: const Icon(Icons.picture_as_pdf_outlined),
              label: Text(card.isFinalized ? 'View PDF' : 'Preview PDF'),
            ),
          ),
          if (canSubmit) ...[
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: FilledButton.icon(
                onPressed: isActing ? null : () => _confirmSubmit(context),
                icon: const Icon(Icons.send_outlined),
                label: const Text('Submit to Dean'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _confirmSubmit(BuildContext context) async {
    final bloc = context.read<ReportCardPreviewBloc>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Submit to the Dean?'),
        content: Text(
          "${card.studentName.isEmpty ? 'This report' : "${card.studentName}'s report"} "
          "will be sent to the Dean of Studies for review. You will not be "
          "able to edit it while it's under review.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      bloc.add(const ReportCardPreviewSubmittedToDean());
    }
  }
}
