import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/design_system/searchable_picker.dart';
import 'package:school_pulse/injection_container.dart' as di;
import 'package:school_pulse/core/usecases/usecase.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/features/discipline/domain/entities/discipline_incident.dart';
import 'package:school_pulse/features/discipline/domain/entities/counseling_session.dart';
import 'package:school_pulse/features/student/domain/entities/student.dart';
import 'package:school_pulse/features/student/domain/usecases/get_all_students.dart';
import 'package:school_pulse/features/auth/domain/usecases/get_staff_members.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/shared/staff_dashboard/staff_dashboard_widgets.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'bloc/discipline_bloc.dart';
import 'bloc/discipline_event.dart';
import 'bloc/discipline_state.dart';

/// Ways an incident can be closed out - shown as a structured "Punishment"
/// choice rather than free text, so reports can be aggregated later.
const List<String> kDisciplinaryActions = [
  'Verbal Warning',
  'Written Warning',
  'Detention',
  'Community Service',
  'Parent Meeting',
  'Suspension',
  'Expulsion Referral',
];

class DisciplineDashboardScreen extends StatefulWidget {
  const DisciplineDashboardScreen({super.key});

  @override
  State<DisciplineDashboardScreen> createState() =>
      _DisciplineDashboardScreenState();
}

class _DisciplineDashboardScreenState extends State<DisciplineDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Student> _students = [];
  Map<String, String> _classTeacherByClassName = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<DisciplineBloc>().add(LoadRecentIncidents());
    _loadLookups();
  }

  Future<void> _loadLookups() async {
    final studentsResult = await di.sl<GetAllStudents>()();
    final staffResult = await di.sl<GetStaffMembers>()(NoParams());
    if (!mounted) return;
    setState(() {
      _students = studentsResult.getOrElse(() => const []);
      final staff = staffResult.getOrElse(() => const []);
      _classTeacherByClassName = {
        for (final member in staff)
          if (member.role == UserRole.classTeacher &&
              (member.assignedClass ?? '').isNotEmpty)
            member.assignedClass!: member.name,
      };
    });
  }

  String _studentName(String studentId) {
    for (final s in _students) {
      if (s.id == studentId) return s.name;
    }
    return 'Unknown Student';
  }

  Student? _studentById(String studentId) {
    for (final s in _students) {
      if (s.id == studentId) return s;
    }
    return null;
  }

  String? _classTeacherFor(String studentId) {
    final student = _studentById(studentId);
    if (student == null) return null;
    return _classTeacherByClassName[student.className];
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final semanticColors = Theme.of(context).extension<SemanticColors>()!;

    return Scaffold(
      appBar: staffDashboardAppBar(context, roleLabel: 'Discipline & Guidance'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: BlocBuilder<DisciplineBloc, DisciplineState>(
              builder: (context, state) {
                final loaded = state is DisciplineLoaded ? state : null;
                return StaffHeroSummaryCard(
                  greetingNameFallback: 'there',
                  kpis: loaded == null
                      ? null
                      : [
                          StaffKpiData(
                            title: 'Total Incidents',
                            valueText: '${loaded.incidents.length}',
                            subtitle: 'Logged',
                            icon: Icons.gavel_outlined,
                            color: AppColors.information(context),
                          ),
                          StaffKpiData(
                            title: 'Pending Review',
                            valueText:
                                '${loaded.incidents.where((i) => i.resolution.isEmpty).length}',
                            subtitle: 'Needs action',
                            icon: Icons.pending_actions_outlined,
                            color: AppColors.danger(context),
                          ),
                          StaffKpiData(
                            title: 'Counseling Sessions',
                            valueText: '${loaded.sessions.length}',
                            subtitle: 'This month',
                            icon: Icons.psychology_outlined,
                            color: AppColors.success(context),
                          ),
                          StaffKpiData(
                            title: 'Resolved',
                            valueText:
                                '${loaded.incidents.where((i) => i.resolution.isNotEmpty).length}',
                            subtitle: 'Closed out',
                            icon: Icons.check_circle_outline_rounded,
                            color: AppColors.warning(context),
                          ),
                        ],
                );
              },
            ),
          ),
          Material(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Row(
              children: [
                Expanded(
                  child: TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(text: 'Incidents', icon: Icon(Icons.gavel)),
                      Tab(text: 'Counseling', icon: Icon(Icons.psychology)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainer,
                  ),
                  onPressed: () {
                    if (_tabController.index == 0) {
                      _showLogIncidentDialog(context);
                    } else {
                      _showLogCounselingDialog(context);
                    }
                  },
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<DisciplineBloc, DisciplineState>(
              builder: (context, state) {
                if (state is DisciplineLoading) {
                  return const _DisciplineDashboardSkeleton();
                }

                if (state is DisciplineError) {
                  return Center(child: Text(state.message));
                }

                if (state is DisciplineLoaded) {
                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _IncidentsTab(
                        state: state,
                        semanticColors: semanticColors,
                        studentName: _studentName,
                        classTeacherFor: _classTeacherFor,
                        onStartCounseling: (studentId, incidentId) {
                          _tabController.index = 1;
                          _showLogCounselingDialog(
                            context,
                            initialStudentId: studentId,
                            linkedIncidentId: incidentId,
                          );
                        },
                      ),
                      _CounselingTab(state: state, studentName: _studentName),
                    ],
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showLogIncidentDialog(BuildContext context) {
    final bloc = context.read<DisciplineBloc>();
    final descriptionController = TextEditingController();
    Severity severity = Severity.warning;

    showDialog(
      context: context,
      builder: (dialogContext) => FutureBuilder<List<Student>>(
        future: di.sl<GetAllStudents>()().then(
          (r) => r.getOrElse(() => const []),
        ),
        builder: (dialogContext, snapshot) {
          final students = snapshot.data ?? const <Student>[];
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AlertDialog(
              content: SizedBox(
                height: 80,
                child: Center(child: SchoolPulseLoader()),
              ),
            );
          }
          if (students.isEmpty) {
            return AlertDialog(
              title: const Text('Log Incident'),
              content: const Text('No students found.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Close'),
                ),
              ],
            );
          }
          String selectedStudentId = students.first.id;
          String? selectedPunishment;

          return StatefulBuilder(
            builder: (dialogContext, setDialogState) => AlertDialog(
              title: const Text('Log Incident'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SearchablePickerField<Student>(
                      label: 'Student',
                      value: students.firstWhere(
                        (s) => s.id == selectedStudentId,
                      ),
                      items: students,
                      labelBuilder: (s) => s.name,
                      subtitleBuilder: (s) => s.className,
                      onChanged: (s) =>
                          setDialogState(() => selectedStudentId = s.id),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<Severity>(
                      initialValue: severity,
                      decoration: const InputDecoration(labelText: 'Severity'),
                      items: Severity.values
                          .map(
                            (s) => DropdownMenuItem(
                              value: s,
                              child: Text(s.name.toUpperCase()),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setDialogState(() => severity = value ?? severity),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String?>(
                      initialValue: selectedPunishment,
                      decoration: const InputDecoration(
                        labelText: 'Punishment (optional - can decide later)',
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('Not yet decided'),
                        ),
                        ...kDisciplinaryActions.map(
                          (a) => DropdownMenuItem(value: a, child: Text(a)),
                        ),
                      ],
                      onChanged: (value) =>
                          setDialogState(() => selectedPunishment = value),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    if (descriptionController.text.trim().isEmpty) return;
                    bloc.add(
                      LogIncidentRequested(
                        studentId: selectedStudentId,
                        description: descriptionController.text.trim(),
                        severity: severity,
                        punishment: selectedPunishment ?? '',
                      ),
                    );
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Log Incident'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showLogCounselingDialog(
    BuildContext context, {
    String? initialStudentId,
    String? linkedIncidentId,
  }) {
    final bloc = context.read<DisciplineBloc>();
    final authState = context.read<AuthBloc>().state;
    final counselorId = authState is AuthAuthenticated ? authState.user.id : '';
    final reasonController = TextEditingController();
    final notesController = TextEditingController();
    final recommendationsController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => FutureBuilder<List<Student>>(
        future: di.sl<GetAllStudents>()().then(
          (r) => r.getOrElse(() => const []),
        ),
        builder: (dialogContext, snapshot) {
          final students = snapshot.data ?? const <Student>[];
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AlertDialog(
              content: SizedBox(
                height: 80,
                child: Center(child: SchoolPulseLoader()),
              ),
            );
          }
          if (students.isEmpty) {
            return AlertDialog(
              title: const Text('Log Counseling'),
              content: const Text('No students found.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Close'),
                ),
              ],
            );
          }
          String selectedStudentId =
              students.any((s) => s.id == initialStudentId)
              ? initialStudentId!
              : students.first.id;

          return StatefulBuilder(
            builder: (dialogContext, setDialogState) => AlertDialog(
              title: Text(
                linkedIncidentId != null
                    ? 'Log Counseling Session (from incident)'
                    : 'Log Counseling Session',
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SearchablePickerField<Student>(
                      label: 'Student',
                      value: students.firstWhere(
                        (s) => s.id == selectedStudentId,
                      ),
                      items: students,
                      labelBuilder: (s) => s.name,
                      subtitleBuilder: (s) => s.className,
                      onChanged: (s) =>
                          setDialogState(() => selectedStudentId = s.id),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: reasonController,
                      decoration: const InputDecoration(
                        labelText: 'Reason for Counseling',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: notesController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Session Notes',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: recommendationsController,
                      decoration: const InputDecoration(
                        labelText: 'Recommendations',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    if (reasonController.text.trim().isEmpty) return;
                    bloc.add(
                      LogCounselingSessionRequested(
                        studentId: selectedStudentId,
                        counselorId: counselorId,
                        reason: reasonController.text.trim(),
                        notes: notesController.text.trim(),
                        recommendations: recommendationsController.text.trim(),
                        linkedIncidentId: linkedIncidentId,
                      ),
                    );
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Log Session'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _IncidentsTab extends StatelessWidget {
  final DisciplineLoaded state;
  final SemanticColors semanticColors;
  final String Function(String studentId) studentName;
  final String? Function(String studentId) classTeacherFor;
  final void Function(String studentId, String incidentId) onStartCounseling;

  const _IncidentsTab({
    required this.state,
    required this.semanticColors,
    required this.studentName,
    required this.classTeacherFor,
    required this.onStartCounseling,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<DisciplineBloc>().add(LoadRecentIncidents());
      },
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
        children: [
          Row(
            children: [
              Expanded(
                child: DashboardStatCard(
                  title: 'Total Incidents',
                  value: state.incidents.length.toDouble(),
                  icon: Icons.gavel_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DashboardStatCard(
                  title: 'Pending Review',
                  value: state.incidents
                      .where((i) => i.resolution.isEmpty)
                      .length
                      .toDouble(),
                  icon: Icons.pending_actions_outlined,
                  color: semanticColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Recent Incidents'),
          const SizedBox(height: 12),
          if (state.incidents.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text('No recent incidents recorded.'),
              ),
            )
          else
            ...state.incidents.asMap().entries.map((entry) {
              final index = entry.key;
              final incident = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: FadeInSlide(
                  delay: Duration(milliseconds: 100 + (index * 50)),
                  child: AppCard(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getSeverityColor(
                          incident.severity,
                          semanticColors,
                        ).withValues(alpha: 0.1),
                        child: Icon(
                          Icons.warning_amber_rounded,
                          color: _getSeverityColor(
                            incident.severity,
                            semanticColors,
                          ),
                        ),
                      ),
                      title: Text(studentName(incident.studentId)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            incident.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('MMM d, yyyy').format(incident.date),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      isThreeLine: true,
                      onTap: () => _showIncidentDetail(context, incident),
                    ),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  void _showIncidentDetail(BuildContext context, DisciplineIncident incident) {
    final teacher = classTeacherFor(incident.studentId);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(studentName(incident.studentId)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('MMM d, yyyy').format(incident.date),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (teacher != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Class Teacher: $teacher',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: 12),
              Text(incident.description),
              if (incident.punishment.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'Punishment',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                Text(incident.punishment),
              ],
              if (incident.resolution.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'Resolution',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                Text(incident.resolution),
              ],
              if (incident.counselingNotes.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'Counseling Notes',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                Text(incident.counselingNotes),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
          FilledButton.icon(
            icon: const Icon(Icons.psychology_outlined, size: 18),
            label: const Text('Start Counseling'),
            onPressed: () {
              Navigator.pop(dialogContext);
              onStartCounseling(incident.studentId, incident.id);
            },
          ),
        ],
      ),
    );
  }

  Color _getSeverityColor(Severity severity, SemanticColors semanticColors) {
    switch (severity) {
      case Severity.info:
        return semanticColors.info;
      case Severity.success:
        return semanticColors.success;
      case Severity.warning:
        return semanticColors.warning;
      case Severity.error:
        return semanticColors.error;
    }
  }
}

class _CounselingTab extends StatelessWidget {
  final DisciplineLoaded state;
  final String Function(String studentId) studentName;

  const _CounselingTab({required this.state, required this.studentName});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<DisciplineBloc>().add(LoadRecentIncidents());
      },
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
        children: [
          DashboardStatCard(
            title: 'Sessions This Month',
            value: state.sessions.length.toDouble(),
            icon: Icons.psychology_outlined,
            color: Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Recent Sessions'),
          const SizedBox(height: 12),
          if (state.sessions.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text('No counseling sessions recorded.'),
              ),
            )
          else
            ...state.sessions.asMap().entries.map((entry) {
              final index = entry.key;
              final session = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: FadeInSlide(
                  delay: Duration(milliseconds: 100 + (index * 50)),
                  child: AppCard(
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Icon(
                          session.linkedIncidentId != null
                              ? Icons.link
                              : Icons.person_outline,
                        ),
                      ),
                      title: Text('Reason: ${session.reason}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Student: ${studentName(session.studentId)}'),
                          Text(
                            DateFormat('MMM d, yyyy').format(session.date),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      onTap: () => _showSessionDetail(context, session),
                    ),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  void _showSessionDetail(BuildContext context, CounselingSession session) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(studentName(session.studentId)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('MMM d, yyyy').format(session.date),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (session.linkedIncidentId != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Linked to a discipline incident',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                ),
              ],
              const SizedBox(height: 12),
              Text('Reason:', style: Theme.of(context).textTheme.labelMedium),
              Text(session.reason),
              const SizedBox(height: 12),
              Text('Notes:', style: Theme.of(context).textTheme.labelMedium),
              Text(session.notes),
              const SizedBox(height: 12),
              Text(
                'Recommendations:',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              Text(session.recommendations),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _DisciplineDashboardSkeleton extends StatelessWidget {
  const _DisciplineDashboardSkeleton();

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
        ...List.generate(
          5,
          (index) => const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Skeleton(height: 80, borderRadius: 12),
          ),
        ),
      ],
    );
  }
}
