import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/core/utils.dart';
import 'package:school_pulse/features/health/domain/entities/emergency_incident.dart';
import 'package:school_pulse/features/health/presentation/bloc/health_bloc.dart';
import 'package:school_pulse/features/health/presentation/bloc/health_event.dart';
import 'package:school_pulse/features/health/presentation/bloc/health_state.dart';
import 'package:school_pulse/features/student/domain/entities/student.dart';
import 'package:school_pulse/injection_container.dart' as di;
import 'package:school_pulse/features/student/domain/usecases/get_all_students.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:go_router/go_router.dart';

class IncidentDetailsScreen extends StatefulWidget {
  final String incidentId;

  const IncidentDetailsScreen({super.key, required this.incidentId});

  @override
  State<IncidentDetailsScreen> createState() => _IncidentDetailsScreenState();
}

class _IncidentDetailsScreenState extends State<IncidentDetailsScreen> {
  Student? _student;
  bool _studentLoadStarted = false;

  String get _schoolId {
    final auth = context.read<AuthBloc>().state;
    return auth is AuthAuthenticated ? auth.user.schoolId : '';
  }

  @override
  void initState() {
    super.initState();
    context.read<HealthBloc>().add(
      FetchEmergencyIncidents(schoolId: _schoolId),
    );
  }

  void _loadStudent(String studentId) async {
    if (_student != null || _studentLoadStarted) return;
    _studentLoadStarted = true;
    final result = await di.sl<GetAllStudents>()(schoolId: _schoolId);
    result.fold((_) => null, (students) {
      if (mounted) {
        setState(() {
          _student = students.firstWhere(
            (s) => s.id == studentId,
            orElse: () => Student.empty(studentId),
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Emergency Incident Details')),
      body: BlocBuilder<HealthBloc, HealthState>(
        builder: (context, state) {
          if (state is HealthLoading) {
            return const Center(child: SchoolPulseLoader());
          }

          if (state is EmergencyIncidentsLoaded) {
            final matches = state.incidents
                .where((incident) => incident.id == widget.incidentId)
                .toList();
            if (matches.isEmpty) {
              return const Center(child: Text('Incident not found.'));
            }
            final incident = matches.first;
            _loadStudent(incident.studentId);

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildStatusHeader(incident),
                const SizedBox(height: 24),
                _buildStudentInfo(),
                const SizedBox(height: 24),
                _buildSection('Incident Details', incident.incidentDetails),
                const SizedBox(height: 16),
                _buildSection(
                  'First Aid Provided',
                  incident.firstAidGiven.isEmpty
                      ? 'None recorded'
                      : incident.firstAidGiven,
                ),
                const SizedBox(height: 16),
                _buildSection('Outcome', incident.outcome),
                if (incident.hospitalReferral?.trim().isNotEmpty == true) ...[
                  const SizedBox(height: 16),
                  _buildSection(
                    'Hospital / Referral',
                    incident.hospitalReferral!,
                  ),
                ],
                const SizedBox(height: 24),
                _buildChecklist(incident),
              ],
            );
          }

          if (state is HealthError) {
            return EmptyState(
              icon: Icons.cloud_off_outlined,
              title: 'Could not load incident',
              message: state.message,
              ctaLabel: 'Retry',
              onCtaPressed: () => context.read<HealthBloc>().add(
                FetchEmergencyIncidents(schoolId: _schoolId),
              ),
            );
          }

          return const Center(child: Text('Incident not found.'));
        },
      ),
    );
  }

  Widget _buildStatusHeader(EmergencyIncident incident) {
    return AppCard(
      color: Colors.black,
      borderColor: Colors.black,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Icon(Icons.emergency, color: Colors.black, size: 48),
          const SizedBox(height: 12),
          Text(
            'EMERGENCY REPORT',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            DateFormatter.format(incident.dateTime),
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }

  Widget _buildStudentInfo() {
    if (_student == null) {
      return const AppCard(
        child: ListTile(
          leading: CircleAvatar(child: Icon(Icons.person_outline)),
          title: Text('Loading student details…'),
        ),
      );
    }
    return AppCard(
      child: ListTile(
        leading: AvatarInitials(name: _student!.name),
        title: Text(
          _student!.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Class: ${_student!.className}'),
        trailing: IconButton(
          icon: const Icon(Icons.person_outline),
          onPressed: () => context.push('/staff/nurse/profile/${_student!.id}'),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        AppCard(
          padding: const EdgeInsets.all(12),
          child: Text(content, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }

  Widget _buildChecklist(EmergencyIncident incident) {
    return AppCard(
      child: Column(
        children: [
          CheckboxListTile(
            value: incident.parentNotified,
            onChanged: null,
            title: const Text('Parent Notified'),
            secondary: const Icon(Icons.family_restroom),
          ),
          CheckboxListTile(
            value: incident.ambulanceRequired,
            onChanged: null,
            title: const Text('Ambulance Required'),
            secondary: const Icon(Icons.medical_services),
          ),
        ],
      ),
    );
  }
}
