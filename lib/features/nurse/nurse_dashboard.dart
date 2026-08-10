import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/design_system/searchable_picker.dart';
import 'package:school_pulse/core/utils.dart';
import 'package:school_pulse/injection_container.dart' as di;
import 'package:school_pulse/features/student/domain/entities/student.dart';
import 'package:school_pulse/features/student/domain/usecases/get_all_students.dart';
import 'package:school_pulse/features/health/domain/entities/clinic_visit.dart';
import 'package:school_pulse/features/health/domain/entities/emergency_incident.dart';
import 'package:school_pulse/features/matron/domain/entities/boarding_entities.dart';
import 'package:school_pulse/features/health/presentation/bloc/health_bloc.dart';
import 'package:school_pulse/features/health/presentation/bloc/health_event.dart';
import 'package:school_pulse/features/health/presentation/bloc/health_state.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';

import 'package:school_pulse/features/notifications/presentation/notification_bell_button.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/domain/usecases/get_staff_members.dart';
import 'package:school_pulse/features/student/domain/entities/parent_access_code.dart';
import 'package:school_pulse/features/student/domain/usecases/manage_parent_access_codes.dart';
import 'package:school_pulse/core/usecases/usecase.dart';

class NurseDashboardScreen extends StatefulWidget {
  const NurseDashboardScreen({super.key});

  @override
  State<NurseDashboardScreen> createState() => _NurseDashboardScreenState();
}

class _NurseDashboardScreenState extends State<NurseDashboardScreen> {
  List<Student> _allStudents = [];
  List<UserEntity> _allStaff = [];
  List<ParentAccessCode> _parentCodes = [];

  UserEntity? get _currentUser {
    final state = context.read<AuthBloc>().state;
    return state is AuthAuthenticated ? state.user : null;
  }

  String get _schoolId => _currentUser?.schoolId ?? '';

  @override
  void initState() {
    super.initState();
    _loadMetadata();
    context.read<HealthBloc>().add(FetchHealthDashboardData(_schoolId));
  }

  Future<void> _loadMetadata() async {
    final results = await Future.wait([
      di.sl<GetAllStudents>()(schoolId: _schoolId).then(
        (r) => r.getOrElse(() => const <Student>[]),
      ),
      di.sl<GetStaffMembers>()(NoParams()).then(
        (r) => r.fold(
          (_) => <UserEntity>[],
          (staff) =>
              staff.where((member) => member.schoolId == _schoolId).toList(),
        ),
      ),
      di.sl<GetAllAccessCodes>()(schoolId: _schoolId).then(
        (r) => r.fold((_) => <ParentAccessCode>[], (c) => c),
      ),
    ]);
    if (mounted) {
      setState(() {
        _allStudents = results[0] as List<Student>;
        _allStaff = results[1] as List<UserEntity>;
        _parentCodes = results[2] as List<ParentAccessCode>;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final semanticColors = Theme.of(context).extension<SemanticColors>()!;

    return BlocListener<HealthBloc, HealthState>(
      listener: (context, state) {
        if (state is HealthActionSuccess) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
          context.read<HealthBloc>().add(FetchHealthDashboardData(_schoolId));
        } else if (state is HealthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: semanticColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        body: BlocBuilder<HealthBloc, HealthState>(
          builder: (context, state) {
            if (_schoolId.isEmpty) {
              return const EmptyState(
                icon: Icons.domain_disabled_outlined,
                title: 'School assignment required',
                message:
                    'This nurse account is not assigned to a school. Ask an administrator to update the account.',
              );
            }

            if (state is HealthLoading || state is HealthInitial) {
              return const Center(child: SchoolPulseLoader());
            }

            if (state is HealthDashboardLoaded) {
              final welfareConcerns = state.welfareRecords
                  .where(
                    (record) =>
                        record.category == 'Concern' ||
                        record.category == 'Sick',
                  )
                  .toList();
              final authState = context.watch<AuthBloc>().state;
              final userName = authState is AuthAuthenticated
                  ? authState.user.name
                  : 'User';

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<HealthBloc>().add(
                    FetchHealthDashboardData(_schoolId),
                  );
                },
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  children: [
                    const SizedBox(height: 48), // Space for status bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome back,',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.outline,
                                    ),
                              ),
                              Text(
                                userName,
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.5,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.chat_bubble_outline_rounded,
                              ),
                              onPressed: () => context.push('/staff/messages'),
                              tooltip: 'Messages',
                              style: IconButton.styleFrom(
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainer,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const NotificationBellButton(),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildStatsGrid(state, semanticColors),
                    const SizedBox(height: 20),
                    _buildQuickActions(context),
                    const SizedBox(height: 24),
                    if (state.todayEmergencies.isNotEmpty) ...[
                      const SectionHeader(
                        title: "Today's Emergencies",
                        color: Colors.red,
                      ),
                      ...state.todayEmergencies.map(
                        (e) =>
                            _EmergencyCard(incident: e, students: _allStudents),
                      ),
                      const SizedBox(height: 24),
                    ],
                    if (welfareConcerns.isNotEmpty) ...[
                      const SectionHeader(title: 'Boarding Welfare Concerns'),
                      ...welfareConcerns.map(
                        (record) => _WelfareCard(
                          record: record,
                          students: _allStudents,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    const SectionHeader(title: 'Recent Clinic Visits'),
                    if (state.todayVisits.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text('No clinic visits recorded today.'),
                        ),
                      )
                    else
                      ...state.todayVisits
                          .take(10)
                          .map(
                            (visit) => _VisitCard(
                              visit: visit,
                              students: _allStudents,
                              staff: _allStaff,
                              parentCodes: _parentCodes,
                            ),
                          ),
                    const SizedBox(height: 24),
                    if (state.lowStockItems.isNotEmpty) ...[
                      const SectionHeader(title: 'Inventory Alerts'),
                      AppCard(
                        color: semanticColors.warning.withValues(alpha: 0.1),
                        child: Column(
                          children: state.lowStockItems
                              .map(
                                (item) => ListTile(
                                  leading: Icon(
                                    Icons.warning_amber_rounded,
                                    color: semanticColors.warning,
                                  ),
                                  title: Text(item.name),
                                  subtitle: Text(
                                    'Only ${item.quantity} ${item.unit} left (Reorder at ${item.reorderLevel})',
                                  ),
                                  trailing: TextButton(
                                    onPressed: () =>
                                        context.push('/staff/nurse/inventory'),
                                    child: const Text('Restock'),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ],
                    if (state.pendingRequests.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      const SectionHeader(title: 'Medical Supply Requests'),
                      ...state.pendingRequests
                          .take(5)
                          .map(
                            (request) => AppCard(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: const Icon(
                                  Icons.local_shipping_outlined,
                                ),
                                title: Text(request.itemName),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${request.quantity} ${request.unit} • ${request.status.name.splitCamelCase()}',
                                    ),
                                    if (request.rejectionReason
                                            ?.trim()
                                            .isNotEmpty ==
                                        true)
                                      Text(
                                        'Reason: ${request.rejectionReason}',
                                        style: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.error,
                                        ),
                                      ),
                                  ],
                                ),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () =>
                                    context.push('/staff/nurse/inventory'),
                              ),
                            ),
                          ),
                    ],
                  ],
                ),
              );
            }

            if (state is HealthError) {
              return EmptyState(
                icon: Icons.cloud_off_outlined,
                title: 'Could not load health data',
                message: state.message,
                ctaLabel: 'Retry',
                onCtaPressed: () => context.read<HealthBloc>().add(
                  FetchHealthDashboardData(_schoolId),
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          key: const Key('nurse-new-visit-button'),
          onPressed: () => _showNewVisitDialog(context),
          label: const Text('New Visit'),
          icon: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(
    HealthDashboardLoaded state,
    SemanticColors semanticColors,
  ) {
    return Row(
      children: [
        Expanded(
          child: DashboardStatCard(
            title: 'Visits Today',
            value: state.todayVisits.length.toDouble(),
            icon: Icons.medical_services_outlined,
            color: semanticColors.info,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DashboardStatCard(
            title: 'Emergencies',
            value: state.todayEmergencies.length.toDouble(),
            icon: Icons.emergency_outlined,
            color: semanticColors.error,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 8,
      childAspectRatio: 0.9,
      children: [
        _QuickActionButton(
          icon: Icons.person_search_outlined,
          label: 'Student Health',
          onTap: () => _showStudentSearch(context),
        ),
        _QuickActionButton(
          icon: Icons.report_problem_outlined,
          label: 'Emergency',
          onTap: () => _showEmergencyDialog(context),
        ),
        _QuickActionButton(
          icon: Icons.history_outlined,
          label: 'All History',
          onTap: () => context.push('/staff/nurse/history'),
        ),
        _QuickActionButton(
          icon: Icons.inventory_2_outlined,
          label: 'Inventory',
          onTap: () => context.push('/staff/nurse/inventory'),
        ),
        _QuickActionButton(
          icon: Icons.message_outlined,
          label: 'Messages',
          onTap: () => context.push('/staff/messages'),
        ),
        _QuickActionButton(
          icon: Icons.support_agent_outlined,
          label: 'Support',
          onTap: () => _showAdminContactsSheet(context),
        ),
      ],
    );
  }

  void _showStudentSearch(BuildContext context) {
    if (_allStudents.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No students are available for this school. Pull down to retry.',
          ),
        ),
      );
      return;
    }
    showSearch(
      context: context,
      delegate: StudentHealthSearchDelegate(_allStudents),
    );
  }

  void _showEmergencyDialog(BuildContext context) {
    if (_allStudents.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No students are available for this school.'),
        ),
      );
      return;
    }
    String? selectedStudentId;
    final detailsController = TextEditingController();
    final firstAidController = TextEditingController();
    final referralController = TextEditingController();
    var ambulanceRequired = false;
    var parentNotified = false;
    String? validationError;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Report Emergency Incident'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SearchablePickerField<Student>(
                  label: 'Student',
                  value: selectedStudentId != null
                      ? _allStudents.firstWhere(
                          (s) => s.id == selectedStudentId,
                        )
                      : null,
                  items: _allStudents,
                  labelBuilder: (s) => s.name,
                  subtitleBuilder: (s) => s.className,
                  onChanged: (s) =>
                      setDialogState(() => selectedStudentId = s.id),
                ),
                const SizedBox(height: 16),
                TextField(
                  key: const Key('emergency-details-field'),
                  controller: detailsController,
                  decoration: const InputDecoration(
                    labelText: 'Incident Details',
                    hintText: 'What happened?',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: referralController,
                  decoration: const InputDecoration(
                    labelText: 'Hospital / referral details (optional)',
                  ),
                ),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Ambulance required'),
                  value: ambulanceRequired,
                  onChanged: (value) =>
                      setDialogState(() => ambulanceRequired = value),
                ),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Parent already notified'),
                  value: parentNotified,
                  onChanged: (value) =>
                      setDialogState(() => parentNotified = value),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: firstAidController,
                  decoration: const InputDecoration(
                    labelText: 'First Aid Provided',
                  ),
                  maxLines: 2,
                ),
                if (validationError != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    validationError!,
                    key: const Key('emergency-validation-error'),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              key: const Key('record-emergency-button'),
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                if (selectedStudentId == null) {
                  setDialogState(
                    () => validationError = 'Select the student involved.',
                  );
                  return;
                }
                if (detailsController.text.trim().isEmpty) {
                  setDialogState(
                    () => validationError = 'Describe what happened.',
                  );
                  return;
                }
                if (_schoolId.isEmpty || (_currentUser?.id ?? '').isEmpty) {
                  setDialogState(
                    () => validationError =
                        'Your nurse account is missing its school assignment.',
                  );
                  return;
                }
                context.read<HealthBloc>().add(
                  RecordNewEmergencyIncident(
                    EmergencyIncident(
                      id: '',
                      studentId: selectedStudentId!,
                      dateTime: DateTime.now(),
                      incidentDetails: detailsController.text.trim(),
                      firstAidGiven: firstAidController.text.trim(),
                      ambulanceRequired: ambulanceRequired,
                      hospitalReferral: referralController.text.trim().isEmpty
                          ? null
                          : referralController.text.trim(),
                      parentNotified: parentNotified,
                      staffInvolved: const [],
                      outcome: 'Pending assessment',
                      recordedBy: _currentUser?.id ?? '',
                      schoolId: _schoolId,
                    ),
                  ),
                );
                Navigator.pop(context);
              },
              child: const Text('Record Emergency'),
            ),
          ],
        ),
      ),
    );
  }

  void _showNewVisitDialog(BuildContext context) {
    if (_allStudents.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No students are available for this school.'),
        ),
      );
      return;
    }
    String? selectedStudentId;
    final reasonController = TextEditingController();
    final symptomsController = TextEditingController();
    final tempController = TextEditingController();
    final diagnosisController = TextEditingController();
    VisitOutcome selectedOutcome = VisitOutcome.sentBackToClass;
    String? validationError;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 20,
        ),
        child: StatefulBuilder(
          builder: (context, setDialogState) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'New Clinic Visit',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SearchablePickerField<Student>(
                  label: 'Student',
                  value: selectedStudentId != null
                      ? _allStudents.firstWhere(
                          (s) => s.id == selectedStudentId,
                        )
                      : null,
                  items: _allStudents,
                  labelBuilder: (s) => s.name,
                  subtitleBuilder: (s) => s.className,
                  onChanged: (s) =>
                      setDialogState(() => selectedStudentId = s.id),
                ),
                const SizedBox(height: 16),
                TextField(
                  key: const Key('visit-reason-field'),
                  controller: reasonController,
                  decoration: const InputDecoration(
                    labelText: 'Reason for Visit',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: symptomsController,
                  decoration: const InputDecoration(labelText: 'Symptoms'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: tempController,
                        decoration: const InputDecoration(
                          labelText: 'Temp (°C)',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<VisitOutcome>(
                        isExpanded: true,
                        initialValue: selectedOutcome,
                        decoration: const InputDecoration(labelText: 'Outcome'),
                        items: VisitOutcome.values
                            .map(
                              (o) => DropdownMenuItem(
                                value: o,
                                child: Text(o.name.splitCamelCase()),
                              ),
                            )
                            .toList(),
                        onChanged: (val) =>
                            setDialogState(() => selectedOutcome = val!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: diagnosisController,
                  decoration: const InputDecoration(
                    labelText: 'Diagnosis / Notes',
                  ),
                ),
                if (validationError != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    validationError!,
                    key: const Key('visit-validation-error'),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  key: const Key('complete-visit-button'),
                  onPressed: () {
                    final temperature = tempController.text.trim().isEmpty
                        ? null
                        : double.tryParse(tempController.text.trim());
                    if (selectedStudentId == null) {
                      setDialogState(
                        () => validationError = 'Select a student.',
                      );
                      return;
                    }
                    if (reasonController.text.trim().isEmpty) {
                      setDialogState(
                        () =>
                            validationError = 'Enter the reason for the visit.',
                      );
                      return;
                    }
                    if (tempController.text.trim().isNotEmpty &&
                        (temperature == null ||
                            temperature < 30 ||
                            temperature > 45)) {
                      setDialogState(
                        () => validationError =
                            'Enter a temperature between 30°C and 45°C.',
                      );
                      return;
                    }
                    if (_schoolId.isEmpty || (_currentUser?.id ?? '').isEmpty) {
                      setDialogState(
                        () => validationError =
                            'Your nurse account is missing its school assignment.',
                      );
                      return;
                    }
                    context.read<HealthBloc>().add(
                      RecordNewClinicVisit(
                        ClinicVisit(
                          id: '',
                          studentId: selectedStudentId!,
                          dateTime: DateTime.now(),
                          reason: reasonController.text.trim(),
                          symptoms: symptomsController.text.trim(),
                          temperature: temperature,
                          diagnosis: diagnosisController.text.trim(),
                          outcome: selectedOutcome,
                          recordedBy: _currentUser?.id ?? '',
                          schoolId: _schoolId,
                        ),
                      ),
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('Complete Visit Log'),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAdminContactsSheet(BuildContext context) {
    final staff = _allStaff
        .where((s) => s.isActive && s.schoolId == _schoolId)
        .toList();
    final leadership = staff
        .where(
          (s) => s.role == UserRole.headTeacher || s.role == UserRole.director,
        )
        .toList();
    final storekeepers = staff
        .where((s) => s.role == UserRole.storeInventory)
        .toList();

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Contact Admin / Store',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            if (leadership.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Escalate a health matter',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              ...leadership.map(
                (member) => ListTile(
                  leading: const Icon(Icons.admin_panel_settings_outlined),
                  title: Text(member.name),
                  subtitle: Text(UserRoleDisplay.name(member.role)),
                  onTap: () {
                    Navigator.pop(context);
                    context.push(
                      '/staff/messages?recipientId=${member.id}&recipientName=${Uri.encodeComponent(member.name)}&recipientRole=${Uri.encodeComponent(UserRoleDisplay.name(member.role))}',
                    );
                  },
                ),
              ),
            ],
            if (storekeepers.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Request new medical supplies',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              ...storekeepers.map(
                (member) => ListTile(
                  leading: const Icon(Icons.inventory_2_outlined),
                  title: Text(member.name),
                  subtitle: const Text('Storekeeper'),
                  onTap: () {
                    Navigator.pop(context);
                    context.push(
                      '/staff/messages?recipientId=${member.id}&recipientName=${Uri.encodeComponent(member.name)}&recipientRole=Storekeeper',
                    );
                  },
                ),
              ),
            ],
            if (leadership.isEmpty && storekeepers.isEmpty)
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Text(
                  'No active leadership or Store contacts are configured for this school.',
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}

class _EmergencyCard extends StatelessWidget {
  final EmergencyIncident incident;
  final List<Student> students;

  const _EmergencyCard({required this.incident, required this.students});

  @override
  Widget build(BuildContext context) {
    final student = students.firstWhere(
      (s) => s.id == incident.studentId,
      orElse: () => Student.empty(incident.studentId),
    );
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.red.shade50,
      borderColor: Colors.red.shade200,
      child: ListTile(
        leading: const Icon(Icons.emergency, color: Colors.red),
        title: Text(
          student.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        subtitle: Text(
          incident.incidentDetails,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.red),
        onTap: () => context.push('/staff/nurse/incident/${incident.id}'),
      ),
    );
  }
}

class _WelfareCard extends StatelessWidget {
  final WelfareRecord record;
  final List<Student> students;

  const _WelfareCard({required this.record, required this.students});

  @override
  Widget build(BuildContext context) {
    final student = students.firstWhere(
      (s) => s.id == record.studentId,
      orElse: () => Student.empty(record.studentId),
    );
    final semanticColors = Theme.of(context).extension<SemanticColors>()!;

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AvatarInitials(name: student.name, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      DateFormatter.relative(record.date),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
              StatusBadge(
                label: 'Dorm: ${record.category}',
                color: record.category == 'Sick'
                    ? semanticColors.error
                    : semanticColors.warning,
              ),
            ],
          ),
          const Divider(height: 24),
          _VisitDetail(label: 'Note', value: record.note),
          const SizedBox(height: 8),
          _VisitDetail(label: 'Recorded By', value: record.recordedBy),
          const Divider(height: 24),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () =>
                  context.push('/staff/nurse/profile/${student.id}'),
              child: const Text('Check Health History'),
            ),
          ),
        ],
      ),
    );
  }
}

class _VisitCard extends StatelessWidget {
  final ClinicVisit visit;
  final List<Student> students;
  final List<UserEntity> staff;
  final List<ParentAccessCode> parentCodes;

  const _VisitCard({
    required this.visit,
    required this.students,
    required this.staff,
    required this.parentCodes,
  });

  @override
  Widget build(BuildContext context) {
    final student = students.firstWhere(
      (s) => s.id == visit.studentId,
      orElse: () => Student.empty(visit.studentId),
    );
    final semanticColors = Theme.of(context).extension<SemanticColors>()!;

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AvatarInitials(name: student.name, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      DateFormatter.relative(visit.dateTime),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
              StatusBadge(
                label: visit.outcome.name.splitCamelCase(),
                color: _getOutcomeColor(visit.outcome, semanticColors),
              ),
            ],
          ),
          const Divider(height: 24),
          _VisitDetail(label: 'Reason', value: visit.reason),
          if (visit.symptoms.isNotEmpty) ...[
            const SizedBox(height: 8),
            _VisitDetail(label: 'Symptoms', value: visit.symptoms),
          ],
          if (visit.temperature != null) ...[
            const SizedBox(height: 8),
            _VisitDetail(label: 'Vitals', value: '${visit.temperature}°C'),
          ],
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () =>
                    context.push('/staff/nurse/profile/${student.id}'),
                child: const Text('View Profile'),
              ),
              IconButton(
                icon: const Icon(Icons.chat_bubble_outline, size: 20),
                onPressed: () => _showCommunicationSheet(context, student),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getOutcomeColor(VisitOutcome outcome, SemanticColors colors) {
    switch (outcome) {
      case VisitOutcome.sentBackToClass:
        return colors.success;
      case VisitOutcome.sentHome:
        return colors.warning;
      case VisitOutcome.admittedToSickBay:
        return colors.info;
      case VisitOutcome.referredToHospital:
        return colors.error;
    }
  }

  void _showCommunicationSheet(BuildContext context, Student student) {
    final parent = parentCodes
        .where((c) => c.studentIds.contains(student.id))
        .firstOrNull;
    final teacher = staff
        .where(
          (s) =>
              s.role == UserRole.classTeacher &&
              s.assignedClass == student.className,
        )
        .firstOrNull;

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Message regarding ${student.name}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            if (parent != null)
              ListTile(
                leading: const Icon(Icons.family_restroom),
                title: Text('Parent: ${parent.parentName ?? "Parent"}'),
                onTap: () {
                  Navigator.pop(context);
                  context.push(
                    '/staff/messages?recipientId=parent_${parent.parentCode}&recipientName=${Uri.encodeComponent(parent.parentName ?? "Parent")}&recipientRole=Parent',
                  );
                },
              ),
            if (teacher != null)
              ListTile(
                leading: const Icon(Icons.badge_outlined),
                title: Text('Class Teacher: ${teacher.name}'),
                onTap: () {
                  Navigator.pop(context);
                  context.push(
                    '/staff/messages?recipientId=${teacher.id}&recipientName=${Uri.encodeComponent(teacher.name)}&recipientRole=Class Teacher',
                  );
                },
              ),
            if (parent == null && teacher == null)
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 4, 24, 20),
                child: Text(
                  'No parent or class teacher contact is linked to this student yet.',
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _VisitDetail extends StatelessWidget {
  final String label;
  final String value;
  const _VisitDetail({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
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

class StudentHealthSearchDelegate extends SearchDelegate {
  final List<Student> students;
  StudentHealthSearchDelegate(this.students);

  @override
  List<Widget>? buildActions(BuildContext context) => [
    IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
  ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => close(context, null),
  );

  @override
  Widget buildResults(BuildContext context) => _buildList(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildList(context);

  Widget _buildList(BuildContext context) {
    final filtered = students
        .where(
          (s) =>
              s.name.toLowerCase().contains(query.toLowerCase()) ||
              s.className.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();

    if (filtered.isEmpty) {
      return const EmptyState(
        icon: Icons.person_search_outlined,
        title: 'No students found',
        message: 'Try a different student name or class.',
      );
    }

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final student = filtered[index];
        return ListTile(
          leading: AvatarInitials(name: student.name),
          title: Text(student.name),
          subtitle: Text(student.className),
          onTap: () {
            close(context, null);
            context.push('/staff/nurse/profile/${student.id}');
          },
        );
      },
    );
  }
}

extension StringExtension on String {
  String splitCamelCase() {
    return replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
      (Match m) => '${m[1]} ${m[2]}',
    ).capitalize();
  }

  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}
