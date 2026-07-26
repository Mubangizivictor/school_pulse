import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/features/notifications/presentation/notification_bell_button.dart';
import 'bloc/games_bloc.dart';
import 'bloc/games_event.dart';
import 'bloc/games_state.dart';

class GamesDashboardScreen extends StatefulWidget {
  const GamesDashboardScreen({super.key});

  @override
  State<GamesDashboardScreen> createState() => _GamesDashboardScreenState();
}

class _GamesDashboardScreenState extends State<GamesDashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<GamesBloc>().add(GamesDashboardRequested());
  }

  @override
  Widget build(BuildContext context) {
    final semanticColors = Theme.of(context).extension<SemanticColors>()!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Games Portal'),
        actions: [
          const NotificationBellButton(),
        ],
      ),
      body: BlocBuilder<GamesBloc, GamesState>(
        builder: (context, state) {
          if (state is GamesLoading) {
            return const _GamesSkeleton();
          }

          if (state is GamesError) {
            return Center(child: Text(state.message));
          }

          if (state is GamesLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<GamesBloc>().add(GamesDashboardRequested());
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  FadeInSlide(
                    child: Text(
                      'Sports & Activities',
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
                          title: 'Active Teams',
                          value: state.activeTeams.toDouble(),
                          icon: Icons.groups_outlined,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      FadeInSlide(
                        delay: const Duration(milliseconds: 200),
                        child: DashboardStatCard(
                          title: 'Equipment Items',
                          value: state.totalEquipment.toDouble(),
                          icon: Icons.sports_tennis,
                          color: semanticColors.info,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  FadeInSlide(
                    delay: const Duration(milliseconds: 300),
                    child: AlertBanner(
                      title: 'Next Major Event',
                      message: state.nextEvent,
                      color: semanticColors.success,
                      icon: Icons.event,
                    ),
                  ),
                  const FadeInSlide(
                    delay: Duration(milliseconds: 400),
                    child: SectionHeader(title: 'Upcoming Fixtures'),
                  ),
                  ...state.upcomingFixtures.asMap().entries.map((entry) {
                    final index = entry.key;
                    final fixture = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: FadeInSlide(
                        delay: Duration(milliseconds: 500 + (index * 100)),
                        child: AppCard(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                              child: Icon(Icons.sports_soccer, color: Theme.of(context).colorScheme.secondary),
                            ),
                            title: Text('${fixture.sport} vs ${fixture.opponent}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(fixture.venue),
                            trailing: Text(fixture.date, style: Theme.of(context).textTheme.bodySmall),
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

class _GamesSkeleton extends StatelessWidget {
  const _GamesSkeleton();

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
        const Skeleton(height: 60, borderRadius: 12),
        const SizedBox(height: 24),
        const Skeleton(width: 120, height: 20),
        const SizedBox(height: 16),
        ...List.generate(2, (index) => const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Skeleton(height: 72, borderRadius: 12),
        )),
      ],
    );
  }
}
