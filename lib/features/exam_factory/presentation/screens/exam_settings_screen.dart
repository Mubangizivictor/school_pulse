import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import '../../domain/entities/exam_factory_entities.dart';
import '../bloc/exam_factory_cubit.dart';
import '../widgets/exam_factory_shell.dart';

/// Module-wide reference: per-series configuration entry points and the
/// server-enforced role matrix. Permissions themselves are never editable
/// from the client - Firestore rules and each Cloud Function's own role
/// check are the actual boundary (see hasExamRole()/isLead() throughout the
/// backend) - so this screen surfaces what they are rather than pretending
/// they are client-configurable.
class ExamSettingsScreen extends StatelessWidget {
  const ExamSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExamFactoryCubit>();
    return ExamFactoryScaffold(
      title: 'Exam Factory settings',
      backFallback: '/staff/dean/exam-factory',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.l,
          AppSpacing.l,
          AppSpacing.l,
          100,
        ),
        children: [
          Text('Examination series', style: AppTypography.titleSmall),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.event_note_outlined),
              title: const Text('Manage series & deadlines'),
              subtitle: const Text(
                'Grading scale, paper template, submission/printing/marking deadlines',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/staff/dean/exam-factory/series'),
            ),
          ),
          const SizedBox(height: 20),
          Text('Roles & permissions', style: AppTypography.titleSmall),
          const SizedBox(height: 4),
          Text(
            'Enforced server-side and cannot be changed from this screen.',
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: 8),
          const _PermissionRow(
            role: 'Teacher',
            grants:
                'Submit/edit own questions, view own submissions, mark assigned papers',
          ),
          const _PermissionRow(
            role: 'HOD / Moderator',
            grants: 'Moderate submitted questions in their subject scope',
          ),
          const _PermissionRow(
            role:
                'Dean of Studies / Head Teacher / Deputy / Director / School Admin',
            grants:
                'Full series, question, paper, print, operations and results access',
          ),
          const _PermissionRow(
            role: 'Print Officer',
            grants:
                'Secure Print Room only — cannot browse the Question Bank or edit papers',
          ),
          const SizedBox(height: 20),
          Text('Recent activity', style: AppTypography.titleSmall),
          const SizedBox(height: 8),
          StreamBuilder<List<ExamAuditEntry>>(
            stream: cubit.watchAuditTrail(),
            builder: (context, snap) {
              final entries = (snap.data ?? const <ExamAuditEntry>[])
                  .take(10)
                  .toList();
              if (entries.isEmpty) {
                return const Text('No activity recorded yet.');
              }
              return Column(
                children: entries
                    .map(
                      (e) => Card(
                        child: ListTile(
                          dense: true,
                          leading: const Icon(Icons.history_outlined, size: 20),
                          title: Text(e.actionLabel),
                          subtitle: Text(e.role.isEmpty ? 'System' : e.role),
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

class _PermissionRow extends StatelessWidget {
  final String role, grants;
  const _PermissionRow({required this.role, required this.grants});
  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 8),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(role, style: AppTypography.titleSmall),
          const SizedBox(height: 4),
          Text(grants, style: AppTypography.bodySmall),
        ],
      ),
    ),
  );
}
