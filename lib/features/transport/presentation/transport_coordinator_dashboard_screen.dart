import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/shared/staff_dashboard/staff_dashboard_widgets.dart';
import 'bloc/transport_coordinator_bloc.dart';
import 'bloc/transport_coordinator_event.dart';
import 'bloc/transport_coordinator_state.dart';

class TransportCoordinatorDashboardScreen extends StatefulWidget {
  const TransportCoordinatorDashboardScreen({super.key});

  @override
  State<TransportCoordinatorDashboardScreen> createState() =>
      _TransportCoordinatorDashboardScreenState();
}

class _TransportCoordinatorDashboardScreenState
    extends State<TransportCoordinatorDashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TransportCoordinatorBloc>().add(
      TransportCoordinatorDashboardRequested(),
    );
  }

  void _showRouteActions(BuildContext context, BusRoute route) {
    showModalBottomSheet(
      context: context,
      builder: (bottomSheetContext) => BlocProvider.value(
        value: context.read<TransportCoordinatorBloc>(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Route: ${route.name}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              if (route.status != 'In Transit')
                ListTile(
                  leading: const Icon(Icons.play_arrow, color: Colors.green),
                  title: const Text('Start Trip'),
                  onTap: () {
                    context.read<TransportCoordinatorBloc>().add(
                      StartTripRequested(route.id),
                    );
                    Navigator.pop(bottomSheetContext);
                  },
                )
              else
                ListTile(
                  leading: const Icon(Icons.stop, color: Colors.red),
                  title: const Text('End Trip'),
                  onTap: () {
                    context.read<TransportCoordinatorBloc>().add(
                      EndTripRequested(route.id),
                    );
                    Navigator.pop(bottomSheetContext);
                  },
                ),
              ListTile(
                leading: const Icon(Icons.qr_code_scanner),
                title: const Text('Log Student Pickup'),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  _simulateStudentPickup(context, route.id);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _simulateStudentPickup(BuildContext context, String routeId) {
    context.read<TransportCoordinatorBloc>().add(
      LogStudentPickupRequested(routeId: routeId, studentId: 'STUDENT_123'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final semanticColors = Theme.of(context).extension<SemanticColors>()!;

    return Scaffold(
      appBar: staffDashboardAppBar(context, roleLabel: 'Transport'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/staff/transport/lookup'),
        icon: const Icon(Icons.search),
        label: const Text('Route Lookup'),
      ),
      body: BlocListener<TransportCoordinatorBloc, TransportCoordinatorState>(
        listener: (context, state) {
          if (state is TripActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: semanticColors.success,
              ),
            );
          }
        },
        child: BlocBuilder<TransportCoordinatorBloc, TransportCoordinatorState>(
          builder: (context, state) {
            if (state is TransportCoordinatorLoading) {
              return const _TransportSkeleton();
            }

            if (state is TransportCoordinatorError) {
              return Center(child: Text(state.message));
            }

            if (state is TransportCoordinatorLoaded) {
              return _buildDashboard(context, state, semanticColors);
            }

            return const _TransportSkeleton();
          },
        ),
      ),
    );
  }

  Widget _buildDashboard(
    BuildContext context,
    TransportCoordinatorLoaded state,
    SemanticColors semanticColors,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<TransportCoordinatorBloc>().add(
          TransportCoordinatorDashboardRequested(),
        );
      },
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
        children: [
          FadeInSlide(
            child: StaffHeroSummaryCard(
              greetingNameFallback: 'there',
              kpis: [
                StaffKpiData(
                  title: 'Active Buses',
                  valueText: '${state.activeBuses}',
                  subtitle: 'On the road',
                  icon: Icons.directions_bus,
                  color: AppColors.information(context),
                ),
                StaffKpiData(
                  title: 'Students In Transit',
                  valueText: '${state.studentsInTransit}',
                  subtitle: 'Right now',
                  icon: Icons.person_pin_circle_outlined,
                  color: AppColors.success(context),
                ),
                StaffKpiData(
                  title: 'Routes',
                  valueText: '${state.routes.length}',
                  subtitle: 'Total',
                  icon: Icons.alt_route_rounded,
                  color: AppColors.warning(context),
                ),
                StaffKpiData(
                  title: 'En Route',
                  valueText:
                      '${state.routes.where((r) => r.status == 'In Transit').length}',
                  subtitle: 'Active now',
                  icon: Icons.directions_bus_filled_outlined,
                  color: AppColors.danger(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const FadeInSlide(
            delay: Duration(milliseconds: 300),
            child: SectionHeader(title: 'Active Routes'),
          ),
          const SizedBox(height: 12),
          ...state.routes.asMap().entries.map((entry) {
            final index = entry.key;
            final route = entry.value;
            final isEnRoute = route.status == 'In Transit';

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
                        color: isEnRoute
                            ? semanticColors.info
                            : semanticColors.success,
                      ),
                    ),
                    title: Text(
                      route.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('${route.busNumber} • ${route.driver}'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${route.studentCount} students',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        StatusBadge(
                          label: route.status,
                          color: isEnRoute
                              ? semanticColors.info
                              : semanticColors.success,
                        ),
                      ],
                    ),
                    onTap: () => _showRouteActions(context, route),
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
}

class _TransportSkeleton extends StatelessWidget {
  const _TransportSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
      children: [
        const Skeleton(width: 200, height: 28),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(child: const Skeleton(height: 48, borderRadius: 12)),
            const SizedBox(width: 12),
            Expanded(child: const Skeleton(height: 48, borderRadius: 12)),
          ],
        ),
        const SizedBox(height: 24),
        const Skeleton(width: 120, height: 20),
        const SizedBox(height: 12),
        ...List.generate(
          3,
          (index) => const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Skeleton(height: 80, borderRadius: 12),
          ),
        ),
      ],
    );
  }
}
