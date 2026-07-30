import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/health/domain/entities/student_health_profile.dart';
import 'package:school_pulse/features/health/presentation/bloc/health_bloc.dart';
import 'package:school_pulse/features/health/presentation/bloc/health_event.dart';
import 'package:school_pulse/features/health/presentation/bloc/health_state.dart';
import 'package:school_pulse/features/student/domain/entities/student.dart';
import 'package:school_pulse/injection_container.dart' as di;
import 'package:school_pulse/features/student/domain/usecases/get_all_students.dart';
import 'package:school_pulse/features/health/presentation/widgets/vaccination_card.dart';
import 'package:school_pulse/features/health/presentation/widgets/allergy_list.dart';
import 'package:school_pulse/core/utils.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:url_launcher/url_launcher.dart';

class StudentHealthProfileScreen extends StatefulWidget {
  final String studentId;

  const StudentHealthProfileScreen({super.key, required this.studentId});

  @override
  State<StudentHealthProfileScreen> createState() =>
      _StudentHealthProfileScreenState();
}

class _StudentHealthProfileScreenState
    extends State<StudentHealthProfileScreen> {
  Student? _student;

  String get _schoolId {
    final auth = context.read<AuthBloc>().state;
    return auth is AuthAuthenticated ? auth.user.schoolId : '';
  }

  @override
  void initState() {
    super.initState();
    _loadStudent();
    context.read<HealthBloc>().add(
      FetchStudentHealthProfile(widget.studentId, _schoolId),
    );
  }

  Future<void> _loadStudent() async {
    final result = await di.sl<GetAllStudents>()(schoolId: _schoolId);
    result.fold((l) => null, (students) {
      if (mounted) {
        setState(() {
          _student = students.firstWhere(
            (s) => s.id == widget.studentId,
            orElse: () => Student.empty(widget.studentId),
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_student?.name ?? 'Health Profile')),
      body: BlocBuilder<HealthBloc, HealthState>(
        builder: (context, state) {
          if (state is HealthLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is StudentHealthProfileLoaded) {
            final profile = state.profile;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildHeader(profile),
                const SizedBox(height: 24),
                _buildSection('Critical Information', [
                  _InfoTile(
                    label: 'Blood Group',
                    value: '${profile.bloodGroup}${profile.rhesusFactor ?? ""}',
                    color: Colors.red.shade700,
                  ),
                  AllergyList(
                    allergies: profile.allergies
                        .map(
                          (a) => AllergyInfo(
                            allergen: a,
                            reaction: 'Check medical notes',
                            severity: 'High',
                          ),
                        )
                        .toList(),
                    onAdd: () => _showAddAllergyDialog(profile),
                  ),
                  const SizedBox(height: 12),
                  _InfoTile(
                    label: 'Chronic Conditions',
                    value: profile.chronicIllnesses.isEmpty
                        ? 'None'
                        : profile.chronicIllnesses.join(', '),
                    isWarning: profile.chronicIllnesses.isNotEmpty,
                  ),
                ]),
                const SizedBox(height: 24),
                _buildSection('Vitals & Measurements', [
                  Row(
                    children: [
                      Expanded(
                        child: _InfoTile(
                          label: 'Height',
                          value: profile.height != null
                              ? '${profile.height} cm'
                              : 'N/A',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _InfoTile(
                          label: 'Weight',
                          value: profile.weight != null
                              ? '${profile.weight} kg'
                              : 'N/A',
                        ),
                      ),
                    ],
                  ),
                  _InfoTile(
                    label: 'BMI',
                    value: profile.bmi?.toStringAsFixed(1) ?? 'N/A',
                  ),
                ]),
                const SizedBox(height: 24),
                VaccinationCard(
                  records: profile.vaccinationHistory,
                  onAdd: () => _showAddVaccinationDialog(profile),
                ),
                const SizedBox(height: 24),
                _buildSection('Emergency Contact', [
                  _InfoTile(
                    label: 'Contact Name',
                    value: profile.emergencyContactName,
                  ),
                  _InfoTile(
                    label: 'Phone Number',
                    value: profile.emergencyContactPhone,
                    isPhone: true,
                  ),
                ]),
                const SizedBox(height: 24),
                _buildSection('Medications', [
                  _InfoTile(
                    label: 'Current Medications',
                    value: profile.currentMedications.isEmpty
                        ? 'None'
                        : profile.currentMedications.join(', '),
                  ),
                ]),
                const SizedBox(height: 24),
                _buildVisitHistory(state),
                const SizedBox(height: 40),
              ],
            );
          }

          if (state is HealthError) {
            return EmptyState(
              icon: Icons.cloud_off_outlined,
              title: 'Could not load health profile',
              message: state.message,
              ctaLabel: 'Retry',
              onCtaPressed: () => context.read<HealthBloc>().add(
                FetchStudentHealthProfile(widget.studentId, _schoolId),
              ),
            );
          }

          return const Center(child: Text('Profile not found.'));
        },
      ),
    );
  }

  Widget _buildHeader(StudentHealthProfile profile) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      color: Theme.of(
        context,
      ).colorScheme.primaryContainer.withValues(alpha: 0.3),
      child: Column(
        children: [
          AvatarInitials(name: _student?.name ?? 'Student', size: 64),
          const SizedBox(height: 16),
          Text(
            _student?.name ?? 'Unknown',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            'Class: ${_student?.className ?? "N/A"}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  void _saveProfile(StudentHealthProfile profile) {
    context.read<HealthBloc>().add(UpdateHealthProfile(profile, _schoolId));
  }

  void _showAddAllergyDialog(StudentHealthProfile profile) {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add allergy or sensitivity'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Allergen',
            hintText: 'e.g. Penicillin or peanuts',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final allergen = controller.text.trim();
              if (allergen.isEmpty) return;
              _saveProfile(
                profile.copyWith(allergies: [...profile.allergies, allergen]),
              );
              Navigator.pop(dialogContext);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddVaccinationDialog(StudentHealthProfile profile) {
    final controller = TextEditingController();
    var administeredOn = DateTime.now();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('Add vaccination'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Vaccine name'),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Date administered'),
                subtitle: Text(DateFormatter.format(administeredOn)),
                trailing: const Icon(Icons.calendar_today_outlined),
                onTap: () async {
                  final selected = await showDatePicker(
                    context: dialogContext,
                    firstDate: DateTime(1990),
                    lastDate: DateTime.now(),
                    initialDate: administeredOn,
                  );
                  if (selected != null) {
                    setDialogState(() => administeredOn = selected);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final vaccine = controller.text.trim();
                if (vaccine.isEmpty) return;
                _saveProfile(
                  profile.copyWith(
                    vaccinationHistory: [
                      ...profile.vaccinationHistory,
                      VaccinationRecord(
                        id: DateTime.now().microsecondsSinceEpoch.toString(),
                        vaccineName: vaccine,
                        dateAdministered: administeredOn,
                      ),
                    ],
                  ),
                );
                Navigator.pop(dialogContext);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: title),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildVisitHistory(StudentHealthProfileLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Recent Medical History'),
        const SizedBox(height: 8),
        if (state.visitHistory.isEmpty && state.incidentHistory.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: Text('No history recorded.')),
          )
        else ...[
          ...state.incidentHistory.map(
            (e) => _HistoryTile(
              title: 'Emergency Incident',
              subtitle: e.incidentDetails,
              date: e.dateTime,
              color: Colors.red,
              icon: Icons.emergency,
            ),
          ),
          ...state.visitHistory
              .take(5)
              .map(
                (v) => _HistoryTile(
                  title: 'Clinic Visit: ${v.reason}',
                  subtitle: 'Outcome: ${v.outcome.name}',
                  date: v.dateTime,
                  color: Colors.blue,
                  icon: Icons.medical_services,
                ),
              ),
        ],
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  final bool isWarning;
  final bool isPhone;

  const _InfoTile({
    required this.label,
    required this.value,
    this.color,
    this.isWarning = false,
    this.isPhone = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 8),
      color: isWarning ? Colors.orange.shade50 : null,
      borderColor: isWarning ? Colors.orange.shade200 : null,
      child: ListTile(
        title: Text(label, style: Theme.of(context).textTheme.labelSmall),
        subtitle: Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color ?? (isWarning ? Colors.orange.shade900 : null),
          ),
        ),
        trailing: isPhone
            ? IconButton(
                icon: const Icon(Icons.phone),
                onPressed: value.trim().isEmpty
                    ? null
                    : () async {
                        final launched = await launchUrl(
                          Uri(scheme: 'tel', path: value.trim()),
                        );
                        if (!launched && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Could not open the phone dialer.'),
                            ),
                          );
                        }
                      },
              )
            : null,
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final DateTime date;
  final Color color;
  final IconData icon;

  const _HistoryTile({
    required this.title,
    required this.subtitle,
    required this.date,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(
              DateFormatter.format(date),
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}
