import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/teacher/domain/entities/class_report_entry.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_reports/class_reports_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_teacher_context/class_teacher_context_bloc.dart';
import 'class_report_card_preview_screen.dart';

/// Class-teacher report queue, styled after the approved reports dashboard.
/// It reads the assigned roster and report entries only; no academic values
/// are calculated or invented in this view.
class ReportsDashboardScreen extends StatefulWidget {
  const ReportsDashboardScreen({super.key});

  @override
  State<ReportsDashboardScreen> createState() => _ReportsDashboardScreenState();
}

class _ReportsDashboardScreenState extends State<ReportsDashboardScreen> {
  final _search = TextEditingController();
  ReportEntryStatus? _status;

  @override
  void initState() {
    super.initState();
    _search.addListener(_refresh);
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _search
      ..removeListener(_refresh)
      ..dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  void _load() {
    final active = context.read<ClassTeacherContextBloc>().state.active;
    if (active != null) {
      context.read<ClassReportsBloc>().add(ClassReportsRequested(active));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        child: BlocConsumer<ClassReportsBloc, ClassReportsState>(
          listenWhen: (before, after) =>
              before.errorMessage != after.errorMessage ||
              before.successMessage != after.successMessage,
          listener: (context, state) {
            final message = state.successMessage ?? state.errorMessage;
            if (message == null) return;
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(message)));
            context.read<ClassReportsBloc>().add(
              const ClassReportsFeedbackCleared(),
            );
          },
          builder: (context, state) {
            final active = context
                .watch<ClassTeacherContextBloc>()
                .state
                .active;
            if (active == null) {
              return const _NoClass();
            }
            if (state.isLoading) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SchoolPulseLoader(),
                    SizedBox(height: 16),
                    Text('Loading class reports...'),
                  ],
                ),
              );
            }

            final rows = _filtered(state.entries);
            final complete = state.entries
                .where(
                  (entry) =>
                      entry.status == ReportEntryStatus.classTeacherCompleted ||
                      entry.status.isApprovedUpstream,
                )
                .length;
            final inProgress = state.entries
                .where(
                  (entry) =>
                      entry.status == ReportEntryStatus.inProgress ||
                      entry.status == ReportEntryStatus.returnedForCorrection,
                )
                .length;
            final notStarted = state.entries
                .where((entry) => entry.status == ReportEntryStatus.draft)
                .length;
            final termLabel = active.termName.isEmpty
                ? 'Current term'
                : active.termName;

            return RefreshIndicator(
              onRefresh: () async => _load(),
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  const _Header(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
                    child: Column(
                      children: [
                        _Metrics(
                          total: state.entries.length,
                          completed: complete,
                          inProgress: inProgress,
                          notStarted: notStarted,
                        ),
                        const SizedBox(height: 24),
                        _TermLabel(termLabel: termLabel),
                        const SizedBox(height: 10),
                        _Controls(search: _search, onFilterTap: _showFilters),
                        const SizedBox(height: 12),
                        _StatusFilters(
                          selected: _status,
                          onChanged: (value) => setState(() => _status = value),
                        ),
                        if (state.unapprovedSubjects.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          _WaitingNotice(subjects: state.unapprovedSubjects),
                        ],
                        const SizedBox(height: 20),
                        _ReportTable(
                          entries: rows,
                          missingFor: state.missingFor,
                          classLabel: [active.className, active.streamName]
                              .where(
                                (value) => value != null && value.isNotEmpty,
                              )
                              .join(' - '),
                          onOpen: (entry) {
                            final activeContext = state.context;
                            if (entry.reportCardId != null &&
                                activeContext != null) {
                              // A generated report card exists - open the
                              // real preview, not the section-editing screen.
                              context.push(
                                '/staff/reports/preview',
                                extra: ClassReportCardPreviewArgs(
                                  reportCardId: entry.reportCardId!,
                                  context: activeContext,
                                ),
                              );
                            } else {
                              context.push(
                                '/staff/reports/student/${entry.studentId}',
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 20),
                        _CreateButton(
                          enabled: state.canGenerate,
                          onPressed: () => context.read<ClassReportsBloc>().add(
                            const ClassReportsGenerated(),
                          ),
                        ),
                        if (state.submittableToDean.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          _SubmitToDeanButton(
                            count: state.submittableToDean.length,
                            onPressed: () => _confirmSubmitToDean(
                              context,
                              state.submittableToDean,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  List<ClassReportEntry> _filtered(List<ClassReportEntry> entries) {
    final query = _search.text.trim().toLowerCase();
    return entries.where((entry) {
      final matchesSearch =
          query.isEmpty ||
          entry.studentName.toLowerCase().contains(query) ||
          entry.studentId.toLowerCase().contains(query);
      return matchesSearch && (_status == null || entry.status == _status);
    }).toList();
  }

  Future<void> _confirmSubmitToDean(
    BuildContext context,
    List<ClassReportEntry> submittable,
  ) async {
    final bloc = context.read<ClassReportsBloc>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Submit to the Dean?'),
        content: Text(
          submittable.length == 1
              ? "${submittable.first.studentName}'s report card will be "
                    'sent to the Dean of Studies for review. You will '
                    "not be able to edit it while it's under review."
              : '${submittable.length} report cards will be sent to the '
                    'Dean of Studies for review. You will not be able to '
                    "edit them while they're under review.",
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
    if (confirmed != true) return;
    bloc.add(
      ClassReportCardsSubmittedToDean(
        submittable.map((e) => e.reportCardId).whereType<String>().toList(),
      ),
    );
  }

  void _showFilters() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: .72,
          minChildSize: .4,
          maxChildSize: .9,
          builder: (context, scrollController) => ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: Text('Filter reports', style: AppTypography.titleMedium),
              ),
              const SizedBox(height: 8),
              for (final item in <ReportEntryStatus?>[
                null,
                ...ReportEntryStatus.values,
              ])
                ListTile(
                  title: Text(item?.label ?? 'All students'),
                  trailing: _status == item ? const Icon(Icons.check) : null,
                  onTap: () {
                    setState(() => _status = item);
                    Navigator.pop(sheetContext);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(24, 24, 20, 22),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CLASS TEACHER',
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.textMuted(context),
            fontWeight: FontWeight.w800,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Reports',
          style: AppTypography.headlineSmall.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );
}

class _TermLabel extends StatelessWidget {
  const _TermLabel({required this.termLabel});
  final String termLabel;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(
        Icons.calendar_month_outlined,
        size: 18,
        color: AppColors.textSecondary(context),
      ),
      const SizedBox(width: 6),
      Text(
        termLabel,
        style: AppTypography.labelMedium.copyWith(
          color: AppColors.textSecondary(context),
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );
}

class _Metrics extends StatelessWidget {
  const _Metrics({
    required this.total,
    required this.completed,
    required this.inProgress,
    required this.notStarted,
  });
  final int total, completed, inProgress, notStarted;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
    decoration: BoxDecoration(
      color: AppColors.surfaceElevated(context),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.border(context)),
    ),
    child: Row(
      children: [
        _Metric(
          icon: Icons.groups_rounded,
          value: total,
          label: 'Total Students',
          color: AppColors.primary(context),
        ),
        _Metric(
          icon: Icons.check_circle_outline_rounded,
          value: completed,
          label: 'Reports Completed',
          color: AppColors.success(context),
        ),
        _Metric(
          icon: Icons.edit_note_rounded,
          value: inProgress,
          label: 'In Progress',
          color: AppColors.warning(context),
        ),
        _Metric(
          icon: Icons.schedule_rounded,
          value: notStarted,
          label: 'Not Started',
          color: AppColors.secondary(context),
        ),
      ],
    ),
  );
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });
  final IconData icon;
  final int value;
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Icon(icon, color: color, size: 27),
        const SizedBox(height: 8),
        Text(
          '$value',
          style: AppTypography.headlineSmall.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          maxLines: 2,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textSecondary(context),
          ),
        ),
      ],
    ),
  );
}

class _Controls extends StatelessWidget {
  const _Controls({required this.search, required this.onFilterTap});
  final TextEditingController search;
  final VoidCallback onFilterTap;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: TextField(
          controller: search,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            hintText: 'Search student...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
      const SizedBox(width: 8),
      IconButton(
        onPressed: onFilterTap,
        icon: const Icon(Icons.tune_rounded),
        style: IconButton.styleFrom(
          minimumSize: const Size(54, 54),
          side: BorderSide(color: AppColors.border(context)),
        ),
        tooltip: 'Filter students',
      ),
    ],
  );
}

class _StatusFilters extends StatelessWidget {
  const _StatusFilters({required this.selected, required this.onChanged});
  final ReportEntryStatus? selected;
  final ValueChanged<ReportEntryStatus?> onChanged;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: [
        FilterChip(
          label: const Text('All'),
          selected: selected == null,
          onSelected: (_) => onChanged(null),
        ),
        const SizedBox(width: 8),
        ...ReportEntryStatus.values.map(
          (status) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(status.label),
              selected: selected == status,
              onSelected: (_) => onChanged(status),
            ),
          ),
        ),
      ],
    ),
  );
}

class _WaitingNotice extends StatelessWidget {
  const _WaitingNotice({required this.subjects});
  final List<String> subjects;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.warning(context),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      children: [
        Icon(Icons.hourglass_top_rounded, color: AppColors.warning(context)),
        const SizedBox(width: 8),
        Expanded(
          child: Text('Waiting for approved marks: ${subjects.join(', ')}'),
        ),
      ],
    ),
  );
}

class _ReportTable extends StatelessWidget {
  const _ReportTable({
    required this.entries,
    required this.missingFor,
    required this.classLabel,
    required this.onOpen,
  });
  final List<ClassReportEntry> entries;
  final List<ReportSection> Function(ClassReportEntry) missingFor;
  final String classLabel;
  final ValueChanged<ClassReportEntry> onOpen;
  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Text(
            'No students match this view.',
            style: TextStyle(color: AppColors.textSecondary(context)),
          ),
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: 760,
            child: Column(
              children: [
                const _TableHeader(),
                ...entries.map(
                  (entry) => _TableRow(
                    entry: entry,
                    classLabel: classLabel,
                    missing: missingFor(entry),
                    onOpen: () => onOpen(entry),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Showing 1 - ${entries.length} of ${entries.length}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader();
  @override
  Widget build(BuildContext context) => Container(
    color: AppColors.surfaceContainer(context),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    child: const Row(
      children: [
        _Cell('STUDENT', 3),
        _Cell('CLASS', 2),
        _Cell('STATUS', 2),
        _Cell('LAST UPDATED', 2),
        _Cell('ACTION', 1),
      ],
    ),
  );
}

class _Cell extends StatelessWidget {
  const _Cell(this.text, this.flex, {this.child});
  final String text;
  final int flex;
  final Widget? child;
  @override
  Widget build(BuildContext context) => Expanded(
    flex: flex,
    child:
        child ??
        Text(
          text,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textSecondary(context),
            fontWeight: FontWeight.w800,
            letterSpacing: .5,
          ),
        ),
  );
}

class _TableRow extends StatelessWidget {
  const _TableRow({
    required this.entry,
    required this.classLabel,
    required this.missing,
    required this.onOpen,
  });
  final ClassReportEntry entry;
  final String classLabel;
  final List<ReportSection> missing;
  final VoidCallback onOpen;
  @override
  Widget build(BuildContext context) {
    final statusColor = entry.status == ReportEntryStatus.returnedForCorrection
        ? AppColors.danger(context)
        : missing.isEmpty
        ? AppColors.success(context)
        : entry.status == ReportEntryStatus.draft
        ? AppColors.textSecondary(context)
        : AppColors.warning(context);
    final date = entry.updatedAt == null
        ? '—'
        : DateFormat('dd MMM\nyy, h:mm a').format(entry.updatedAt!);
    return InkWell(
      onTap: onOpen,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border(context))),
        ),
        child: Row(
          children: [
            _Cell(
              '',
              3,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 23,
                    backgroundColor: AppColors.primarySoft(context),
                    child: Text(
                      entry.studentName.isEmpty
                          ? '?'
                          : entry.studentName.substring(0, 1).toUpperCase(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.studentName.isEmpty
                              ? entry.studentId
                              : entry.studentName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.titleSmall.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'ID: ${entry.studentId}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _Cell(
              '',
              2,
              child: Text(
                classLabel.isEmpty ? 'Assigned class' : classLabel,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            _Cell(
              '',
              2,
              child: Align(
                alignment: Alignment.centerLeft,
                child: _StatusBadge(
                  label: entry.status.label,
                  color: statusColor,
                ),
              ),
            ),
            _Cell(
              '',
              2,
              child: Text(
                date,
                style: AppTypography.bodySmall.copyWith(height: 1.35),
              ),
            ),
            _Cell(
              '',
              1,
              child: Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: onOpen,
                  tooltip: entry.isEditable ? 'Edit report' : 'View report',
                  icon: Icon(
                    entry.isEditable
                        ? Icons.edit_note_outlined
                        : Icons.visibility_outlined,
                  ),
                  color: AppColors.primary(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(7),
      border: Border.all(color: color),
    ),
    child: Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: AppTypography.labelSmall.copyWith(
        color: color,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

class _CreateButton extends StatelessWidget {
  const _CreateButton({required this.enabled, required this.onPressed});
  final bool enabled;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 58,
    child: FilledButton.icon(
      onPressed: enabled ? onPressed : null,
      icon: const Icon(Icons.add, size: 27),
      label: const Text('Refresh report readiness'),
    ),
  );
}

class _SubmitToDeanButton extends StatelessWidget {
  const _SubmitToDeanButton({required this.count, required this.onPressed});
  final int count;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 52,
    child: OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.send_outlined, size: 22),
      label: Text('Submit $count report${count == 1 ? '' : 's'} to the Dean'),
    ),
  );
}

class _NoClass extends StatelessWidget {
  const _NoClass();
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Text(
        'No class-teacher assignment is active.',
        style: AppTypography.titleMedium,
      ),
    ),
  );
}
