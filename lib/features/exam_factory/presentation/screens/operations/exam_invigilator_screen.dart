import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import '../../../domain/entities/exam_factory_entities.dart';
import '../../bloc/exam_factory_cubit.dart';
import '../../widgets/exam_factory_shell.dart';

String invigilatorRoleLabel(InvigilatorRole role) =>
    role == InvigilatorRole.chief
    ? 'Chief invigilator'
    : 'Assistant invigilator';

class ExamInvigilatorScreen extends StatefulWidget {
  final String sittingId;
  const ExamInvigilatorScreen({super.key, required this.sittingId});

  @override
  State<ExamInvigilatorScreen> createState() => _ExamInvigilatorScreenState();
}

class _ExamInvigilatorScreenState extends State<ExamInvigilatorScreen> {
  final _staffIdController = TextEditingController();
  final _staffNameController = TextEditingController();
  InvigilatorRole _role = InvigilatorRole.assistant;
  bool _assigning = false;

  @override
  void dispose() {
    _staffIdController.dispose();
    _staffNameController.dispose();
    super.dispose();
  }

  Future<void> _assign(ExamFactoryCubit cubit) async {
    if (_staffIdController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter the staff member\'s ID.')),
      );
      return;
    }
    setState(() => _assigning = true);
    try {
      await cubit.assignInvigilator(
        sittingId: widget.sittingId,
        staffId: _staffIdController.text.trim(),
        staffName: _staffNameController.text.trim(),
        role: _role,
      );
      if (!mounted) return;
      _staffIdController.clear();
      _staffNameController.clear();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invigilator assigned.')));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            cubit.state.error ?? 'Could not assign this invigilator.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _assigning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExamFactoryCubit>();
    return ExamFactoryScaffold(
      title: 'Invigilator assignment',
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
            controller: _staffIdController,
            decoration: const InputDecoration(labelText: 'Staff ID'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _staffNameController,
            decoration: const InputDecoration(
              labelText: 'Staff name (for display)',
            ),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<InvigilatorRole>(
            initialValue: _role,
            decoration: const InputDecoration(labelText: 'Role'),
            items: InvigilatorRole.values
                .map(
                  (r) => DropdownMenuItem(
                    value: r,
                    child: Text(invigilatorRoleLabel(r)),
                  ),
                )
                .toList(),
            onChanged: (v) => setState(() => _role = v ?? _role),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: _assigning ? null : () => _assign(cubit),
            icon: _assigning
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.add),
            label: Text(_assigning ? 'Assigning…' : 'Assign invigilator'),
          ),
          const SizedBox(height: 24),
          Text('Assigned', style: AppTypography.titleSmall),
          const SizedBox(height: 8),
          StreamBuilder<List<ExamInvigilatorAssignment>>(
            stream: cubit.watchInvigilators(sittingId: widget.sittingId),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final assignments =
                  snap.data ?? const <ExamInvigilatorAssignment>[];
              if (assignments.isEmpty) {
                return const Text('No invigilators assigned yet.');
              }
              return Column(
                children: assignments
                    .map(
                      (a) => Card(
                        child: ListTile(
                          leading: const Icon(Icons.person_outline),
                          title: Text(
                            a.staffName.isEmpty ? a.staffId : a.staffName,
                          ),
                          subtitle: Text(invigilatorRoleLabel(a.role)),
                          trailing: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => cubit.removeInvigilator(a.id),
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
