import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import '../../../domain/entities/exam_factory_entities.dart';
import '../../bloc/exam_factory_cubit.dart';
import '../../widgets/exam_factory_shell.dart';
import '../papers/exam_paper_builder_screen.dart' show paperStatusLabel;

/// Lists every locked paper with marking progress, so DOS can see at a
/// glance which papers still need marks entered, submitted or approved.
class ExamMarkingDashboardScreen extends StatelessWidget {
  const ExamMarkingDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExamFactoryCubit>();
    return ExamFactoryScaffold(
      title: 'Marking dashboard',
      backFallback: '/staff/dean/exam-factory',
      child: ExamFactoryStreamView<ExamPaper>(
        stream: cubit.watchPapers(),
        emptyIcon: Icons.fact_check_outlined,
        emptyTitle: 'No papers to mark',
        emptyMessage: 'Locked papers appear here once scheduled for marking.',
        builder: (context, items) {
          final markable = items.where((p) => p.isLocked).toList();
          if (markable.isEmpty) {
            return const ExamFactoryEmpty(
              icon: Icons.fact_check_outlined,
              title: 'No papers to mark',
              message: 'Locked papers appear here once scheduled for marking.',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.l,
              AppSpacing.l,
              AppSpacing.l,
              100,
            ),
            itemCount: markable.length,
            itemBuilder: (context, index) {
              final paper = markable[index];
              return StreamBuilder<List<ExamMarkEntry>>(
                stream: cubit.watchMarkEntries(paperId: paper.id),
                builder: (context, snap) {
                  final entries = snap.data ?? const <ExamMarkEntry>[];
                  final submitted = entries
                      .where((e) => e.status != MarkEntryStatus.draft)
                      .length;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      title: Text(paper.title, style: AppTypography.titleSmall),
                      subtitle: Text(
                        '${entries.length} marked · $submitted submitted',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push(
                        '/staff/dean/exam-factory/mark-entry?paperId=${paper.id}',
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class ExamMarkEntryScreen extends StatefulWidget {
  final String paperId;
  const ExamMarkEntryScreen({super.key, required this.paperId});

  @override
  State<ExamMarkEntryScreen> createState() => _ExamMarkEntryScreenState();
}

class _ExamMarkEntryScreenState extends State<ExamMarkEntryScreen> {
  final _studentIdController = TextEditingController();
  final _studentNameController = TextEditingController();
  final _scoreController = TextEditingController();
  bool _isAbsent = false;
  bool _saving = false;

  @override
  void dispose() {
    _studentIdController.dispose();
    _studentNameController.dispose();
    _scoreController.dispose();
    super.dispose();
  }

  Future<void> _save(ExamFactoryCubit cubit) async {
    if (_studentIdController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter the candidate\'s ID.')),
      );
      return;
    }
    final score = _isAbsent
        ? null
        : double.tryParse(_scoreController.text.trim());
    if (!_isAbsent && score == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter a valid score.')));
      return;
    }
    setState(() => _saving = true);
    try {
      await cubit.saveMarkEntry(
        paperId: widget.paperId,
        studentId: _studentIdController.text.trim(),
        studentName: _studentNameController.text.trim(),
        score: score,
        isAbsent: _isAbsent,
        operationId: '${widget.paperId}_${_studentIdController.text.trim()}',
      );
      if (!mounted) return;
      _studentIdController.clear();
      _studentNameController.clear();
      _scoreController.clear();
      setState(() => _isAbsent = false);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(cubit.state.error ?? 'Could not save this mark.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _submitAll(ExamFactoryCubit cubit) async {
    try {
      final count = await cubit.submitMarks(widget.paperId);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$count mark(s) submitted.')));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(cubit.state.error ?? 'Could not submit marks.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExamFactoryCubit>();
    return ExamFactoryScaffold(
      title: 'Mark entry',
      backFallback: '/staff/dean/exam-factory/marking',
      action: TextButton(
        onPressed: () => _submitAll(cubit),
        child: const Text('Submit all'),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.l,
          AppSpacing.l,
          AppSpacing.l,
          100,
        ),
        children: [
          TextField(
            controller: _studentIdController,
            decoration: const InputDecoration(labelText: 'Candidate ID'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _studentNameController,
            decoration: const InputDecoration(labelText: 'Candidate name'),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _scoreController,
                  enabled: !_isAbsent,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(labelText: 'Score'),
                ),
              ),
              const SizedBox(width: 10),
              FilterChip(
                label: const Text('Absent'),
                selected: _isAbsent,
                onSelected: (v) => setState(() => _isAbsent = v),
              ),
            ],
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: _saving ? null : () => _save(cubit),
            icon: _saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined),
            label: Text(_saving ? 'Saving…' : 'Save mark'),
          ),
          const SizedBox(height: 24),
          Text('Entered marks', style: AppTypography.titleSmall),
          const SizedBox(height: 8),
          StreamBuilder<List<ExamMarkEntry>>(
            stream: cubit.watchMarkEntries(paperId: widget.paperId),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final entries = snap.data ?? const <ExamMarkEntry>[];
              if (entries.isEmpty) {
                return const Text('No marks entered yet.');
              }
              return Column(
                children: entries
                    .map(
                      (e) => Card(
                        child: ListTile(
                          title: Text(
                            e.studentName.isEmpty ? e.studentId : e.studentName,
                          ),
                          subtitle: Text(
                            e.isAbsent
                                ? 'Absent'
                                : '${e.score} / ${e.maximumMark}',
                          ),
                          trailing: Chip(label: Text(e.status.name)),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Papers still missing at least one candidate's mark, across all locked
/// papers - the "who hasn't finished marking" cross-cut view.
class ExamMissingMarksScreen extends StatelessWidget {
  const ExamMissingMarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExamFactoryCubit>();
    return ExamFactoryScaffold(
      title: 'Missing marks',
      backFallback: '/staff/dean/exam-factory/marking',
      child: ExamFactoryStreamView<ExamPaper>(
        stream: cubit.watchPapers(),
        emptyIcon: Icons.checklist_outlined,
        emptyTitle: 'Nothing to check',
        emptyMessage: 'Locked papers will appear here once marking starts.',
        builder: (context, items) {
          final markable = items.where((p) => p.isLocked).toList();
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.l,
              AppSpacing.l,
              AppSpacing.l,
              100,
            ),
            itemCount: markable.length,
            itemBuilder: (context, index) {
              final paper = markable[index];
              return StreamBuilder<List<ExamMarkEntry>>(
                stream: cubit.watchMarkEntries(paperId: paper.id),
                builder: (context, snap) {
                  final entries = snap.data ?? const <ExamMarkEntry>[];
                  final draft = entries
                      .where((e) => e.status == MarkEntryStatus.draft)
                      .length;
                  if (entries.isEmpty || draft == 0) {
                    return const SizedBox.shrink();
                  }
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: Icon(
                        Icons.warning_amber_rounded,
                        color: AppColors.warning(context),
                      ),
                      title: Text(paper.title, style: AppTypography.titleSmall),
                      subtitle: Text('$draft mark(s) not yet submitted'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push(
                        '/staff/dean/exam-factory/mark-entry?paperId=${paper.id}',
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

/// DOS review of a paper's submitted marks before approving them into
/// Performance and Report Cards. Approval is irreversible for already-
/// published rows - see approveExamResults for why.
class ExamResultVerificationScreen extends StatefulWidget {
  final String paperId;
  const ExamResultVerificationScreen({super.key, required this.paperId});

  @override
  State<ExamResultVerificationScreen> createState() =>
      _ExamResultVerificationScreenState();
}

class _ExamResultVerificationScreenState
    extends State<ExamResultVerificationScreen> {
  bool _approving = false;

  Future<void> _approve(ExamFactoryCubit cubit) async {
    setState(() => _approving = true);
    try {
      final result = await cubit.approveResults(widget.paperId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${result['approvedCount']} of ${result['totalEntries']} result(s) approved.',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            cubit.state.error ?? 'Could not approve these results.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _approving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExamFactoryCubit>();
    return ExamFactoryScaffold(
      title: 'Result verification',
      backFallback: '/staff/dean/exam-factory/marking',
      child: StreamBuilder<ExamPaper?>(
        stream: cubit.watchPaper(widget.paperId),
        builder: (context, paperSnap) {
          final paper = paperSnap.data;
          return StreamBuilder<List<ExamMarkEntry>>(
            stream: cubit.watchMarkEntries(paperId: widget.paperId),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const ExamFactoryLoading();
              }
              final entries = snap.data ?? const <ExamMarkEntry>[];
              final draft = entries
                  .where((e) => e.status == MarkEntryStatus.draft)
                  .length;
              final approved = entries
                  .where((e) => e.status == MarkEntryStatus.approved)
                  .length;
              return ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.l,
                  AppSpacing.l,
                  AppSpacing.l,
                  100,
                ),
                children: [
                  if (paper != null)
                    Text(
                      paper.title,
                      style: AppTypography.titleLarge.copyWith(fontSize: 18),
                    ),
                  if (paper != null) Text(paperStatusLabel(paper.status)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _Stat(
                          label: 'Total',
                          value: '${entries.length}',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _Stat(
                          label: 'Draft',
                          value: '$draft',
                          warn: draft > 0,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _Stat(label: 'Approved', value: '$approved'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (draft > 0)
                    Card(
                      color: AppColors.warningSurface(context),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          '$draft mark(s) are still draft. All marks must be submitted before results can be approved.',
                        ),
                      ),
                    )
                  else
                    FilledButton.icon(
                      onPressed: _approving || entries.isEmpty
                          ? null
                          : () => _approve(cubit),
                      icon: _approving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.verified_outlined),
                      label: Text(
                        _approving ? 'Approving…' : 'Approve results',
                      ),
                    ),
                  const SizedBox(height: 20),
                  ...entries.map(
                    (e) => Card(
                      child: ListTile(
                        title: Text(
                          e.studentName.isEmpty ? e.studentId : e.studentName,
                        ),
                        subtitle: Text(
                          e.isAbsent
                              ? 'Absent'
                              : '${e.score} / ${e.maximumMark}',
                        ),
                        trailing: Chip(label: Text(e.status.name)),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label, value;
  final bool warn;
  const _Stat({required this.label, required this.value, this.warn = false});
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Text(
            value,
            style: AppTypography.titleLarge.copyWith(
              color: warn ? AppColors.warning(context) : null,
            ),
          ),
          Text(label, style: AppTypography.bodySmall),
        ],
      ),
    ),
  );
}
