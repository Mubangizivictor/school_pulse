import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import '../../../domain/entities/exam_factory_entities.dart';
import '../../bloc/exam_factory_cubit.dart';
import '../../widgets/exam_factory_shell.dart';

/// Institution-wide view of every paper's result-approval state - where DOS
/// scans for what still needs approving, as distinct from Result
/// Verification, which is the per-paper approve action itself.
class ExamResultApprovalScreen extends StatelessWidget {
  const ExamResultApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExamFactoryCubit>();
    return ExamFactoryScaffold(
      title: 'Result approval',
      backFallback: '/staff/dean/exam-factory/marking',
      child: ExamFactoryStreamView<ExamPaper>(
        stream: cubit.watchPapers(),
        emptyIcon: Icons.fact_check_outlined,
        emptyTitle: 'Nothing awaiting approval',
        emptyMessage: 'Papers with submitted marks will appear here.',
        builder: (context, items) {
          final markable = items.where((p) => p.isLocked).toList();
          if (markable.isEmpty) {
            return const ExamFactoryEmpty(
              icon: Icons.fact_check_outlined,
              title: 'Nothing awaiting approval',
              message: 'Papers with submitted marks will appear here.',
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
                  final approved = entries
                      .where((e) => e.status == MarkEntryStatus.approved)
                      .length;
                  final submitted = entries
                      .where((e) => e.status == MarkEntryStatus.submitted)
                      .length;
                  final allApproved =
                      entries.isNotEmpty && approved == entries.length;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: Icon(
                        allApproved
                            ? Icons.check_circle_outline
                            : Icons.pending_actions_outlined,
                        color: allApproved
                            ? AppColors.success(context)
                            : AppColors.warning(context),
                      ),
                      title: Text(paper.title, style: AppTypography.titleSmall),
                      subtitle: Text(
                        allApproved
                            ? 'All ${entries.length} result(s) approved'
                            : '$submitted submitted, awaiting approval',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push(
                        '/staff/dean/exam-factory/result-verification?paperId=${paper.id}',
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
