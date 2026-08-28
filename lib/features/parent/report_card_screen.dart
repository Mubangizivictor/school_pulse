import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:school_pulse/design_system/responsive/app_responsive_content.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/student/presentation/bloc/selected_student_bloc.dart';
import 'package:school_pulse/features/student/presentation/bloc/selected_student_state.dart';
import 'package:school_pulse/features/teacher/domain/entities/canonical_report_card.dart';
import 'package:school_pulse/features/teacher/presentation/screens/report_making/widgets/report_card_body.dart';
import 'package:school_pulse/injection_container.dart';

import 'presentation/bloc/report_card/parent_report_card_bloc.dart';
import 'widgets/student_app_bar.dart';

/// The Parent's report-card area, rebuilt against the canonical
/// schools/{schoolId}/reportCards snapshot - the earlier version read a
/// legacy top-level `report_cards` collection with no relationship to the
/// Bursar-release gate at all. Only reports Firestore rules actually let
/// this account read (finalized + released + linked student) ever appear
/// here; a held/unreleased report simply never shows up in the list, not
/// shown-then-blocked.
class ReportCardScreen extends StatefulWidget {
  const ReportCardScreen({super.key});

  @override
  State<ReportCardScreen> createState() => _ReportCardScreenState();
}

class _ReportCardScreenState extends State<ReportCardScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: StudentAppBar(title: 'Report Card'),
      body: ParentReportCardBody(),
    );
  }
}

/// The report-card list/detail body, standalone-scaffold-free so it can be
/// embedded either as its own routed screen ([ReportCardScreen], the
/// Student-role path) or as one tab of the parent's Academics screen -
/// owns its own [ParentReportCardBloc] instance either way, since each host
/// needs an independent load lifecycle.
class ParentReportCardBody extends StatefulWidget {
  const ParentReportCardBody({super.key});

  @override
  State<ParentReportCardBody> createState() => _ParentReportCardBodyState();
}

class _ParentReportCardBodyState extends State<ParentReportCardBody> {
  late final ParentReportCardBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = sl<ParentReportCardBloc>();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  void _load() {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;
    // A Student account carries its own studentId directly; a Parent
    // account resolves through the currently-selected child, falling back
    // to their first linked student.
    final selectedState = context.read<SelectedStudentBloc>().state;
    final studentId =
        authState.user.studentId ??
        (selectedState is SelectedStudentLoaded
            ? selectedState.student.id
            : authState.user.studentIds.firstOrNull);
    if (studentId == null) return;
    _bloc.add(
      ParentReportCardsRequested(
        schoolId: authState.user.schoolId,
        studentId: studentId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: BlocConsumer<ParentReportCardBloc, ParentReportCardState>(
        listener: (context, state) {
          if (state.downloadUrl != null) {
            launchUrl(
              Uri.parse(state.downloadUrl!),
              mode: LaunchMode.externalApplication,
            );
            _bloc.add(const ParentReportCardFeedbackCleared());
          }
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
            _bloc.add(const ParentReportCardFeedbackCleared());
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: SchoolPulseLoader());
          }
          if (state.reportCards.isEmpty) {
            return EmptyState(
              icon: Icons.lock_outline,
              title: 'Report not yet released',
              message:
                  "Please contact the school bursar's office for "
                  'assistance.',
              ctaLabel: 'Refresh',
              onCtaPressed: _load,
            );
          }
          return AppResponsiveContent(
            child: _ReportCardList(
              reportCards: state.reportCards,
              isDownloading: state.isDownloading,
            ),
          );
        },
      ),
    );
  }
}

class _ReportCardList extends StatelessWidget {
  const _ReportCardList({
    required this.reportCards,
    required this.isDownloading,
  });
  final List<CanonicalReportCard> reportCards;
  final bool isDownloading;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.xl),
      itemCount: reportCards.length,
      itemBuilder: (context, index) {
        final card = reportCards[index];
        return AppCard(
          margin: const EdgeInsets.only(bottom: AppSpacing.m),
          child: ExpansionTile(
            title: Text(
              'Term ${card.termId} · ${card.academicYearId}',
              style: AppTypography.titleSmall,
            ),
            subtitle: Text(
              'Average ${card.average?.toStringAsFixed(1) ?? '-'} • '
              '${card.overallGrade ?? '-'}',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textMuted(context),
              ),
            ),
            children: [
              SizedBox(height: 500, child: ReportCardBody(card: card)),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.m),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: isDownloading || card.pdfUrl == null
                        ? null
                        : () => context.read<ParentReportCardBloc>().add(
                            ParentReportCardPdfRequested(card.reportCardId),
                          ),
                    icon: const Icon(Icons.picture_as_pdf_outlined),
                    label: Text(
                      card.pdfUrl == null
                          ? 'PDF not available yet'
                          : 'Download official PDF',
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
