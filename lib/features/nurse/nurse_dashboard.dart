import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/design_system/searchable_picker.dart';
import 'package:school_pulse/core/utils.dart';
import 'package:school_pulse/injection_container.dart' as di;
import 'package:school_pulse/features/student/domain/entities/student.dart';
import 'package:school_pulse/features/student/domain/usecases/get_all_students.dart';
import 'package:school_pulse/features/health/domain/entities/health_visit.dart';
import 'package:school_pulse/features/health/domain/usecases/get_all_health_visits.dart';
import 'package:school_pulse/features/health/domain/usecases/log_health_visit.dart';
import 'package:school_pulse/features/nurse/presentation/screens/medicine_inventory_screen.dart';

class _HealthSnapshot {
  final List<Student> students;
  final List<HealthVisit> visits;

  const _HealthSnapshot({required this.students, required this.visits});
}

class NurseDashboardScreen extends StatefulWidget {
  const NurseDashboardScreen({super.key});

  @override
  State<NurseDashboardScreen> createState() => _NurseDashboardScreenState();
}

class _NurseDashboardScreenState extends State<NurseDashboardScreen> {
  late Future<_HealthSnapshot> _snapshotFuture;

  @override
  void initState() {
    super.initState();
    _snapshotFuture = _loadSnapshot();
  }

  void _reload() {
    setState(() => _snapshotFuture = _loadSnapshot());
  }

  Future<_HealthSnapshot> _loadSnapshot() async {
    final results = await Future.wait([
      di.sl<GetAllStudents>()().then((r) => r.getOrElse(() => const <Student>[])),
      di.sl<GetAllHealthVisits>()().then((r) => r.getOrElse(() => const <HealthVisit>[])),
    ]);
    return _HealthSnapshot(
      students: results[0] as List<Student>,
      visits: results[1] as List<HealthVisit>,
    );
  }

  @override
  Widget build(BuildContext context) {
    final semanticColors = Theme.of(context).extension<SemanticColors>()!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sick Bay Portal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.message_outlined),
            onPressed: () => context.push('/staff/messages'),
          ),
          IconButton(
          icon: const Icon(Icons.inventory_2_outlined),
          tooltip: 'Medicine Inventory',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MedicineInventoryScreen()),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add_box_outlined),
            onPressed: () => _showNewVisitDialog(context),
          ),
        ],
      ),
      body: FutureBuilder<_HealthSnapshot>(
        future: _snapshotFuture,
        builder: (context, snapshot) {
          final data = snapshot.data;
          final isLoading = snapshot.connectionState == ConnectionState.waiting;
          final studentsById = {for (final s in data?.students ?? const <Student>[]) s.id: s};
          final visits = data?.visits ?? const <HealthVisit>[];
          final now = DateTime.now();
          final today = visits.where((v) => v.date.year == now.year && v.date.month == now.month && v.date.day == now.day).toList();
          final thisWeek = visits.where((v) => now.difference(v.date).inDays < 7).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (isLoading)
                const Row(
                  children: [
                    Expanded(child: Skeleton(height: 100)),
                    SizedBox(width: 12),
                    Expanded(child: Skeleton(height: 100)),
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: DashboardStatCard(
                        title: 'Visits Today',
                        value: today.length.toDouble(),
                        icon: Icons.medical_services_outlined,
                        color: semanticColors.info,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DashboardStatCard(
                        title: 'This Week',
                        value: thisWeek.length.toDouble(),
                        icon: Icons.calendar_view_week_outlined,
                        color: semanticColors.warning,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 24),
              const SectionHeader(title: 'Recent Visits'),
              if (isLoading)
                ...List.generate(3, (index) => const _VisitSkeleton())
              else if (visits.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: Text('No health visits recorded yet.')),
                )
              else
                ...visits.take(10).map((visit) {
                  final studentName = studentsById[visit.studentId]?.name ?? 'Unknown Student';
                  return AppCard(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            AvatarInitials(name: studentName, size: 32),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(studentName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Text(
                                    DateFormatter.relative(visit.date),
                                    style: Theme.of(context).textTheme.labelSmall,
                                  ),
                                ],
                              ),
                            ),
                            StatusBadge(label: 'Treated', color: semanticColors.success),
                          ],
                        ),
                        const Divider(height: 24),
                        _VisitDetail(label: 'Reason', value: visit.reason),
                        const SizedBox(height: 8),
                        _VisitDetail(label: 'Treatment', value: visit.treatment),
                        const SizedBox(height: 8),
                        _VisitDetail(label: 'Medication', value: visit.medication),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () => context.push('/staff/messages'),
                              icon: const Icon(Icons.chat_bubble_outline, size: 18),
                              label: const Text('Message Parent/Teacher'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }

  void _showNewVisitDialog(BuildContext context) {
    _snapshotFuture.then((data) {
      if (!context.mounted) return;
      final students = data.students;
      if (students.isEmpty) return;

      final reasonController = TextEditingController();
      final treatmentController = TextEditingController();
      final medicationController = TextEditingController();
      String selectedStudentId = students.first.id;

      showDialog(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (dialogContext, setDialogState) => AlertDialog(
            title: const Text('New Sick Bay Visit'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SearchablePickerField<Student>(
                    label: 'Student',
                    value: students.firstWhere((s) => s.id == selectedStudentId),
                    items: students,
                    labelBuilder: (s) => s.name,
                    subtitleBuilder: (s) => s.className,
                    onChanged: (s) => setDialogState(() => selectedStudentId = s.id),
                  ),
                  const SizedBox(height: 16),
                  TextField(controller: reasonController, decoration: const InputDecoration(labelText: 'Reason')),
                  const SizedBox(height: 16),
                  TextField(controller: treatmentController, decoration: const InputDecoration(labelText: 'Treatment')),
                  const SizedBox(height: 16),
                  TextField(controller: medicationController, decoration: const InputDecoration(labelText: 'Medication')),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
              FilledButton(
                onPressed: () async {
                  if (reasonController.text.trim().isEmpty) return;
                  await di.sl<LogHealthVisit>()(HealthVisit(
                    id: '',
                    studentId: selectedStudentId,
                    date: DateTime.now(),
                    reason: reasonController.text.trim(),
                    treatment: treatmentController.text.trim(),
                    medication: medicationController.text.trim(),
                  ));
                  if (dialogContext.mounted) Navigator.pop(dialogContext);
                  _reload();
                },
                child: const Text('Log Visit'),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _VisitSkeleton extends StatelessWidget {
  const _VisitSkeleton();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Skeleton(height: 32, width: 32, borderRadius: 16),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Skeleton(height: 14, width: 120),
                    const SizedBox(height: 4),
                    const Skeleton(height: 10, width: 80),
                  ],
                ),
              ),
              const Skeleton(height: 24, width: 60, borderRadius: 12),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              const Skeleton(height: 12, width: 60),
              const SizedBox(width: 20),
              const Expanded(child: Skeleton(height: 12)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Skeleton(height: 12, width: 60),
              const SizedBox(width: 20),
              const Expanded(child: Skeleton(height: 12)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Skeleton(height: 12, width: 60),
              const SizedBox(width: 20),
              const Expanded(child: Skeleton(height: 12)),
            ],
          ),
        ],
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
            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
