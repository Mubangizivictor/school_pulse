import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/core/utils/reporting_engine.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import '../bloc/security_bloc.dart';
import '../bloc/security_event.dart';
import '../bloc/security_state.dart';

class SecurityReportsScreen extends StatefulWidget {
  const SecurityReportsScreen({super.key});

  @override
  State<SecurityReportsScreen> createState() => _SecurityReportsScreenState();
}

class _SecurityReportsScreenState extends State<SecurityReportsScreen> {
  DateTimeRange _range = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 7)),
    end: DateTime.now(),
  );
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    // Patrols and lost & found are only streamed once their own screens are
    // visited - start them here too so reports are populated even if the
    // officer opens Reports directly without visiting those screens first.
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<SecurityBloc>().add(WatchPatrolsRequested(authState.user.schoolId));
      context.read<SecurityBloc>().add(WatchLostAndFoundRequested(authState.user.schoolId));
    }
  }

  bool _inRange(DateTime timestamp) =>
      !timestamp.isBefore(_range.start) && timestamp.isBefore(_range.end.add(const Duration(days: 1)));

  Future<void> _pickRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: _range,
    );
    if (picked != null) setState(() => _range = picked);
  }

  Future<void> _export(Future<void> Function() exportFn) async {
    setState(() => _isExporting = true);
    try {
      await exportFn();
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth >= 700;

    return Scaffold(
      appBar: AppBar(title: const Text('Security Reports')),
      body: BlocBuilder<SecurityBloc, SecurityState>(
        builder: (context, state) {
          final movements = state.studentMovements.where((m) => _inRange(m.timestamp)).toList();
          final incidents = state.incidents.where((i) => _inRange(i.timestamp)).toList();
          final patrols = state.patrols.where((p) => _inRange(p.timestamp)).toList();
          final lostAndFound = state.lostAndFound.where((i) => _inRange(i.dateFound)).toList();

          return Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: ListView(
                padding: EdgeInsets.all(isLargeScreen ? 24 : 16),
                children: [
                  Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      title: const Text('Report Date Range', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        '${_range.start.toLocal().toString().split(' ').first} — ${_range.end.toLocal().toString().split(' ').first}',
                      ),
                      trailing: FilledButton.tonalIcon(
                        onPressed: _pickRange,
                        icon: const Icon(Icons.edit_calendar_outlined),
                        label: const Text('Change'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  GridView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: screenWidth > 1100 ? 2 : 1,
                      mainAxisExtent: 100,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 12,
                    ),
                    children: [
                      _ReportTile(
                        icon: Icons.door_front_door_outlined,
                        title: 'Gate & Movement Report',
                        subtitle: '${movements.length} record(s)',
                        isLoading: _isExporting,
                        onExport: () => _export(() => ReportingEngine.exportStudentMovementsToExcel(movements)),
                      ),
                      _ReportTile(
                        icon: Icons.gavel_outlined,
                        title: 'Incidents Report',
                        subtitle: '${incidents.length} record(s)',
                        isLoading: _isExporting,
                        onExport: () => _export(() => ReportingEngine.exportSecurityIncidentsToExcel(incidents)),
                      ),
                      _ReportTile(
                        icon: Icons.directions_walk_outlined,
                        title: 'Patrol Report',
                        subtitle: '${patrols.length} record(s)',
                        isLoading: _isExporting,
                        onExport: () => _export(() => ReportingEngine.exportPatrolLogToExcel(patrols)),
                      ),
                      _ReportTile(
                        icon: Icons.inventory_2_outlined,
                        title: 'Lost & Found Report',
                        subtitle: '${lostAndFound.length} record(s)',
                        isLoading: _isExporting,
                        onExport: () => _export(() => ReportingEngine.exportLostAndFoundToExcel(lostAndFound)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Card(
                    color: Colors.transparent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: Colors.grey, width: 0.5),
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Visitor reports (today / history / frequent visitors) are available from the Visitors dashboard export.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ReportTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isLoading;
  final VoidCallback onExport;

  const _ReportTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isLoading,
    required this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: IconButton(
          icon: isLoading
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.file_download_outlined),
          onPressed: isLoading ? null : onExport,
        ),
      ),
    );
  }
}
