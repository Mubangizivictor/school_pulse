import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_radius.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/admin/data/models/system_config.dart';
import 'package:school_pulse/features/admin/data/repositories/system_config_repository.dart';
import 'package:school_pulse/features/teacher/domain/entities/active_responsibility_context.dart';
import 'package:school_pulse/features/teacher/domain/entities/class_report_entry.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_performance/class_performance_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_reports/class_reports_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_teacher_context/class_teacher_context_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_teacher_context/class_teacher_context_state.dart';
import 'package:school_pulse/injection_container.dart' as di;

/// Matches the reference "Reports" mockup: quick-report tiles, recent
/// reports list, and a request-report CTA - all backed by real class
/// teacher data (ClassPerformanceBloc, ClassReportsBloc) and the
/// attendance history screen. No mock/hardcoded content.
class TeacherReportsScreen extends StatefulWidget {
  const TeacherReportsScreen({super.key});

  @override
  State<TeacherReportsScreen> createState() => _TeacherReportsScreenState();
}

class _TeacherReportsScreenState extends State<TeacherReportsScreen> {
  final _performanceBloc = di.sl<ClassPerformanceBloc>();
  final _reportsBloc = di.sl<ClassReportsBloc>();

  ReportEntryStatus? _statusFilter;
  bool _showAllReports = false;

  @override
  void initState() {
    super.initState();
    final active = context.read<ClassTeacherContextBloc>().state.active;
    if (active != null) {
      _performanceBloc.add(ClassPerformanceRequested(active));
      _reportsBloc.add(ClassReportsRequested(active));
    }
  }

  Future<void> _showFilterSheet(BuildContext context) async {
    final chosen = await showModalBottomSheet<ReportEntryStatus?>(
      context: context,
      backgroundColor: AppColors.surfaceElevated(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.l),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Filter recent reports',
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.textPrimary(sheetContext),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                ListTile(
                  title: Text(
                    'All statuses',
                    style: TextStyle(
                      color: AppColors.textPrimary(sheetContext),
                    ),
                  ),
                  trailing: _statusFilter == null
                      ? Icon(
                          Icons.check,
                          color: AppColors.primary(sheetContext),
                        )
                      : null,
                  onTap: () => Navigator.pop(sheetContext, null),
                ),
                for (final status in ReportEntryStatus.values)
                  ListTile(
                    title: Text(
                      status.label,
                      style: TextStyle(
                        color: AppColors.textPrimary(sheetContext),
                      ),
                    ),
                    trailing: _statusFilter == status
                        ? Icon(
                            Icons.check,
                            color: AppColors.primary(sheetContext),
                          )
                        : null,
                    onTap: () => Navigator.pop(sheetContext, status),
                  ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted) return;
    setState(() => _statusFilter = chosen);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _performanceBloc),
        BlocProvider.value(value: _reportsBloc),
      ],
      child: Scaffold(
        backgroundColor: AppColors.background(context),
        body: SafeArea(
          child: BlocBuilder<ClassTeacherContextBloc, ClassTeacherContextState>(
            builder: (context, ctxState) {
              final active = ctxState.active;
              // The reference layout fits a fixed set of sections on one
              // screen with no scroll on a standard/large phone. Rather than
              // guess a breakpoint, measure the content once and only allow
              // scrolling when it's taller than the viewport - smaller
              // phones scroll, larger ones don't.
              return LayoutBuilder(
                builder: (context, constraints) {
                  final content = Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(context, active),
                      _buildIntroBanner(context),
                      _buildSectionTitle(context, 'Quick Reports'),
                      _buildQuickReports(context, active),
                      _buildRecentReportsHeader(context),
                      _buildRecentReportsList(context),
                      _buildRequestReportCard(context),
                      const SizedBox(height: AppSpacing.l),
                    ],
                  );

                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: content,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    ActiveResponsibilityContext? active,
  ) {
    final className = active == null
        ? null
        : [
            active.className,
            active.streamName,
          ].where((e) => e != null && e.isNotEmpty).join(' ');

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reports',
                  style: AppTypography.headlineMedium.copyWith(
                    color: AppColors.textPrimary(context),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (className != null && className.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    className,
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.primary(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          OutlinedButton.icon(
            onPressed: () => _showFilterSheet(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textPrimary(context),
              backgroundColor: AppColors.surfaceContainer(context),
              side: BorderSide(color: AppColors.border(context)),
              shape: RoundedRectangleBorder(borderRadius: AppRadius.medium),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.l,
                vertical: AppSpacing.m,
              ),
            ),
            icon: const Icon(Icons.filter_alt_outlined, size: 18),
            label: const Text('Filter'),
          ),
        ],
      ),
    );
  }

  Widget _buildIntroBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.primarySoft(context),
          borderRadius: AppRadius.large,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated(context),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.description_outlined,
                color: AppColors.primary(context),
                size: 22,
              ),
            ),
            const SizedBox(width: AppSpacing.l),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Track and view class performance',
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.textPrimary(context),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Generate reports, analyze trends and monitor '
                    'student progress.',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Text(
        title,
        style: AppTypography.titleLarge.copyWith(
          color: AppColors.textPrimary(context),
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildRecentReportsHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Recent Reports',
            style: AppTypography.titleLarge.copyWith(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.w800,
            ),
          ),
          TextButton(
            onPressed: () => setState(() => _showAllReports = !_showAllReports),
            child: Text(_showAllReports ? 'Show Less' : 'View All'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickReports(
    BuildContext context,
    ActiveResponsibilityContext? active,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: AppSpacing.l,
        mainAxisSpacing: AppSpacing.l,
        childAspectRatio: 1.4,
        children: [
          _QuickReportTile(
            icon: Icons.groups_outlined,
            color: AppColors.electricBlue,
            title: 'Class Attendance',
            subtitle: 'View attendance summary and trends',
            onTap: () => context.push('/staff/attendance/history'),
          ),
          _QuickReportTile(
            icon: Icons.fact_check_outlined,
            color: AppColors.successGreen,
            title: 'Academic Performance',
            subtitle: 'Analyze marks and grade performance',
            onTap: active?.classId == null
                ? null
                : () => context.push(
                    '/staff/classes/${active!.classId}/performance',
                  ),
          ),
          _QuickReportTile(
            icon: Icons.pie_chart_outline,
            color: AppColors.goldenYellow,
            title: 'Assessment Reports',
            subtitle: 'View assessment results and analytics',
            onTap: active?.classId == null
                ? null
                : () => context.push(
                    '/staff/classes/${active!.classId}/performance',
                  ),
          ),
          _QuickReportTile(
            icon: Icons.trending_up_rounded,
            color: AppColors.brightOrange,
            title: 'Student Progress',
            subtitle: 'Track individual student progress',
            onTap: active?.classId == null
                ? null
                : () => context.push(
                    '/staff/classes/${active!.classId}/performance',
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentReportsList(BuildContext context) {
    return BlocBuilder<ClassReportsBloc, ClassReportsState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.x3l),
            child: Center(child: SchoolPulseLoader()),
          );
        }

        if (state.errorMessage != null) {
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: AppSpacing.l,
            ),
            child: Text(
              state.errorMessage!,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textMuted(context),
              ),
            ),
          );
        }

        final entries = [...state.entries]
          ..sort((a, b) {
            final aDate = a.submittedAt ?? a.updatedAt ?? DateTime(1970);
            final bDate = b.submittedAt ?? b.updatedAt ?? DateTime(1970);
            return bDate.compareTo(aDate);
          });

        final filtered = _statusFilter == null
            ? entries
            : entries.where((e) => e.status == _statusFilter).toList();

        if (filtered.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: AppSpacing.l,
            ),
            child: Text(
              entries.isEmpty
                  ? 'No reports yet. Reports appear here once you submit '
                        'student report entries to the academic office.'
                  : 'No reports match this filter.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textMuted(context),
              ),
            ),
          );
        }

        // The reference shows four rows without scrolling; the full list
        // remains reachable via "View All".
        final visible = _showAllReports ? filtered : filtered.take(4).toList();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              for (var i = 0; i < visible.length; i++) ...[
                if (i > 0) const Divider(height: 1),
                _RecentReportTile(entry: visible[i]),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildRequestReportCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.l),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer(context),
          borderRadius: AppRadius.large,
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: AppColors.information(context)),
            const SizedBox(width: AppSpacing.l),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Need custom reports?',
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.textPrimary(context),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Contact the Academic Office to generate custom '
                    'reports for your class.',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.m),
            TextButton(
              onPressed: () => _showRequestReportSheet(context),
              child: const Text('Request Report'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showRequestReportSheet(BuildContext context) async {
    SystemConfig? config;
    String? loadError;
    try {
      config = await di.sl<SystemConfigRepository>().getConfig();
    } catch (_) {
      loadError = 'Could not load academic office contact details.';
    }

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        final email = config?.schoolEmail;
        final phone = config?.schoolPhone;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Academic Office',
                  style: AppTypography.titleLarge.copyWith(
                    color: AppColors.textPrimary(sheetContext),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.s),
                Text(
                  'Reach out for custom reports outside the categories '
                  'above.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary(sheetContext),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                if (loadError != null)
                  Text(
                    loadError,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.danger(sheetContext),
                    ),
                  )
                else ...[
                  if (email != null && email.isNotEmpty)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.email_outlined,
                        color: AppColors.primary(sheetContext),
                      ),
                      title: Text(email),
                      onTap: () =>
                          launchUrl(Uri(scheme: 'mailto', path: email)),
                    ),
                  if (phone != null && phone.isNotEmpty)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.phone_outlined,
                        color: AppColors.primary(sheetContext),
                      ),
                      title: Text(phone),
                      onTap: () => launchUrl(Uri(scheme: 'tel', path: phone)),
                    ),
                  if ((email == null || email.isEmpty) &&
                      (phone == null || phone.isEmpty))
                    Text(
                      'No contact details have been set up for the '
                      'academic office yet.',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textMuted(sheetContext),
                      ),
                    ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _QuickReportTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _QuickReportTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.large,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.l),
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
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                const Spacer(),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: AppColors.textMuted(context),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.m),
            Text(
              title,
              style: AppTypography.titleSmall.copyWith(
                color: AppColors.textPrimary(context),
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textMuted(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentReportTile extends StatelessWidget {
  final ClassReportEntry entry;

  const _RecentReportTile({required this.entry});

  Color _statusColor(BuildContext context) {
    switch (entry.status) {
      case ReportEntryStatus.published:
      case ReportEntryStatus.leadershipApproved:
      case ReportEntryStatus.academicOfficeApproved:
        return AppColors.success(context);
      case ReportEntryStatus.returnedForCorrection:
        return AppColors.danger(context);
      case ReportEntryStatus.submittedForReview:
      case ReportEntryStatus.classTeacherCompleted:
        return AppColors.warning(context);
      case ReportEntryStatus.draft:
      case ReportEntryStatus.inProgress:
      case ReportEntryStatus.archived:
        return AppColors.textMuted(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final date = entry.submittedAt ?? entry.updatedAt;
    final color = _statusColor(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.description_outlined, color: color, size: 20),
          ),
          const SizedBox(width: AppSpacing.l),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.studentName.isEmpty
                      ? 'Report ${entry.id}'
                      : entry.studentName,
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textPrimary(context),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  date == null
                      ? entry.status.label
                      : '${DateFormat('d MMM yyyy').format(date)} • '
                            '${entry.status.label}',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textMuted(context),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: AppRadius.full,
            ),
            child: Text(
              entry.status.label,
              style: AppTypography.labelSmall.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
