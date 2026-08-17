import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/features/admin/presentation/widgets/admin_app_bar.dart';
import '../../bloc/structure_bloc.dart';
import '../../bloc/structure_state.dart';
import '../../widgets/structure_wizard_banner.dart';

/// A dedicated, card-led view of the assignments stored on Subject records.
/// The canonical edit form remains Subjects, so assignments and subjects never
/// drift into competing data models.
class SubjectClassAssignmentsScreen extends StatelessWidget {
  const SubjectClassAssignmentsScreen({
    super.key,
    this.wizardStep,
    this.wizardTotal,
  });

  final int? wizardStep;
  final int? wizardTotal;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AdminAppBar(
      title: 'Subject–Class Assignments',
      bottom: wizardStep == null || wizardTotal == null
          ? null
          : StructureWizardBanner(
              stepId: 'subject-class-assignments',
              stepNumber: wizardStep!,
              totalSteps: wizardTotal!,
            ),
    ),
    body: BlocBuilder<StructureBloc, StructureState>(
      builder: (context, state) {
        final activeSubjects = state.subjects.where((s) => s.isActive).toList();
        final assignments = activeSubjects
            .where(
              (s) =>
                  s.assignedClassIds.isNotEmpty ||
                  s.assignedLevelIds.isNotEmpty,
            )
            .toList();
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          children: [
            Text(
              'Subject–Class Assignments',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 5),
            Text(
              'Choose which classes or levels each subject applies to.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 18),
            if (assignments.isEmpty)
              _EmptyAssignments(
                onManage: () =>
                    context.push('/staff/admin/structure/academics/subjects'),
              )
            else ...[
              ...assignments.map((subject) {
                final classes = state.classes
                    .where(
                      (schoolClass) =>
                          subject.assignedClassIds.contains(schoolClass.id),
                    )
                    .map((schoolClass) => schoolClass.name)
                    .toList();
                final levels = state.levels
                    .where(
                      (level) => subject.assignedLevelIds.contains(level.id),
                    )
                    .map((level) => level.name)
                    .toList();
                final scope = [...classes, ...levels].join(' • ');
                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.auto_stories_outlined),
                    ),
                    title: Text(subject.name),
                    subtitle: Text(
                      scope.isEmpty ? 'No class or level assigned' : scope,
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push(
                      '/staff/admin/structure/academics/subjects',
                    ),
                  ),
                );
              }),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () =>
                    context.push('/staff/admin/structure/academics/subjects'),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Manage subject assignments'),
              ),
            ],
          ],
        );
      },
    ),
  );
}

class _EmptyAssignments extends StatelessWidget {
  const _EmptyAssignments({required this.onManage});
  final VoidCallback onManage;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Icon(Icons.assignment_outlined, size: 42),
          const SizedBox(height: 12),
          Text(
            'No subject–class assignments yet',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          const Text(
            'Open a subject to choose the classes and levels it applies to.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: onManage,
            child: const Text('Set up subjects and assignments'),
          ),
        ],
      ),
    ),
  );
}
