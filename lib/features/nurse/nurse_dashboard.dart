import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/core/utils.dart';
import 'package:school_pulse/injection_container.dart' as di;
import 'package:school_pulse/features/student/domain/entities/student.dart';
import 'package:school_pulse/features/student/domain/usecases/get_all_students.dart';
import 'package:school_pulse/features/health/presentation/bloc/health_bloc.dart';
import 'package:school_pulse/features/health/presentation/bloc/health_state.dart';

class NurseDashboardScreen extends StatelessWidget {
  const NurseDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final semanticColors = Theme.of(context).extension<SemanticColors>()!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sick Bay Portal'),
        actions: [
          IconButton(icon: const Icon(Icons.add_box_outlined), onPressed: () {}),
        ],
      ),
      body: FutureBuilder<List<Student>>(
        future: di.sl<GetAllStudents>()().then((r) => r.getOrElse(() => const [])),
        builder: (context, studentsSnapshot) {
          final studentsById = {for (final s in studentsSnapshot.data ?? const <Student>[]) s.id: s};
          return BlocBuilder<HealthBloc, HealthState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildHealthStats(context, semanticColors, state),
              const SizedBox(height: 24),
              const SectionHeader(title: 'Quick Actions'),
              QuickActionGrid(
                items: [
                  QuickActionItem(
                    label: 'New Visit',
                    icon: Icons.add_moderator,
                    color: semanticColors.error,
                    onTap: () {},
                  ),
                  QuickActionItem(
                    label: 'Inventory',
                    icon: Icons.medication_liquid,
                    color: semanticColors.info,
                    onTap: () {},
                  ),
                  QuickActionItem(
                    label: 'Health Log',
                    icon: Icons.history_edu,
                    color: semanticColors.success,
                    onTap: () {},
                  ),
                  QuickActionItem(
                    label: 'Allergies',
                    icon: Icons.warning_amber,
                    color: semanticColors.warning,
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const SectionHeader(title: 'Recent Visits'),
              if (state is HealthLoading)
                ...List.generate(3, (index) => const _VisitSkeleton())
              else if (state is HealthLoaded)
                ...state.visits.map((visit) {
                  final studentName = studentsById[visit.studentId]?.name ?? 'Unknown Student';
                  return AppCard(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            AvatarInitials(name: studentName, size: 32),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(studentName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Text(
                                    DateFormatter.relative(visit.date),
                                    style: Theme.of(context).textTheme.labelSmall,
                                  ),
                                ],
                              ),
                            ),
                            StatusBadge(label: 'Treated', color: semanticColors.success),
                          ],
                        ),
                        const Divider(height: 24),
                        _VisitDetail(label: 'Reason', value: visit.reason),
                        const SizedBox(height: 8),
                        _VisitDetail(label: 'Treatment', value: visit.treatment),
                        const SizedBox(height: 8),
                        _VisitDetail(label: 'Medication', value: visit.medication),
                      ],
                    ),
                  );
                })
              else if (state is HealthError)
                Center(child: Text(state.message))
              else
                const Center(child: Text('Start by fetching health visits')),
              const SizedBox(height: 16),
              const SectionHeader(title: 'Medical Alerts'),
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: semanticColors.error),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        '3 Students with known allergies in P.4 today.',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    TextButton(onPressed: () {}, child: const Text('View')),
                  ],
                ),
              ),
            ],
          );
            },
          );
        },
      ),
    );
  }

  Widget _buildHealthStats(BuildContext context, SemanticColors colors, HealthState state) {
    if (state is HealthLoading) {
      return const Row(
        children: [
          Expanded(child: Skeleton(height: 100)),
          SizedBox(width: 12),
          Expanded(child: Skeleton(height: 100)),
        ],
      );
    }
    return Row(
      children: [
        Expanded(
          child: DashboardStatCard(
            title: 'Visits Today',
            value: 8,
            icon: Icons.medical_services_outlined,
            color: colors.info,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DashboardStatCard(
            title: 'Resting',
            value: 2,
            icon: Icons.bed_outlined,
            color: colors.warning,
          ),
        ),
      ],
    );
  }
}

class _VisitSkeleton extends StatelessWidget {
  const _VisitSkeleton();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Skeleton(height: 32, width: 32, borderRadius: 16),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Skeleton(height: 14, width: 120),
                    const SizedBox(height: 4),
                    const Skeleton(height: 10, width: 80),
                  ],
                ),
              ),
              const Skeleton(height: 24, width: 60, borderRadius: 12),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              const Skeleton(height: 12, width: 60),
              const SizedBox(width: 20),
              const Expanded(child: Skeleton(height: 12)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Skeleton(height: 12, width: 60),
              const SizedBox(width: 20),
              const Expanded(child: Skeleton(height: 12)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Skeleton(height: 12, width: 60),
              const SizedBox(width: 20),
              const Expanded(child: Skeleton(height: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

class _VisitDetail extends StatelessWidget {
  final String label;
  final String value;

  const _VisitDetail({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
