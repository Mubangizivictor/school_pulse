import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/core/utils.dart';
import 'package:school_pulse/features/health/domain/entities/clinic_visit.dart';
import 'package:school_pulse/features/health/presentation/bloc/health_bloc.dart';
import 'package:school_pulse/features/health/presentation/bloc/health_event.dart';
import 'package:school_pulse/features/health/presentation/bloc/health_state.dart';
import 'package:school_pulse/features/student/domain/entities/student.dart';
import 'package:school_pulse/injection_container.dart' as di;
import 'package:school_pulse/features/student/domain/usecases/get_all_students.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';

class HealthHistoryScreen extends StatefulWidget {
  const HealthHistoryScreen({super.key});

  @override
  State<HealthHistoryScreen> createState() => _HealthHistoryScreenState();
}

class _HealthHistoryScreenState extends State<HealthHistoryScreen> {
  List<Student> _allStudents = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadStudents();
    final auth = context.read<AuthBloc>().state;
    if (auth is AuthAuthenticated) {
      context.read<HealthBloc>().add(
        FetchClinicVisits(schoolId: auth.user.schoolId),
      );
    }
  }

  Future<void> _loadStudents() async {
    final auth = context.read<AuthBloc>().state;
    final schoolId = auth is AuthAuthenticated ? auth.user.schoolId : '';
    final result = await di.sl<GetAllStudents>()(schoolId: schoolId);
    result.fold((_) => null, (students) {
      if (mounted) setState(() => _allStudents = students);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clinic Visit History')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search by student name or reason...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<HealthBloc, HealthState>(
              builder: (context, state) {
                if (state is HealthLoading) {
                  return const Center(child: SchoolPulseLoader());
                }

                if (state is ClinicVisitsLoaded) {
                  final filteredVisits = state.visits.where((v) {
                    final student = _allStudents.firstWhere(
                      (s) => s.id == v.studentId,
                      orElse: () => Student.empty(v.studentId),
                    );
                    final matchStudent = student.name.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    );
                    final matchReason = v.reason.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    );
                    return matchStudent || matchReason;
                  }).toList();

                  if (filteredVisits.isEmpty) {
                    return const Center(
                      child: Text('No matching records found.'),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredVisits.length,
                    itemBuilder: (context, index) {
                      final visit = filteredVisits[index];
                      final student = _allStudents.firstWhere(
                        (s) => s.id == visit.studentId,
                        orElse: () => Student.empty(visit.studentId),
                      );

                      return _HistoryItem(visit: visit, student: student);
                    },
                  );
                }

                if (state is HealthError) {
                  return EmptyState(
                    icon: Icons.cloud_off_outlined,
                    title: 'Could not load clinic history',
                    message: state.message,
                    ctaLabel: 'Retry',
                    onCtaPressed: () {
                      final auth = context.read<AuthBloc>().state;
                      if (auth is AuthAuthenticated) {
                        context.read<HealthBloc>().add(
                          FetchClinicVisits(schoolId: auth.user.schoolId),
                        );
                      }
                    },
                  );
                }

                return const Center(child: Text('Failed to load history.'));
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final ClinicVisit visit;
  final Student student;

  const _HistoryItem({required this.visit, required this.student});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: AvatarInitials(name: student.name),
        title: Text(
          student.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(visit.reason),
            Text(
              DateFormatter.format(visit.dateTime),
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
        trailing: StatusBadge(
          label: visit.outcome.name.splitCamelCase(),
          color: _getOutcomeColor(visit.outcome),
        ),
        onTap: () => context.push('/staff/nurse/profile/${student.id}'),
      ),
    );
  }

  Color _getOutcomeColor(VisitOutcome outcome) {
    switch (outcome) {
      case VisitOutcome.sentBackToClass:
        return Colors.black;
      case VisitOutcome.sentHome:
        return Colors.black;
      case VisitOutcome.admittedToSickBay:
        return Colors.black;
      case VisitOutcome.referredToHospital:
        return Colors.black;
    }
  }
}

extension on String {
  String splitCamelCase() {
    final value = replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
      (Match match) => '${match[1]} ${match[2]}',
    );
    return value.isEmpty ? value : value[0].toUpperCase() + value.substring(1);
  }
}
