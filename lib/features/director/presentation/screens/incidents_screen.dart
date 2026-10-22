import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/director/presentation/widgets/director_drawer.dart';

/// "Incidents" screen from the reference: All / Open / Resolved segmented
/// tabs over a list of incident cards.
///
/// TODO: No incident-tracking repository exists yet for the Director module
/// (security incidents, discipline cases, health emergencies, etc. each live
/// in their own modules with no unified feed). This screen is a visual shell
/// only - wire it to a real aggregated incidents source before shipping.
class IncidentsScreen extends StatefulWidget {
  const IncidentsScreen({super.key});

  @override
  State<IncidentsScreen> createState() => _IncidentsScreenState();
}

class _IncidentsScreenState extends State<IncidentsScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const DirectorDrawer(),
      appBar: AppBar(title: const Text('Incidents')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.l,
          AppSpacing.xl,
          AppSpacing.x3l,
        ),
        child: Column(
          children: [
            SegmentedTabControl(
              labels: const ['All', 'Open', 'Resolved'],
              selectedIndex: _tab,
              onChanged: (i) => setState(() => _tab = i),
            ),
            const Expanded(
              child: EmptyState(
                icon: Icons.report_gmailerrorred_outlined,
                title: 'No incidents to show',
                message:
                    'Security, discipline, health and other incidents will '
                    'appear here once the module is connected to a shared '
                    'incidents feed.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
