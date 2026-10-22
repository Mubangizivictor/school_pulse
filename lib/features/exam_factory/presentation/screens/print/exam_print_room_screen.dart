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

/// Only locked, print-ready papers appear here. Controlled PDF generation,
/// downloads and print jobs are all server-audited; nothing here works
/// offline by design (see repository docs on offline behaviour).
class ExamPrintRoomScreen extends StatelessWidget {
  const ExamPrintRoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExamFactoryCubit>();
    return ExamFactoryScaffold(
      title: 'Print Room',
      subtitle: 'Confidential — controlled print jobs only',
      backFallback: '/staff/dean/exam-factory',
      child: ExamFactoryStreamView<ExamPaper>(
        stream: cubit.watchPapers(),
        emptyIcon: Icons.print_outlined,
        emptyTitle: 'No papers ready to print',
        emptyMessage:
            'Papers appear here once locked by the approval workflow.',
        builder: (context, items) {
          final printable = items.where((p) => p.isLocked).toList();
          if (printable.isEmpty) {
            return const ExamFactoryEmpty(
              icon: Icons.print_outlined,
              title: 'No papers ready to print',
              message:
                  'Papers appear here once locked by the approval workflow.',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.l,
              AppSpacing.l,
              AppSpacing.l,
              100,
            ),
            itemCount: printable.length,
            itemBuilder: (context, index) {
              final paper = printable[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: Icon(
                    paper.filesGenerated
                        ? Icons.lock_outline
                        : Icons.hourglass_top_outlined,
                    color: paper.filesGenerated
                        ? AppColors.success(context)
                        : AppColors.warning(context),
                  ),
                  title: Text(paper.title, style: AppTypography.titleSmall),
                  subtitle: Text(
                    '${paperStatusLabel(paper.status)} · v${paper.version}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(
                    '/staff/dean/exam-factory/print-job?paperId=${paper.id}',
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ExamPrintJobScreen extends StatefulWidget {
  final String paperId;
  const ExamPrintJobScreen({super.key, required this.paperId});

  @override
  State<ExamPrintJobScreen> createState() => _ExamPrintJobScreenState();
}

class _ExamPrintJobScreenState extends State<ExamPrintJobScreen> {
  final _copiesController = TextEditingController(text: '1');
  final _extraCopiesController = TextEditingController(text: '0');
  final _printerController = TextEditingController();
  final _reprintReasonController = TextEditingController();
  String _paperSize = 'A4';
  bool _duplex = false;
  bool _includeMarkingGuide = false;
  bool _generating = false;
  bool _starting = false;

  @override
  void dispose() {
    _copiesController.dispose();
    _extraCopiesController.dispose();
    _printerController.dispose();
    _reprintReasonController.dispose();
    super.dispose();
  }

  Future<void> _generateFiles(ExamFactoryCubit cubit) async {
    setState(() => _generating = true);
    try {
      await cubit.generatePaperFiles(widget.paperId, watermark: 'CONFIDENTIAL');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Controlled PDF generated.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(cubit.state.error ?? 'Could not generate the PDF.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  Future<void> _download(
    ExamFactoryCubit cubit,
    String fileType,
    String label,
  ) async {
    try {
      final url = await cubit.getPaperDownloadUrl(widget.paperId, fileType);
      if (!mounted) return;
      if (url.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not prepare $label for download.')),
        );
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$label link ready. It expires in 10 minutes.')),
      );
      // ignore: use_build_context_synchronously
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(label),
          content: SelectableText(url),
          actions: [
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(cubit.state.error ?? 'Could not download $label.'),
        ),
      );
    }
  }

  Future<void> _startPrintJob(ExamFactoryCubit cubit, bool isReprint) async {
    final copies = int.tryParse(_copiesController.text.trim()) ?? 0;
    if (copies <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid copy count.')),
      );
      return;
    }
    if (isReprint && _reprintReasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A reprint reason is required.')),
      );
      return;
    }
    setState(() => _starting = true);
    try {
      await cubit.recordPrintJob(
        widget.paperId,
        copies: copies,
        extraCopies: int.tryParse(_extraCopiesController.text.trim()) ?? 0,
        printer: _printerController.text.trim(),
        paperSize: _paperSize,
        duplex: _duplex,
        includeMarkingGuide: _includeMarkingGuide,
        isReprint: isReprint,
        reprintReason: _reprintReasonController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Print job started.')));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(cubit.state.error ?? 'Could not start the print job.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExamFactoryCubit>();
    return ExamFactoryScaffold(
      title: 'Print job',
      subtitle: 'Confidential',
      backFallback: '/staff/dean/exam-factory/print-room',
      child: StreamBuilder<ExamPaper?>(
        stream: cubit.watchPaper(widget.paperId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const ExamFactoryLoading();
          }
          final paper = snapshot.data;
          if (paper == null) {
            return const ExamFactoryEmpty(
              icon: Icons.error_outline,
              title: 'Paper not found',
              message: 'This paper may have been removed.',
            );
          }
          if (!paper.isLocked) {
            return ExamFactoryEmpty(
              icon: Icons.lock_open_outlined,
              title: 'Not ready to print',
              message:
                  'Only approved and locked papers may be printed. Current status: ${paperStatusLabel(paper.status)}.',
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.l,
              AppSpacing.l,
              AppSpacing.l,
              100,
            ),
            children: [
              Card(
                color: AppColors.warningSurface(context),
                child: Padding(
                  padding: const EdgeInsets.all(13),
                  child: Row(
                    children: [
                      Icon(
                        Icons.security_outlined,
                        color: AppColors.warning(context),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'All downloads and print actions are recorded.',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                paper.title,
                style: AppTypography.titleLarge.copyWith(fontSize: 18),
              ),
              Text(
                '${paperStatusLabel(paper.status)} · v${paper.version} · ${paper.totalMarks} marks',
              ),
              const SizedBox(height: 18),
              if (!paper.filesGenerated)
                FilledButton.icon(
                  onPressed: _generating ? null : () => _generateFiles(cubit),
                  icon: _generating
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.lock_outline),
                  label: Text(
                    _generating ? 'Generating…' : 'Generate controlled PDF',
                  ),
                )
              else ...[
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            _download(cubit, 'questionPaper', 'Question paper'),
                        icon: const Icon(Icons.description_outlined),
                        label: const Text('Question paper'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            _download(cubit, 'markingGuide', 'Marking guide'),
                        icon: const Icon(Icons.fact_check_outlined),
                        label: const Text('Marking guide'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Text('Print options', style: AppTypography.titleSmall),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _copiesController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Copies'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _extraCopiesController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Extra copies',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _printerController,
                  decoration: const InputDecoration(
                    labelText: 'Printer / print location',
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _paperSize,
                        decoration: const InputDecoration(
                          labelText: 'Paper size',
                        ),
                        items: const [
                          DropdownMenuItem(value: 'A4', child: Text('A4')),
                          DropdownMenuItem(value: 'A3', child: Text('A3')),
                          DropdownMenuItem(
                            value: 'Letter',
                            child: Text('Letter'),
                          ),
                        ],
                        onChanged: (v) =>
                            setState(() => _paperSize = v ?? _paperSize),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SwitchListTile(
                        title: const Text('Duplex'),
                        value: _duplex,
                        onChanged: (v) => setState(() => _duplex = v),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
                SwitchListTile(
                  title: const Text('Include marking guide in the job'),
                  value: _includeMarkingGuide,
                  onChanged: (v) => setState(() => _includeMarkingGuide = v),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _starting
                        ? null
                        : () => _startPrintJob(cubit, false),
                    icon: const Icon(Icons.print_outlined),
                    label: Text(_starting ? 'Starting…' : 'Start print job'),
                  ),
                ),
                const SizedBox(height: 22),
                Text('Reprint', style: AppTypography.titleSmall),
                const SizedBox(height: 8),
                TextField(
                  controller: _reprintReasonController,
                  decoration: const InputDecoration(
                    labelText: 'Reprint reason (required for reprints)',
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _starting
                        ? null
                        : () => _startPrintJob(cubit, true),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Record reprint'),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Text('Print audit', style: AppTypography.titleSmall),
              const SizedBox(height: 8),
              StreamBuilder<List<ExamPrintJob>>(
                stream: cubit.watchPrintJobs(paperId: paper.id),
                builder: (context, jobsSnap) {
                  final jobs = jobsSnap.data ?? const <ExamPrintJob>[];
                  if (jobs.isEmpty) {
                    return const Text('No print jobs recorded yet.');
                  }
                  return Column(
                    children: jobs
                        .map(
                          (job) => Card(
                            child: ListTile(
                              leading: Icon(
                                job.status == PrintJobStatus.completed
                                    ? Icons.check_circle_outline
                                    : Icons.hourglass_top_outlined,
                              ),
                              title: Text(
                                '${job.copies + job.extraCopies} copies · v${job.version}',
                              ),
                              subtitle: Text(
                                '${job.isReprint ? 'Reprint: ${job.reprintReason}' : 'Print job'} · ${job.status == PrintJobStatus.completed ? 'Completed' : 'In progress'}',
                              ),
                              trailing: job.status == PrintJobStatus.started
                                  ? TextButton(
                                      onPressed: () =>
                                          cubit.completePrintJob(job.id),
                                      child: const Text('Mark done'),
                                    )
                                  : null,
                            ),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
