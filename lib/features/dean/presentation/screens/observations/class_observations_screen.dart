import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_bloc.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_event.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_state.dart';
import 'package:school_pulse/injection_container.dart';
import 'package:intl/intl.dart';

class ClassObservationsScreen extends StatelessWidget {
  const ClassObservationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<DeanBloc>()..add(ClassObservationsRequested()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Class Observations'),
        ),
        body: BlocBuilder<DeanBloc, DeanState>(
          builder: (context, state) {
            if (state is DeanLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ClassObservationsLoaded) {
              if (state.observations.isEmpty) {
                return const Center(child: Text('No class observations recorded yet.'));
              }
              return _buildObservationList(state.observations);
            } else if (state is DeanError) {
              return Center(child: Text(state.message));
            }
            return const Center(child: Text('Loading observations...'));
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            // Navigate to record new observation screen or show dialog
          },
          label: const Text('Record Observation'),
          icon: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildObservationList(List<dynamic> observations) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: observations.length,
      itemBuilder: (context, index) {
        final obs = observations[index];
        return AppCard(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text('Observer: ${obs.observerName}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Teacher: ${obs.teacherName} • ${obs.className}'),
                Text('Date: ${DateFormat('MMM dd, yyyy').format(obs.observedAt)}'),
                const SizedBox(height: 4),
                _buildRatingBar(obs.rating),
              ],
            ),
            trailing: const Icon(Icons.chevron_right),
            isThreeLine: true,
            onTap: () {
              // Show observation details
            },
          ),
        );
      },
    );
  }

  Widget _buildRatingBar(int rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          size: 16,
          color: Colors.amber,
        );
      }),
    );
  }
}
