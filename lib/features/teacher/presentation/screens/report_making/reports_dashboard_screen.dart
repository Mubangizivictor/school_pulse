import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_reports/class_reports_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_teacher_context/class_teacher_context_bloc.dart';
import 'package:school_pulse/features/teacher/domain/entities/class_report_entry.dart';

class ReportsDashboardScreen extends StatefulWidget {
  const ReportsDashboardScreen({super.key});

  @override
  State<ReportsDashboardScreen> createState() => _ReportsDashboardScreenState();
}

class _ReportsDashboardScreenState extends State<ReportsDashboardScreen> {
  @override
  void initState() {
    super.initState();
    final active = context.read<ClassTeacherContextBloc>().state.active;
    if (active != null) {
      context.read<ClassReportsBloc>().add(ClassReportsRequested(active));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.surfaceElevated(context),
        foregroundColor: AppColors.textPrimary(context),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'REPORTS DASHBOARD',
              style: TextStyle(
                color: AppColors.textMuted(context),
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              'Manage Class Reports',
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.settings_outlined,
              color: AppColors.textPrimary(context),
            ),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: AppColors.border(context).withValues(alpha: 0.5),
            height: 1,
          ),
        ),
      ),
      body: BlocConsumer<ClassReportsBloc, ClassReportsState>(
        listenWhen: (previous, current) =>
            previous.errorMessage != current.errorMessage ||
            previous.successMessage != current.successMessage,
        listener: (context, state) {
          final message = state.successMessage ?? state.errorMessage;
          if (message == null) return;
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: state.successMessage != null
                    ? AppColors.success(context)
                    : AppColors.danger(context),
              ),
            );
          context.read<ClassReportsBloc>().add(
            const ClassReportsFeedbackCleared(),
          );
        },
        builder: (context, state) {
          if (state.isLoading) {
            return Center(child: const SchoolPulseLoader());
          }

          final contextState = context.watch<ClassTeacherContextBloc>().state;
          if (contextState.active == null) {
            return const EmptyState(
              icon: Icons.class_outlined,
              title: 'No class assigned',
              message:
                  'You are not currently the Class Teacher for any class, '
                  'so there are no reports to work on.',
            );
          }

          if (state.entries.isEmpty) {
            return EmptyState(
              icon: Icons.description_outlined,
              title: 'No reports to work on',
              message:
                  state.errorMessage ??
                  'No students have been placed in your class for this term.',
            );
          }

          final progress = state.progress;
          final active = contextState.active!;
          final termLabel = [
            active.termName,
            active.academicYearName,
          ].where((e) => e.isNotEmpty).join(', ');

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppCard(
                  color: AppColors.primary(context).withValues(alpha: 0.05),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Active Term',
                            style: TextStyle(
                              color: AppColors.textPrimary(context),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          StatusBadge(
                            label: progress.pending == 0
                                ? 'Complete'
                                : 'In Progress',
                            color: progress.pending == 0
                                ? AppColors.success(context)
                                : AppColors.information(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        termLabel.isEmpty ? 'Current term' : termLabel,
                        style: TextStyle(
                          color: AppColors.textPrimary(context),
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _StatMiniCard(
                              label: 'Students',
                              value: '${progress.total}',
                              icon: Icons.people_outline,
                              color: AppColors.primary(context),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _StatMiniCard(
                              label: 'Completed',
                              value: '${progress.complete}',
                              icon: Icons.check_circle_outline,
                              color: AppColors.success(context),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _StatMiniCard(
                              label: 'Pending',
                              value: '${progress.pending}',
                              icon: Icons.pending_actions,
                              color: AppColors.warning(context),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      PrimaryButton(
                        label: 'Start Report Entry',
                        onPressed: () =>
                            context.push('/staff/reports/select-class'),
                      ),
                    ],
                  ),
                ),
                // Named rather than folded into "pending": the teacher cannot
                // fix an unapproved mark themselves, so this tells them who to
                // chase instead of implying their own work is unfinished.
                if (state.unapprovedSubjects.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  AppCard(
                    color: AppColors.warning(context).withValues(alpha: 0.08),
                    child: Row(
                      children: [
                        Icon(
                          Icons.hourglass_empty,
                          size: 18,
                          color: AppColors.warning(context),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Waiting on approved marks for '
                            '${state.unapprovedSubjects.join(', ')}.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (state.returned.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  AppCard(
                    color: AppColors.danger(context).withValues(alpha: 0.08),
                    onTap: () => context.push('/staff/reports/select-students'),
                    child: Row(
                      children: [
                        Icon(
                          Icons.assignment_return_outlined,
                          size: 18,
                          color: AppColors.danger(context),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '${state.returned.length} report'
                            '${state.returned.length == 1 ? '' : 's'} returned '
                            'for correction.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary(context),
                            ),
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          size: 18,
                          color: AppColors.textMuted(context),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                SectionHeader(
                  title: 'Students',
                  color: AppColors.textPrimary(context),
                ),
                const SizedBox(height: 12),
                for (final entry in state.entries)
                  _ReportEntryCard(
                    name: entry.studentName.isEmpty
                        ? entry.studentId
                        : entry.studentName,
                    status: entry.status.label,
                    missing: state
                        .missingFor(entry)
                        .map((s) => s.label)
                        .toList(),
                    isReturned: entry.wasReturned,
                    onTap: () => context.push('/staff/reports/select-students'),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// One student's report row. Shows what is still missing rather than only
/// that something is, so the teacher knows which screen to open.
class _ReportEntryCard extends StatelessWidget {
  final String name;
  final String status;
  final List<String> missing;
  final bool isReturned;
  final VoidCallback onTap;

  const _ReportEntryCard({
    required this.name,
    required this.status,
    required this.missing,
    required this.isReturned,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isReturned
        ? AppColors.danger(context)
        : (missing.isEmpty
              ? AppColors.success(context)
              : AppColors.warning(context));

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        padding: const EdgeInsets.all(12),
        onTap: onTap,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      color: AppColors.textPrimary(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    missing.isEmpty ? status : 'Missing: ${missing.join(', ')}',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                ],
              ),
            ),
            StatusBadge(label: status, color: color),
          ],
        ),
      ),
    );
  }
}

class _StatMiniCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatMiniCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border(context).withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: AppColors.textPrimary(context),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }
}
