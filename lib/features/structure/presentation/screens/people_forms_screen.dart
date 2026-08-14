import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:school_pulse/core/usecases/usecase.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/admin/presentation/widgets/admin_app_bar.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/domain/usecases/get_staff_members.dart';
import 'package:school_pulse/features/structure/domain/entities/structure_entities.dart';
import 'package:school_pulse/injection_container.dart' as di;
import '../bloc/structure_bloc.dart';
import '../bloc/structure_event.dart';
import '../bloc/structure_state.dart';
import '../widgets/structure_dialogs.dart' show showDeleteConfirmDialog;
import '../widgets/structure_ui_kit.dart';

const List<String> kStaffDesignationCategorySuggestions = [
  'Leadership',
  'Administration',
  'Academic',
  'Finance',
  'Student Welfare',
  'Boarding',
  'Operations',
  'Support Staff',
  'Other',
];

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
  late final TextEditingController _order;
  late bool _active;
  String? _headOfDepartmentStaffId;
  List<UserEntity> _staff = const [];
  bool _loadingStaff = true;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.existing?.name);
    _code = TextEditingController(text: widget.existing?.code);
    _description = TextEditingController(text: widget.existing?.description);
    _order = TextEditingController(
      text: widget.existing == null
          ? ''
          : widget.existing!.displayOrder.toString(),
    );
    _active = widget.existing?.isActive ?? true;
    _headOfDepartmentStaffId = widget.existing?.headOfDepartmentStaffId;
    if (_headOfDepartmentStaffId?.isEmpty == true) {
      _headOfDepartmentStaffId = null;
    }
    _loadStaff();
  }

  Future<void> _loadStaff() async {
    final result = await di.sl<GetStaffMembers>()(NoParams());
    if (!mounted) return;
    setState(() {
      _staff = result.getOrElse(() => const []);
      _loadingStaff = false;
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _code.dispose();
    _description.dispose();
    _order.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final duplicate = structureDuplicateCode<Department>(
      items: context.read<StructureBloc>().state.departments,
      codeOf: (d) => d.code,
      idOf: (d) => d.id,
      code: _code.text,
      excludeId: widget.existing?.id,
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
          headOfDepartmentStaffId: _headOfDepartmentStaffId ?? '',
          displayOrder: int.tryParse(_order.text.trim()) ?? 0,
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
      _loadingStaff
          ? const _LoadingSelector(label: 'Head of Department')
          : StructureStaffPickerField(
              label: 'Head of Department',
              selectedStaffId: _headOfDepartmentStaffId,
              staff: _staff,
              onChanged: (id) => setState(() => _headOfDepartmentStaffId = id),
            ),
      _FormField(
        controller: _description,
        label: 'Description',
        hint: 'Brief description of this department',
        maxLines: 3,
      ),
      _FormField(
        controller: _order,
        label: 'Display Order',
        hint: 'e.g. 1',
        helper: 'Lower numbers appear first',
        keyboardType: TextInputType.number,
      ),
      _ActiveSwitch(
        value: _active,
        onChanged: (value) => setState(() => _active = value),
      ),
    ],
  );
}

class DepartmentDetailsScreen extends StatelessWidget {
  const DepartmentDetailsScreen({
    super.key,
    required this.schoolId,
    required this.department,
  });
  final String schoolId;
  final Department department;

  @override
  Widget build(BuildContext context) => BlocBuilder<StructureBloc, StructureState>(
    builder: (context, state) {
      final current = state.departments.firstWhere(
        (d) => d.id == department.id,
        orElse: () => department,
      );
      return _RecordDetailsShell(
        title: current.name,
        icon: Icons.account_balance_outlined,
        color: Colors.blue,
        isActive: current.isActive,
        onEdit: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: context.read<StructureBloc>(),
              child: DepartmentFormScreen(schoolId: schoolId, existing: current),
            ),
          ),
        ),
        onToggleActive: () => context.read<StructureBloc>().add(
          SaveDepartmentRequested(current.copyWith(isActive: !current.isActive)),
        ),
        onDelete: () async {
          final confirmed = await showDeleteConfirmDialog(
            context,
            title: 'Delete Department',
            message: 'Delete "${current.name}"? This cannot be undone.',
          );
          if (confirmed == true && context.mounted) {
            context.read<StructureBloc>().add(DeleteDepartmentRequested(current.id));
            Navigator.of(context).pop();
          }
        },
        rows: [
          _DetailRow('Code', current.code.isEmpty ? 'Not set' : current.code),
          _StaffNameRow(
            label: 'Head of Department',
            staffId: current.headOfDepartmentStaffId,
          ),
          _DetailRow(
            'Description',
            current.description.isEmpty ? 'Not set' : current.description,
          ),
          _StaffCountRow(label: 'Staff', filterId: current.id, byDepartment: true),
          _DetailRow(
            'Subjects',
            '${state.subjects.where((s) => s.departmentId == current.id).length} connected',
          ),
        ],
      );
    },
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
  late final TextEditingController _code;
  late final TextEditingController _category;
  late final TextEditingController _description;
  late final TextEditingController _order;
  late bool _active;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.existing?.name);
    _code = TextEditingController(text: widget.existing?.code);
    _category = TextEditingController(text: widget.existing?.category);
    _description = TextEditingController(text: widget.existing?.description);
    _order = TextEditingController(
      text: widget.existing == null
          ? ''
          : widget.existing!.displayOrder.toString(),
    );
    _active = widget.existing?.isActive ?? true;
  }

  @override
  void dispose() {
    _name.dispose();
    _code.dispose();
    _category.dispose();
    _description.dispose();
    _order.dispose();
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
          code: _code.text.trim(),
          category: _category.text.trim(),
          description: _description.text.trim(),
          displayOrder: int.tryParse(_order.text.trim()) ?? 0,
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
      _FormField(
        controller: _code,
        label: 'Role Code',
        hint: 'e.g. HOD',
        required: true,
      ),
      _SuggestField(
        controller: _category,
        label: 'Category',
        hint: 'Select or type a category',
        suggestions: kStaffDesignationCategorySuggestions,
        required: true,
      ),
      _FormField(
        controller: _description,
        label: 'Description',
        hint: 'Brief description of this role',
        maxLines: 3,
      ),
      _FormField(
        controller: _order,
        label: 'Display Order',
        hint: 'e.g. 1',
        helper: 'Lower numbers appear first',
        keyboardType: TextInputType.number,
      ),
      _ActiveSwitch(
        value: _active,
        onChanged: (value) => setState(() => _active = value),
      ),
    ],
  );
}

class DesignationDetailsScreen extends StatelessWidget {
  const DesignationDetailsScreen({
    super.key,
    required this.schoolId,
    required this.designation,
  });
  final String schoolId;
  final StaffDesignation designation;

  @override
  Widget build(BuildContext context) => BlocBuilder<StructureBloc, StructureState>(
    builder: (context, state) {
      final current = state.designations.firstWhere(
        (d) => d.id == designation.id,
        orElse: () => designation,
      );
      return _RecordDetailsShell(
        title: current.name,
        icon: Icons.person_outline_rounded,
        color: Colors.deepPurple,
        isActive: current.isActive,
        onEdit: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: context.read<StructureBloc>(),
              child: DesignationFormScreen(schoolId: schoolId, existing: current),
            ),
          ),
        ),
        onToggleActive: () => context.read<StructureBloc>().add(
          SaveDesignationRequested(current.copyWith(isActive: !current.isActive)),
        ),
        onDelete: () async {
          final confirmed = await showDeleteConfirmDialog(
            context,
            title: 'Delete Staff Role',
            message: 'Delete "${current.name}"? This cannot be undone.',
          );
          if (confirmed == true && context.mounted) {
            context.read<StructureBloc>().add(DeleteDesignationRequested(current.id));
            Navigator.of(context).pop();
          }
        },
        rows: [
          _DetailRow('Code', current.code.isEmpty ? 'Not set' : current.code),
          _DetailRow('Category', current.category.isEmpty ? 'Not set' : current.category),
          _DetailRow(
            'Description',
            current.description.isEmpty ? 'Not set' : current.description,
          ),
          _StaffCountRow(label: 'Assigned Staff', filterId: current.id, byDepartment: false),
        ],
      );
    },
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

/// Shared details-page shell for a Structure record: header card, a list of
/// label/value rows, and Edit / Activate-Deactivate / Delete actions.
class _RecordDetailsShell extends StatelessWidget {
  const _RecordDetailsShell({
    required this.title,
    required this.icon,
    required this.color,
    required this.isActive,
    required this.onEdit,
    required this.onToggleActive,
    required this.onDelete,
    required this.rows,
  });
  final String title;
  final IconData icon;
  final Color color;
  final bool isActive;
  final VoidCallback onEdit;
  final VoidCallback onToggleActive;
  final VoidCallback onDelete;
  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: onEdit,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'toggle') onToggleActive();
              if (value == 'delete') onDelete();
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'toggle',
                child: Text(isActive ? 'Deactivate' : 'Activate'),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    StructureStatusBadge(
                      label: isActive ? 'Active' : 'Inactive',
                      isActive: isActive,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.outline.withValues(alpha: .18)),
            ),
            child: Column(children: rows),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.label, this.value);
  final String label, value;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 130,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
      const Divider(height: 1),
    ],
  );
}

class _StaffNameRow extends StatefulWidget {
  const _StaffNameRow({required this.label, required this.staffId});
  final String label;
  final String staffId;
  @override
  State<_StaffNameRow> createState() => _StaffNameRowState();
}

class _StaffNameRowState extends State<_StaffNameRow> {
  String? _name;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  Future<void> _resolve() async {
    if (widget.staffId.isEmpty) {
      setState(() => _loaded = true);
      return;
    }
    final result = await di.sl<GetStaffMembers>()(NoParams());
    if (!mounted) return;
    final staff = result.getOrElse(() => const []);
    UserEntity? match;
    for (final member in staff) {
      if (member.id == widget.staffId) {
        match = member;
        break;
      }
    }
    setState(() {
      _name = match?.name;
      _loaded = true;
    });
  }

  @override
  Widget build(BuildContext context) => _DetailRow(
    widget.label,
    !_loaded
        ? '...'
        : (widget.staffId.isEmpty ? 'Not assigned' : (_name ?? 'Unknown staff')),
  );
}

class _StaffCountRow extends StatefulWidget {
  const _StaffCountRow({
    required this.label,
    required this.filterId,
    required this.byDepartment,
  });
  final String label;
  final String filterId;
  final bool byDepartment;
  @override
  State<_StaffCountRow> createState() => _StaffCountRowState();
}

class _StaffCountRowState extends State<_StaffCountRow> {
  int? _count;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  Future<void> _resolve() async {
    final result = await di.sl<GetStaffMembers>()(NoParams());
    if (!mounted) return;
    final staff = result.getOrElse(() => const []);
    final count = staff
        .where(
          (s) => widget.byDepartment
              ? s.departmentId == widget.filterId
              : s.designationId == widget.filterId,
        )
        .length;
    setState(() => _count = count);
  }

  @override
  Widget build(BuildContext context) =>
      _DetailRow(widget.label, _count == null ? '...' : '$_count');
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
    this.keyboardType,
  });
  final TextEditingController? controller;
  final String label, hint;
  final bool required;
  final bool enabled;
  final int maxLines;
  final String? helper;
  final TextInputType? keyboardType;
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
          keyboardType: keyboardType,
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

/// A text field with tappable suggestion chips - lets an admin pick a
/// common value quickly while still allowing any free-text entry, so
/// Category stays school-configurable rather than a locked enum.
class _SuggestField extends StatelessWidget {
  const _SuggestField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.suggestions,
    this.required = false,
  });
  final TextEditingController controller;
  final String label, hint;
  final List<String> suggestions;
  final bool required;

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
          validator: required
              ? (value) =>
                    value == null || value.trim().isEmpty ? 'Required' : null
              : null,
          decoration: InputDecoration(
            hintText: hint,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(7)),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: suggestions
              .map(
                (s) => ActionChip(
                  label: Text(s, style: const TextStyle(fontSize: 12)),
                  onPressed: () => controller.text = s,
                ),
              )
              .toList(),
        ),
      ],
    ),
  );
}

class _LoadingSelector extends StatelessWidget {
  const _LoadingSelector({required this.label});
  final String label;
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
              color: Theme.of(context).colorScheme.outline.withValues(alpha: .35),
            ),
            borderRadius: BorderRadius.circular(7),
          ),
          alignment: Alignment.centerLeft,
          child: const SizedBox(
            height: 16,
            width: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
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
