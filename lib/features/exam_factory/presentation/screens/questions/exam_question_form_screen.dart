import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_bloc.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_state.dart';
import '../../../domain/entities/exam_factory_entities.dart';
import '../../bloc/exam_factory_cubit.dart';
import '../../widgets/exam_factory_shell.dart';
import '../../widgets/exam_factory_structure_loader.dart';

String questionTypeLabel(ExamQuestionType type) => switch (type) {
  ExamQuestionType.multipleChoice => 'Multiple choice',
  ExamQuestionType.shortAnswer => 'Short answer',
  ExamQuestionType.structured => 'Structured',
  ExamQuestionType.essay => 'Essay',
  ExamQuestionType.calculation => 'Calculation',
  ExamQuestionType.practical => 'Practical',
  ExamQuestionType.comprehension => 'Comprehension',
  ExamQuestionType.matching => 'Matching',
  ExamQuestionType.diagramLabelling => 'Diagram/labelling',
};

String difficultyLabel(ExamQuestionDifficulty difficulty) =>
    switch (difficulty) {
      ExamQuestionDifficulty.easy => 'Easy',
      ExamQuestionDifficulty.medium => 'Medium',
      ExamQuestionDifficulty.hard => 'Hard',
    };

/// Submit or edit a question. Teachers may only edit their own draft or
/// changes-requested questions; the backend enforces this independently.
class ExamQuestionFormScreen extends StatefulWidget {
  final String? questionId;
  const ExamQuestionFormScreen({super.key, this.questionId});

  @override
  State<ExamQuestionFormScreen> createState() => _ExamQuestionFormScreenState();
}

class _ExamQuestionFormScreenState extends State<ExamQuestionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _topicController = TextEditingController();
  final _textController = TextEditingController();
  final _marksController = TextEditingController(text: '5');
  final _answerController = TextEditingController();
  final _guideController = TextEditingController();
  final _notesController = TextEditingController();

  String? _seriesId;
  String? _classId;
  String? _subjectId;
  ExamQuestionType _type = ExamQuestionType.shortAnswer;
  ExamQuestionDifficulty _difficulty = ExamQuestionDifficulty.medium;
  bool _saving = false;
  bool _loadedExisting = false;
  ExamQuestionStatus _status = ExamQuestionStatus.draft;

  @override
  void initState() {
    super.initState();
    ensureStructureLoaded(
      context,
      context.read<ExamFactoryCubit>().institutionId,
    );
  }

  @override
  void dispose() {
    _topicController.dispose();
    _textController.dispose();
    _marksController.dispose();
    _answerController.dispose();
    _guideController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _applyExisting(ExamQuestion q) {
    if (_loadedExisting) return;
    _loadedExisting = true;
    _seriesId = q.seriesId;
    _classId = q.classId;
    _subjectId = q.subjectId;
    _topicController.text = q.topic;
    _textController.text = q.text;
    _marksController.text = '${q.marks}';
    _answerController.text = q.suggestedAnswer;
    _guideController.text = q.markingGuide;
    _notesController.text = q.teacherNotes;
    _type = q.type;
    _difficulty = q.difficulty;
    _status = q.status;
  }

  Future<void> _save(ExamFactoryCubit cubit, {required bool submit}) async {
    if (!_formKey.currentState!.validate()) return;
    if (_seriesId == null || _classId == null || _subjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select an exam series, class and subject.'),
        ),
      );
      return;
    }
    setState(() => _saving = true);
    final id =
        widget.questionId ??
        FirebaseFirestore.instance.collection('_ids').doc().id;
    final operationId = DateTime.now().microsecondsSinceEpoch.toString();
    try {
      await cubit.saveQuestionDraft(
        ExamQuestion(
          id: id,
          seriesId: _seriesId!,
          institutionId: cubit.institutionId,
          classId: _classId!,
          subjectId: _subjectId!,
          topic: _topicController.text.trim(),
          creatorId: cubit.currentUserId,
          text: _textController.text.trim(),
          marks: int.tryParse(_marksController.text.trim()) ?? 0,
          version: 1,
          type: _type,
          status: ExamQuestionStatus.draft,
          difficulty: _difficulty,
          suggestedAnswer: _answerController.text.trim(),
          markingGuide: _guideController.text.trim(),
          teacherNotes: _notesController.text.trim(),
        ),
        operationId: operationId,
      );
      if (submit) {
        await cubit.submitQuestion(id, operationId: operationId);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            submit ? 'Question submitted for review.' : 'Draft saved.',
          ),
        ),
      );
      context.pop();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(cubit.state.error ?? 'Could not save this question.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExamFactoryCubit>();
    final questionId = widget.questionId;

    Widget form(StructureState structure) {
      final canEdit =
          questionId == null ||
          _status == ExamQuestionStatus.draft ||
          _status == ExamQuestionStatus.changesRequested;
      return Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.l,
            AppSpacing.l,
            AppSpacing.l,
            100,
          ),
          children: [
            if (!canEdit)
              Card(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'This question is no longer editable. Approved or used questions require a new version.',
                  ),
                ),
              ),
            const SizedBox(height: 10),
            StreamBuilder<List<ExamSeries>>(
              stream: cubit.watchSeries(),
              builder: (context, snap) {
                final series = snap.data ?? const [];
                return DropdownButtonFormField<String>(
                  initialValue: _seriesId,
                  decoration: const InputDecoration(labelText: 'Exam series'),
                  items: series
                      .map(
                        (s) =>
                            DropdownMenuItem(value: s.id, child: Text(s.name)),
                      )
                      .toList(),
                  onChanged: canEdit
                      ? (v) => setState(() => _seriesId = v)
                      : null,
                  validator: (v) => v == null ? 'Select an exam series' : null,
                );
              },
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
                          (c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(c.name),
                          ),
                        )
                        .toList(),
                    onChanged: canEdit
                        ? (v) => setState(() => _classId = v)
                        : null,
                    validator: (v) => v == null ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _subjectId,
                    decoration: const InputDecoration(labelText: 'Subject'),
                    items: structure.subjects
                        .map(
                          (s) => DropdownMenuItem(
                            value: s.id,
                            child: Text(s.name),
                          ),
                        )
                        .toList(),
                    onChanged: canEdit
                        ? (v) => setState(() => _subjectId = v)
                        : null,
                    validator: (v) => v == null ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _topicController,
              enabled: canEdit,
              decoration: const InputDecoration(labelText: 'Topic'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 14),
            Text('Question type', style: AppTypography.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ExamQuestionType.values
                  .map(
                    (t) => ChoiceChip(
                      label: Text(questionTypeLabel(t)),
                      selected: _type == t,
                      onSelected: canEdit
                          ? (_) => setState(() => _type = t)
                          : null,
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _textController,
              enabled: canEdit,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'Question text',
                alignLabelWithHint: true,
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _marksController,
                    enabled: canEdit,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Marks'),
                    validator: (v) {
                      final marks = int.tryParse(v ?? '');
                      if (marks == null || marks <= 0 || marks > 100) {
                        return '1-100';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<ExamQuestionDifficulty>(
                    initialValue: _difficulty,
                    decoration: const InputDecoration(labelText: 'Difficulty'),
                    items: ExamQuestionDifficulty.values
                        .map(
                          (d) => DropdownMenuItem(
                            value: d,
                            child: Text(difficultyLabel(d)),
                          ),
                        )
                        .toList(),
                    onChanged: canEdit
                        ? (v) => setState(() => _difficulty = v ?? _difficulty)
                        : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _answerController,
              enabled: canEdit,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Suggested answer',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _guideController,
              enabled: canEdit,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Marking guide',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _notesController,
              enabled: canEdit,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText:
                    'Teacher notes (internal, not shown to moderators as answer key)',
                alignLabelWithHint: true,
              ),
            ),
            if (_status == ExamQuestionStatus.changesRequested) ...[
              const SizedBox(height: 14),
              StreamBuilder<ExamQuestion?>(
                stream: cubit.watchQuestion(questionId!),
                builder: (context, snap) {
                  final comment = snap.data?.moderationComment ?? '';
                  if (comment.isEmpty) return const SizedBox.shrink();
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Moderator feedback',
                            style: AppTypography.titleSmall,
                          ),
                          const SizedBox(height: 6),
                          Text(comment),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
            const SizedBox(height: 24),
            if (canEdit)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _saving
                          ? null
                          : () => _save(cubit, submit: false),
                      child: const Text('Save draft'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: _saving
                          ? null
                          : () => _save(cubit, submit: true),
                      child: _saving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Submit for review'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      );
    }

    return ExamFactoryScaffold(
      title: questionId == null ? 'Submit Question' : 'Edit Draft Question',
      backFallback: '/staff/exam-factory/my-questions',
      child: BlocBuilder<StructureBloc, StructureState>(
        builder: (context, structure) {
          if (structure.classes.isEmpty && structure.subjects.isEmpty) {
            return const ExamFactoryLoading();
          }
          if (questionId == null) return form(structure);
          return StreamBuilder<ExamQuestion?>(
            stream: cubit.watchQuestion(questionId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const ExamFactoryLoading();
              }
              final question = snapshot.data;
              if (question == null) {
                return const ExamFactoryEmpty(
                  icon: Icons.error_outline,
                  title: 'Question not found',
                  message: 'This question may have been removed.',
                );
              }
              _applyExisting(question);
              return form(structure);
            },
          );
        },
      ),
    );
  }
}
