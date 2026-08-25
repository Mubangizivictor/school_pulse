import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:school_pulse/core/permissions/permission.dart';
import 'package:school_pulse/core/usecases/usecase.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/admin/data/models/audit_log.dart';
import 'package:school_pulse/features/admin/data/repositories/audit_repository.dart';
import 'package:school_pulse/features/admin/presentation/widgets/admin_app_bar.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/domain/usecases/get_staff_members.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/structure/domain/entities/structure_entities.dart';
import 'package:school_pulse/features/structure/domain/services/structure_dependency_service.dart';
import 'package:school_pulse/features/teacher/domain/entities/staff_role_assignment.dart';
import 'package:school_pulse/injection_container.dart' as di;
import '../bloc/role_assignment_cubit.dart';
import '../bloc/role_assignment_state.dart';
import '../bloc/structure_bloc.dart';
import '../bloc/structure_event.dart';
import '../bloc/structure_state.dart';
import '../widgets/structure_dialogs.dart'
    show showDeleteConfirmDialog, kSubjectColorSwatches;
import '../widgets/structure_ui_kit.dart';
import 'assign_staff_role_screen.dart';

/// Curated icon set for staff designations - a fixed catalog (rather than a
/// free icon-font picker) keeps `iconName` values stable and renderable
/// across every screen that displays a designation.
const Map<String, IconData> kStaffDesignationIcons = {
  'badge_outlined': Icons.badge_outlined,
  'person_outline_rounded': Icons.person_outline_rounded,
  'school_outlined': Icons.school_outlined,
  'admin_panel_settings_outlined': Icons.admin_panel_settings_outlined,
  'shield_outlined': Icons.shield_outlined,
  'menu_book_outlined': Icons.menu_book_outlined,
  'account_balance_outlined': Icons.account_balance_outlined,
  'local_hospital_outlined': Icons.local_hospital_outlined,
  'directions_bus_outlined': Icons.directions_bus_outlined,
  'restaurant_outlined': Icons.restaurant_outlined,
  'security_outlined': Icons.security_outlined,
  'engineering_outlined': Icons.engineering_outlined,
  'sports_outlined': Icons.sports_outlined,
  'groups_outlined': Icons.groups_outlined,
  'inventory_2_outlined': Icons.inventory_2_outlined,
};

IconData staffDesignationIcon(String name) =>
    kStaffDesignationIcons[name] ?? Icons.badge_outlined;

Color staffDesignationColor(String hex) {
  if (hex.isEmpty) return kSubjectColorSwatches.first;
  try {
    return Color(int.parse(hex.replaceFirst('#', '0xff')));
  } catch (_) {
    return kSubjectColorSwatches.first;
  }
}

const List<String> kStaffDesignationCategorySuggestions = [
  'Leadership',
  'Administration',
  'Academic',
  'Finance',
  'Student Welfare',
  'Boarding',
  'Operations',
  'Support Staff',
  'Health',
  'Security',
  'Transport',
  'Library',
  'Stores / Procurement',
  'Catering',
  'Religious Life',
  'Sports & Activities',
  'Admissions',
  'ICT',
  'Custom / Other',
];

const List<String> kStaffRoleScopeTypes = [
  'wholeSchool',
  'level',
  'class',
  'stream',
  'department',
  'subject',
  'dormitory',
  'house',
  'club',
  'sport',
  'route',
  'vehicle',
  'gate',
  'libraryBranch',
  'store',
  'custom',
];

const List<String> kStaffRoleNatures = [
  'Standard',
  'Leadership',
  'Academic Responsibility',
  'Operational',
  'Support',
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
  Widget build(
    BuildContext context,
  ) => BlocBuilder<StructureBloc, StructureState>(
    builder: (context, state) {
      final current = state.departments.firstWhere(
        (d) => d.id == department.id,
        orElse: () => department,
      );
      return _RecordDetailsShell(
        title: current.name,
        icon: Icons.account_balance_outlined,
        color: Colors.black,
        isActive: current.isActive,
        onEdit: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: context.read<StructureBloc>(),
              child: DepartmentFormScreen(
                schoolId: schoolId,
                existing: current,
              ),
            ),
          ),
        ),
        onToggleActive: () => context.read<StructureBloc>().add(
          SaveDepartmentRequested(
            current.copyWith(isActive: !current.isActive),
          ),
        ),
        onDelete: () async {
          final confirmed = await showDeleteConfirmDialog(
            context,
            title: 'Delete Department',
            message: 'Delete "${current.name}"? This cannot be undone.',
          );
          if (confirmed == true && context.mounted) {
            context.read<StructureBloc>().add(
              DeleteDepartmentRequested(current.id),
            );
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
          _StaffCountRow(
            label: 'Staff',
            filterId: current.id,
            byDepartment: true,
          ),
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
  late bool _requiresScope;
  late bool _multipleStaff;
  late bool _concurrentRoles;
  late bool _temporaryAssignments;
  late String _scopeType;
  late String _nature;
  late String _iconName;
  late Color _color;
  late Set<String> _permissions;

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
    _requiresScope = widget.existing?.requiresScope ?? false;
    _multipleStaff = widget.existing?.allowMultipleStaff ?? true;
    _concurrentRoles = widget.existing?.allowConcurrentAssignments ?? true;
    _temporaryAssignments = widget.existing?.allowTemporaryAssignments ?? true;
    _scopeType = widget.existing?.scopeType ?? 'wholeSchool';
    _nature = widget.existing?.roleNature ?? 'Standard';
    _iconName = widget.existing?.iconName ?? 'badge_outlined';
    _color = staffDesignationColor(widget.existing?.colorHex ?? '');
    _permissions = {...?widget.existing?.permissions};
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
    final code = _code.text.trim();
    final duplicate = context.read<StructureBloc>().state.designations.any(
      (role) =>
          role.id != widget.existing?.id &&
          role.code.trim().toLowerCase() == code.toLowerCase(),
    );
    if (duplicate) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Role code must be unique for this school.'),
        ),
      );
      return;
    }
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
          scopeType: _scopeType,
          roleNature: _nature,
          requiresScope: _requiresScope,
          allowMultipleStaff: _multipleStaff,
          allowConcurrentAssignments: _concurrentRoles,
          allowTemporaryAssignments: _temporaryAssignments,
          isSystemPreset: widget.existing?.isSystemPreset ?? false,
          isArchived: widget.existing?.isArchived ?? false,
          iconName: _iconName,
          colorHex: '#${_color.toARGB32().toRadixString(16).substring(2)}',
          permissions: _permissions,
        ),
      ),
    );
    Navigator.of(context).pop();
  }

  Future<void> _pickPermissions() async {
    var selected = {..._permissions};
    final grouped = <String, List<String>>{};
    for (final (category, id) in Permission.all) {
      grouped.putIfAbsent(category, () => []).add(id);
    }
    final categories = grouped.keys.toList()..sort();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (c) => StatefulBuilder(
        builder: (c, set) => SafeArea(
          child: SizedBox(
            height: MediaQuery.of(c).size.height * .8,
            child: Column(
              children: [
                const ListTile(title: Text('Select permissions')),
                Expanded(
                  child: ListView(
                    children: categories.expand((category) {
                      final ids = grouped[category]!;
                      return [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                          child: Text(
                            category.toUpperCase(),
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              color: AppColors.textMuted(c),
                              letterSpacing: .6,
                            ),
                          ),
                        ),
                        ...ids.map(
                          (id) => CheckboxListTile(
                            dense: true,
                            title: Text(id),
                            value: selected.contains(id),
                            onChanged: (v) => set(
                              () => v! ? selected.add(id) : selected.remove(id),
                            ),
                          ),
                        ),
                      ];
                    }).toList(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: FilledButton(
                    onPressed: () => Navigator.pop(c),
                    child: Text('Apply (${selected.length} selected)'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    setState(() => _permissions = selected);
  }

  @override
  Widget build(BuildContext context) => _RecordFormShell(
    title: widget.existing == null ? 'Add Staff Role' : 'Edit Staff Role',
    submitLabel: 'Save Role',
    onSubmit: _save,
    formKey: _formKey,
    children: [
      const _RoleFormSection('Basic information'),
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
      const _RoleFormSection('Role behavior'),
      DropdownButtonFormField<String>(
        initialValue: _scopeType,
        decoration: const InputDecoration(labelText: 'Scope type *'),
        items: kStaffRoleScopeTypes
            .map(
              (value) => DropdownMenuItem(
                value: value,
                child: Text(_scopeLabel(value)),
              ),
            )
            .toList(),
        onChanged: (value) => setState(() => _scopeType = value!),
      ),
      const SizedBox(height: 16),
      DropdownButtonFormField<String>(
        initialValue: _nature,
        decoration: const InputDecoration(labelText: 'Role nature *'),
        items: kStaffRoleNatures
            .map((value) => DropdownMenuItem(value: value, child: Text(value)))
            .toList(),
        onChanged: (value) => setState(() => _nature = value!),
      ),
      const SizedBox(height: 8),
      SwitchListTile.adaptive(
        contentPadding: EdgeInsets.zero,
        title: const Text('Requires scope'),
        subtitle: const Text(
          'Request a defined responsibility area when assigned.',
        ),
        value: _requiresScope,
        onChanged: (value) => setState(() => _requiresScope = value),
      ),
      const _RoleFormSection('Assignment rules'),
      SwitchListTile.adaptive(
        contentPadding: EdgeInsets.zero,
        title: const Text('Can be assigned to multiple staff'),
        value: _multipleStaff,
        onChanged: (value) => setState(() => _multipleStaff = value),
      ),
      SwitchListTile.adaptive(
        contentPadding: EdgeInsets.zero,
        title: const Text('Allow other active roles'),
        subtitle: const Text(
          'This responsibility will not replace a staff member’s existing roles.',
        ),
        value: _concurrentRoles,
        onChanged: (value) => setState(() => _concurrentRoles = value),
      ),
      SwitchListTile.adaptive(
        contentPadding: EdgeInsets.zero,
        title: const Text('Allow temporary assignment'),
        value: _temporaryAssignments,
        onChanged: (value) => setState(() => _temporaryAssignments = value),
      ),
      const _RoleFormSection('Display & status'),
      _FormField(
        controller: _order,
        label: 'Display Order',
        hint: 'e.g. 1',
        helper: 'Lower numbers appear first',
        keyboardType: TextInputType.number,
      ),
      const Padding(padding: EdgeInsets.only(bottom: 6), child: Text('Icon')),
      Wrap(
        spacing: 12,
        runSpacing: 12,
        children: kStaffDesignationIcons.entries.map((entry) {
          final selected = entry.key == _iconName;
          return InkWell(
            onTap: () => setState(() => _iconName = entry.key),
            borderRadius: BorderRadius.circular(24),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: selected ? _color : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? _color : Colors.black,
                  width: selected ? 2 : 1,
                ),
              ),
              child: Icon(entry.value, color: selected ? _color : null),
            ),
          );
        }).toList(),
      ),
      const SizedBox(height: 16),
      const Padding(padding: EdgeInsets.only(bottom: 6), child: Text('Color')),
      Wrap(
        spacing: 12,
        children: kSubjectColorSwatches.map((swatch) {
          final selected = swatch.toARGB32() == _color.toARGB32();
          return InkWell(
            onTap: () => setState(() => _color = swatch),
            borderRadius: BorderRadius.circular(18),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: swatch,
                shape: BoxShape.circle,
                border: selected
                    ? Border.all(color: Colors.black, width: 3)
                    : null,
              ),
              child: selected
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
          );
        }).toList(),
      ),
      _ActiveSwitch(
        value: _active,
        onChanged: (value) => setState(() => _active = value),
      ),
      const _RoleFormSection('Permissions'),
      ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          _permissions.isEmpty
              ? 'No permissions granted'
              : '${_permissions.length} permission${_permissions.length == 1 ? '' : 's'} granted',
        ),
        subtitle: const Text(
          'Staff assigned this role gain these permissions through '
          'EffectiveAccessResolver.',
        ),
        trailing: OutlinedButton.icon(
          onPressed: _pickPermissions,
          icon: const Icon(Icons.tune),
          label: const Text('Select'),
        ),
      ),
    ],
  );
}

class _RoleFormSection extends StatelessWidget {
  const _RoleFormSection(this.title);
  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 12, bottom: 8),
    child: Text(
      title.toUpperCase(),
      style: TextStyle(
        color: AppColors.primary(context),
        fontWeight: FontWeight.w700,
        fontSize: 12,
        letterSpacing: .6,
      ),
    ),
  );
}

String _scopeLabel(String value) => value
    .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(1)}')
    .replaceFirstMapped(
      RegExp(r'^.'),
      (match) => match.group(0)!.toUpperCase(),
    );

class _RoleRulesRow extends StatelessWidget {
  const _RoleRulesRow(this.role);
  final StaffDesignation role;

  @override
  Widget build(BuildContext context) {
    final rules = [
      if (role.requiresScope) 'Scope required',
      if (role.allowMultipleStaff) 'Multiple staff',
      if (role.allowConcurrentAssignments) 'Multi-role staff',
      if (role.allowTemporaryAssignments) 'Temporary allowed',
    ];
    return _DetailRow(
      'Assignment rules',
      rules.isEmpty ? 'No special rules' : rules.join(' • '),
    );
  }
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
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          di.sl<RoleAssignmentCubit>()..loadForRole(schoolId, designation.id),
      child: BlocBuilder<StructureBloc, StructureState>(
        builder: (context, state) {
          final current = state.designations.firstWhere(
            (d) => d.id == designation.id,
            orElse: () => designation,
          );
          return _RecordDetailsShell(
            title: current.name,
            icon: staffDesignationIcon(current.iconName),
            color: staffDesignationColor(current.colorHex),
            isActive: current.isActive,
            onEdit: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<StructureBloc>(),
                  child: DesignationFormScreen(
                    schoolId: schoolId,
                    existing: current,
                  ),
                ),
              ),
            ),
            onToggleActive: () => context.read<StructureBloc>().add(
              SaveDesignationRequested(
                current.copyWith(isActive: !current.isActive),
              ),
            ),
            onDelete: () async {
              if (current.isArchived) {
                context.read<StructureBloc>().add(
                  RestoreDesignationRequested(current.id),
                );
                return;
              }
              final activeAssignments = await di
                  .sl<StructureDependencyService>()
                  .countAssignmentsForDesignation(schoolId, current.id);
              if (!context.mounted) return;
              final confirmed = await showDeleteConfirmDialog(
                context,
                title: 'Archive Staff Role',
                message:
                    'Archive "${current.name}"? Existing assignment history is retained and no new assignments can be made.',
                impactMessage: activeAssignments > 0
                    ? '$activeAssignments active assignment${activeAssignments == 1 ? '' : 's'} reference this role.'
                    : null,
              );
              if (confirmed == true && context.mounted) {
                context.read<StructureBloc>().add(
                  ArchiveDesignationRequested(current.id),
                );
                Navigator.of(context).pop();
              }
            },
            deleteLabel: current.isArchived ? 'Restore' : 'Archive',
            rows: [
              if (current.isArchived)
                const _DetailRow('Status', 'Archived — read only history'),
              _DetailRow(
                'Code',
                current.code.isEmpty ? 'Not set' : current.code,
              ),
              _DetailRow(
                'Category',
                current.category.isEmpty ? 'Not set' : current.category,
              ),
              _DetailRow('Scope model', _scopeLabel(current.scopeType)),
              _DetailRow('Role nature', current.roleNature),
              _RoleRulesRow(current),
              _DetailRow(
                'Description',
                current.description.isEmpty ? 'Not set' : current.description,
              ),
              _DetailRow(
                'Permissions',
                current.permissions.isEmpty
                    ? 'No permissions granted — role label does not grant access on its own.'
                    : current.permissions.join(', '),
              ),
              _StaffCountRow(
                label: 'Assigned Staff',
                filterId: current.id,
                byDepartment: false,
              ),
            ],
            footer: _RoleAssignmentsSection(role: current),
            floatingActionButton: current.isActive && !current.isArchived
                ? FloatingActionButton.extended(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => MultiBlocProvider(
                          providers: [
                            BlocProvider.value(
                              value: context.read<RoleAssignmentCubit>(),
                            ),
                            BlocProvider.value(
                              value: context.read<StructureBloc>(),
                            ),
                          ],
                          child: AssignStaffRoleScreen(
                            preselectedRole: current,
                          ),
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.person_add_alt_1_outlined),
                    label: const Text('Assign to Staff'),
                    backgroundColor: AppColors.primary(context),
                    foregroundColor: Colors.white,
                  )
                : null,
          );
        },
      ),
    );
  }
}

/// Assignments tab-equivalent content: every staff member currently holding
/// this role, plus its audit history. Rendered as a footer section on the
/// details page rather than a separate tabbed screen, since the existing
/// Structure details shell is single-scroll for every other entity type.
class _RoleAssignmentsSection extends StatelessWidget {
  const _RoleAssignmentsSection({required this.role});
  final StaffDesignation role;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ASSIGNMENTS',
          style: TextStyle(
            color: AppColors.primary(context),
            fontWeight: FontWeight.w700,
            fontSize: 12,
            letterSpacing: .6,
          ),
        ),
        const SizedBox(height: 8),
        BlocBuilder<RoleAssignmentCubit, RoleAssignmentState>(
          builder: (context, state) {
            if (state is RoleAssignmentLoading ||
                state is RoleAssignmentInitial) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: LinearProgressIndicator(),
              );
            }
            if (state is RoleAssignmentError) {
              return Text(
                'Could not load assignments: ${state.message}',
                style: Theme.of(context).textTheme.labelSmall,
              );
            }
            final assignments = (state as RoleAssignmentLoaded).assignments;
            if (assignments.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('No staff currently hold this role.'),
              );
            }
            return Column(
              children: assignments
                  .map(
                    (a) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _AssignmentRow(assignment: a, role: role),
                    ),
                  )
                  .toList(),
            );
          },
        ),
        const SizedBox(height: 22),
        Text(
          'HISTORY',
          style: TextStyle(
            color: AppColors.primary(context),
            fontWeight: FontWeight.w700,
            fontSize: 12,
            letterSpacing: .6,
          ),
        ),
        const SizedBox(height: 8),
        StreamBuilder<List<AuditLog>>(
          stream: di.sl<AuditRepository>().watchLogsForEntity(
            schoolId: role.schoolId,
            relatedEntityId: role.id,
          ),
          builder: (context, snapshot) {
            final logs = snapshot.data ?? const [];
            if (logs.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('No history recorded yet.'),
              );
            }
            return Column(
              children: logs
                  .map(
                    (log) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      leading: Icon(
                        staffDesignationIcon(log.iconName),
                        color: staffDesignationColor(log.colorHex),
                        size: 20,
                      ),
                      title: Text(log.title),
                      subtitle: Text(log.description),
                      trailing: Text(
                        '${log.timestamp.day}/${log.timestamp.month}/${log.timestamp.year}',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

class _AssignmentRow extends StatelessWidget {
  const _AssignmentRow({required this.assignment, required this.role});
  final StaffRoleAssignment assignment;
  final StaffDesignation role;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<UserEntity>>(
      future: di.sl<GetStaffMembers>()(NoParams()).then(
        (r) => r.getOrElse(() => const []),
      ),
      builder: (context, snapshot) {
        final staff = snapshot.data ?? const [];
        final match = staff
            .where((s) => s.id == assignment.staffId)
            .firstOrNull;
        final scope = assignment.scopeSummaryLabel;
        return AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              AvatarInitials(name: match?.name ?? 'Staff member', size: 32),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      match?.name ?? assignment.staffId,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      [
                        if (scope.isNotEmpty) scope,
                        assignment.status.name,
                      ].join(' • '),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
              if (assignment.status == AssignmentStatus.active)
                TextButton(
                  onPressed: () {
                    final authState = context.read<AuthBloc>().state;
                    if (authState is AuthAuthenticated) {
                      context.read<RoleAssignmentCubit>().endAssignment(
                        assignment: assignment,
                        role: role,
                        actor: authState.user,
                      );
                    }
                  },
                  child: const Text('End'),
                )
              else if (assignment.status == AssignmentStatus.suspended)
                TextButton(
                  onPressed: () {
                    final authState = context.read<AuthBloc>().state;
                    if (authState is AuthAuthenticated) {
                      context.read<RoleAssignmentCubit>().reactivateAssignment(
                        assignment: assignment,
                        role: role,
                        actor: authState.user,
                      );
                    }
                  },
                  child: const Text('Reactivate'),
                ),
            ],
          ),
        );
      },
    );
  }
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
    this.deleteLabel = 'Delete',
    this.footer,
    this.floatingActionButton,
  });
  final String title;
  final IconData icon;
  final Color color;
  final bool isActive;
  final VoidCallback onEdit;
  final VoidCallback onToggleActive;
  final VoidCallback onDelete;
  final List<Widget> rows;
  final String deleteLabel;

  /// Extra content appended below the rows card (e.g. an Assignments list).
  final Widget? footer;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Details'),
        actions: [
          IconButton(icon: const Icon(Icons.edit_outlined), onPressed: onEdit),
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
              PopupMenuItem(
                value: 'delete',
                child: Text(
                  deleteLabel,
                  style: const TextStyle(color: Colors.black),
                ),
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
                  color: color,
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
              border: Border.all(color: colors.outline),
            ),
            child: Column(children: rows),
          ),
          if (footer != null) ...[const SizedBox(height: 22), footer!],
        ],
      ),
      floatingActionButton: floatingActionButton,
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
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
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
        : (widget.staffId.isEmpty
              ? 'Not assigned'
              : (_name ?? 'Unknown staff')),
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
    this.helper,
    this.keyboardType,
  });
  final TextEditingController? controller;
  final String label, hint;
  final bool required;
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
            border: Border.all(color: Theme.of(context).colorScheme.outline),
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
