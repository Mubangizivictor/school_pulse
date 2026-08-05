import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/notifications/domain/entities/alert.dart';
import 'package:school_pulse/features/notifications/domain/usecases/get_alerts.dart';
import 'package:school_pulse/features/security/domain/entities/security_entities.dart';
import 'package:school_pulse/features/security/domain/usecases/security_usecases.dart';
import 'package:school_pulse/features/security/presentation/bloc/security_bloc.dart';
import 'package:school_pulse/features/security/presentation/bloc/security_event.dart';
import 'package:school_pulse/features/security/presentation/bloc/security_state.dart';
import 'package:school_pulse/features/student/presentation/bloc/selected_student_bloc.dart';
import 'package:school_pulse/features/student/presentation/bloc/selected_student_state.dart';
import 'package:school_pulse/injection_container.dart' as di;
import 'widgets/student_app_bar.dart';

/// Parent-facing view of their child's security activity - arrival/
/// departure log, pickup history, authorized pickup persons, and security
/// alerts scoped to that child only. Never touches WatchIncidents or any
/// other cross-student security data.
class SecurityActivityScreen extends StatefulWidget {
  const SecurityActivityScreen({super.key});

  @override
  State<SecurityActivityScreen> createState() => _SecurityActivityScreenState();
}

class _SecurityActivityScreenState extends State<SecurityActivityScreen> {
  List<PickupAuthorization> _authorizations = [];
  List<Alert> _alerts = [];
  bool _isLoadingExtras = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final studentState = context.read<SelectedStudentBloc>().state;
    final authState = context.read<AuthBloc>().state;
    if (studentState is! SelectedStudentLoaded ||
        authState is! AuthAuthenticated)
      return;

    final studentId = studentState.student.id;
    context.read<SecurityBloc>().add(
      WatchStudentMovementsRequested(
        authState.user.schoolId,
        studentId: studentId,
      ),
    );
    _loadExtras(authState.user.schoolId, studentId);
  }

  Future<void> _loadExtras(String schoolId, String studentId) async {
    setState(() => _isLoadingExtras = true);
    final authorizationsResult = await di.sl<GetPickupAuthorizations>()(
      schoolId,
      studentId,
    );
    final alertsResult = await di.sl<GetAlerts>()([studentId]);
    if (!mounted) return;
    setState(() {
      _authorizations = authorizationsResult.fold((f) => [], (a) => a);
      _alerts = alertsResult.fold((f) => [], (a) => a);
      _isLoadingExtras = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const StudentAppBar(title: 'Security & Safety'),
      body: RefreshIndicator(
        onRefresh: () async => _load(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SectionHeader(title: 'Arrival & Departure'),
            const SizedBox(height: 8),
            BlocBuilder<SecurityBloc, SecurityState>(
              builder: (context, state) {
                if (state.studentMovements.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('No movement records yet.'),
                  );
                }
                return Column(
                  children: state.studentMovements
                      .map((m) => _MovementTile(movement: m))
                      .toList(),
                );
              },
            ),
            const SizedBox(height: 24),
            const SectionHeader(title: 'Authorized Pickup Persons'),
            const SizedBox(height: 8),
            if (_isLoadingExtras)
              const Center(child: CircularProgressIndicator())
            else if (_authorizations.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'No one else is authorized to pick up this child yet.',
                ),
              )
            else
              ..._authorizations.map(
                (a) => AppCard(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: a.photoUrl != null
                          ? NetworkImage(a.photoUrl!)
                          : null,
                      child: a.photoUrl == null
                          ? const Icon(Icons.person_outline)
                          : null,
                    ),
                    title: Text(a.authorizedPersonName),
                    subtitle: Text('${a.relationship} • ${a.phone}'),
                  ),
                ),
              ),
            const SizedBox(height: 24),
            const SectionHeader(title: 'Security Alerts'),
            const SizedBox(height: 8),
            if (_isLoadingExtras)
              const Center(child: CircularProgressIndicator())
            else if (_alerts.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('No security alerts for this child.'),
              )
            else
              ..._alerts.map(
                (alert) => AppCard(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.notifications_active_outlined),
                    title: Text(alert.title),
                    subtitle: Text(alert.message),
                    trailing: Text(
                      '${alert.timestamp.hour.toString().padLeft(2, '0')}:${alert.timestamp.minute.toString().padLeft(2, '0')}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MovementTile extends StatelessWidget {
  final StudentMovement movement;
  const _MovementTile({required this.movement});

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
        title: Text(movement.movementType),
        subtitle: Text(
          movement.timestamp.toLocal().toString().split('.').first,
        ),
      ),
    );
  }
}
