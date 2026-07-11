import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'bloc/security_bloc.dart';
import 'bloc/security_event.dart';
import 'bloc/security_state.dart';

class SecurityDashboardScreen extends StatefulWidget {
  const SecurityDashboardScreen({super.key});

  @override
  State<SecurityDashboardScreen> createState() => _SecurityDashboardScreenState();
}

class _SecurityDashboardScreenState extends State<SecurityDashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SecurityBloc>().add(SecurityDashboardRequested());
  }

  @override
  Widget build(BuildContext context) {
    final semanticColors = Theme.of(context).extension<SemanticColors>()!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Security Portal'),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_none), onPressed: () {}),
        ],
      ),
      body: BlocBuilder<SecurityBloc, SecurityState>(
        builder: (context, state) {
          if (state is SecurityLoading) {
            return const _SecuritySkeleton();
          }

          if (state is SecurityError) {
            return Center(child: Text(state.message));
          }

          if (state is SecurityLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<SecurityBloc>().add(SecurityDashboardRequested());
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  FadeInSlide(
                    child: Text(
                      "Security Status",
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
                          title: 'Guards on Duty',
                          value: state.guardsOnDuty.toDouble(),
                          icon: Icons.security,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      FadeInSlide(
                        delay: const Duration(milliseconds: 200),
                        child: DashboardStatCard(
                          title: 'Active Visitors',
                          value: state.visitorsIn.toDouble(),
                          icon: Icons.person_pin_circle_outlined,
                          color: semanticColors.success,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const FadeInSlide(
                    delay: Duration(milliseconds: 300),
                    child: SectionHeader(title: 'Recent Activity'),
                  ),
                  ...state.recentAlerts.asMap().entries.map((entry) {
                    final index = entry.key;
                    final alert = entry.value;
                    Color alertColor = semanticColors.info;
                    if (alert.severity == 'medium') alertColor = semanticColors.warning;
                    if (alert.severity == 'high') alertColor = semanticColors.error;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: FadeInSlide(
                        delay: Duration(milliseconds: 400 + (index * 100)),
                        child: AppCard(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: alertColor.withValues(alpha: 0.1),
                              child: Icon(Icons.notifications_outlined, color: alertColor),
                            ),
                            title: Text(alert.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(alert.time),
                            trailing: const Icon(Icons.chevron_right),
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

class _SecuritySkeleton extends StatelessWidget {
  const _SecuritySkeleton();

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
      ],
    );
  }
}
