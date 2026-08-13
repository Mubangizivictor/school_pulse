import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import '../../../domain/entities/assessment_grading_entities.dart';
import '../../bloc/structure_bloc.dart';
import '../../bloc/structure_event.dart';
import '../../bloc/structure_state.dart';
import '../../widgets/academics_ui_kit.dart';
import '../../widgets/structure_dialogs.dart' show showDeleteConfirmDialog;
import '../../widgets/structure_empty_hint.dart';

class AssessmentTypesScreen extends StatefulWidget {
  const AssessmentTypesScreen({super.key});

  @override
  State<AssessmentTypesScreen> createState() => _AssessmentTypesScreenState();
}

class _AssessmentTypesScreenState extends State<AssessmentTypesScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final schoolId =
        (context.watch<AuthBloc>().state as AuthAuthenticated).user.schoolId;
    return BlocBuilder<StructureBloc, StructureState>(
      builder: (context, state) {
        final bloc = context.read<StructureBloc>();
        final types = state.assessmentTypes
            .where((t) => t.name.toLowerCase().contains(_query.toLowerCase()))
            .toList()
          ..sort((a, b) => a.name.compareTo(b.name));

        return AcademicsListScaffold(
          title: 'Assessment Types',
          subtitle: 'Manage the kinds of assessment used in your school.',
          searchHint: 'Search assessment types...',
          onSearchChanged: (v) => setState(() => _query = v),
          fabLabel: 'Add Assessment Type',
          onFabPressed: () =>
              _openForm(context, schoolId: schoolId, bloc: bloc),
          body: types.isEmpty
              ? StructureEmptyHint(
                  _query.isEmpty
                      ? 'No assessment types yet.\nAdd Test, Quiz, Coursework, Exam, or whatever this school uses.'
                      : 'No assessment types match "$_query".',
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                  itemCount: types.length,
                  itemBuilder: (context, index) {
                    final type = types[index];
                    return AcademicsListCard(
                      icon: Icons.fact_check_outlined,
                      color: Colors.green,
                      title: type.name,
                      subtitle: type.description,
                      trailingLabel: type.weightPercentage > 0
                          ? '${type.weightPercentage.toStringAsFixed(0)}%'
                          : null,
                      isActive: type.isActive,
                      onTap: () => _openForm(
                        context,
                        schoolId: schoolId,
                        bloc: bloc,
                        existing: type,
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
    AssessmentTypeDef? existing,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _AssessmentTypeFormScreen(
          schoolId: schoolId,
          existing: existing,
          onSave: (t) => bloc.add(SaveAssessmentTypeRequested(t)),
          onDelete: existing == null
              ? null
              : () => bloc.add(DeleteAssessmentTypeRequested(existing.id)),
        ),
      ),
    );
  }
}

class _AssessmentTypeFormScreen extends StatefulWidget {
  final String schoolId;
  final AssessmentTypeDef? existing;
  final void Function(AssessmentTypeDef) onSave;
  final VoidCallback? onDelete;

  const _AssessmentTypeFormScreen({
    required this.schoolId,
    this.existing,
    required this.onSave,
    this.onDelete,
  });

  @override
  State<_AssessmentTypeFormScreen> createState() =>
      _AssessmentTypeFormScreenState();
}

class _AssessmentTypeFormScreenState
    extends State<_AssessmentTypeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(
    text: widget.existing?.name,
  );
  late final _weightController = TextEditingController(
    text:
        widget.existing?.weightPercentage == null ||
            widget.existing!.weightPercentage == 0
        ? ''
        : widget.existing!.weightPercentage.toString(),
  );
  late final _descController = TextEditingController(
    text: widget.existing?.description,
  );
  late bool _isActive = widget.existing?.isActive ?? true;

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return AcademicsFormScaffold(
      title: isEdit ? 'Edit Assessment Type' : 'Add Assessment Type',
      subtitle: isEdit
          ? 'Update this assessment type.'
          : 'Create a new assessment type for your school.',
      saveLabel: isEdit ? 'Save Changes' : 'Save Assessment Type',
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
                decoration: const InputDecoration(hintText: 'e.g. Midterm'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),
              const _FieldLabel('Default Weight (%)'),
              TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(hintText: 'e.g. 30'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              const SizedBox(height: 16),
              const _FieldLabel('Description'),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  hintText: 'Optional description',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 8),
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
                      title: 'Delete Assessment Type',
                      message: 'Delete "${widget.existing!.name}"?',
                    );
                    if (confirmed == true && mounted) {
                      widget.onDelete!();
                      Navigator.of(context).pop();
                    }
                  },
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  label: const Text(
                    'Delete Assessment Type',
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
    final weight = double.tryParse(_weightController.text) ?? 0;
    if (weight < 0 || weight > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Weight must be between 0 and 100')),
      );
      return;
    }
    widget.onSave(
      AssessmentTypeDef(
        id: widget.existing?.id ?? const Uuid().v4(),
        schoolId: widget.existing?.schoolId ?? widget.schoolId,
        name: _nameController.text.trim(),
        weightPercentage: weight,
        description: _descController.text.trim(),
        isActive: _isActive,
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
