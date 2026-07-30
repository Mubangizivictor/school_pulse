import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/notifications/presentation/notification_bell_button.dart';
import 'package:school_pulse/features/security/domain/entities/security_entities.dart';
import 'bloc/security_bloc.dart';
import 'bloc/security_event.dart';
import 'bloc/security_state.dart';
import 'screens/emergency_detail_screen.dart';
import 'screens/incident_detail_screen.dart';
import 'screens/report_incident_screen.dart';

import 'widgets/emergency_protocol_dialog.dart';
import 'widgets/verification_workflow.dart';

class SecurityDashboardScreen extends StatefulWidget {
  const SecurityDashboardScreen({super.key});

  @override
  State<SecurityDashboardScreen> createState() => _SecurityDashboardScreenState();
}

class _SecurityDashboardScreenState extends State<SecurityDashboardScreen> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<SecurityBloc>().add(LoadSecurityDashboard(authState.user.schoolId));
    }
  }

  void _showVerificationWorkflow(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 20,
          left: 20,
          right: 20,
        ),
        child: const VerificationWorkflow(),
      ),
    );
  }

  void _showEmergencyProtocol(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const EmergencyProtocolDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final semanticColors = Theme.of(context).extension<SemanticColors>()!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Security Portal'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'gates':
                  context.push('/staff/security/gates');
                  break;
                case 'pickup':
                  context.push('/staff/security/pickup');
                  break;
                case 'pickup-authorizations':
                  context.push('/staff/security/pickup-authorizations');
                  break;
                case 'lost-and-found':
                  context.push('/staff/security/lost-and-found');
                  break;
                case 'patrols':
                  context.push('/staff/security/patrols');
                  break;
                case 'settings':
                  context.push('/staff/security/settings');
                  break;
                case 'reports':
                  context.push('/staff/security/reports');
                  break;
                case 'report':
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ReportIncidentScreen()));
                  break;
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'gates', child: Text('Manage Gates')),
              PopupMenuItem(value: 'pickup', child: Text('Student Pickup')),
              PopupMenuItem(value: 'pickup-authorizations', child: Text('Pickup Authorizations')),
              PopupMenuItem(value: 'lost-and-found', child: Text('Lost & Found')),
              PopupMenuItem(value: 'patrols', child: Text('Security Patrols')),
              PopupMenuItem(value: 'settings', child: Text('Admin Security Settings')),
              PopupMenuItem(value: 'reports', child: Text('Reports')),
              PopupMenuItem(value: 'report', child: Text('Report Incident to Admin')),
            ],
          ),
          const NotificationBellButton(),
        ],
      ),
      body: BlocConsumer<SecurityBloc, SecurityState>(
        listenWhen: (previous, current) => !identical(previous.feedback, current.feedback) && current.feedback != null,
        listener: (context, state) {
          final feedback = state.feedback!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(feedback.message),
              backgroundColor: feedback.isError ? Colors.red : null,
            ),
          );
        },
        builder: (context, state) {
          if (state.status == SecurityStatus.loading || state.status == SecurityStatus.initial) {
            return const _SecuritySkeleton();
          }

          if (state.status == SecurityStatus.error) {
            return Center(child: Text(state.errorMessage ?? 'Something went wrong'));
          }

          return RefreshIndicator(
              onRefresh: () async {
                final authState = context.read<AuthBloc>().state;
                if (authState is AuthAuthenticated) {
                  context.read<SecurityBloc>().add(LoadSecurityDashboard(authState.user.schoolId));
                }
              },
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                children: [
                  FadeInSlide(
                    child: Text(
                      "Security Status",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: FadeInSlide(
                          delay: const Duration(milliseconds: 100),
                          child: DashboardStatCard(
                            title: 'People Inside',
                            value: (state.stats['peopleCurrentlyInside'] ?? 0).toDouble(),
                            icon: Icons.groups_outlined,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FadeInSlide(
                          delay: const Duration(milliseconds: 150),
                          child: DashboardStatCard(
                            title: 'Students In',
                            value: (state.stats['studentsIn'] ?? 0).toDouble(),
                            icon: Icons.person_pin_circle_outlined,
                            color: semanticColors.success,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: FadeInSlide(
                          delay: const Duration(milliseconds: 200),
                          child: DashboardStatCard(
                            title: 'Visitors Inside',
                            value: (state.stats['visitorsCurrentlyInside'] ?? 0).toDouble(),
                            icon: Icons.badge_outlined,
                            color: semanticColors.info,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FadeInSlide(
                          delay: const Duration(milliseconds: 250),
                          child: DashboardStatCard(
                            title: 'Pending Incidents',
                            value: (state.stats['pendingIncidents'] ?? 0).toDouble(),
                            icon: Icons.report_gmailerrorred_outlined,
                            color: semanticColors.warning,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (state.activeEmergencies.isNotEmpty) ...[
                    const FadeInSlide(
                      delay: Duration(milliseconds: 250),
                      child: SectionHeader(title: 'Active Emergencies', color: Colors.red),
                    ),
                    const SizedBox(height: 12),
                    ...state.activeEmergencies.map((emergency) => _EmergencyCard(
                          emergency: emergency,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => EmergencyDetailScreen(emergency: emergency)),
                          ),
                        )),
                    const SizedBox(height: 24),
                  ],
                  const FadeInSlide(
                    delay: Duration(milliseconds: 300),
                    child: SectionHeader(title: 'Recent Movements'),
                  ),
                  const SizedBox(height: 12),
                  if (state.studentMovements.isEmpty)
                    const Center(child: Text("No recent movements recorded"))
                  else
                    ...state.studentMovements.take(5).map((movement) => _MovementListTile(movement: movement)),
                  const SizedBox(height: 24),
                  const FadeInSlide(
                    delay: Duration(milliseconds: 400),
                    child: SectionHeader(title: 'Active Incidents'),
                  ),
                  const SizedBox(height: 12),
                  if (state.incidents.isEmpty)
                    const Center(child: Text("No active incidents"))
                  else
                    ...state.incidents.take(5).map((incident) => _IncidentListTile(
                          incident: incident,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => IncidentDetailScreen(incident: incident)),
                          ),
                        )),
                  const SizedBox(height: 32),
                ],
              ),
            );
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: 'emergency',
            onPressed: () => _showEmergencyProtocol(context),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.emergency),
            label: const Text("EMERGENCY"),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'verify',
            onPressed: () => _showVerificationWorkflow(context),
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text("Verify Entry/Exit"),
          ),
        ],
      ),
    );
  }
}

class _EmergencyCard extends StatelessWidget {
  final EmergencyEvent emergency;
  final VoidCallback onTap;
  const _EmergencyCard({required this.emergency, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.red.shade50,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.warning, color: Colors.red),
        title: Text(emergency.type, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
        subtitle: Text(emergency.description),
        trailing: const Icon(Icons.chevron_right, color: Colors.red),
        onTap: onTap,
      ),
    );
  }
}

class _MovementListTile extends StatelessWidget {
  final StudentMovement movement;
  const _MovementListTile({required this.movement});

  @override
  Widget build(BuildContext context) {
    final isIn = movement.direction.toLowerCase() == 'in';
    return AppCard(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isIn ? Colors.green.shade50 : Colors.blue.shade50,
          child: Icon(
            isIn ? Icons.login : Icons.logout,
            color: isIn ? Colors.green : Colors.blue,
          ),
        ),
        title: Text(movement.studentName),
        subtitle: Text("${movement.movementType} • ${movement.className}"),
        trailing: Text(
          "${movement.timestamp.hour}:${movement.timestamp.minute.toString().padLeft(2, '0')}",
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    );
  }
}

class _IncidentListTile extends StatelessWidget {
  final SecurityIncident incident;
  final VoidCallback onTap;
  const _IncidentListTile({required this.incident, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.orange.shade50,
          child: const Icon(Icons.gavel, color: Colors.orange),
        ),
        title: Text(incident.type),
        subtitle: Text(incident.description, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.orange.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            incident.status,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange),
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}

class _SecuritySkeleton extends StatelessWidget {
  const _SecuritySkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
      children: [
        const Skeleton(width: 200, height: 28),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(child: const Skeleton(height: 48, borderRadius: 12)),
            const SizedBox(width: 12),
            Expanded(child: const Skeleton(height: 48, borderRadius: 12)),
          ],
        ),
        const SizedBox(height: 24),
        const Skeleton(width: 120, height: 20),
        const SizedBox(height: 12),
        ...List.generate(3, (index) => const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Skeleton(height: 72, borderRadius: 12),
        )),
      ],
    );
  }
}
