import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_bloc.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_state.dart';
import '../../../domain/entities/exam_factory_entities.dart';
import '../../bloc/exam_factory_cubit.dart';
import '../../widgets/exam_factory_shell.dart';
import '../../widgets/exam_factory_structure_loader.dart';

String paperStatusLabel(ExamPaperStatus status) => switch (status) {
  ExamPaperStatus.draft => 'DRAFT',
  ExamPaperStatus.compiling => 'COMPILING',
  ExamPaperStatus.readyForModeration => 'READY FOR MODERATION',
  ExamPaperStatus.changesRequested => 'CHANGES REQUESTED',
  ExamPaperStatus.readyForApproval => 'FOR APPROVAL',
  ExamPaperStatus.approved => 'APPROVED',
  ExamPaperStatus.locked => 'LOCKED',
  ExamPaperStatus.printReady => 'PRINT READY',
  ExamPaperStatus.printed => 'PRINTED',
  ExamPaperStatus.administered => 'ADMINISTERED',
  ExamPaperStatus.archived => 'ARCHIVED',
};

Color paperStatusColor(BuildContext context, ExamPaperStatus status) =>
    switch (status) {
      ExamPaperStatus.approved ||
      ExamPaperStatus.locked ||
      ExamPaperStatus.printReady ||
      ExamPaperStatus.printed ||
      ExamPaperStatus.administered => AppColors.success(context),
      ExamPaperStatus.readyForApproval ||
      ExamPaperStatus.readyForModeration => AppColors.information(context),
      ExamPaperStatus.changesRequested => AppColors.warning(context),
      _ => AppColors.textMuted(context),
    };

class ExamPaperListScreen extends StatelessWidget {
  const ExamPaperListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExamFactoryCubit>();
    return ExamFactoryScaffold(
      title: 'Papers',
      backFallback: '/staff/dean/exam-factory',
      action: IconButton(
        tooltip: 'Create paper',
        icon: const Icon(Icons.add_circle_outline),
        onPressed: () => context.push('/staff/dean/exam-factory/paper-builder'),
      ),
      child: ExamFactoryStreamView<ExamPaper>(
        stream: cubit.watchPapers(),
        emptyIcon: Icons.article_outlined,
        emptyTitle: 'No papers yet',
        emptyMessage:
            'Create a paper and add approved questions from the bank.',
        emptyAction: FilledButton.icon(
          onPressed: () =>
              context.push('/staff/dean/exam-factory/paper-builder'),
          icon: const Icon(Icons.add),
          label: const Text('Create paper'),
        ),
        builder: (context, items) => ListView.builder(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.l,
            AppSpacing.l,
            AppSpacing.l,
            100,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final paper = items[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                title: Text(paper.title, style: AppTypography.titleSmall),
                subtitle: Text(
                  '${paper.totalMarks} / ${paper.targetMarks} marks · v${paper.version}',
                ),
                trailing: Text(
                  paperStatusLabel(paper.status),
                  style: TextStyle(
                    color: paperStatusColor(context, paper.status),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                onTap: () => context.push(
                  '/staff/dean/exam-factory/paper-builder?paperId=${paper.id}',
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class ExamPaperBuilderScreen extends StatefulWidget {
  final String? paperId;
  final List<String> initialQuestionIds;
  const ExamPaperBuilderScreen({
    super.key,
    this.paperId,
    this.initialQuestionIds = const [],
  });

  @override
  State<ExamPaperBuilderScreen> createState() => _ExamPaperBuilderScreenState();
}

class _ExamPaperBuilderScreenState extends State<ExamPaperBuilderScreen> {
  final _titleController = TextEditingController();
  final _targetMarksController = TextEditingController(text: '100');
  final _durationController = TextEditingController(text: '60');
  String? _seriesId;
  String? _classId;
  String? _subjectId;
  final List<String> _questionIds = [];
  bool _loadedExisting = false;
  bool _saving = false;
  ExamPaperStatus _status = ExamPaperStatus.draft;

  @override
  void initState() {
    super.initState();
    _questionIds.addAll(widget.initialQuestionIds);
    ensureStructureLoaded(
      context,
      context.read<ExamFactoryCubit>().institutionId,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _targetMarksController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _applyExisting(ExamPaper paper) {
    if (_loadedExisting) return;
    _loadedExisting = true;
    _titleController.text = paper.title;
    _targetMarksController.text = '${paper.targetMarks}';
    _durationController.text = '${paper.durationMinutes}';
    _seriesId = paper.seriesId;
    _classId = paper.classId;
    _subjectId = paper.subjectId;
    _status = paper.status;
    _questionIds
      ..clear()
      ..addAll(paper.questionIds);
  }

  Future<void> _save(
    ExamFactoryCubit cubit,
    List<ExamQuestion> approvedQuestions,
  ) async {
    if (_titleController.text.trim().isEmpty ||
        _seriesId == null ||
        _classId == null ||
        _subjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fill in title, series, class and subject.'),
        ),
      );
      return;
    }
    final targetMarks = int.tryParse(_targetMarksController.text.trim()) ?? 0;
    final totalMarks = approvedQuestions
        .where((q) => _questionIds.contains(q.id))
        .fold<int>(0, (total, q) => total + q.marks);
    setState(() => _saving = true);
    final id = widget.paperId ?? const Uuid().v4();
    try {
      await cubit.savePaper(
        ExamPaper(
          id: id,
          seriesId: _seriesId!,
          institutionId: cubit.institutionId,
          classId: _classId!,
          subjectId: _subjectId!,
          title: _titleController.text.trim(),
          targetMarks: targetMarks,
          totalMarks: totalMarks,
          version: 1,
          status: _status,
          durationMinutes: int.tryParse(_durationController.text.trim()) ?? 60,
          questionIds: _questionIds,
        ),
        operationId: DateTime.now().microsecondsSinceEpoch.toString(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Paper saved.')));
      if (widget.paperId == null)
        context.pushReplacement(
          '/staff/dean/exam-factory/paper-builder?paperId=$id',
        );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(cubit.state.error ?? 'Could not save the paper.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _addQuestions() async {
    context.push('/staff/dean/exam-factory/question-bank?pickerForPaper=1');
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExamFactoryCubit>();

    Widget builderBody(StructureState structure, List<ExamQuestion> approved) {
      final selectedQuestions = _questionIds
          .map((id) {
            for (final q in approved) {
              if (q.id == id) return q;
            }
            return null;
          })
          .whereType<ExamQuestion>()
          .toList();
      final totalMarks = selectedQuestions.fold<int>(
        0,
        (total, q) => total + q.marks,
      );
      final targetMarks = int.tryParse(_targetMarksController.text.trim()) ?? 0;
      final marksValid = targetMarks == totalMarks && targetMarks > 0;

      return ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.l,
          AppSpacing.l,
          AppSpacing.l,
          100,
        ),
        children: [
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Paper title'),
          ),
          const SizedBox(height: 14),
          StreamBuilder<List<ExamSeries>>(
            stream: cubit.watchSeries(),
            builder: (context, snap) => DropdownButtonFormField<String>(
              initialValue: _seriesId,
              decoration: const InputDecoration(labelText: 'Exam series'),
              items: (snap.data ?? const <ExamSeries>[])
                  .map(
                    (s) => DropdownMenuItem(value: s.id, child: Text(s.name)),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _seriesId = v),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _classId,
                  decoration: const InputDecoration(labelText: 'Class'),
                  items: structure.classes
                      .map(
                        (c) =>
                            DropdownMenuItem(value: c.id, child: Text(c.name)),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _classId = v),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _subjectId,
                  decoration: const InputDecoration(labelText: 'Subject'),
                  items: structure.subjects
                      .map(
                        (s) =>
                            DropdownMenuItem(value: s.id, child: Text(s.name)),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _subjectId = v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _targetMarksController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Target marks'),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller: _durationController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Duration (minutes)',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Text(
                'Questions ($totalMarks / $targetMarks marks)',
                style: AppTypography.titleSmall,
              ),
              const Spacer(),
              if (!marksValid)
                Icon(
                  Icons.warning_amber_rounded,
                  size: 18,
                  color: AppColors.warning(context),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (selectedQuestions.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border(context)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(child: Text('No questions added yet.')),
            )
          else
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: selectedQuestions.length,
              onReorderItem: (oldIndex, newIndex) => setState(() {
                final id = _questionIds.removeAt(oldIndex);
                _questionIds.insert(newIndex, id);
              }),
              itemBuilder: (context, index) {
                final q = selectedQuestions[index];
                return Card(
                  key: ValueKey(q.id),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 17,
                      child: Text('${index + 1}'),
                    ),
                    title: Text(
                      q.text,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text('${q.topic} · ${q.marks} marks'),
                    trailing: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () =>
                          setState(() => _questionIds.remove(q.id)),
                    ),
                  ),
                );
              },
            ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _addQuestions,
                  icon: const Icon(Icons.add),
                  label: const Text('Add questions'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _saving ? null : () => _save(cubit, approved),
                  icon: _saving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(_saving ? 'Saving…' : 'Save paper'),
                ),
              ),
            ],
          ),
          if (widget.paperId != null && _status == ExamPaperStatus.draft) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: marksValid
                    ? () async {
                        await cubit.requestPaperApproval(widget.paperId!);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Sent for approval.')),
                          );
                        }
                      }
                    : null,
                icon: const Icon(Icons.send_outlined),
                label: const Text('Send for approval'),
              ),
            ),
          ],
        ],
      );
    }

    return ExamFactoryScaffold(
      title: widget.paperId == null ? 'Create paper' : 'Paper Builder',
      backFallback: '/staff/dean/exam-factory/papers',
      child: BlocBuilder<StructureBloc, StructureState>(
        builder: (context, structure) => StreamBuilder<List<ExamQuestion>>(
          stream: cubit.watchQuestions(status: ExamQuestionStatus.approved),
          builder: (context, approvedSnap) {
            final approvedOnly = approvedSnap.data ?? const <ExamQuestion>[];
            if (widget.paperId == null) {
              return builderBody(structure, approvedOnly);
            }
            return StreamBuilder<ExamPaper?>(
              stream: cubit.watchPaper(widget.paperId!),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const ExamFactoryLoading();
                }
                final paper = snap.data;
                if (paper == null) {
                  return const ExamFactoryEmpty(
                    icon: Icons.error_outline,
                    title: 'Paper not found',
                    message: 'This paper may have been removed.',
                  );
                }
                _applyExisting(paper);
                return StreamBuilder<List<ExamQuestion>>(
                  stream: cubit.watchQuestions(
                    status: ExamQuestionStatus.usedInPaper,
                  ),
                  builder: (context, usedSnap) {
                    final used = (usedSnap.data ?? const <ExamQuestion>[])
                        .where((q) => paper.questionIds.contains(q.id));
                    return builderBody(structure, [...approvedOnly, ...used]);
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
