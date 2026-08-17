import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../data/repositories/curriculum_assignment_repository_impl.dart';
import '../../domain/entities/curriculum_assignment.dart';
import '../../domain/entities/structure_entities.dart';
import '../../domain/repositories/curriculum_assignment_repository.dart';
import '../../domain/services/structure_tenant_resolver.dart';
import '../bloc/structure_bloc.dart';
import '../bloc/structure_state.dart';

class CurriculumAssignmentScreen extends StatefulWidget {
  const CurriculumAssignmentScreen({super.key});

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
      appBar: AppBar(title: const Text('Curriculum / Subject Allocation')),
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
              body: 'Create at least one active class before curriculum allocation.',
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
              final assignments = snapshot.data!
                  .where((item) => item.academicYearId == currentYear.id)
                  .toList()
                ..sort((a, b) {
                  final classCompare = a.classId.compareTo(b.classId);
                  if (classCompare != 0) return classCompare;
                  return a.displayOrder.compareTo(b.displayOrder);
                });

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      'Define what each class/stream studies in ${currentYear.name}. Subject definitions stay reusable; these year-scoped allocations drive timetable, marks and teacher assignment.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                    ),
                  ),
                  Expanded(
                    child: assignments.isEmpty
                        ? const _Message(
                            title: 'No curriculum allocated yet',
                            body:
                                'Add the subjects taught by each class or stream for the current academic year.',
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                            itemCount: assignments.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final item = assignments[index];
                              final schoolClass = structure.classes
                                  .where((value) => value.id == item.classId)
                                  .firstOrNull;
                              final stream = structure.streams
                                  .where((value) => value.id == item.streamId)
                                  .firstOrNull;
                              final subject = structure.subjects
                                  .where((value) => value.id == item.subjectId)
                                  .firstOrNull;
                              return Card(
                                child: ListTile(
                                  title: Text(
                                    subject?.name ?? 'Missing subject',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  subtitle: Text([
                                    schoolClass?.name ?? 'Missing class',
                                    if (stream != null) stream.name,
                                    item.isCompulsory
                                        ? 'Compulsory'
                                        : 'Elective',
                                    if (item.periodsPerWeek > 0)
                                      '${item.periodsPerWeek} periods/week',
                                  ].join(' • ')),
                                  trailing: PopupMenuButton<String>(
                                    onSelected: (action) {
                                      if (action == 'edit') {
                                        _showForm(
                                          context,
                                          structure,
                                          currentYear,
                                          existing: item,
                                        );
                                      } else if (action == 'deactivate') {
                                        _repository
                                            .deactivateAssignment(item.id);
                                      }
                                    },
                                    itemBuilder: (_) => const [
                                      PopupMenuItem(
                                        value: 'edit',
                                        child: Text('Edit'),
                                      ),
                                      PopupMenuItem(
                                        value: 'deactivate',
                                        child: Text('Deactivate'),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: BlocBuilder<StructureBloc, StructureState>(
        builder: (context, structure) {
          final currentYear = structure.academicYears
              .where((year) => year.isCurrent && !year.isArchived)
              .firstOrNull;
          final canAdd = currentYear != null &&
              structure.classes.any((item) => item.isActive) &&
              structure.subjects.any((item) => item.isActive);
          return FloatingActionButton.extended(
            onPressed: canAdd
                ? () => _showForm(context, structure, currentYear)
                : null,
            icon: const Icon(Icons.add),
            label: const Text('Add Allocation'),
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
    final activeClasses =
        structure.classes.where((item) => item.isActive).toList();
    final activeSubjects =
        structure.subjects.where((item) => item.isActive).toList();
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
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) {
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
                  Text(
                    existing == null
                        ? 'Add Curriculum Allocation'
                        : 'Edit Curriculum Allocation',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: classId,
                    decoration: const InputDecoration(labelText: 'Class *'),
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
                  const SizedBox(height: 12),
                  if (classStreams.isNotEmpty)
                    DropdownButtonFormField<String>(
                      value: streamId,
                      decoration: const InputDecoration(
                        labelText: 'Stream / Section',
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
                  if (classStreams.isNotEmpty) const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: eligibleSubjects.any((item) => item.id == subjectId)
                        ? subjectId
                        : null,
                    decoration: const InputDecoration(labelText: 'Subject *'),
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
                  const SizedBox(height: 12),
                  TextField(
                    controller: periods,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Periods per week',
                      helperText: '0 means the school has not set a target.',
                    ),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Compulsory for this class/stream'),
                    value: compulsory,
                    onChanged: (value) =>
                        setSheetState(() => compulsory = value),
                  ),
                  const SizedBox(height: 12),
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
                      child: const Text('Save Allocation'),
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
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
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
