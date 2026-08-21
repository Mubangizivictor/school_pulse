import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/teacher/domain/entities/class_report_entry.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_reports/class_reports_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_teacher_context/class_teacher_context_bloc.dart';

/// Real, tenant-scoped class report queue. Academic figures remain owned by
/// the Report Card Engine; this screen only manages class-teacher sections.
class ReportsDashboardScreen extends StatefulWidget {
  const ReportsDashboardScreen({super.key});
  @override
  State<ReportsDashboardScreen> createState() => _ReportsDashboardScreenState();
}

class _ReportsDashboardScreenState extends State<ReportsDashboardScreen> {
  final _search = TextEditingController();
  ReportEntryStatus? _filter;

  @override
  void initState() {
    super.initState();
    _search.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _load() {
    final active = context.read<ClassTeacherContextBloc>().state.active;
    if (active != null) {
      context.read<ClassReportsBloc>().add(ClassReportsRequested(active));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background(context),
    appBar: AppBar(
      titleSpacing: AppSpacing.l,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'REPORT CARDS',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textMuted(context),
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          Text('Manage Class Reports', style: AppTypography.titleLarge),
        ],
      ),
      actions: [
        IconButton(
          tooltip: 'Refresh reports',
          onPressed: _load,
          icon: const Icon(Icons.refresh_rounded),
        ),
      ],
    ),
    body: BlocConsumer<ClassReportsBloc, ClassReportsState>(
      listenWhen: (before, after) =>
          before.errorMessage != after.errorMessage ||
          before.successMessage != after.successMessage,
      listener: (context, state) {
        final message = state.successMessage ?? state.errorMessage;
        if (message != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(message)));
          context.read<ClassReportsBloc>().add(
            const ClassReportsFeedbackCleared(),
          );
        }
      },
      builder: (context, state) {
        final active = context.watch<ClassTeacherContextBloc>().state.active;
        if (active == null) return const _NoClass();
        if (state.isLoading) return const Center(child: SchoolPulseLoader());
        final rows = state.entries.where((entry) {
          final query = _search.text.trim().toLowerCase();
          return (_filter == null || entry.status == _filter) &&
              (query.isEmpty ||
                  entry.studentName.toLowerCase().contains(query) ||
                  entry.studentId.toLowerCase().contains(query));
        }).toList();
        final progress = state.progress;
        final started = state.entries
            .where((e) => e.status == ReportEntryStatus.inProgress)
            .length;
        final fresh = state.entries
            .where((e) => e.status == ReportEntryStatus.draft)
            .length;
        final classLabel = [
          active.className,
          active.streamName,
        ].where((e) => e != null && e.isNotEmpty).join(' - ');
        final period = [
          active.termName,
          active.academicYearName,
        ].where((e) => e.isNotEmpty).join(' • ');
        return RefreshIndicator(
          onRefresh: () async => _load(),
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.l),
            children: [
              Text(
                classLabel.isEmpty ? 'Assigned class' : classLabel,
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.primary(context),
                ),
              ),
              if (period.isNotEmpty)
                Text(
                  period,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
                ),
              const SizedBox(height: AppSpacing.l),
              _ProgressCard(
                total: progress.total,
                complete: progress.complete,
                inProgress: started,
                notStarted: fresh,
              ),
              if (state.unapprovedSubjects.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.m),
                _Notice(
                  message:
                      'Waiting for approved marks: ${state.unapprovedSubjects.join(', ')}. Marks are read-only in Report Cards.',
                ),
              ],
              const SizedBox(height: AppSpacing.l),
              TextField(
                controller: _search,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Search student or admission ID',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.s),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _FilterChip(
                      label: 'All (${state.entries.length})',
                      selected: _filter == null,
                      onTap: () => setState(() => _filter = null),
                    ),
                    for (final status in ReportEntryStatus.values)
                      _FilterChip(
                        label: status.label,
                        selected: _filter == status,
                        onTap: () => setState(() => _filter = status),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.m),
              if (rows.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Center(
                    child: Text(
                      'No students match this filter.',
                      style: TextStyle(color: AppColors.textSecondary(context)),
                    ),
                  ),
                )
              else
                ...rows.map(
                  (entry) => _StudentRow(
                    entry: entry,
                    missing: state.missingFor(entry),
                    onTap: () => context.push(
                      '/staff/reports/student/${entry.studentId}',
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    ),
  );
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.total,
    required this.complete,
    required this.inProgress,
    required this.notStarted,
  });
  final int total, complete, inProgress, notStarted;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(AppSpacing.l),
    decoration: BoxDecoration(
      color: AppColors.surfaceElevated(context),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.border(context)),
    ),
    child: Row(
      children: [
        _Stat(
          Icons.groups_outlined,
          total,
          'Students',
          AppColors.primary(context),
        ),
        _Stat(
          Icons.check_circle_outline,
          complete,
          'Completed',
          AppColors.success(context),
        ),
        _Stat(
          Icons.edit_outlined,
          inProgress,
          'In progress',
          AppColors.warning(context),
        ),
        _Stat(
          Icons.schedule_outlined,
          notStarted,
          'Not started',
          AppColors.textSecondary(context),
        ),
      ],
    ),
  );
}

class _Stat extends StatelessWidget {
  const _Stat(this.icon, this.value, this.label, this.color);
  final IconData icon;
  final int value;
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Icon(icon, color: color, size: 21),
        const SizedBox(height: 6),
        Text(
          '$value',
          style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w800),
        ),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textSecondary(context),
          ),
        ),
      ],
    ),
  );
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    ),
  );
}

class _Notice extends StatelessWidget {
  const _Notice({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(AppSpacing.m),
    decoration: BoxDecoration(
      color: AppColors.warning(context).withValues(alpha: .1),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Icon(Icons.pending_actions_outlined, color: AppColors.warning(context)),
        const SizedBox(width: 10),
        Expanded(child: Text(message)),
      ],
    ),
  );
}

class _NoClass extends StatelessWidget {
  const _NoClass();
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.class_outlined, size: 48),
          const SizedBox(height: AppSpacing.m),
          Text(
            'No class-teacher assignment is active.',
            style: AppTypography.titleMedium,
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            'Choose an active class-teacher responsibility to work on report cards.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary(context)),
          ),
        ],
      ),
    ),
  );
}

class _StudentRow extends StatelessWidget {
  const _StudentRow({
    required this.entry,
    required this.missing,
    required this.onTap,
  });
  final ClassReportEntry entry;
  final List<ReportSection> missing;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final color = entry.status == ReportEntryStatus.returnedForCorrection
        ? AppColors.danger(context)
        : missing.isEmpty
        ? AppColors.success(context)
        : AppColors.warning(context);
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.s),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          child: Text(
            entry.studentName.isEmpty
                ? '?'
                : entry.studentName.substring(0, 1).toUpperCase(),
          ),
        ),
        title: Text(
          entry.studentName.isEmpty ? entry.studentId : entry.studentName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          missing.isEmpty
              ? entry.status.label
              : 'Missing: ${missing.map((s) => s.label).join(', ')}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              entry.status.label,
              style: AppTypography.labelSmall.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
