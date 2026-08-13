import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:school_pulse/features/admin/presentation/widgets/admin_app_bar.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import '../../../domain/entities/assessment_grading_entities.dart';
import '../../bloc/structure_bloc.dart';
import '../../bloc/structure_event.dart';
import '../../bloc/structure_state.dart';
import '../../widgets/academics_ui_kit.dart';
import '../../widgets/structure_dialogs.dart' show showDeleteConfirmDialog;
import '../../widgets/structure_empty_hint.dart';

class GradingSystemsScreen extends StatefulWidget {
  const GradingSystemsScreen({super.key});

  @override
  State<GradingSystemsScreen> createState() => _GradingSystemsScreenState();
}

class _GradingSystemsScreenState extends State<GradingSystemsScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final schoolId =
        (context.watch<AuthBloc>().state as AuthAuthenticated).user.schoolId;
    return BlocBuilder<StructureBloc, StructureState>(
      builder: (context, state) {
        final bloc = context.read<StructureBloc>();
        final systems = state.gradingSystems
            .where((s) => s.name.toLowerCase().contains(_query.toLowerCase()))
            .toList()
          ..sort((a, b) => a.name.compareTo(b.name));

        return AcademicsListScaffold(
          title: 'Grading Systems',
          subtitle: 'Configure grading scales and systems for your school.',
          searchHint: 'Search grading systems...',
          onSearchChanged: (v) => setState(() => _query = v),
          fabLabel: 'Add Grading System',
          onFabPressed: () =>
              _openForm(context, schoolId: schoolId, bloc: bloc),
          body: systems.isEmpty
              ? StructureEmptyHint(
                  _query.isEmpty
                      ? 'No grading systems yet.\nAdd A-F, Percentage, Competency-based, or whatever this school uses.'
                      : 'No grading systems match "$_query".',
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                  itemCount: systems.length,
                  itemBuilder: (context, index) {
                    final system = systems[index];
                    final bandCount = state.gradeBands
                        .where((b) => b.gradingSystemId == system.id)
                        .length;
                    return AcademicsListCard(
                      icon: Icons.star_outline,
                      color: Colors.amber.shade800,
                      title: system.name,
                      subtitle: [
                        if (system.type.isNotEmpty) system.type,
                        if (system.isDefault) 'Default',
                      ].join(' • '),
                      trailingLabel: bandCount > 0
                          ? '$bandCount Grade${bandCount == 1 ? '' : 's'}'
                          : null,
                      isActive: system.isActive,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => _GradingSystemDetailScreen(
                            schoolId: schoolId,
                            system: system,
                          ),
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }

  void _openForm(
    BuildContext context, {
    required String schoolId,
    required StructureBloc bloc,
    GradingSystemDef? existing,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _GradingSystemFormScreen(
          schoolId: schoolId,
          existing: existing,
          onSave: (s) => bloc.add(SaveGradingSystemRequested(s)),
          onDelete: existing == null
              ? null
              : () => bloc.add(DeleteGradingSystemRequested(existing.id)),
        ),
      ),
    );
  }
}

class _GradingSystemDetailScreen extends StatelessWidget {
  final String schoolId;
  final GradingSystemDef system;

  const _GradingSystemDetailScreen({
    required this.schoolId,
    required this.system,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StructureBloc, StructureState>(
      builder: (context, state) {
        final bloc = context.read<StructureBloc>();
        final current = state.gradingSystems
                .where((s) => s.id == system.id)
                .firstOrNull ??
            system;
        final bands = state.gradeBands
            .where((b) => b.gradingSystemId == system.id)
            .toList()
          ..sort((a, b) => a.order.compareTo(b.order));

        return Scaffold(
          appBar: AdminAppBar(
            title: current.name,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => _GradingSystemFormScreen(
                      schoolId: schoolId,
                      existing: current,
                      onSave: (s) => bloc.add(SaveGradingSystemRequested(s)),
                      onDelete: () =>
                          bloc.add(DeleteGradingSystemRequested(current.id)),
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: bands.isEmpty
              ? const StructureEmptyHint(
                  'No grade bands yet.\nAdd bands like A: 80-100, B: 70-79, ...',
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                  itemCount: bands.length,
                  itemBuilder: (context, index) {
                    final band = bands[index];
                    return AcademicsListCard(
                      icon: Icons.grade_outlined,
                      color: Colors.amber.shade800,
                      title: '${band.grade}  (${band.minScore.toStringAsFixed(0)}-${band.maxScore.toStringAsFixed(0)})',
                      subtitle: band.remarks,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => _GradeBandFormScreen(
                            schoolId: schoolId,
                            gradingSystemId: system.id,
                            existing: band,
                            onSave: (b) => bloc.add(SaveGradeBandRequested(b)),
                            onDelete: () =>
                                bloc.add(DeleteGradeBandRequested(band.id)),
                          ),
                        ),
                      ),
                    );
                  },
                ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => _GradeBandFormScreen(
                  schoolId: schoolId,
                  gradingSystemId: system.id,
                  onSave: (b) => bloc.add(SaveGradeBandRequested(b)),
                ),
              ),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Add Grade'),
          ),
        );
      },
    );
  }
}

class _GradingSystemFormScreen extends StatefulWidget {
  final String schoolId;
  final GradingSystemDef? existing;
  final void Function(GradingSystemDef) onSave;
  final VoidCallback? onDelete;

  const _GradingSystemFormScreen({
    required this.schoolId,
    this.existing,
    required this.onSave,
    this.onDelete,
  });

  @override
  State<_GradingSystemFormScreen> createState() =>
      _GradingSystemFormScreenState();
}

class _GradingSystemFormScreenState extends State<_GradingSystemFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(
    text: widget.existing?.name,
  );
  late final _typeController = TextEditingController(
    text: widget.existing?.type,
  );
  late bool _isDefault = widget.existing?.isDefault ?? false;
  late bool _isActive = widget.existing?.isActive ?? true;

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return AcademicsFormScaffold(
      title: isEdit ? 'Edit Grading System' : 'Add Grading System',
      subtitle: isEdit
          ? 'Update this grading system.'
          : 'Create a new grading system for your school.',
      saveLabel: isEdit ? 'Save Changes' : 'Save Grading System',
      onSave: _submit,
      fields: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _FieldLabel('Name *'),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(hintText: 'e.g. A-F Scale'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),
              const _FieldLabel('Type'),
              TextFormField(
                controller: _typeController,
                decoration: const InputDecoration(
                  hintText: 'e.g. Letter grade, Percentage, Competency-based',
                ),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Default grading system'),
                value: _isDefault,
                onChanged: (v) => setState(() => _isDefault = v),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Active'),
                value: _isActive,
                onChanged: (v) => setState(() => _isActive = v),
              ),
              if (isEdit && widget.onDelete != null) ...[
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () async {
                    final confirmed = await showDeleteConfirmDialog(
                      context,
                      title: 'Delete Grading System',
                      message: 'Delete "${widget.existing!.name}"?',
                    );
                    if (confirmed == true && mounted) {
                      widget.onDelete!();
                      Navigator.of(context).pop();
                    }
                  },
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  label: const Text(
                    'Delete Grading System',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    widget.onSave(
      GradingSystemDef(
        id: widget.existing?.id ?? const Uuid().v4(),
        schoolId: widget.existing?.schoolId ?? widget.schoolId,
        name: _nameController.text.trim(),
        type: _typeController.text.trim(),
        isDefault: _isDefault,
        isActive: _isActive,
      ),
    );
    Navigator.of(context).pop();
  }
}

class _GradeBandFormScreen extends StatefulWidget {
  final String schoolId;
  final String gradingSystemId;
  final GradeBand? existing;
  final void Function(GradeBand) onSave;
  final VoidCallback? onDelete;

  const _GradeBandFormScreen({
    required this.schoolId,
    required this.gradingSystemId,
    this.existing,
    required this.onSave,
    this.onDelete,
  });

  @override
  State<_GradeBandFormScreen> createState() => _GradeBandFormScreenState();
}

class _GradeBandFormScreenState extends State<_GradeBandFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _gradeController = TextEditingController(
    text: widget.existing?.grade,
  );
  late final _minController = TextEditingController(
    text: widget.existing?.minScore.toString(),
  );
  late final _maxController = TextEditingController(
    text: widget.existing?.maxScore.toString(),
  );
  late final _remarksController = TextEditingController(
    text: widget.existing?.remarks,
  );
  late final _orderController = TextEditingController(
    text: widget.existing?.order.toString() ?? '',
  );

  @override
  void dispose() {
    _gradeController.dispose();
    _minController.dispose();
    _maxController.dispose();
    _remarksController.dispose();
    _orderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return AcademicsFormScaffold(
      title: isEdit ? 'Edit Grade' : 'Add Grade',
      subtitle: 'Define a score range and grade.',
      saveLabel: isEdit ? 'Save Changes' : 'Save Grade',
      onSave: _submit,
      fields: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _FieldLabel('Grade *'),
              TextFormField(
                controller: _gradeController,
                decoration: const InputDecoration(hintText: 'e.g. A'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Grade is required' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _FieldLabel('Minimum Score *'),
                        TextFormField(
                          controller: _minController,
                          decoration: const InputDecoration(hintText: '80'),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (v) =>
                              double.tryParse(v ?? '') == null ? 'Required' : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _FieldLabel('Maximum Score *'),
                        TextFormField(
                          controller: _maxController,
                          decoration: const InputDecoration(hintText: '100'),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (v) =>
                              double.tryParse(v ?? '') == null ? 'Required' : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const _FieldLabel('Descriptor'),
              TextFormField(
                controller: _remarksController,
                decoration: const InputDecoration(
                  hintText: 'e.g. Excellent, Distinction',
                ),
              ),
              const SizedBox(height: 16),
              const _FieldLabel('Display Order'),
              TextFormField(
                controller: _orderController,
                decoration: const InputDecoration(hintText: 'e.g. 1'),
                keyboardType: TextInputType.number,
              ),
              if (isEdit && widget.onDelete != null) ...[
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () async {
                    final confirmed = await showDeleteConfirmDialog(
                      context,
                      title: 'Delete Grade',
                      message: 'Delete "${widget.existing!.grade}"?',
                    );
                    if (confirmed == true && mounted) {
                      widget.onDelete!();
                      Navigator.of(context).pop();
                    }
                  },
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  label: const Text(
                    'Delete Grade',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final min = double.tryParse(_minController.text) ?? 0;
    final max = double.tryParse(_maxController.text) ?? 0;
    if (max < min) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum score must be greater than or equal to minimum'),
        ),
      );
      return;
    }
    widget.onSave(
      GradeBand(
        id: widget.existing?.id ?? const Uuid().v4(),
        schoolId: widget.existing?.schoolId ?? widget.schoolId,
        gradingSystemId: widget.gradingSystemId,
        grade: _gradeController.text.trim(),
        minScore: min,
        maxScore: max,
        remarks: _remarksController.text.trim(),
        order: int.tryParse(_orderController.text) ?? 0,
      ),
    );
    Navigator.of(context).pop();
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
      ),
    );
  }
}
