import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/dean/domain/entities/academic_intervention.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_bloc.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_event.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_state.dart';
import 'package:school_pulse/injection_container.dart';

/// Student Academic Profile — pushed on top of the Overview tab from a
/// student search / alert / intervention deep link. Shows a Term1 vs Term2
/// performance trend, subject score table, at-risk subjects and a shortcut
/// to create a new intervention plan for this student.
class StudentAcademicProfileScreen extends StatefulWidget {
  final String studentId;

  const StudentAcademicProfileScreen({super.key, required this.studentId});

  @override
  State<StudentAcademicProfileScreen> createState() =>
      _StudentAcademicProfileScreenState();
}

class _StudentAcademicProfileScreenState
    extends State<StudentAcademicProfileScreen>
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
      create: (context) =>
          sl<DeanBloc>()
            ..add(StudentAcademicProfileRequested(widget.studentId)),
      child: Scaffold(
        backgroundColor: AppColors.background(context),
        appBar: AppBar(
          backgroundColor: AppColors.surfaceContainer(context),
          title: Text('Student Profile', style: AppTypography.titleLarge),
        ),
        body: BlocConsumer<DeanBloc, DeanState>(
          listener: (context, state) {
            if (state is DeanOperationSuccess) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
              context.read<DeanBloc>().add(
                StudentAcademicProfileRequested(widget.studentId),
              );
            }
          },
          builder: (context, state) {
            if (state is StudentAcademicProfileLoaded) {
              return _buildContent(context, state.profile);
            }
            if (state is DeanError) {
              return EmptyState(
                icon: Icons.error_outline,
                title: 'Could not load profile',
                message: state.message,
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Map<String, dynamic> profile) {
    final term1Marks =
        (profile['term1Marks'] as Map?)?.cast<String, dynamic>() ??
        <String, dynamic>{};
    final term2Marks =
        (profile['term2Marks'] as Map?)?.cast<String, dynamic>() ??
        <String, dynamic>{};
    final subjects = term2Marks.keys.toList()..sort();

    return Column(
      children: [
        _buildHeader(context, profile),
        TabBar(
          controller: _tabController,
          labelColor: AppColors.primary(context),
          unselectedLabelColor: AppColors.textMuted(context),
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Performance'),
            Tab(text: 'Interventions'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _OverviewTab(profile: profile),
              _PerformanceTab(
                subjects: subjects,
                term1Marks: term1Marks,
                term2Marks: term2Marks,
              ),
              _InterventionsTab(
                profile: profile,
                studentId: widget.studentId,
                studentName: profile['studentName'] as String? ?? 'Student',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, Map<String, dynamic> profile) {
    final name = profile['studentName'] as String? ?? 'Student';
    final className = profile['className'] as String? ?? '';
    final admissionNumber = profile['admissionNumber'] as String? ?? '';
    final overallAverage = (profile['overallAverage'] as num?)?.toDouble() ?? 0;

    return Container(
      width: double.infinity,
      color: AppColors.surfaceContainer(context),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.l,
        AppSpacing.xl,
        AppSpacing.xl,
      ),
      child: Row(
        children: [
          AvatarInitials(name: name, size: 56),
          const SizedBox(width: AppSpacing.l),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '$className • $admissionNumber',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textMuted(context),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${overallAverage.toStringAsFixed(1)}%',
                style: AppTypography.titleLarge.copyWith(
                  color: AppColors.primary(context),
                ),
              ),
              Text(
                'Overall Avg',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textMuted(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  final Map<String, dynamic> profile;

  const _OverviewTab({required this.profile});

  @override
  Widget build(BuildContext context) {
    final attendanceRate = (profile['attendanceRate'] as num?)?.toDouble() ?? 0;
    final remarks = profile['remarks'] as String? ?? '';
    final subjectTeachers =
        (profile['subjectTeachers'] as List?)?.cast<Map>() ?? const [];

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        AppCard(
          child: Row(
            children: [
              Icon(
                Icons.event_available_outlined,
                color: AppColors.success(context),
              ),
              const SizedBox(width: AppSpacing.l),
              Expanded(
                child: Text('Attendance Rate', style: AppTypography.titleSmall),
              ),
              Text(
                '${(attendanceRate * 100).toStringAsFixed(0)}%',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.success(context),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.l),
        const SectionHeader(title: 'Subject Teachers'),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: subjectTeachers.map((entry) {
              return ListTile(
                dense: true,
                title: Text(
                  entry['subject'] as String? ?? '',
                  style: AppTypography.bodyMedium,
                ),
                trailing: Text(
                  entry['teacher'] as String? ?? '',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textMuted(context),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        if (remarks.isNotEmpty) ...[
          const SectionHeader(title: 'Remarks'),
          AppCard(
            child: Text(
              remarks,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary(context),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _PerformanceTab extends StatelessWidget {
  final List<String> subjects;
  final Map<String, dynamic> term1Marks;
  final Map<String, dynamic> term2Marks;

  const _PerformanceTab({
    required this.subjects,
    required this.term1Marks,
    required this.term2Marks,
  });

  List<String> get _atRiskSubjects => subjects
      .where((s) => ((term2Marks[s] as num?)?.toDouble() ?? 100) < 60)
      .toList();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        const SectionHeader(title: 'Term 1 vs Term 2'),
        AppCard(
          child: SizedBox(
            height: 220,
            child: subjects.isEmpty
                ? const Center(child: Text('No score data available'))
                : LineChart(_buildChartData(context)),
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        Row(
          children: [
            _LegendDot(color: AppColors.textMuted(context), label: 'Term 1'),
            const SizedBox(width: AppSpacing.xl),
            _LegendDot(color: AppColors.primary(context), label: 'Term 2'),
          ],
        ),
        const SectionHeader(title: 'Subject Scores'),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: subjects.map((s) {
              final t1 = (term1Marks[s] as num?)?.toDouble() ?? 0;
              final t2 = (term2Marks[s] as num?)?.toDouble() ?? 0;
              final delta = t2 - t1;
              return ListTile(
                dense: true,
                title: Text(s, style: AppTypography.bodyMedium),
                subtitle: Text(
                  'T1: ${t1.toStringAsFixed(0)}%  →  T2: ${t2.toStringAsFixed(0)}%',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textMuted(context),
                  ),
                ),
                trailing: StatusBadge(
                  label: '${delta >= 0 ? '+' : ''}${delta.toStringAsFixed(0)}',
                  color: delta >= 0
                      ? AppColors.success(context)
                      : AppColors.danger(context),
                ),
              );
            }).toList(),
          ),
        ),
        if (_atRiskSubjects.isNotEmpty) ...[
          const SectionHeader(title: 'At Risk Subjects'),
          ..._atRiskSubjects.map(
            (s) => AlertBanner(
              title: s,
              message:
                  'Term 2 score: ${((term2Marks[s] as num?)?.toDouble() ?? 0).toStringAsFixed(0)}% — below the 60% pass threshold.',
              color: AppColors.danger(context),
              icon: Icons.trending_down,
            ),
          ),
        ],
      ],
    );
  }

  LineChartData _buildChartData(BuildContext context) {
    final term1Spots = <FlSpot>[];
    final term2Spots = <FlSpot>[];
    for (var i = 0; i < subjects.length; i++) {
      final s = subjects[i];
      term1Spots.add(
        FlSpot(i.toDouble(), (term1Marks[s] as num?)?.toDouble() ?? 0),
      );
      term2Spots.add(
        FlSpot(i.toDouble(), (term2Marks[s] as num?)?.toDouble() ?? 0),
      );
    }
    return LineChartData(
      minY: 0,
      maxY: 100,
      gridData: const FlGridData(show: true, drawVerticalLine: false),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 32,
            interval: 25,
            getTitlesWidget: (value, meta) => Text(
              value.toInt().toString(),
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textMuted(context),
              ),
            ),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 28,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index < 0 || index >= subjects.length) {
                return const SizedBox.shrink();
              }
              final label = subjects[index];
              return Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  label.length > 3 ? label.substring(0, 3) : label,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textMuted(context),
                  ),
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: term1Spots,
          isCurved: true,
          color: AppColors.textMuted(context),
          barWidth: 2,
          dotData: const FlDotData(show: true),
        ),
        LineChartBarData(
          spots: term2Spots,
          isCurved: true,
          color: AppColors.primary(context),
          barWidth: 3,
          dotData: const FlDotData(show: true),
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSpacing.s),
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

class _InterventionsTab extends StatelessWidget {
  final Map<String, dynamic> profile;
  final String studentId;
  final String studentName;

  const _InterventionsTab({
    required this.profile,
    required this.studentId,
    required this.studentName,
  });

  @override
  Widget build(BuildContext context) {
    final interventions =
        (profile['interventions'] as List?)?.cast<Map>() ?? const [];

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        if (interventions.isEmpty)
          const EmptyState(
            icon: Icons.psychology_outlined,
            title: 'No interventions',
            message: 'No intervention plans exist for this student yet.',
          )
        else
          ...interventions.map(
            (i) => AppCard(
              margin: const EdgeInsets.only(bottom: AppSpacing.l),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      i['reason'] as String? ?? '',
                      style: AppTypography.bodyMedium,
                    ),
                  ),
                  StatusBadge(
                    label: (i['status'] as String? ?? '').toUpperCase(),
                    color: AppColors.information(context),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: AppSpacing.xl),
        Builder(
          builder: (context) => SizedBox(
            width: double.infinity,
            child: PrimaryButton(
              label: 'Create New Intervention',
              icon: Icons.add,
              onPressed: () => _showCreateInterventionSheet(context),
            ),
          ),
        ),
      ],
    );
  }

  void _showCreateInterventionSheet(BuildContext context) {
    final deanBloc = context.read<DeanBloc>();
    final formKey = GlobalKey<FormState>();
    String reason = '';
    InterventionType type = InterventionType.remedial;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
            left: AppSpacing.xl,
            right: AppSpacing.xl,
            top: AppSpacing.xl,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SectionHeader(title: 'New Intervention for $studentName'),
                const SizedBox(height: AppSpacing.xl),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Reason for Intervention',
                  ),
                  maxLines: 2,
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                  onSaved: (v) => reason = v!,
                ),
                const SizedBox(height: AppSpacing.xl),
                DropdownButtonFormField<InterventionType>(
                  initialValue: type,
                  decoration: const InputDecoration(
                    labelText: 'Intervention Type',
                  ),
                  items: InterventionType.values
                      .map(
                        (t) => DropdownMenuItem(
                          value: t,
                          child: Text(t.name.toUpperCase()),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => type = v!),
                ),
                const SizedBox(height: AppSpacing.x3l),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState?.validate() ?? false) {
                      formKey.currentState?.save();
                      deanBloc.add(
                        CreateInterventionRequested(
                          AcademicIntervention(
                            id: DateTime.now().millisecondsSinceEpoch
                                .toString(),
                            studentId: studentId,
                            studentName: studentName,
                            reason: reason,
                            type: type,
                            status: InterventionStatus.pending,
                            startDate: DateTime.now(),
                            assignedTo: const [],
                            outcomes: '',
                          ),
                        ),
                      );
                      Navigator.pop(sheetContext);
                    }
                  },
                  child: const Text('Create Plan'),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
