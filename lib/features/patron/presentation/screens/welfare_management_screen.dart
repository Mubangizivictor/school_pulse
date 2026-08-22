import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/searchable_picker.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/patron/domain/entities/patron_entities.dart';
import 'package:school_pulse/features/patron/presentation/bloc/patron_bloc.dart';
import 'package:school_pulse/features/patron/presentation/bloc/patron_event.dart';
import 'package:school_pulse/features/patron/presentation/bloc/patron_state.dart';
import 'package:school_pulse/features/student/domain/entities/student.dart';
import 'package:school_pulse/features/student/domain/usecases/get_all_students.dart';
import 'package:school_pulse/injection_container.dart' as di;

const _kWelfareCategories = [
  'Concern',
  'Check-in',
  'Counseling',
  'Check-up',
  'Observation',
];

class WelfareManagementScreen extends StatefulWidget {
  const WelfareManagementScreen({super.key});

  @override
  State<WelfareManagementScreen> createState() =>
      _WelfareManagementScreenState();
}

class _WelfareManagementScreenState extends State<WelfareManagementScreen>
    with SingleTickerProviderStateMixin {
  List<Student> _students = const [];
  late final TabController _tabController;

  AuthAuthenticated? get _auth {
    final state = context.read<AuthBloc>().state;
    return state is AuthAuthenticated ? state : null;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    final schoolId = _auth?.user.schoolId ?? '';
    context.read<PatronBloc>().add(WatchWelfareRecords(schoolId: schoolId));
    context.read<PatronBloc>().add(const WatchCounselingReferrals());
    context.read<PatronBloc>().add(const WatchBehaviourObservations());
    _loadStudents();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadStudents() async {
    final auth = _auth;
    if (auth == null || auth.user.schoolId.isEmpty) return;
    final result = await di.sl<GetAllStudents>()(schoolId: auth.user.schoolId);
    if (!mounted) return;
    result.fold((_) => null, (students) {
      setState(() {
        _students = students
            .where((student) => student.gender.name == 'male')
            .toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welfare Monitoring'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Welfare Log'),
            Tab(text: 'Referrals'),
            Tab(text: 'Behaviour'),
          ],
        ),
      ),
      body: BlocListener<PatronBloc, PatronState>(
        listenWhen: (_, current) =>
            current is PatronActionSuccess || current is PatronError,
        listener: (context, state) {
          if (state is PatronActionSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is PatronError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: TabBarView(
          controller: _tabController,
          children: [
            _WelfareLogTab(students: _students, auth: _auth),
            _ReferralsTab(students: _students, auth: _auth),
            _BehaviourTab(students: _students, auth: _auth),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          switch (_tabController.index) {
            case 0:
              _showLogWelfareDialog(context);
              break;
            case 1:
              _showLogReferralDialog(context);
              break;
            case 2:
              _showLogBehaviourDialog(context);
              break;
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('New'),
      ),
    );
  }

  void _showLogWelfareDialog(BuildContext context) {
    final noteController = TextEditingController();
    String selectedCategory = 'Concern';
    Student? selectedStudent;
    var isPrivate = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) {
          return AlertDialog(
            title: const Text('Log Welfare Entry'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SearchablePickerField<Student>(
                    label: 'Student',
                    value: selectedStudent,
                    items: _students,
                    labelBuilder: (student) => student.name,
                    subtitleBuilder: (student) => student.className,
                    onChanged: (student) =>
                        setState(() => selectedStudent = student),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Category'),
                    initialValue: selectedCategory,
                    items: _kWelfareCategories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (val) => setState(() => selectedCategory = val!),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: noteController,
                    decoration: const InputDecoration(
                      labelText: 'Observations / Notes',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    onChanged: (_) => setState(() {}),
                  ),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Private record'),
                    subtitle: const Text(
                      'Only boarding staff and administrators can view it',
                    ),
                    value: isPrivate,
                    onChanged: (value) =>
                        setState(() => isPrivate = value ?? false),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed:
                    selectedStudent == null || noteController.text.isEmpty
                    ? null
                    : () {
                        final record = WelfareRecord(
                          id: '',
                          schoolId: _auth?.user.schoolId ?? '',
                          studentId: selectedStudent!.id,
                          studentName: selectedStudent!.name,
                          category: selectedCategory,
                          note: noteController.text.trim(),
                          date: DateTime.now(),
                          recordedBy: _auth?.user.name ?? 'Patron',
                          isPrivate: isPrivate,
                        );
                        context.read<PatronBloc>().add(
                          LogWelfareRecordEvent(record),
                        );
                        Navigator.pop(dialogContext);
                      },
                child: const Text('Save Record'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showLogReferralDialog(BuildContext context) {
    final reasonController = TextEditingController();
    final referredToController = TextEditingController();
    Student? selectedStudent;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) {
          return AlertDialog(
            title: const Text('Counseling Referral'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SearchablePickerField<Student>(
                    label: 'Student',
                    value: selectedStudent,
                    items: _students,
                    labelBuilder: (student) => student.name,
                    subtitleBuilder: (student) => student.className,
                    onChanged: (student) =>
                        setState(() => selectedStudent = student),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: reasonController,
                    decoration: const InputDecoration(
                      labelText: 'Reason for Referral',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: referredToController,
                    decoration: const InputDecoration(
                      labelText: 'Referred To (optional)',
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
              ElevatedButton(
                onPressed:
                    selectedStudent == null || reasonController.text.isEmpty
                    ? null
                    : () {
                        context.read<PatronBloc>().add(
                          LogCounselingReferralEvent(
                            CounselingReferral(
                              id: '',
                              studentId: selectedStudent!.id,
                              studentName: selectedStudent!.name,
                              reason: reasonController.text.trim(),
                              referredBy: _auth?.user.name ?? 'Patron',
                              referredTo:
                                  referredToController.text.trim().isEmpty
                                  ? null
                                  : referredToController.text.trim(),
                              referralDate: DateTime.now(),
                            ),
                          ),
                        );
                        Navigator.pop(dialogContext);
                      },
                child: const Text('Submit Referral'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showLogBehaviourDialog(BuildContext context) {
    final descController = TextEditingController();
    String type = 'Positive';
    Student? selectedStudent;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) {
          return AlertDialog(
            title: const Text('Behaviour Observation'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SearchablePickerField<Student>(
                    label: 'Student',
                    value: selectedStudent,
                    items: _students,
                    labelBuilder: (student) => student.name,
                    subtitleBuilder: (student) => student.className,
                    onChanged: (student) =>
                        setState(() => selectedStudent = student),
                  ),
                  const SizedBox(height: 16),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'Positive', label: Text('Positive')),
                      ButtonSegment(value: 'Concern', label: Text('Concern')),
                    ],
                    selected: {type},
                    onSelectionChanged: (sel) =>
                        setState(() => type = sel.first),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    onChanged: (_) => setState(() {}),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed:
                    selectedStudent == null || descController.text.isEmpty
                    ? null
                    : () {
                        context.read<PatronBloc>().add(
                          LogBehaviourObservationEvent(
                            BehaviourObservation(
                              id: '',
                              studentId: selectedStudent!.id,
                              studentName: selectedStudent!.name,
                              type: type,
                              description: descController.text.trim(),
                              date: DateTime.now(),
                              recordedBy: _auth?.user.name ?? 'Patron',
                            ),
                          ),
                        );
                        Navigator.pop(dialogContext);
                      },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _WelfareLogTab extends StatelessWidget {
  final List<Student> students;
  final AuthAuthenticated? auth;
  const _WelfareLogTab({required this.students, required this.auth});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PatronBloc, PatronState>(
      buildWhen: (_, current) =>
          current is WelfareRecordsLoaded || current is PatronLoading,
      builder: (context, state) {
        if (state is PatronLoading) {
          return const Center(child: SchoolPulseLoader());
        }
        if (state is! WelfareRecordsLoaded) return const SizedBox.shrink();
        final records = state.records;
        if (records.isEmpty) {
          return const EmptyState(
            icon: Icons.health_and_safety_outlined,
            title: 'No welfare records',
            message: 'Welfare entries recorded by the Patron appear here.',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.l),
          itemCount: records.length,
          itemBuilder: (context, index) {
            final record = records[index];
            return AppCard(
              margin: const EdgeInsets.only(bottom: AppSpacing.m),
              padding: const EdgeInsets.all(AppSpacing.l),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          record.studentName,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      if (record.isPrivate) ...[
                        const Icon(
                          Icons.lock_outline,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: AppSpacing.s),
                      ],
                      _CategoryChip(category: record.category),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s),
                  Text(record.note),
                  const SizedBox(height: AppSpacing.m),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('MMM d, yyyy').format(record.date),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                      Text(
                        'By: ${record.recordedBy}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _ReferralsTab extends StatelessWidget {
  final List<Student> students;
  final AuthAuthenticated? auth;
  const _ReferralsTab({required this.students, required this.auth});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PatronBloc, PatronState>(
      buildWhen: (_, current) => current is CounselingReferralsLoaded,
      builder: (context, state) {
        if (state is! CounselingReferralsLoaded) {
          return const Center(child: SchoolPulseLoader());
        }
        if (state.referrals.isEmpty) {
          return const EmptyState(
            icon: Icons.psychology_outlined,
            title: 'No Referrals',
            message: 'Counseling referrals will appear here.',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.l),
          itemCount: state.referrals.length,
          itemBuilder: (context, index) {
            final referral = state.referrals[index];
            return AppCard(
              margin: const EdgeInsets.only(bottom: AppSpacing.m),
              child: ListTile(
                title: Text(
                  referral.studentName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(referral.reason),
                trailing: DropdownButton<String>(
                  value: referral.status,
                  items: ['Pending', 'Scheduled', 'Completed', 'Declined']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      context.read<PatronBloc>().add(
                        UpdateReferralStatusEvent(referral.id, val),
                      );
                    }
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _BehaviourTab extends StatelessWidget {
  final List<Student> students;
  final AuthAuthenticated? auth;
  const _BehaviourTab({required this.students, required this.auth});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PatronBloc, PatronState>(
      buildWhen: (_, current) => current is BehaviourObservationsLoaded,
      builder: (context, state) {
        if (state is! BehaviourObservationsLoaded) {
          return const Center(child: SchoolPulseLoader());
        }
        if (state.observations.isEmpty) {
          return const EmptyState(
            icon: Icons.visibility_outlined,
            title: 'No Observations',
            message: 'Positive and concerning behaviour notes appear here.',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.l),
          itemCount: state.observations.length,
          itemBuilder: (context, index) {
            final obs = state.observations[index];
            final isPositive = obs.type == 'Positive';
            return AppCard(
              margin: const EdgeInsets.only(bottom: AppSpacing.m),
              child: ListTile(
                leading: Icon(
                  isPositive
                      ? Icons.thumb_up_outlined
                      : Icons.warning_amber_outlined,
                  color: isPositive
                      ? AppColors.success(context)
                      : AppColors.warning(context),
                ),
                title: Text(
                  obs.studentName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(obs.description),
                trailing: Text(
                  DateFormat('MMM d').format(obs.date),
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String category;
  const _CategoryChip({required this.category});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (category) {
      case 'Concern':
        color = AppColors.warning(context);
        break;
      case 'Check-in':
        color = Colors.teal;
        break;
      case 'Counseling':
        color = AppColors.primary(context);
        break;
      case 'Check-up':
        color = AppColors.success(context);
        break;
      case 'Observation':
        color = Colors.purple;
        break;
      default:
        color = AppColors.border(context);
    }
    return Chip(
      label: Text(
        category,
        style: const TextStyle(color: Colors.white, fontSize: 10),
      ),
      backgroundColor: color,
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
