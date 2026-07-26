import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/features/notifications/presentation/notification_bell_button.dart';
import 'bloc/catering_bloc.dart';
import 'bloc/catering_event.dart';
import 'bloc/catering_state.dart';

class CateringDashboardScreen extends StatefulWidget {
  const CateringDashboardScreen({super.key});

  @override
  State<CateringDashboardScreen> createState() => _CateringDashboardScreenState();
}

class _CateringDashboardScreenState extends State<CateringDashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CateringBloc>().add(CateringDashboardRequested());
  }

  @override
  Widget build(BuildContext context) {
    final semanticColors = Theme.of(context).extension<SemanticColors>()!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catering Portal'),
        actions: [
          const NotificationBellButton(),
        ],
      ),
      body: BlocBuilder<CateringBloc, CateringState>(
        builder: (context, state) {
          if (state is CateringLoading) {
            return const _CateringSkeleton();
          }

          if (state is CateringError) {
            return Center(child: Text(state.message));
          }

          if (state is CateringLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<CateringBloc>().add(CateringDashboardRequested());
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  FadeInSlide(
                    child: Text(
                      "Today's Menu",
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
                          title: 'Students Fed',
                          value: state.totalStudents.toDouble(),
                          icon: Icons.people_outline,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      FadeInSlide(
                        delay: const Duration(milliseconds: 200),
                        child: DashboardStatCard(
                          title: 'Special Diets',
                          value: state.specialDiets.toDouble(),
                          icon: Icons.restaurant_menu,
                          color: semanticColors.warning,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const FadeInSlide(
                    delay: Duration(milliseconds: 300),
                    child: SectionHeader(title: 'Meal Schedule'),
                  ),
                  ...state.todayMeals.asMap().entries.map((entry) {
                    final index = entry.key;
                    final meal = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: FadeInSlide(
                        delay: Duration(milliseconds: 400 + (index * 100)),
                        child: AppCard(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                              child: Icon(Icons.lunch_dining, color: Theme.of(context).colorScheme.primary),
                            ),
                            title: Text(meal.mealType, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(meal.menu),
                            trailing: Text(meal.time, style: Theme.of(context).textTheme.bodySmall),
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 24),
                  const FadeInSlide(
                    delay: Duration(milliseconds: 700),
                    child: SectionHeader(title: 'Inventory Status'),
                  ),
                  FadeInSlide(
                    delay: const Duration(milliseconds: 800),
                    child: ProgressCard(
                      title: 'Dry Stores Level',
                      progress: state.stockLevel,
                      subtitle: '${(state.stockLevel * 100).round()}% Remaining',
                      color: state.stockLevel < 0.3 ? semanticColors.error : null,
                    ),
                  ),
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

class _CateringSkeleton extends StatelessWidget {
  const _CateringSkeleton();

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
          child: Skeleton(height: 72, borderRadius: 12),
        )),
        const SizedBox(height: 24),
        const Skeleton(width: 120, height: 20),
        const SizedBox(height: 16),
        const Skeleton(height: 100, borderRadius: 12),
      ],
    );
  }
}
