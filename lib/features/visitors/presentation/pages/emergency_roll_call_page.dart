import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/visitor.dart';
import '../bloc/visitors_bloc.dart';
import '../bloc/visitors_event.dart';
import '../bloc/visitors_state.dart';

class EmergencyRollCallPage extends StatefulWidget {
  const EmergencyRollCallPage({super.key});

  @override
  State<EmergencyRollCallPage> createState() => _EmergencyRollCallPageState();
}

class _EmergencyRollCallPageState extends State<EmergencyRollCallPage> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<VisitorsBloc>().add(
        LoadEmergencyRollCall(authState.user.schoolId),
      );
    }
  }

  void _shareRollCall(List<Visitor> visitors) {
    final buffer = StringBuffer()
      ..writeln('EMERGENCY ROLL-CALL')
      ..writeln(DateFormat('MMM dd, yyyy HH:mm').format(DateTime.now()))
      ..writeln('${visitors.length} visitor(s) currently on premises:')
      ..writeln();
    for (final v in visitors) {
      buffer.writeln(
        '- ${v.fullName} (${v.phone}) | Host: ${v.host} | In: ${DateFormat('HH:mm').format(v.arrivalTime)}'
        '${v.gateId != null ? ' | Gate: ${v.gateId}' : ''}',
      );
    }
    Share.share(buffer.toString(), subject: 'Emergency Roll-Call');
  }

  Future<void> _callVisitor(BuildContext context, String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (!await launchUrl(uri)) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to place call to $phone')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Roll-Call'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<VisitorsBloc, VisitorsState>(
        builder: (context, state) {
          if (state is VisitorsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is VisitorsLoaded) {
            final activeVisitors = state.activeVisitors;

            if (activeVisitors.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 64,
                      color: Colors.green,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'All visitors accounted for.',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('No visitors are currently checked in.'),
                  ],
                ),
              );
            }

            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.red.shade50,
                  child: Row(
                    children: [
                      const Icon(Icons.warning, color: Colors.red),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${activeVisitors.length} visitors are currently on the premises.',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _shareRollCall(activeVisitors),
                        icon: const Icon(Icons.share),
                        label: const Text('Share List'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: activeVisitors.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final visitor = activeVisitors[index];
                      return AppCard(
                        child: ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.person),
                          ),
                          title: Text(
                            visitor.fullName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Host: ${visitor.host} (${visitor.department})',
                              ),
                              Text('Phone: ${visitor.phone}'),
                              Text(
                                'Arrival: ${DateFormat('HH:mm').format(visitor.arrivalTime)}',
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.phone, color: Colors.green),
                            onPressed: () =>
                                _callVisitor(context, visitor.phone),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }

          return const Center(child: Text('Unable to load roll-call data'));
        },
      ),
    );
  }
}
