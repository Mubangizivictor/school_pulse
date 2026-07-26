import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
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
                  const SectionHeader(title: 'Recent Visitors'),
                  const SizedBox(height: 12),
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
                    label: 'New Visitor Entry',
                    onPressed: () => _showNewVisitorDialog(context),
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

  void _showNewVisitorDialog(BuildContext context) {
    final nameController = TextEditingController();
    final purposeController = TextEditingController();
    final contactController = TextEditingController();
    final bloc = context.read<GatekeeperBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('New Visitor Entry'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Full Name')),
            const SizedBox(height: 16),
            TextField(
              controller: contactController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Contact Number'),
            ),
            const SizedBox(height: 16),
            TextField(controller: purposeController, decoration: const InputDecoration(labelText: 'Purpose of Visit')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (nameController.text.trim().isEmpty) return;
              bloc.add(LogVisitorEntry(
                visitorName: nameController.text.trim(),
                purpose: purposeController.text.trim().isEmpty ? 'General visit' : purposeController.text.trim(),
                contact: contactController.text.trim(),
              ));
              Navigator.pop(dialogContext);
            },
            child: const Text('Log Entry'),
          ),
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
