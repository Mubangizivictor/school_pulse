import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/features/notifications/presentation/notification_bell_button.dart';
import 'bloc/transport_coordinator_bloc.dart';
import 'bloc/transport_coordinator_event.dart';
import 'bloc/transport_coordinator_state.dart';

class TransportCoordinatorDashboardScreen extends StatefulWidget {
  const TransportCoordinatorDashboardScreen({super.key});

  @override
  State<TransportCoordinatorDashboardScreen> createState() => _TransportCoordinatorDashboardScreenState();
}

class _TransportCoordinatorDashboardScreenState extends State<TransportCoordinatorDashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TransportCoordinatorBloc>().add(TransportCoordinatorDashboardRequested());
  }

  @override
  Widget build(BuildContext context) {
    final semanticColors = Theme.of(context).extension<SemanticColors>()!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transport Portal'),
        actions: [
          const NotificationBellButton(),
        ],
      ),
      body: BlocBuilder<TransportCoordinatorBloc, TransportCoordinatorState>(
        builder: (context, state) {
          if (state is TransportCoordinatorLoading) {
            return const _TransportSkeleton();
          }

          if (state is TransportCoordinatorError) {
            return Center(child: Text(state.message));
          }

          if (state is TransportCoordinatorLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<TransportCoordinatorBloc>().add(TransportCoordinatorDashboardRequested());
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  FadeInSlide(
                    child: Text(
                      "Fleet Overview",
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
                          title: 'Active Buses',
                          value: state.activeBuses.toDouble(),
                          icon: Icons.directions_bus,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      FadeInSlide(
                        delay: const Duration(milliseconds: 200),
                        child: DashboardStatCard(
                          title: 'In Transit',
                          value: state.studentsInTransit.toDouble(),
                          icon: Icons.person_pin_circle_outlined,
                          color: semanticColors.info,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const FadeInSlide(
                    delay: Duration(milliseconds: 300),
                    child: SectionHeader(title: 'Active Routes'),
                  ),
                  ...state.routes.asMap().entries.map((entry) {
                    final index = entry.key;
                    final route = entry.value;
                    final isEnRoute = route.status == 'En Route';

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: FadeInSlide(
                        delay: Duration(milliseconds: 400 + (index * 100)),
                        child: AppCard(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isEnRoute 
                                  ? semanticColors.info.withValues(alpha: 0.1)
                                  : semanticColors.success.withValues(alpha: 0.1),
                              child: Icon(
                                Icons.directions_bus_filled_outlined, 
                                color: isEnRoute ? semanticColors.info : semanticColors.success
                              ),
                            ),
                            title: Text(route.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('${route.busNumber} • ${route.driver}'),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${route.studentCount} students',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                StatusBadge(
                                  label: route.status,
                                  color: isEnRoute ? semanticColors.info : semanticColors.success,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 32),
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

class _TransportSkeleton extends StatelessWidget {
  const _TransportSkeleton();

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
          children: List.generate(2, (index) => const Skeleton(borderRadius: 12)),
        ),
        const SizedBox(height: 24),
        const Skeleton(width: 120, height: 20),
        const SizedBox(height: 16),
        ...List.generate(3, (index) => const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Skeleton(height: 80, borderRadius: 12),
        )),
      ],
    );
  }
}
