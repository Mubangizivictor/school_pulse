import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/director/presentation/bloc/director_bloc.dart';
import 'package:school_pulse/features/director/presentation/bloc/director_event.dart';
import 'package:school_pulse/features/director/presentation/bloc/director_state.dart';
import 'package:school_pulse/features/director/domain/entities/director_dashboard_stats.dart';

/// Shared scaffold for every report opened from Strategic Reports: fetches
/// [DirectorDashboardStats] once and hands it to a report-specific builder,
/// so each report definition only supplies its content, not boilerplate.
class ReportDetailScreen extends StatelessWidget {
  final String title;
  final Widget Function(BuildContext context, DirectorDashboardStats stats)
  builder;

  const ReportDetailScreen({
    super.key,
    required this.title,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    context.read<DirectorBloc>().add(DirectorDashboardRequested());
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: BlocBuilder<DirectorBloc, DirectorState>(
        builder: (context, state) {
          if (state is! DirectorDashboardLoaded) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [builder(context, state.stats)],
          );
        },
      ),
    );
  }
}

/// A single labeled metric row used inside a report card.
class ReportMetricRow extends StatelessWidget {
  final String label, value;
  const ReportMetricRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Theme.of(context).hintColor)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    ),
  );
}

/// Honest "not tracked yet" note for a report row with no real backing data
/// source, instead of a fabricated table/chart.
class ReportNotTrackedNote extends StatelessWidget {
  final String message;
  const ReportNotTrackedNote({super.key, required this.message});

  @override
  Widget build(BuildContext context) => AppCard(
    child: Row(
      children: [
        Icon(Icons.info_outline, color: Theme.of(context).hintColor, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            message,
            style: TextStyle(color: Theme.of(context).hintColor),
          ),
        ),
      ],
    ),
  );
}
