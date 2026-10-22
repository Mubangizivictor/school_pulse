import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/director/presentation/bloc/director_bloc.dart';
import 'package:school_pulse/features/director/presentation/bloc/director_event.dart';
import 'package:school_pulse/features/director/presentation/bloc/director_state.dart';
import 'package:school_pulse/features/director/presentation/widgets/director_drawer.dart';

/// "Parent Engagement" screen from the reference: a list of engagement
/// metric rows (active parents, portal usage, messages, appointments,
/// complaints).
///
/// [DirectorDashboardStats] only exposes [parentPortalUsageRate] - the rest
/// of the reference's rows (active parent count, messages sent/opened,
/// appointments, response rate, complaints) have no backing data source yet,
/// so this screen shows the one real metric and an honest empty state for
/// the rest rather than inventing numbers.
class ParentEngagementScreen extends StatelessWidget {
  const ParentEngagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<DirectorBloc>().add(DirectorDashboardRequested());
    return Scaffold(
      drawer: const DirectorDrawer(),
      appBar: AppBar(title: const Text('Parent Engagement')),
      body: BlocBuilder<DirectorBloc, DirectorState>(
        builder: (context, state) {
          if (state is! DirectorDashboardLoaded) {
            return const Center(child: CircularProgressIndicator());
          }
          final stats = state.stats;

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.l,
              AppSpacing.xl,
              AppSpacing.x3l,
            ),
            children: [
              AppCard(
                child: Column(
                  children: [
                    _EngagementRow(
                      icon: Icons.family_restroom,
                      color: Colors.black,
                      label: 'Portal Usage',
                      value: '${stats.parentPortalUsageRate}%',
                    ),
                    const Divider(),
                    // TODO: Wire Active Parents, Messages Sent/Opened,
                    // Appointments, Response Rate and Complaints once the
                    // director module exposes parent-engagement data beyond
                    // the dashboard's aggregate portal-usage rate.
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'Active parents, messages sent/opened, appointments, '
                        'response rate and complaints are not tracked yet.',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _EngagementRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label, value;
  const _EngagementRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Icon(icon, color: color),
    title: Text(label),
    trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
  );
}
