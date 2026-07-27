// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/features/notifications/presentation/notification_bell_button.dart';
import '../bloc/games_bloc.dart';
import '../bloc/games_event.dart';
import '../bloc/games_state.dart';
import '../../domain/entities/games_entities.dart';

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
        title: const Text('Games & Sports'),
        actions: [
          const NotificationBellButton(),
        ],
      ),
      body: BlocConsumer<GamesBloc, GamesState>(
        listener: (context, state) {
          if (state is ActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
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
                      'Inter-House Standings',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _HousePointsGrid(houses: state.houses),
                  const SizedBox(height: 24),
                  const SectionHeader(title: 'Upcoming Competitions'),
                  const SizedBox(height: 12),
                  ...state.competitions.map((comp) => _CompetitionCard(competition: comp)),
                  const SizedBox(height: 24),
                  _QuickActions(),
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

class _HousePointsGrid extends StatelessWidget {
  final List<SportsHouse> houses;

  const _HousePointsGrid({required this.houses});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.3,
      ),
      itemCount: houses.length,
      itemBuilder: (context, index) {
        final house = houses[index];
        return AppCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _parseColor(house.color),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(height: 8),
              Text(house.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(
                '${house.totalPoints} pts',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _parseColor(String colorStr) {
    try {
      return Color(int.parse(colorStr.replaceFirst('#', '0xFF')));
    } catch (_) {
      return Colors.grey;
    }
  }
}

class _CompetitionCard extends StatelessWidget {
  final SportsCompetition competition;

  const _CompetitionCard({required this.competition});

  @override
  Widget build(BuildContext context) {
    final semanticColors = Theme.of(context).extension<SemanticColors>()!;
    
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.emoji_events_outlined)),
        title: Text(competition.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${competition.venue} • ${competition.date.toString().split(' ')[0]}'),
        trailing: StatusBadge(
          label: competition.status,
          color: competition.status == 'Ongoing' ? semanticColors.info : semanticColors.success,
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FilledButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add),
          label: const Text('New Competition'),
          style: FilledButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.edit),
          label: const Text('Update Scores'),
          style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
        ),
      ],
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
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.3,
          children: List.generate(4, (index) => const Skeleton(borderRadius: 12)),
        ),
        const SizedBox(height: 24),
        const Skeleton(width: 150, height: 20),
        const SizedBox(height: 12),
        ...List.generate(3, (index) => const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Skeleton(height: 80, borderRadius: 12),
        )),
      ],
    );
  }
}
