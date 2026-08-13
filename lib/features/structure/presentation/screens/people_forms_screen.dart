import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/admin/presentation/widgets/admin_app_bar.dart';
import 'package:school_pulse/features/structure/domain/entities/structure_entities.dart';
import '../bloc/structure_bloc.dart';
import '../bloc/structure_event.dart';

/// Reference-style full pages for organisation records. These are pages, not
/// dialogs, so a school admin keeps the same mobile navigation rhythm as the
/// rest of Structure.
class DepartmentFormScreen extends StatefulWidget {
  const DepartmentFormScreen({
    super.key,
    required this.schoolId,
    this.existing,
  });
  final String schoolId;
  final Department? existing;
  @override
  State<DepartmentFormScreen> createState() => _DepartmentFormScreenState();
}

class _DepartmentFormScreenState extends State<DepartmentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _code;
  late final TextEditingController _description;
  late bool _active;
  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.existing?.name);
    _code = TextEditingController(text: widget.existing?.code);
    _description = TextEditingController(text: widget.existing?.description);
    _active = widget.existing?.isActive ?? true;
  }

  @override
  void dispose() {
    _name.dispose();
    _code.dispose();
    _description.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final duplicate = context.read<StructureBloc>().state.departments.any(
      (item) =>
          item.id != widget.existing?.id &&
          item.schoolId == widget.schoolId &&
          item.code.trim().toLowerCase() == _code.text.trim().toLowerCase(),
    );
    if (duplicate) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('That department code is already in use.'),
        ),
      );
      return;
    }
    context.read<StructureBloc>().add(
      SaveDepartmentRequested(
        Department(
          id: widget.existing?.id ?? const Uuid().v4(),
          schoolId: widget.schoolId,
          name: _name.text.trim(),
          code: _code.text.trim(),
          description: _description.text.trim(),
          headOfDepartmentStaffId:
              widget.existing?.headOfDepartmentStaffId ?? '',
          isActive: _active,
        ),
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) => _RecordFormShell(
    title: widget.existing == null ? 'Add Department' : 'Edit Department',
    submitLabel: 'Save Department',
    onSubmit: _save,
    formKey: _formKey,
    children: [
      _FormField(
        controller: _name,
        label: 'Department Name',
        hint: 'e.g. Academic Affairs',
        required: true,
      ),
      _FormField(
        controller: _code,
        label: 'Department Code',
        hint: 'e.g. ACD',
        required: true,
      ),
      const _DisabledSelector(
        label: 'Head of Department',
        hint: 'Select staff member',
      ),
      _FormField(
        controller: _description,
        label: 'Description',
        hint: 'Brief description of this department',
        maxLines: 3,
      ),
      const _FormField(
        label: 'Display Order',
        hint: 'e.g. 1',
        enabled: false,
        helper: 'Lower numbers appear first',
      ),
      _ActiveSwitch(
        value: _active,
        onChanged: (value) => setState(() => _active = value),
      ),
    ],
  );
}

class DesignationFormScreen extends StatefulWidget {
  const DesignationFormScreen({
    super.key,
    required this.schoolId,
    this.existing,
  });
  final String schoolId;
  final StaffDesignation? existing;
  @override
  State<DesignationFormScreen> createState() => _DesignationFormScreenState();
}

class _DesignationFormScreenState extends State<DesignationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _description;
  late bool _active;
  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.existing?.name);
    _description = TextEditingController(text: widget.existing?.description);
    _active = widget.existing?.isActive ?? true;
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    context.read<StructureBloc>().add(
      SaveDesignationRequested(
        StaffDesignation(
          id: widget.existing?.id ?? const Uuid().v4(),
          schoolId: widget.schoolId,
          name: _name.text.trim(),
          description: _description.text.trim(),
          isActive: _active,
        ),
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) => _RecordFormShell(
    title: widget.existing == null ? 'Add Staff Role' : 'Edit Staff Role',
    submitLabel: 'Save Role',
    onSubmit: _save,
    formKey: _formKey,
    children: [
      _FormField(
        controller: _name,
        label: 'Role / Designation Name',
        hint: 'e.g. Head of Department',
        required: true,
      ),
      const _FormField(
        label: 'Role Code',
        hint: 'Use your school’s role code',
        enabled: false,
      ),
      const _DisabledSelector(label: 'Category', hint: 'Select category'),
      _FormField(
        controller: _description,
        label: 'Description',
        hint: 'Brief description of this role',
        maxLines: 3,
      ),
      const _FormField(
        label: 'Display Order',
        hint: 'e.g. 1',
        enabled: false,
        helper: 'Lower numbers appear first',
      ),
      _ActiveSwitch(
        value: _active,
        onChanged: (value) => setState(() => _active = value),
      ),
    ],
  );
}

class _RecordFormShell extends StatelessWidget {
  const _RecordFormShell({
    required this.title,
    required this.submitLabel,
    required this.onSubmit,
    required this.formKey,
    required this.children,
  });
  final String title, submitLabel;
  final VoidCallback onSubmit;
  final GlobalKey<FormState> formKey;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AdminAppBar(title: title),
    body: SafeArea(
      child: Column(
        children: [
          Expanded(
            child: Form(
              key: formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                children: children,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: onSubmit,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary(context),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: Text(submitLabel),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _FormField extends StatelessWidget {
  const _FormField({
    this.controller,
    required this.label,
    required this.hint,
    this.required = false,
    this.maxLines = 1,
    this.enabled = true,
    this.helper,
  });
  final TextEditingController? controller;
  final String label, hint;
  final bool required, enabled;
  final int maxLines;
  final String? helper;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 15),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.labelSmall,
            children: [
              TextSpan(text: label),
              if (required)
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
            ],
          ),
        ),
        const SizedBox(height: 7),
        TextFormField(
          controller: controller,
          enabled: enabled,
          maxLines: maxLines,
          validator: required
              ? (value) =>
                    value == null || value.trim().isEmpty ? 'Required' : null
              : null,
          decoration: InputDecoration(
            hintText: hint,
            helperText: helper,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(7)),
          ),
        ),
      ],
    ),
  );
}

class _DisabledSelector extends StatelessWidget {
  const _DisabledSelector({required this.label, required this.hint});
  final String label, hint;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 15),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 7),
        Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: .35),
            ),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  hint,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const Icon(Icons.keyboard_arrow_down),
            ],
          ),
        ),
      ],
    ),
  );
}

class _ActiveSwitch extends StatelessWidget {
  const _ActiveSwitch({required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) => SwitchListTile(
    contentPadding: EdgeInsets.zero,
    title: const Text('Active'),
    value: value,
    onChanged: onChanged,
  );
}
