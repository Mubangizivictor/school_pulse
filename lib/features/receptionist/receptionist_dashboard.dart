import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/features/receptionist/presentation/bloc/receptionist_bloc.dart';
import 'package:school_pulse/features/receptionist/presentation/bloc/receptionist_event.dart';
import 'package:school_pulse/features/receptionist/presentation/bloc/receptionist_state.dart';

class ReceptionistDashboardScreen extends StatefulWidget {
  const ReceptionistDashboardScreen({super.key});

  @override
  State<ReceptionistDashboardScreen> createState() => _ReceptionistDashboardScreenState();
}

class _ReceptionistDashboardScreenState extends State<ReceptionistDashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ReceptionistBloc>().add(ReceptionistDashboardRequested());
  }

  @override
  Widget build(BuildContext context) {
    final semanticColors = Theme.of(context).extension<SemanticColors>()!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Receptionist Portal'),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_none), onPressed: () {}),
        ],
      ),
      body: BlocBuilder<ReceptionistBloc, ReceptionistState>(
        builder: (context, state) {
          if (state is ReceptionistLoading) {
            return const _ReceptionistSkeleton();
          }

          if (state is ReceptionistError) {
            return Center(child: Text(state.message));
          }

          if (state is ReceptionistLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<ReceptionistBloc>().add(ReceptionistDashboardRequested());
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  FadeInSlide(
                    child: Text(
                      'Front Desk Overview',
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
                          title: 'Upcoming',
                          value: state.upcomingAppointments.toDouble(),
                          icon: Icons.calendar_today_outlined,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      FadeInSlide(
                        delay: const Duration(milliseconds: 200),
                        child: DashboardStatCard(
                          title: 'Visitors Today',
                          value: state.totalVisitorsToday.toDouble(),
                          icon: Icons.people_outline,
                          color: semanticColors.info,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const SectionHeader(title: 'Upcoming Appointments'),
                  const SizedBox(height: 12),
                  ...state.appointments.map((appt) => FadeInSlide(
                        child: AppCard(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                                child: const Icon(Icons.event),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(appt.visitorName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    Text(appt.purpose, style: Theme.of(context).textTheme.bodySmall),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    DateFormat('HH:mm').format(appt.time),
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    appt.status,
                                    style: TextStyle(color: semanticColors.warning, fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _QuickAction(
                        label: 'Schedule Meeting',
                        icon: Icons.add_task,
                        color: semanticColors.info,
                        onTap: () {},
                      ),
                      _QuickAction(
                        label: 'Inquiry Log',
                        icon: Icons.description_outlined,
                        color: semanticColors.success,
                        onTap: () {},
                      ),
                    ],
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

class _QuickAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: (MediaQuery.of(context).size.width - 44) / 2,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReceptionistSkeleton extends StatelessWidget {
  const _ReceptionistSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Skeleton(width: 200, height: 28),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(child: const Skeleton(height: 100, borderRadius: 12)),
            const SizedBox(width: 12),
            Expanded(child: const Skeleton(height: 100, borderRadius: 12)),
          ],
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
