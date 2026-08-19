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
    final subjects = (data['subjectBreakdown'] as List?) ?? [];
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
        const SectionHeader(title: 'Subject Readiness'),
        const SizedBox(height: AppSpacing.l),
        ...subjects.map((s) {
          final readiness = ((s['readiness'] ?? 0) as num).toDouble();
          final projection = ((s['passRateProjection'] ?? 0) as num).toDouble();
          return _ReadinessRow(
            title: s['subject'] ?? '',
            subtitle:
                'Projected pass rate: ${(projection * 100).toStringAsFixed(0)}%',
            value: readiness,
          );
        }),
      ],
    );
  }

  Widget _buildReportsReadiness(BuildContext context, Map data) {
    final overall = ((data['overallReadiness'] ?? 0) as num).toDouble();
    final classes = (data['classBreakdown'] as List?) ?? [];
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
              const SizedBox(height: AppSpacing.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _SummaryStat(
                    label: 'Published',
                    value: '${data['reportCardsPublished'] ?? 0}',
                  ),
                  _SummaryStat(
                    label: 'Pending Approval',
                    value: '${data['reportCardsPendingApproval'] ?? 0}',
                  ),
                  _SummaryStat(
                    label: 'Marks Entered',
                    value:
                        '${(((data['marksFullyEntered'] ?? 0) as num) * 100).toStringAsFixed(0)}%',
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.x3l),
        const SectionHeader(title: 'Class Readiness'),
        const SizedBox(height: AppSpacing.l),
        ...classes.map((c) {
          final readiness = ((c['readiness'] ?? 0) as num).toDouble();
          return _ReadinessRow(
            title: c['className'] ?? '',
            subtitle: null,
            value: readiness,
          );
        }),
      ],
    );
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
  final String title;
  final String? subtitle;
  final double value;

  const _ReadinessRow({
    required this.title,
    this.subtitle,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final color = value >= 0.8
        ? AppColors.success(context)
        : value >= 0.5
        ? AppColors.warning(context)
        : AppColors.danger(context);
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppTypography.titleSmall),
              Text(
                '${(value * 100).toStringAsFixed(0)}%',
                style: AppTypography.labelLarge.copyWith(color: color),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtitle!,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textMuted(context),
              ),
            ),
          ],
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
