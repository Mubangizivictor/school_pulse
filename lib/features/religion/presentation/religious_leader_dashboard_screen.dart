import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/notifications/presentation/notification_bell_button.dart';
import 'bloc/religion_bloc.dart';
import 'bloc/religion_event.dart';
import 'bloc/religion_state.dart';
import '../domain/entities/religion_entities.dart';

class ReligiousLeaderDashboardScreen extends StatefulWidget {
  const ReligiousLeaderDashboardScreen({super.key});

  @override
  State<ReligiousLeaderDashboardScreen> createState() =>
      _ReligiousLeaderDashboardScreenState();
}

class _ReligiousLeaderDashboardScreenState
    extends State<ReligiousLeaderDashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ReligionBloc>().add(ReligionDashboardRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Religious & Spiritual Life'),
        actions: [const NotificationBellButton()],
      ),
      body: BlocConsumer<ReligionBloc, ReligionState>(
        listener: (context, state) {
          if (state is ReligionActionSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is ReligionLoading) {
            return const _ReligionSkeleton();
          }

          if (state is ReligionError) {
            return Center(child: Text(state.message));
          }

          if (state is ReligionLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<ReligionBloc>().add(ReligionDashboardRequested());
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 15,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FadeInSlide(
                      child: Text(
                        'Spiritual Oversight',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: FadeInSlide(
                            delay: const Duration(milliseconds: 100),
                            child: DashboardStatCard(
                              title: 'Activities',
                              value: state.activities.length.toDouble(),
                              icon: Icons.event,
                              color: Colors.purple,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FadeInSlide(
                            delay: const Duration(milliseconds: 200),
                            child: DashboardStatCard(
                              title: 'Groups',
                              value: state.groups.length.toDouble(),
                              icon: Icons.group_work,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const SectionHeader(title: 'Upcoming Activities'),
                    const SizedBox(height: 12),
                    ...state.activities.map(
                      (activity) =>
                          FadeInSlide(child: _ActivityCard(activity: activity)),
                    ),
                    const SizedBox(height: 24),
                    const SectionHeader(title: 'Spiritual Groups'),
                    const SizedBox(height: 12),
                    ...state.groups.map(
                      (group) => FadeInSlide(child: _GroupCard(group: group)),
                    ),
                    const SizedBox(height: 32),
                    _QuickActions(),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final ReligionActivity activity;

  const _ActivityCard({required this.activity});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text(
            activity.category[0],
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
        ),
        title: Text(
          activity.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${activity.venue} • ${activity.dateTime.toString().split(' ')[0]}',
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  final SpiritualGroup group;

  const _GroupCard({required this.group});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(
          group.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Leader: ${group.leader}'),
        trailing: Text(
          '${group.memberCount} members',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
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
          label: const Text('Add Activity'),
          style: FilledButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
          ),
        ),
      ],
    );
  }
}

class _ReligionSkeleton extends StatelessWidget {
  const _ReligionSkeleton();

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
        const Skeleton(width: 150, height: 20),
        const SizedBox(height: 12),
        ...List.generate(
          3,
          (index) => const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Skeleton(height: 70, borderRadius: 12),
          ),
        ),
      ],
    );
  }
}
