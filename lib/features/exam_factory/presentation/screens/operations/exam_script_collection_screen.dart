import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import '../../../domain/entities/exam_factory_entities.dart';
import '../../bloc/exam_factory_cubit.dart';
import '../../widgets/exam_factory_shell.dart';

String scriptStatusLabel(ScriptStatus status) => switch (status) {
  ScriptStatus.distributed => 'Distributed',
  ScriptStatus.collected => 'Collected',
  ScriptStatus.missing => 'Missing',
};

Color scriptStatusColor(BuildContext context, ScriptStatus status) =>
    switch (status) {
      ScriptStatus.distributed => AppColors.information(context),
      ScriptStatus.collected => AppColors.success(context),
      ScriptStatus.missing => AppColors.danger(context),
    };

class ExamScriptCollectionScreen extends StatefulWidget {
  final String sittingId;
  const ExamScriptCollectionScreen({super.key, required this.sittingId});

  @override
  State<ExamScriptCollectionScreen> createState() =>
      _ExamScriptCollectionScreenState();
}

class _ExamScriptCollectionScreenState
    extends State<ExamScriptCollectionScreen> {
  final _studentIdController = TextEditingController();
  final _studentNameController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _studentIdController.dispose();
    _studentNameController.dispose();
    super.dispose();
  }

  Future<void> _record(ExamFactoryCubit cubit, ScriptStatus status) async {
    if (_studentIdController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter the candidate\'s ID.')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await cubit.recordScript(
        sittingId: widget.sittingId,
        studentId: _studentIdController.text.trim(),
        studentName: _studentNameController.text.trim(),
        status: status,
        operationId:
            '${widget.sittingId}_${_studentIdController.text.trim()}_${status.name}',
      );
      if (!mounted) return;
      _studentIdController.clear();
      _studentNameController.clear();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(cubit.state.error ?? 'Could not record this script.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExamFactoryCubit>();
    return ExamFactoryScaffold(
      title: 'Script collection',
      backFallback:
          '/staff/dean/exam-factory/exam-day?sittingId=${widget.sittingId}',
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
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ScriptStatus.values
                .map(
                  (status) => FilledButton.tonalIcon(
                    onPressed: _saving ? null : () => _record(cubit, status),
                    icon: Icon(switch (status) {
                      ScriptStatus.distributed => Icons.outbox_outlined,
                      ScriptStatus.collected => Icons.move_to_inbox_outlined,
                      ScriptStatus.missing => Icons.error_outline,
                    }),
                    label: Text(scriptStatusLabel(status)),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 24),
          Text('Scripts', style: AppTypography.titleSmall),
          const SizedBox(height: 8),
          StreamBuilder<List<ExamScriptRecord>>(
            stream: cubit.watchScripts(sittingId: widget.sittingId),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final scripts = snap.data ?? const <ExamScriptRecord>[];
              if (scripts.isEmpty) {
                return const Text('No scripts tracked yet.');
              }
              return Column(
                children: scripts
                    .map(
                      (s) => Card(
                        child: ListTile(
                          title: Text(
                            s.studentName.isEmpty ? s.studentId : s.studentName,
                          ),
                          trailing: Text(
                            scriptStatusLabel(s.status),
                            style: TextStyle(
                              color: scriptStatusColor(context, s.status),
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
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
