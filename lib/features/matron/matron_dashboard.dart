import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/features/matron/presentation/bloc/matron_bloc.dart';
import 'package:school_pulse/features/matron/presentation/bloc/matron_event.dart';
import 'package:school_pulse/features/matron/presentation/bloc/matron_state.dart';

class MatronDashboardScreen extends StatefulWidget {
  const MatronDashboardScreen({super.key});

  @override
  State<MatronDashboardScreen> createState() => _MatronDashboardScreenState();
}

class _MatronDashboardScreenState extends State<MatronDashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<MatronBloc>().add(MatronDashboardRequested());
  }

  @override
  Widget build(BuildContext context) {
    final semanticColors = Theme.of(context).extension<SemanticColors>()!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Matron Portal'),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_none), onPressed: () {}),
        ],
      ),
      body: BlocBuilder<MatronBloc, MatronState>(
        builder: (context, state) {
          if (state is MatronLoading) {
            return const _MatronSkeleton();
          }

          if (state is MatronError) {
            return Center(child: Text(state.message));
          }

          if (state is MatronLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<MatronBloc>().add(MatronDashboardRequested());
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  FadeInSlide(
                    child: Text(
                      'Boarding Overview',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 24),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.1,
                    children: [
                      FadeInSlide(
                        delay: const Duration(milliseconds: 100),
                        child: DashboardStatCard(
                          title: 'Total Boarders',
                          value: state.totalStudents.toDouble(),
                          icon: Icons.hotel_outlined,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      FadeInSlide(
                        delay: const Duration(milliseconds: 200),
                        child: DashboardStatCard(
                          title: 'Present',
                          value: state.studentsPresent.toDouble(),
                          icon: Icons.check_circle_outline,
                          color: semanticColors.success,
                        ),
                      ),
                      FadeInSlide(
                        delay: const Duration(milliseconds: 300),
                        child: DashboardStatCard(
                          title: 'On Leave',
                          value: state.studentsOnLeave.toDouble(),
                          icon: Icons.time_to_leave_outlined,
                          color: semanticColors.warning,
                        ),
                      ),
                      FadeInSlide(
                        delay: const Duration(milliseconds: 400),
                        child: DashboardStatCard(
                          title: 'Sick Bay',
                          value: 2,
                          icon: Icons.medical_services_outlined,
                          color: semanticColors.error,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const SectionHeader(title: 'Dormitories'),
                  const SizedBox(height: 12),
                  ...state.dormitories.map((dorm) => FadeInSlide(
                        child: AppCard(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(dorm.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  StatusBadge(
                                    label: dorm.status,
                                    color: dorm.status == 'Normal' ? semanticColors.success : semanticColors.error,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: dorm.currentOccupants / dorm.capacity,
                                  minHeight: 8,
                                  backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                                  valueColor: AlwaysStoppedAnimation(
                                    dorm.currentOccupants > dorm.capacity ? semanticColors.error : Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${dorm.currentOccupants} / ${dorm.capacity} Occupants',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      )),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: 'Night Roll Call',
                    onPressed: () {},
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _MatronSkeleton extends StatelessWidget {
  const _MatronSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Skeleton(width: 200, height: 28),
        const SizedBox(height: 24),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.1,
          children: List.generate(4, (index) => const Skeleton(borderRadius: 12)),
        ),
        const SizedBox(height: 24),
        const Skeleton(width: 150, height: 20),
        const SizedBox(height: 12),
        ...List.generate(3, (index) => const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Skeleton(height: 100, borderRadius: 12),
            )),
      ],
    );
  }
}
