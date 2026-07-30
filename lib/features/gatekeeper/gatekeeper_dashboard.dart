import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/features/gatekeeper/presentation/bloc/gatekeeper_bloc.dart';
import 'package:school_pulse/features/notifications/presentation/notification_bell_button.dart';
import 'package:school_pulse/features/gatekeeper/presentation/bloc/gatekeeper_event.dart';
import 'package:school_pulse/features/gatekeeper/presentation/bloc/gatekeeper_state.dart';

class GatekeeperDashboardScreen extends StatefulWidget {
  const GatekeeperDashboardScreen({super.key});

  @override
  State<GatekeeperDashboardScreen> createState() => _GatekeeperDashboardScreenState();
}

class _GatekeeperDashboardScreenState extends State<GatekeeperDashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<GatekeeperBloc>().add(GatekeeperDashboardRequested());
  }

  @override
  Widget build(BuildContext context) {
    final semanticColors = Theme.of(context).extension<SemanticColors>()!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gatekeeper Portal'),
        actions: [
          const NotificationBellButton(),
        ],
      ),
      body: BlocBuilder<GatekeeperBloc, GatekeeperState>(
        builder: (context, state) {
          if (state is GatekeeperLoading) {
            return const _GatekeeperSkeleton();
          }

          if (state is GatekeeperError) {
            return Center(child: Text(state.message));
          }

          if (state is GatekeeperLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<GatekeeperBloc>().add(GatekeeperDashboardRequested());
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  FadeInSlide(
                    child: Text(
                      'Security Overview',
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
                          title: 'Students In',
                          value: state.studentsIn.toDouble(),
                          icon: Icons.school_outlined,
                          color: semanticColors.success,
                        ),
                      ),
                      FadeInSlide(
                        delay: const Duration(milliseconds: 200),
                        child: DashboardStatCard(
                          title: 'Students Out',
                          value: state.studentsOut.toDouble(),
                          icon: Icons.exit_to_app,
                          color: semanticColors.warning,
                        ),
                      ),
                      FadeInSlide(
                        delay: const Duration(milliseconds: 300),
                        child: DashboardStatCard(
                          title: 'Active Visitors',
                          value: state.activeVisitors.toDouble(),
                          icon: Icons.person_pin_outlined,
                          color: semanticColors.info,
                        ),
                      ),
                      FadeInSlide(
                        delay: const Duration(milliseconds: 400),
                        child: DashboardStatCard(
                          title: 'Security Alerts',
                          value: 0,
                          icon: Icons.gpp_maybe_outlined,
                          color: semanticColors.error,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const SectionHeader(title: 'Quick Actions'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _ActionTile(
                          icon: Icons.directions_car_outlined,
                          label: 'Vehicle Log',
                          color: Colors.blue,
                          onTap: () => _showVehicleLogDialog(context),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ActionTile(
                          icon: Icons.logout,
                          label: 'Check-out All',
                          color: Colors.red,
                          onTap: () {},
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const SectionHeader(title: 'Recent Visitors'),
                  const SizedBox(height: 12),
                  if (state.recentVisitors.isEmpty)
                    EmptyState(
                      icon: Icons.person_off_outlined,
                      title: 'No visitors yet',
                      message: 'New visitors will appear here once they are checked in.',
                      ctaLabel: 'Visit Log',
                      onCtaPressed: () => context.push('/staff/gatekeeper/visitors'),
                    ),
                  ...state.recentVisitors.map((visitor) => FadeInSlide(
                        child: AppCard(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                child: const Icon(Icons.person),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(visitor.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    Text(visitor.purpose, style: Theme.of(context).textTheme.bodySmall),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    DateFormat('HH:mm').format(visitor.entryTime),
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    visitor.status,
                                    style: TextStyle(color: semanticColors.success, fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: 'Visitor Management',
                    icon: Icons.people_outline,
                    onPressed: () => context.push('/staff/gatekeeper/visitors'),
                  ),
                  const SizedBox(height: 12),
                  SecondaryButton(
                    label: 'New Visitor Entry',
                    icon: Icons.add,
                    onPressed: () => context.push('/staff/gatekeeper/visitors/new'),
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


  void _showVehicleLogDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Vehicle Log'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(decoration: const InputDecoration(labelText: 'Plate Number')),
            const SizedBox(height: 16),
            TextField(decoration: const InputDecoration(labelText: 'Driver Name')),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              items: const [
                DropdownMenuItem(value: 'In', child: Text('Entry')),
                DropdownMenuItem(value: 'Out', child: Text('Exit')),
              ],
              onChanged: (_) {},
              decoration: const InputDecoration(labelText: 'Direction'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Log Vehicle')),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}

class _GatekeeperSkeleton extends StatelessWidget {
  const _GatekeeperSkeleton();

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
              child: Skeleton(height: 80, borderRadius: 12),
            )),
      ],
    );
  }
}
