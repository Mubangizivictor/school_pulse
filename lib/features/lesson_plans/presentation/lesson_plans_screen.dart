import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/lesson_plans/domain/entities/lesson_plan.dart';
import 'package:school_pulse/features/lesson_plans/domain/usecases/add_lesson_plan.dart';
import 'package:school_pulse/features/lesson_plans/domain/usecases/get_lesson_plans.dart';
import 'package:school_pulse/injection_container.dart' as di;

class LessonPlansScreen extends StatefulWidget {
  const LessonPlansScreen({super.key});

  @override
  State<LessonPlansScreen> createState() => _LessonPlansScreenState();
}

class _LessonPlansScreenState extends State<LessonPlansScreen> {
  late Future<List<LessonPlan>> _plansFuture;

  String get _teacherId {
    final authState = context.read<AuthBloc>().state;
    return authState is AuthAuthenticated ? authState.user.id : '';
  }

  @override
  void initState() {
    super.initState();
    _plansFuture = _loadPlans();
  }

  Future<List<LessonPlan>> _loadPlans() {
    return di.sl<GetLessonPlans>()(_teacherId).then((r) => r.getOrElse(() => const []));
  }

  void _reload() {
    setState(() => _plansFuture = _loadPlans());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lesson Plans'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: () => _showAddPlanDialog(context)),
        ],
      ),
      body: FutureBuilder<List<LessonPlan>>(
        future: _plansFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final plans = snapshot.data ?? const [];
          if (plans.isEmpty) {
            return const EmptyState(
              icon: Icons.menu_book_outlined,
              title: 'No lesson plans yet',
              message: 'Tap the + button to add your first lesson plan.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: plans.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final plan = plans[index];
              return AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${plan.subject} • ${plan.className}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(DateFormat('MMM d, yyyy').format(plan.date), style: Theme.of(context).textTheme.labelSmall),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(plan.content),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddPlanDialog(BuildContext context) {
    final subjectController = TextEditingController();
    final classController = TextEditingController();
    final contentController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    final teacherId = _teacherId;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('New Lesson Plan'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: subjectController, decoration: const InputDecoration(labelText: 'Subject')),
                const SizedBox(height: 16),
                TextField(controller: classController, decoration: const InputDecoration(labelText: 'Class')),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Date'),
                  subtitle: Text(DateFormat('MMM d, yyyy').format(selectedDate)),
                  trailing: const Icon(Icons.calendar_today, size: 18),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: dialogContext,
                      initialDate: selectedDate,
                      firstDate: DateTime.now().subtract(const Duration(days: 30)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) setDialogState(() => selectedDate = picked);
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: contentController,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Lesson Content / Objectives', alignLabelWithHint: true),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                if (subjectController.text.trim().isEmpty || classController.text.trim().isEmpty) return;
                await di.sl<AddLessonPlan>()(LessonPlan(
                  id: '',
                  teacherId: teacherId,
                  subject: subjectController.text.trim(),
                  className: classController.text.trim(),
                  date: selectedDate,
                  content: contentController.text.trim(),
                ));
                if (dialogContext.mounted) Navigator.pop(dialogContext);
                _reload();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
