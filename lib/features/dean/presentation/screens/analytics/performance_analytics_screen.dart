import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/components/circular_progress_gauge.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_radius.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_bloc.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_event.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_state.dart';
import 'package:school_pulse/features/dean/presentation/screens/more/academic_reports_screen.dart';
import 'package:school_pulse/injection_container.dart';

/// Academic Performance screen: UNEB Readiness + Reports Readiness as two
/// tabs within this one screen, both driven by the same
/// [PerformanceAnalyticsRequested]/[PerformanceAnalyticsLoaded] event/state
/// pair (reading the `unebReadiness` / `reportsReadiness` keys from
/// `analytics`).
class PerformanceAnalyticsScreen extends StatefulWidget {
  const PerformanceAnalyticsScreen({super.key});

  @override
  State<PerformanceAnalyticsScreen> createState() =>
      _PerformanceAnalyticsScreenState();
}

class _PerformanceAnalyticsScreenState extends State<PerformanceAnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
            ..add(const PerformanceAnalyticsRequested(type: 'school')),
      child: Scaffold(
        backgroundColor: AppColors.background(context),
        appBar: AppBar(
          title: const Text('Academic Performance'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'UNEB Readiness'),
              Tab(text: 'Reports Readiness'),
            ],
          ),
        ),
        body: BlocBuilder<DeanBloc, DeanState>(
          builder: (context, state) {
            if (state is DeanLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is PerformanceAnalyticsLoaded) {
              final uneb = (state.analytics['unebReadiness'] as Map?) ?? {};
              final reports =
                  (state.analytics['reportsReadiness'] as Map?) ?? {};
              return TabBarView(
                controller: _tabController,
                children: [
                  _buildUnebReadiness(context, uneb),
                  _buildReportsReadiness(context, reports),
                ],
              );
            } else if (state is DeanError) {
              return Center(child: Text(state.message));
            }
            return const Center(child: Text('Initializing analytics...'));
          },
        ),
      ),
    );
  }

  Widget _buildUnebReadiness(BuildContext context, Map data) {
    final overall = ((data['overallReadiness'] ?? 0) as num).toDouble();
    final categories = (data['readinessCategories'] as List?) ?? [];
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        AppCard(
          child: Column(
            children: [
              CircularProgressGauge(
                value: overall,
                label: 'UNEB Readiness',
                size: 128,
              ),
              const SizedBox(height: AppSpacing.m),
              _readinessStatusBadge(context, overall),
              const SizedBox(height: AppSpacing.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _SummaryStat(
                    label: 'Mock Exams',
                    value:
                        '${data['mockExamsCompleted'] ?? 0}/${data['mockExamsPlanned'] ?? 0}',
                  ),
                  _SummaryStat(
                    label: 'Candidates',
                    value: '${data['candidatesRegistered'] ?? 0}',
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.x3l),
        const SectionHeader(title: 'Readiness Breakdown'),
        const SizedBox(height: AppSpacing.l),
        ...categories.map((c) {
          final readiness = ((c['readiness'] ?? 0) as num).toDouble();
          return _ReadinessRow(label: c['category'] ?? '', value: readiness);
        }),
        const SizedBox(height: AppSpacing.l),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AcademicReportsScreen()),
            ),
            child: const Text('View Full Readiness Report'),
          ),
        ),
      ],
    );
  }

  Widget _buildReportsReadiness(BuildContext context, Map data) {
    final overall = ((data['overallReadiness'] ?? 0) as num).toDouble();
    final classesReady = data['classesReady'] ?? 0;
    final classesTotal = data['classesTotal'] ?? 0;
    final marksCompletePct = ((data['marksCompletePct'] ?? 0) as num)
        .toDouble();
    final teacherRemarksPct = ((data['teacherRemarksPct'] ?? 0) as num)
        .toDouble();
    final classTeacherRemarksPct =
        ((data['classTeacherRemarksPct'] ?? 0) as num).toDouble();
    final moderationCompletePct = ((data['moderationCompletePct'] ?? 0) as num)
        .toDouble();
    final dosReviewStatus = data['dosReviewStatus'] ?? 'Pending';
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        AppCard(
          child: Column(
            children: [
              CircularProgressGauge(
                value: overall,
                label: 'Reports Readiness',
                size: 128,
              ),
              const SizedBox(height: AppSpacing.m),
              _readinessStatusBadge(context, overall),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.x3l),
        const SectionHeader(title: 'Readiness Breakdown'),
        const SizedBox(height: AppSpacing.l),
        _ReportsReadinessRow(
          label: 'Classes Ready',
          value: '$classesReady/$classesTotal',
        ),
        _ReadinessRow(label: 'Marks Complete', value: marksCompletePct),
        _ReadinessRow(label: 'Teacher Remarks', value: teacherRemarksPct),
        _ReadinessRow(
          label: 'Class Teacher Remarks',
          value: classTeacherRemarksPct,
        ),
        _ReadinessRow(
          label: 'Moderation Complete',
          value: moderationCompletePct,
        ),
        _ReportsReadinessRow(label: 'DOS Review', value: dosReviewStatus),
      ],
    );
  }

  Widget _readinessStatusBadge(BuildContext context, double overall) {
    final _ReadinessStatus status = overall >= 0.85
        ? _ReadinessStatus.good
        : overall >= 0.65
        ? _ReadinessStatus.attentionRequired
        : overall >= 0.4
        ? _ReadinessStatus.atRisk
        : _ReadinessStatus.critical;
    return StatusBadge(label: status.label, color: status.color(context));
  }
}

enum _ReadinessStatus {
  good('Ready'),
  attentionRequired('Attention Required'),
  atRisk('At Risk'),
  critical('Critical');

  final String label;
  const _ReadinessStatus(this.label);

  Color color(BuildContext context) {
    switch (this) {
      case _ReadinessStatus.good:
        return AppColors.success(context);
      case _ReadinessStatus.attentionRequired:
        return AppColors.warning(context);
      case _ReadinessStatus.atRisk:
        return AppColors.warning(context);
      case _ReadinessStatus.critical:
        return AppColors.danger(context);
    }
  }
}

class _SummaryStat extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.titleLarge.copyWith(
            color: AppColors.textPrimary(context),
          ),
        ),
        Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.textMuted(context),
          ),
        ),
      ],
    );
  }
}

class _ReadinessRow extends StatelessWidget {
  final String label;
  final double value;

  const _ReadinessRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final color = value >= 0.8
        ? AppColors.success(context)
        : value >= 0.5
        ? AppColors.warning(context)
        : AppColors.danger(context);
    final status = value >= 0.8
        ? 'On Track'
        : value >= 0.5
        ? 'Attention'
        : 'Critical';
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(label, style: AppTypography.titleSmall)),
              Text(
                '${(value * 100).toStringAsFixed(0)}%',
                style: AppTypography.labelLarge.copyWith(color: color),
              ),
              const SizedBox(width: AppSpacing.m),
              StatusBadge(label: status, color: color),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          LinearProgressIndicator(
            value: value,
            backgroundColor: AppColors.border(context),
            color: color,
            minHeight: 8,
            borderRadius: AppRadius.small,
          ),
        ],
      ),
    );
  }
}

class _ReportsReadinessRow extends StatelessWidget {
  final String label;
  final String value;

  const _ReportsReadinessRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.m),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.titleSmall),
          Text(
            value,
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }
}
