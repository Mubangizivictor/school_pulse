import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/core/utils.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/health/presentation/bloc/health_bloc.dart';
import 'package:school_pulse/features/health/presentation/bloc/health_event.dart';
import 'package:school_pulse/features/health/presentation/bloc/health_state.dart';
import 'package:school_pulse/features/health/domain/entities/clinic_visit.dart';
import 'package:school_pulse/features/matron/domain/entities/boarding_entities.dart';
import 'package:school_pulse/features/student/presentation/bloc/selected_student_bloc.dart';
import 'package:school_pulse/features/student/presentation/bloc/selected_student_state.dart';
import 'package:school_pulse/features/parent/widgets/student_app_bar.dart';

class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    final studentState = context.read<SelectedStudentBloc>().state;
    final authState = context.read<AuthBloc>().state;
    if (studentState is SelectedStudentLoaded &&
        authState is AuthAuthenticated) {
      context.read<HealthBloc>().add(
        FetchClinicVisits(
          schoolId: authState.user.schoolId,
          studentId: studentState.student.id,
        ),
      );
    }
  }

  Future<void> _contactSchoolNurse() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated || authState.user.schoolId.isEmpty) {
      _showContactError('Your account is not assigned to a school.');
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('school_contacts')
          .where('schoolId', isEqualTo: authState.user.schoolId)
          .get();
      final nurses = snapshot.docs.where((doc) {
        final data = doc.data();
        final roles = <String>{
          if (data['role'] is String) data['role'] as String,
          ...List<String>.from(data['roles'] as List? ?? const []),
        };
        return roles.contains('nurse') && data['isActive'] != false;
      }).toList();
      if (!mounted) return;
      if (nurses.isEmpty) {
        _showContactError(
          'No active nurse contact is configured for this school yet.',
        );
        return;
      }
      final nurse = nurses.first;
      final data = nurse.data();
      final name = data['name'] as String? ?? 'School Nurse';
      context.push(
        '/parent/messages?recipientId=${nurse.id}&recipientName=${Uri.encodeComponent(name)}&recipientRole=Nurse',
      );
    } catch (_) {
      if (mounted) {
        _showContactError(
          'Could not load the school nurse contact. Try again.',
        );
      }
    }
  }

  void _showContactError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const StudentAppBar(title: 'Health & Wellness'),
      body: BlocListener<SelectedStudentBloc, SelectedStudentState>(
        listener: (context, state) {
          if (state is SelectedStudentLoaded) {
            final authState = context.read<AuthBloc>().state;
            if (authState is AuthAuthenticated) {
              context.read<HealthBloc>().add(
                FetchClinicVisits(
                  schoolId: authState.user.schoolId,
                  studentId: state.student.id,
                ),
              );
            }
          }
        },
        child: BlocBuilder<HealthBloc, HealthState>(
          builder: (context, state) {
            if (state is HealthLoading || state is HealthInitial) {
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Skeleton(height: 80),
                  const SizedBox(height: 24),
                  const Skeleton(height: 24, width: 150),
                  const SizedBox(height: 12),
                  ...List.generate(
                    2,
                    (index) => const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Skeleton(height: 150),
                    ),
                  ),
                ],
              );
            } else if (state is HealthError) {
              return EmptyState(
                icon: Icons.cloud_off,
                title: 'Could not load health records',
                message: state.message,
                ctaLabel: 'Retry',
                onCtaPressed: _fetchData,
              );
            } else if (state is HealthLoaded) {
              final visits = state.visits;
              final welfareRecords = state.welfareRecords;

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (visits.isNotEmpty) ...[
                    const FadeInSlide(
                      delay: Duration(milliseconds: 100),
                      child: SectionHeader(title: 'Nurse Visits'),
                    ),
                    ...visits.asMap().entries.map((entry) {
                      final index = entry.key;
                      final visit = entry.value;
                      return FadeInSlide(
                        delay: Duration(milliseconds: 200 + (index * 100)),
                        child: _buildVisitCard(context, visit),
                      );
                    }),
                    const SizedBox(height: 16),
                  ],
                  if (welfareRecords.isNotEmpty) ...[
                    const FadeInSlide(
                      delay: Duration(milliseconds: 100),
                      child: SectionHeader(title: 'Welfare & Dorm Check-ups'),
                    ),
                    ...welfareRecords.asMap().entries.map((entry) {
                      final index = entry.key;
                      final record = entry.value;
                      return FadeInSlide(
                        delay: Duration(milliseconds: 200 + (index * 100)),
                        child: _buildWelfareCard(context, record),
                      );
                    }),
                    const SizedBox(height: 16),
                  ],
                  if (visits.isEmpty && welfareRecords.isEmpty)
                    const FadeInSlide(
                      delay: Duration(milliseconds: 200),
                      child: EmptyState(
                        icon: Icons.health_and_safety_outlined,
                        title: 'No Health Records',
                        message:
                            'No medical visits or welfare records have been recorded for this student.',
                      ),
                    ),
                  const SizedBox(height: 16),
                  FadeInSlide(
                    delay: const Duration(milliseconds: 500),
                    child: SecondaryButton(
                      label: 'Contact School Nurse',
                      icon: Icons.chat_bubble_outline,
                      onPressed: _contactSchoolNurse,
                    ),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildVisitCard(BuildContext context, ClinicVisit visit) {
    return AppCard(
      onTap: () {}, // For scale animation
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormatter.format(visit.dateTime),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              StatusBadge(
                label: 'Clinic',
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(context, 'Reason', visit.reason, Icons.info_outline),
          const SizedBox(height: 8),
          _buildInfoRow(
            context,
            'Treatment',
            visit.treatmentProvided ?? 'N/A',
            Icons.healing_outlined,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            context,
            'Medication',
            visit.medicationsGiven.isEmpty
                ? 'None'
                : visit.medicationsGiven
                      .map((m) => m.medicationName)
                      .join(', '),
            Icons.medication_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildWelfareCard(BuildContext context, WelfareRecord record) {
    return AppCard(
      onTap: () {}, // For scale animation
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormatter.format(record.date),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              StatusBadge(
                label: record.category,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(context, 'Note', record.note, Icons.note_alt_outlined),
          const SizedBox(height: 8),
          _buildInfoRow(context, 'By', record.recordedBy, Icons.person_outline),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
