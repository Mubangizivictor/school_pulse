import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:uuid/uuid.dart';
import '../../data/repositories/curriculum_assignment_repository_impl.dart';
import '../../domain/entities/curriculum_assignment.dart';
import '../../domain/entities/structure_entities.dart';
import '../../domain/repositories/curriculum_assignment_repository.dart';
import '../../domain/services/structure_tenant_resolver.dart';
import '../bloc/structure_bloc.dart';
import '../bloc/structure_state.dart';

class CurriculumAssignmentScreen extends StatefulWidget {
  const CurriculumAssignmentScreen({super.key, this.showAppBar = true});

  final bool showAppBar;

  @override
  State<CurriculumAssignmentScreen> createState() =>
      _CurriculumAssignmentScreenState();
}

class _CurriculumAssignmentScreenState
    extends State<CurriculumAssignmentScreen> {
  late final CurriculumAssignmentRepository _repository;

  @override
  void initState() {
    super.initState();
    final firestore = FirebaseFirestore.instance;
    _repository = CurriculumAssignmentRepositoryImpl(
      firestore: firestore,
      tenantResolver: StructureTenantResolver(firestore: firestore),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(title: const Text('Curriculum / Subject Allocation'))
          : null,
      backgroundColor: widget.showAppBar ? null : Colors.transparent,
      body: BlocBuilder<StructureBloc, StructureState>(
        builder: (context, structure) {
          final currentYear = structure.academicYears
              .where((year) => year.isCurrent && !year.isArchived)
              .firstOrNull;
          if (currentYear == null) {
            return const _Message(
              title: 'Current academic year required',
              body:
                  'Set an academic year as current before allocating subjects to classes.',
            );
          }
          if (structure.classes.where((item) => item.isActive).isEmpty) {
            return const _Message(
              title: 'Classes required',
              body:
                  'Create at least one active class before curriculum allocation.',
            );
          }
          if (structure.subjects.where((item) => item.isActive).isEmpty) {
            return const _Message(
              title: 'Subjects required',
              body:
                  'Create at least one active subject before curriculum allocation.',
            );
          }

          return StreamBuilder<List<CurriculumAssignment>>(
            stream: _repository.watchAssignments(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return _Message(
                  title: 'Could not load curriculum',
                  body: snapshot.error.toString(),
                );
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final assignments =
                  snapshot.data!
                      .where((item) => item.academicYearId == currentYear.id)
                      .toList()
                    ..sort((a, b) {
                      final classCompare = a.classId.compareTo(b.classId);
                      if (classCompare != 0) return classCompare;
                      return a.displayOrder.compareTo(b.displayOrder);
                    });
              final scheme = Theme.of(context).colorScheme;

              void onAdd() => _showForm(context, structure, currentYear);

              final byGroup = <String, List<CurriculumAssignment>>{};
              for (final item in assignments) {
                final schoolClass = structure.classes
                    .where((value) => value.id == item.classId)
                    .firstOrNull;
                final stream = structure.streams
                    .where((value) => value.id == item.streamId)
                    .firstOrNull;
                final label =
                    '${schoolClass?.name ?? 'Missing class'} • ${stream?.name ?? 'Whole class'}';
                byGroup.putIfAbsent(label, () => []).add(item);
              }

              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              assignments.isEmpty
                                  ? 'Assign subjects to the classes that study them.'
                                  : 'Subjects are assigned to each class or stream.',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                    height: 1.4,
                                  ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton.icon(
                            onPressed: onAdd,
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Add allocation'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      if (assignments.isEmpty)
                        _CurriculumEmptyState(onAdd: onAdd)
                      else
                        Expanded(
                          child: ListView(
                            padding: EdgeInsets.zero,
                            children: [
                              for (final entry in byGroup.entries) ...[
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Text(
                                    entry.key,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                          color: scheme.primary,
                                          fontWeight: FontWeight.w800,
                                        ),
                                  ),
                                ),
                                for (final item in entry.value)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: AppCard(
                                      child: _AssignmentTile(
                                        item: item,
                                        structure: structure,
                                        onEdit: () => _showForm(
                                          context,
                                          structure,
                                          currentYear,
                                          existing: item,
                                        ),
                                        onDeactivate: () => _repository
                                            .deactivateAssignment(item.id),
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 8),
                              ],
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _showForm(
    BuildContext context,
    StructureState structure,
    AcademicYear currentYear, {
    CurriculumAssignment? existing,
  }) async {
    final activeClasses = structure.classes
        .where((item) => item.isActive)
        .toList();
    final activeSubjects = structure.subjects
        .where((item) => item.isActive)
        .toList();
    var classId = existing?.classId ?? activeClasses.first.id;
    var streamId = existing?.streamId ?? '';
    var subjectId = existing?.subjectId ?? activeSubjects.first.id;
    var compulsory = existing?.isCompulsory ?? true;
    final periods = TextEditingController(
      text: (existing?.periodsPerWeek ?? 0).toString(),
    );

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) {
          final scheme = Theme.of(context).colorScheme;
          final selectedClass = activeClasses
              .where((item) => item.id == classId)
              .firstOrNull;
          final classStreams = structure.streams
              .where((item) => item.classId == classId && item.isActive)
              .toList();
          if (streamId.isNotEmpty &&
              !classStreams.any((item) => item.id == streamId)) {
            streamId = '';
          }
          final eligibleSubjects = activeSubjects.where((subject) {
            if (subject.assignedClassIds.isEmpty &&
                subject.assignedLevelIds.isEmpty) {
              return true;
            }
            return subject.assignedClassIds.contains(classId) ||
                (selectedClass != null &&
                    subject.assignedLevelIds.contains(selectedClass.levelId));
          }).toList();
          if (eligibleSubjects.isNotEmpty &&
              !eligibleSubjects.any((item) => item.id == subjectId)) {
            subjectId = eligibleSubjects.first.id;
          }

          return Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              20,
              20,
              MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          existing == null
                              ? 'Add allocation'
                              : 'Edit allocation',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        style: IconButton.styleFrom(
                          backgroundColor: scheme.surfaceContainerHighest,
                          shape: const CircleBorder(),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Assign a subject to a class or stream.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (classStreams.isEmpty)
                    DropdownButtonFormField<String>(
                      initialValue: classId,
                      decoration: const InputDecoration(
                        labelText: 'Class or stream',
                      ),
                      items: activeClasses
                          .map(
                            (item) => DropdownMenuItem(
                              value: item.id,
                              child: Text('${item.name} · Whole class'),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setSheetState(() {
                            classId = value;
                            streamId = '';
                          });
                        }
                      },
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: classId,
                            decoration: const InputDecoration(
                              labelText: 'Class',
                            ),
                            items: activeClasses
                                .map(
                                  (item) => DropdownMenuItem(
                                    value: item.id,
                                    child: Text(item.name),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setSheetState(() {
                                  classId = value;
                                  streamId = '';
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: streamId,
                            decoration: const InputDecoration(
                              labelText: 'Stream',
                            ),
                            items: [
                              const DropdownMenuItem(
                                value: '',
                                child: Text('Whole class'),
                              ),
                              ...classStreams.map(
                                (item) => DropdownMenuItem(
                                  value: item.id,
                                  child: Text(item.name),
                                ),
                              ),
                            ],
                            onChanged: (value) =>
                                setSheetState(() => streamId = value ?? ''),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 18),
                  DropdownButtonFormField<String>(
                    initialValue:
                        eligibleSubjects.any((item) => item.id == subjectId)
                        ? subjectId
                        : null,
                    decoration: const InputDecoration(labelText: 'Subject'),
                    items: eligibleSubjects
                        .map(
                          (item) => DropdownMenuItem(
                            value: item.id,
                            child: Text(item.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setSheetState(() => subjectId = value);
                      }
                    },
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: periods,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Periods per week',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Compulsory',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Switch(
                        value: compulsory,
                        onChanged: (value) =>
                            setSheetState(() => compulsory = value),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: eligibleSubjects.isEmpty
                          ? null
                          : () async {
                              final schoolClass = activeClasses
                                  .where((item) => item.id == classId)
                                  .first;
                              final assignment = CurriculumAssignment(
                                id: existing?.id ?? const Uuid().v4(),
                                academicYearId: currentYear.id,
                                levelId: schoolClass.levelId,
                                classId: classId,
                                streamId: streamId,
                                subjectId: subjectId,
                                isCompulsory: compulsory,
                                periodsPerWeek:
                                    int.tryParse(periods.text.trim()) ?? 0,
                                displayOrder: existing?.displayOrder ?? 0,
                              );
                              try {
                                await _repository.saveAssignment(assignment);
                                if (sheetContext.mounted) {
                                  Navigator.pop(sheetContext);
                                }
                              } catch (error) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context)
                                    ..hideCurrentSnackBar()
                                    ..showSnackBar(
                                      SnackBar(content: Text(error.toString())),
                                    );
                                }
                              }
                            },
                      child: const Text('Save allocation'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
    periods.dispose();
  }
}

class _AssignmentTile extends StatelessWidget {
  const _AssignmentTile({
    required this.item,
    required this.structure,
    required this.onEdit,
    required this.onDeactivate,
  });

  final CurriculumAssignment item;
  final StructureState structure;
  final VoidCallback onEdit;
  final VoidCallback onDeactivate;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final subject = structure.subjects
        .where((value) => value.id == item.subjectId)
        .firstOrNull;
    return ListTile(
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: scheme.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(
          Icons.menu_book_outlined,
          color: Colors.white,
          size: 22,
        ),
      ),
      title: Text(
        subject?.name ?? 'Missing subject',
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
        [
          item.isCompulsory ? 'Compulsory' : 'Elective',
          if (item.periodsPerWeek > 0) '${item.periodsPerWeek} periods/week',
        ].join(' • '),
      ),
      trailing: PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert),
        onSelected: (action) {
          if (action == 'edit') {
            onEdit();
          } else if (action == 'deactivate') {
            onDeactivate();
          }
        },
        itemBuilder: (_) => const [
          PopupMenuItem(value: 'edit', child: Text('Edit')),
          PopupMenuItem(value: 'deactivate', child: Text('Deactivate')),
        ],
      ),
    );
  }
}

class _CurriculumEmptyState extends StatelessWidget {
  final VoidCallback onAdd;

  const _CurriculumEmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        child: Column(
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.account_tree_outlined,
                size: 40,
                color: scheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No allocations yet',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              'Add the first subject allocation to continue.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  final String title;
  final String body;

  const _Message({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.account_tree_outlined, size: 44),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(body, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
