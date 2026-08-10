import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/parent/widgets/student_app_bar.dart';
import 'package:school_pulse/features/patron/domain/entities/patron_entities.dart';
import 'package:school_pulse/features/patron/presentation/bloc/patron_bloc.dart';
import 'package:school_pulse/features/patron/presentation/bloc/patron_event.dart';
import 'package:school_pulse/features/patron/presentation/bloc/patron_state.dart';
import 'package:school_pulse/features/student/presentation/bloc/selected_student_bloc.dart';
import 'package:school_pulse/features/student/presentation/bloc/selected_student_state.dart';

class ParentBoardingScreen extends StatefulWidget {
  const ParentBoardingScreen({super.key});

  @override
  State<ParentBoardingScreen> createState() => _ParentBoardingScreenState();
}

class _ParentBoardingScreenState extends State<ParentBoardingScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final studentState = context.read<SelectedStudentBloc>().state;
    final authState = context.read<AuthBloc>().state;
    if (studentState is SelectedStudentLoaded &&
        authState is AuthAuthenticated) {
      final studentId = studentState.student.id;
      context.read<PatronBloc>().add(
        WatchBoardingStudents(),
      ); // To find dorm info
      context.read<PatronBloc>().add(
        WatchWelfareRecords(
          schoolId: authState.user.schoolId,
          studentId: studentId,
          publicOnly: true,
        ),
      );
      context.read<PatronBloc>().add(
        WatchDisciplineIncidents(studentId: studentId),
      );
      context.read<PatronBloc>().add(WatchAnnouncements());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const StudentAppBar(title: 'Boarding'),
      body: BlocBuilder<SelectedStudentBloc, SelectedStudentState>(
        builder: (context, studentState) {
          if (studentState is! SelectedStudentLoaded) {
            return const Center(child: SchoolPulseLoader());
          }

          final student = studentState.student;

          return BlocBuilder<PatronBloc, PatronState>(
            builder: (context, patronState) {
              return RefreshIndicator(
                onRefresh: () async {
                  _loadData();
                },
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildDormitoryInfo(student.id, patronState),
                    const SizedBox(height: 24),
                    _buildAnnouncements(patronState),
                    const SizedBox(height: 24),
                    _buildSectionHeader('Welfare & Health'),
                    _buildWelfareList(patronState),
                    const SizedBox(height: 24),
                    _buildSectionHeader('Discipline Records'),
                    _buildDisciplineList(patronState),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildAnnouncements(PatronState state) {
    if (state is AnnouncementsLoaded && state.announcements.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Recent Announcements'),
          ...state.announcements
              .take(2)
              .map(
                (announcement) => AppCard(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(
                      Icons.campaign_outlined,
                      color: Colors.orange,
                    ),
                    title: Text(announcement.title),
                    subtitle: Text(announcement.content),
                    trailing: Text(
                      DateFormat('MMM d').format(announcement.date),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
                ),
              ),
          const SizedBox(height: 16),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDormitoryInfo(String studentId, PatronState state) {
    BoardingStudent? boardingData;
    if (state is BoardingStudentsLoaded) {
      try {
        boardingData = state.students.firstWhere((s) => s.id == studentId);
      } catch (_) {
        boardingData = null;
      }
    }

    return AppCard(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.bed_outlined, size: 32),
            title: Text(boardingData?.dormitoryName ?? 'Not Assigned'),
            subtitle: Text(
              boardingData != null
                  ? 'Bed Number: ${boardingData.bedNumber ?? "N/A"}'
                  : 'Dormitory assignment pending',
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color:
                    (boardingData?.status == 'Present'
                            ? Colors.green
                            : Colors.orange)
                        .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                boardingData?.status ?? 'Unknown',
                style: TextStyle(
                  color: boardingData?.status == 'Present'
                      ? Colors.green
                      : Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelfareList(PatronState state) {
    if (state is PatronLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: SchoolPulseLoader(),
        ),
      );
    }

    if (state is WelfareRecordsLoaded) {
      if (state.records.isEmpty) {
        return const AppCard(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('No welfare records found.'),
          ),
        );
      }

      return Column(
        children: state.records.map((record) {
          if (record.isPrivate) return const SizedBox.shrink();
          return AppCard(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text(record.category),
              subtitle: Text(record.note),
              trailing: Text(
                DateFormat('MMM d, yyyy').format(record.date),
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
          );
        }).toList(),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildDisciplineList(PatronState state) {
    if (state is DisciplineIncidentsLoaded) {
      if (state.incidents.isEmpty) {
        return const AppCard(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('No discipline incidents recorded.'),
          ),
        );
      }

      return Column(
        children: state.incidents.map((incident) {
          return AppCard(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text(incident.category),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(incident.description),
                  const SizedBox(height: 4),
                  Text(
                    'Action: ${incident.actionTaken}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    DateFormat('MMM d').format(incident.date),
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color:
                          (incident.status == 'Resolved'
                                  ? Colors.green
                                  : Colors.orange)
                              .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      incident.status,
                      style: TextStyle(
                        color: incident.status == 'Resolved'
                            ? Colors.green
                            : Colors.orange,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      );
    }

    return const SizedBox.shrink();
  }
}
