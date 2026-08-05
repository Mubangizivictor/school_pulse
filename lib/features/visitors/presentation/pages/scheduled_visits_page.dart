import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import '../bloc/visitors_bloc.dart';
import '../bloc/visitors_event.dart';
import '../bloc/visitors_state.dart';
import 'visitor_check_in_screen.dart';

class ScheduledVisitsPage extends StatefulWidget {
  const ScheduledVisitsPage({super.key});

  @override
  State<ScheduledVisitsPage> createState() => _ScheduledVisitsPageState();
}

class _ScheduledVisitsPageState extends State<ScheduledVisitsPage> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<VisitorsBloc>().add(
        LoadScheduledVisits(authState.user.schoolId),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scheduled Visits')),
      body: BlocBuilder<VisitorsBloc, VisitorsState>(
        builder: (context, state) {
          if (state is VisitorsLoading)
            return const Center(child: CircularProgressIndicator());

          if (state is VisitorsLoaded) {
            final visits = state.scheduledVisits
                .where((v) => !v.isCheckedIn && !v.isRejected)
                .toList();
            if (visits.isEmpty) {
              return const Center(child: Text('No upcoming scheduled visits'));
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: visits.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final visit = visits[index];
                return AppCard(
                  child: ListTile(
                    title: Text(
                      visit.fullName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Host: ${visit.host}'),
                        Text('Purpose: ${visit.purpose}'),
                        Text(
                          'Scheduled: ${DateFormat('MMM dd, hh:mm a').format(visit.scheduledTime)}',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    trailing: !visit.isApproved
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                ),
                                tooltip: 'Approve',
                                onPressed: () => context
                                    .read<VisitorsBloc>()
                                    .add(ApproveScheduledVisitEvent(visit.id)),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.cancel,
                                  color: Colors.red,
                                ),
                                tooltip: 'Reject',
                                onPressed: () => context
                                    .read<VisitorsBloc>()
                                    .add(RejectScheduledVisitEvent(visit.id)),
                              ),
                            ],
                          )
                        : ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => VisitorCheckInScreen(
                                    scheduledVisit: visit,
                                  ),
                                ),
                              );
                            },
                            child: const Text('Check In'),
                          ),
                  ),
                );
              },
            );
          }
          return const Center(child: Text('Something went wrong'));
        },
      ),
    );
  }
}
