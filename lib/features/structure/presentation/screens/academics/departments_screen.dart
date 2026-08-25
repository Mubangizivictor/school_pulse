import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/injection_container.dart' as di;
import '../../../domain/entities/structure_entities.dart';
import '../../../domain/services/structure_dependency_service.dart';
import '../../bloc/structure_bloc.dart';
import '../../bloc/structure_event.dart';
import '../../bloc/structure_state.dart';
import '../../widgets/academics_ui_kit.dart';
import '../../widgets/structure_dialogs.dart' show showDeleteConfirmDialog;
import '../../widgets/structure_empty_hint.dart';
import '../../widgets/structure_wizard_banner.dart';

class DepartmentsScreen extends StatefulWidget {
  const DepartmentsScreen({super.key, this.wizardStep, this.wizardTotal});
  final int? wizardStep;
  final int? wizardTotal;

  @override
  State<DepartmentsScreen> createState() => _DepartmentsScreenState();
}

class _DepartmentsScreenState extends State<DepartmentsScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final schoolId =
        (context.watch<AuthBloc>().state as AuthAuthenticated).user.schoolId;
    return BlocBuilder<StructureBloc, StructureState>(
      builder: (context, state) {
        final bloc = context.read<StructureBloc>();
        final departments =
            state.departments
                .where(
                  (d) => d.name.toLowerCase().contains(_query.toLowerCase()),
                )
                .toList()
              ..sort((a, b) => a.name.compareTo(b.name));

        return AcademicsListScaffold(
          title: 'Departments',
          subtitle: 'Manage academic departments.',
          searchHint: 'Search departments...',
          onSearchChanged: (v) => setState(() => _query = v),
          fabLabel: 'Add Department',
          onFabPressed: () =>
              _openForm(context, schoolId: schoolId, bloc: bloc),
          appBarBottom: widget.wizardStep == null || widget.wizardTotal == null
              ? null
              : StructureWizardBanner(
                  stepId: 'departments',
                  stepNumber: widget.wizardStep!,
                  totalSteps: widget.wizardTotal!,
                ),
          body: departments.isEmpty
              ? StructureEmptyHint(
                  _query.isEmpty
                      ? 'No departments defined yet.'
                      : 'No departments match "$_query".',
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                  itemCount: departments.length,
                  itemBuilder: (context, index) {
                    final department = departments[index];
                    final subjectCount = state.subjects
                        .where((s) => s.departmentId == department.id)
                        .length;
                    final parts = [
                      if (department.code.isNotEmpty) department.code,
                      if (department.headOfDepartmentStaffId.isNotEmpty)
                        'Head: ${department.headOfDepartmentStaffId}',
                    ];
                    return AcademicsListCard(
                      icon: Icons.account_balance_outlined,
                      color: Colors.black,
                      title: department.name,
                      subtitle: parts.join(' • '),
                      trailingLabel: subjectCount > 0
                          ? '$subjectCount Subject${subjectCount == 1 ? '' : 's'}'
                          : null,
                      isActive: department.isActive,
                      onTap: () => _openForm(
                        context,
                        schoolId: schoolId,
                        bloc: bloc,
                        existing: department,
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
    Department? existing,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _DepartmentFormScreen(
          schoolId: schoolId,
          existing: existing,
          onSave: (d) => bloc.add(SaveDepartmentRequested(d)),
          onDelete: existing == null
              ? null
              : () async {
                  final dependentCount = await di
                      .sl<StructureDependencyService>()
                      .countStaffInDepartment(schoolId, existing.id);
                  return dependentCount;
                },
          onDeleteConfirmed: existing == null
              ? null
              : (action) {
                  if (action == 'delete') {
                    bloc.add(DeleteDepartmentRequested(existing.id));
                  }
                },
        ),
      ),
    );
  }
}

class _DepartmentFormScreen extends StatefulWidget {
  final String schoolId;
  final Department? existing;
  final void Function(Department) onSave;
  final Future<int> Function()? onDelete;
  final void Function(String action)? onDeleteConfirmed;

  const _DepartmentFormScreen({
    required this.schoolId,
    this.existing,
    required this.onSave,
    this.onDelete,
    this.onDeleteConfirmed,
  });

  @override
  State<_DepartmentFormScreen> createState() => _DepartmentFormScreenState();
}

class _DepartmentFormScreenState extends State<_DepartmentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(
    text: widget.existing?.name,
  );
  late final _codeController = TextEditingController(
    text: widget.existing?.code,
  );
  late final _descController = TextEditingController(
    text: widget.existing?.description,
  );
  late final _headController = TextEditingController(
    text: widget.existing?.headOfDepartmentStaffId,
  );
  late bool _isActive = widget.existing?.isActive ?? true;

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _descController.dispose();
    _headController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return AcademicsFormScaffold(
      title: isEdit ? 'Edit Department' : 'Add Department',
      subtitle: isEdit
          ? 'Update this department.'
          : 'Create a new academic department.',
      saveLabel: isEdit ? 'Save Changes' : 'Save Department',
      onSave: _submit,
      fields: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _FieldLabel('Department Name *'),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(hintText: 'e.g. Sciences'),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Department name is required'
                    : null,
              ),
              const SizedBox(height: 16),
              const _FieldLabel('Department Code *'),
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(hintText: 'e.g. SCI'),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Department code is required'
                    : null,
              ),
              const SizedBox(height: 16),
              const _FieldLabel('Head of Department'),
              TextFormField(
                controller: _headController,
                decoration: const InputDecoration(
                  hintText: 'Staff name (optional)',
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
                  onPressed: _confirmDelete,
                  icon: const Icon(Icons.delete_outline, color: Colors.black),
                  label: const Text(
                    'Delete Department',
                    style: TextStyle(color: Colors.black),
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
      Department(
        id: widget.existing?.id ?? const Uuid().v4(),
        schoolId: widget.existing?.schoolId ?? widget.schoolId,
        name: _nameController.text.trim(),
        code: _codeController.text.trim(),
        description: _descController.text.trim(),
        headOfDepartmentStaffId: _headController.text.trim(),
        isActive: _isActive,
      ),
    );
    Navigator.of(context).pop();
  }

  Future<void> _confirmDelete() async {
    final dependentCount = await widget.onDelete!();
    if (!mounted) return;
    final itemName = widget.existing!.name;
    final confirmed = await showDeleteConfirmDialog(
      context,
      title: 'Delete Department',
      message: dependentCount > 0
          ? '"$itemName" has $dependentCount staff member(s) assigned. Delete anyway?'
          : 'Delete "$itemName"?',
    );
    if (confirmed != true || !mounted) return;
    widget.onDeleteConfirmed!('delete');
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
