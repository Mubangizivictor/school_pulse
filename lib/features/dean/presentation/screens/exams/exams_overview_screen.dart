import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/dean/domain/entities/examination_schedule.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_bloc.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_event.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_state.dart';
import 'package:school_pulse/injection_container.dart';

/// Exams Overview — root of the Reports tab. Upcoming / In Progress /
/// Completed exam schedules with a bottom stat row summarizing the term's
/// examination workload.
class ExamsOverviewScreen extends StatefulWidget {
  const ExamsOverviewScreen({super.key});

  @override
  State<ExamsOverviewScreen> createState() => _ExamsOverviewScreenState();
}

class _ExamsOverviewScreenState extends State<ExamsOverviewScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<DeanBloc>()..add(ExaminationSchedulesRequested()),
      child: Scaffold(
        backgroundColor: AppColors.background(context),
        appBar: AppBar(
          backgroundColor: AppColors.surfaceContainer(context),
          automaticallyImplyLeading: false,
          title: Text('Exams Overview', style: AppTypography.titleLarge),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Upcoming'),
              Tab(text: 'In Progress'),
              Tab(text: 'Completed'),
            ],
          ),
        ),
        body: BlocBuilder<DeanBloc, DeanState>(
          builder: (context, state) {
            if (state is ExaminationSchedulesLoaded) {
              final schedules = state.schedules
                  .whereType<ExaminationSchedule>()
                  .toList();
              final upcoming = schedules
                  .where((e) => e.status == ExaminationStatus.scheduled)
                  .toList();
              final inProgress = schedules
                  .where((e) => e.status == ExaminationStatus.inProgress)
                  .toList();
              final completed = schedules
                  .where(
                    (e) =>
                        e.status == ExaminationStatus.completed ||
                        e.status == ExaminationStatus.marksPending ||
                        e.status == ExaminationStatus.published,
                  )
                  .toList();
              return Column(
                children: [
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _ExamList(
                          exams: upcoming,
                          emptyLabel: 'No upcoming exams',
                        ),
                        _ExamList(
                          exams: inProgress,
                          emptyLabel: 'No exams in progress',
                        ),
                        _ExamList(
                          exams: completed,
                          emptyLabel: 'No completed exams',
                        ),
                      ],
                    ),
                  ),
                  _StatRow(schedules: schedules),
                ],
              );
            }
            if (state is DeanError) {
              return EmptyState(
                icon: Icons.error_outline,
                title: 'Could not load exams',
                message: state.message,
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}

class _ExamList extends StatelessWidget {
  final List<ExaminationSchedule> exams;
  final String emptyLabel;

  const _ExamList({required this.exams, required this.emptyLabel});

  @override
  Widget build(BuildContext context) {
    if (exams.isEmpty) {
      return EmptyState(
        icon: Icons.event_note_outlined,
        title: 'Nothing here',
        message: emptyLabel,
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.xl),
      itemCount: exams.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.l),
      itemBuilder: (context, index) => _ExamCard(exam: exams[index]),
    );
  }
}

class _ExamCard extends StatelessWidget {
  final ExaminationSchedule exam;

  const _ExamCard({required this.exam});

  int get _daysUntil => exam.date.difference(DateTime.now()).inDays;

  @override
  Widget build(BuildContext context) {
    final countdown = _daysUntil > 0
        ? 'In $_daysUntil day${_daysUntil == 1 ? '' : 's'}'
        : _daysUntil == 0
        ? 'Today'
        : '${-_daysUntil} day${-_daysUntil == 1 ? '' : 's'} ago';

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  exam.examName,
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.textPrimary(context),
                  ),
                ),
              ),
              StatusBadge(
                label: _statusLabel(exam.status),
                color: _statusColor(context, exam.status),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            '${exam.subjectName} • ${exam.className}',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary(context),
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 16,
                color: AppColors.textMuted(context),
              ),
              const SizedBox(width: AppSpacing.s),
              Text(
                '${_formatDate(exam.date)} • ${exam.startTime} • ${exam.durationLabel}',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textMuted(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 16,
                color: AppColors.textMuted(context),
              ),
              const SizedBox(width: AppSpacing.s),
              Text(
                exam.venue,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textMuted(context),
                ),
              ),
              const Spacer(),
              Text(
                countdown,
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.primary(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  String _statusLabel(ExaminationStatus status) {
    switch (status) {
      case ExaminationStatus.scheduled:
        return 'Scheduled';
      case ExaminationStatus.inProgress:
        return 'In Progress';
      case ExaminationStatus.completed:
        return 'Completed';
      case ExaminationStatus.marksPending:
        return 'Marks Pending';
      case ExaminationStatus.published:
        return 'Published';
    }
  }

  Color _statusColor(BuildContext context, ExaminationStatus status) {
    switch (status) {
      case ExaminationStatus.scheduled:
        return AppColors.information(context);
      case ExaminationStatus.inProgress:
        return AppColors.warning(context);
      case ExaminationStatus.completed:
        return AppColors.success(context);
      case ExaminationStatus.marksPending:
        return AppColors.warning(context);
      case ExaminationStatus.published:
        return AppColors.success(context);
    }
  }
}

class _StatRow extends StatelessWidget {
  final List<ExaminationSchedule> schedules;

  const _StatRow({required this.schedules});

  @override
  Widget build(BuildContext context) {
    final candidates = schedules.length * 32;
    final invigilators = (schedules.map((e) => e.venue).toSet().length) * 2;
    final rooms = schedules.map((e) => e.venue).toSet().length;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.l,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer(context),
        border: Border(top: BorderSide(color: AppColors.border(context))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(label: 'Exams', value: '${schedules.length}'),
          _StatItem(label: 'Candidates', value: '$candidates'),
          _StatItem(label: 'Invigilators', value: '$invigilators'),
          _StatItem(label: 'Rooms', value: '$rooms'),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.titleMedium.copyWith(
            color: AppColors.textPrimary(context),
          ),
        ),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textMuted(context),
          ),
        ),
      ],
    );
  }
}
