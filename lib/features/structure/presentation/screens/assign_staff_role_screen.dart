import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/core/usecases/usecase.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/admin/presentation/widgets/admin_app_bar.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/domain/usecases/get_staff_members.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/structure/domain/entities/structure_entities.dart';
import 'package:school_pulse/features/structure/presentation/bloc/role_assignment_cubit.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_bloc.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_state.dart';
import 'package:school_pulse/features/structure/presentation/widgets/structure_ui_kit.dart';
import 'package:school_pulse/features/teacher/domain/entities/staff_role_assignment.dart';
import 'package:school_pulse/injection_container.dart' as di;

/// Assigns one [StaffDesignation] to one staff member with an effective
/// date range and a scope chosen dynamically off the role's `scopeType`.
///
/// Does not replace any of the staff member's other assignments - a second
/// call for a different role is a second, independent
/// [StaffRoleAssignment] row (see the entity's own doc comment on why one
/// staff profile can hold many of these at once).
class AssignStaffRoleScreen extends StatefulWidget {
  const AssignStaffRoleScreen({
    super.key,
    this.preselectedStaff,
    this.preselectedRole,
  });

  /// Pre-fills the staff picker when reached from a staff profile's
  /// "+ Assign Role" button.
  final UserEntity? preselectedStaff;

  /// Pre-fills the role picker when reached from a Role Details screen's
  /// "Assign" action.
  final StaffDesignation? preselectedRole;

  @override
  State<AssignStaffRoleScreen> createState() => _AssignStaffRoleScreenState();
}

class _AssignStaffRoleScreenState extends State<AssignStaffRoleScreen> {
  final _formKey = GlobalKey<FormState>();

  UserEntity? _staff;
  StaffDesignation? _role;
  DateTime _effectiveDate = DateTime.now();
  DateTime? _endDate;
  bool _isPrimary = false;

  String? _subjectId;
  String? _classId;
  String? _streamId;
  String? _departmentId;
  String? _houseId;
  final _extraScopeController = TextEditingController();

  List<UserEntity> _staffList = const [];
  bool _staffLoaded = false;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _staff = widget.preselectedStaff;
    _role = widget.preselectedRole;
    _loadStaff();
  }

  @override
  void dispose() {
    _extraScopeController.dispose();
    super.dispose();
  }

  Future<void> _loadStaff() async {
    final result = await di.sl<GetStaffMembers>()(NoParams());
    if (!mounted) return;
    setState(() {
      _staffList = result.getOrElse(() => const []);
      _staffLoaded = true;
      _staff ??= null;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final staff = _staff;
    final role = _role;
    if (staff == null || role == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a staff member and a role.')),
      );
      return;
    }
    if (role.requiresScope && !_hasScope(role)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${role.name} requires a scope to be set.')),
      );
      return;
    }

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;
    final actor = authState.user;
    final structureState = context.read<StructureBloc>().state;

    final className = structureState.classes
        .where((c) => c.id == _classId)
        .map((c) => c.name)
        .firstOrNull;
    final streamName = structureState.streams
        .where((s) => s.id == _streamId)
        .map((s) => s.name)
        .firstOrNull;
    final subjectName = structureState.subjects
        .where((s) => s.id == _subjectId)
        .map((s) => s.name)
        .firstOrNull;

    final draft = StaffRoleAssignment(
      id: '',
      schoolId: actor.schoolId,
      staffId: staff.id,
      userId: staff.id,
      roleDefinitionId: role.id,
      isPrimary: _isPrimary,
      roleType: StaffResponsibilityType.other,
      academicYearId:
          structureState.academicYears
              .where((y) => y.isCurrent)
              .map((y) => y.id)
              .firstOrNull ??
          '',
      subjectId: _subjectId,
      subjectName: subjectName,
      classId: _classId,
      className: className,
      streamId: _streamId,
      streamName: streamName,
      departmentId: _departmentId,
      houseId: _houseId,
      startDate: _effectiveDate,
      endDate: _endDate,
      extraScope: _extraScopeController.text.trim().isEmpty
          ? const {}
          : {'label': _extraScopeController.text.trim()},
      assignedBy: actor.id,
      assignedAt: DateTime.now(),
    );

    setState(() => _submitting = true);
    final ok = await context.read<RoleAssignmentCubit>().assign(
      draft: draft,
      role: role,
      actor: actor,
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (ok) {
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not assign this role. Try again.')),
      );
    }
  }

  bool _hasScope(StaffDesignation role) {
    switch (role.scopeType) {
      case 'subject':
        return _subjectId != null;
      case 'class':
      case 'stream':
        return _classId != null;
      case 'department':
        return _departmentId != null;
      case 'dormitory':
      case 'house':
        return _houseId != null;
      case 'wholeSchool':
        return true;
      default:
        return _extraScopeController.text.trim().isNotEmpty;
    }
  }

  @override
  Widget build(BuildContext context) {
    final structureState = context.watch<StructureBloc>().state;
    return Scaffold(
      appBar: const AdminAppBar(title: 'Assign Role to Staff'),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (_staff != null) _StaffHeaderCard(staff: _staff!),
            if (_staff == null)
              _staffLoaded
                  ? StructureStaffPickerField(
                      label: 'Staff Member',
                      selectedStaffId: null,
                      staff: _staffList,
                      required: true,
                      onChanged: (id) => setState(
                        () => _staff = _staffList
                            .where((s) => s.id == id)
                            .firstOrNull,
                      ),
                    )
                  : const _LoadingField(label: 'Staff Member'),
            const SizedBox(height: 18),
            _SectionLabel('Role'),
            DropdownButtonFormField<String>(
              initialValue: _role?.id,
              decoration: const InputDecoration(labelText: 'Role *'),
              items: structureState.designations
                  .where((d) => d.isActive && !d.isArchived)
                  .map(
                    (d) => DropdownMenuItem(value: d.id, child: Text(d.name)),
                  )
                  .toList(),
              validator: (v) => v == null ? 'Select a role' : null,
              onChanged: (value) => setState(
                () => _role = structureState.designations
                    .where((d) => d.id == value)
                    .firstOrNull,
              ),
            ),
            const SizedBox(height: 18),
            _SectionLabel('Effective Date'),
            _DatePickerField(
              value: _effectiveDate,
              onChanged: (d) =>
                  setState(() => _effectiveDate = d ?? _effectiveDate),
            ),
            const SizedBox(height: 18),
            _SectionLabel('End Date (optional)'),
            _DatePickerField(
              value: _endDate,
              allowClear: true,
              onChanged: (d) => setState(() => _endDate = d),
            ),
            if (_role != null) ...[
              const SizedBox(height: 24),
              Text(
                'SCOPE',
                style: TextStyle(
                  color: AppColors.primary(context),
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  letterSpacing: .6,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Define where this role applies.',
                style: Theme.of(context).textTheme.labelSmall,
              ),
              const SizedBox(height: 12),
              ..._scopeFields(_role!, structureState),
            ],
            const SizedBox(height: 18),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Is Primary Role'),
              subtitle: const Text(
                "This will be the staff member's default role.",
              ),
              value: _isPrimary,
              onChanged: (v) => setState(() => _isPrimary = v),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: _submitting ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary(context),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: _submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Assign Role'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _scopeFields(StaffDesignation role, StructureState state) {
    switch (role.scopeType) {
      case 'subject':
        return [
          DropdownButtonFormField<String>(
            initialValue: _subjectId,
            decoration: const InputDecoration(labelText: 'Subject *'),
            items: state.subjects
                .map((s) => DropdownMenuItem(value: s.id, child: Text(s.name)))
                .toList(),
            onChanged: (v) => setState(() => _subjectId = v),
          ),
        ];
      case 'class':
      case 'stream':
        return [
          DropdownButtonFormField<String>(
            initialValue: _classId,
            decoration: const InputDecoration(labelText: 'Class *'),
            items: state.classes
                .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                .toList(),
            onChanged: (v) => setState(() {
              _classId = v;
              _streamId = null;
            }),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            initialValue: _streamId,
            decoration: const InputDecoration(labelText: 'Stream (optional)'),
            items: state.streams
                .where((s) => s.classId == _classId)
                .map((s) => DropdownMenuItem(value: s.id, child: Text(s.name)))
                .toList(),
            onChanged: (v) => setState(() => _streamId = v),
          ),
        ];
      case 'department':
        return [
          DropdownButtonFormField<String>(
            initialValue: _departmentId,
            decoration: const InputDecoration(labelText: 'Department *'),
            items: state.departments
                .map((d) => DropdownMenuItem(value: d.id, child: Text(d.name)))
                .toList(),
            onChanged: (v) => setState(() => _departmentId = v),
          ),
        ];
      case 'dormitory':
      case 'house':
        return [
          DropdownButtonFormField<String>(
            initialValue: _houseId,
            decoration: const InputDecoration(labelText: 'House / Dormitory *'),
            items: state.houses
                .map((h) => DropdownMenuItem(value: h.id, child: Text(h.name)))
                .toList(),
            onChanged: (v) => setState(() => _houseId = v),
          ),
        ];
      case 'wholeSchool':
        return [
          const _ScopeHint('Applies to the whole school - no scope needed.'),
        ];
      default:
        return [
          const _ScopeHint(
            'No managed list exists yet for this scope type. Enter a label '
            'for record-keeping.',
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _extraScopeController,
            decoration: InputDecoration(
              labelText: 'Scope label',
              hintText: 'e.g. Route A, Main Store, Gate 2',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(7),
              ),
            ),
          ),
        ];
    }
  }
}

class _StaffHeaderCard extends StatelessWidget {
  const _StaffHeaderCard({required this.staff});
  final UserEntity staff;

  @override
  Widget build(BuildContext context) => AppCard(
    child: Row(
      children: [
        AvatarInitials(name: staff.name, size: 48),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                staff.name,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              Text(
                [
                  if (staff.staffCode?.isNotEmpty ?? false) staff.staffCode,
                ].join(),
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 7),
    child: Text(label, style: Theme.of(context).textTheme.labelSmall),
  );
}

class _ScopeHint extends StatelessWidget {
  const _ScopeHint(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(
        Icons.info_outline,
        size: 16,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Text(text, style: Theme.of(context).textTheme.labelSmall),
      ),
    ],
  );
}

class _LoadingField extends StatelessWidget {
  const _LoadingField({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: Theme.of(context).textTheme.labelSmall),
      const SizedBox(height: 7),
      Container(
        height: 46,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: .35),
          ),
          borderRadius: BorderRadius.circular(7),
        ),
        child: const SizedBox(
          height: 16,
          width: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    ],
  );
}

class _DatePickerField extends StatelessWidget {
  const _DatePickerField({
    required this.value,
    required this.onChanged,
    this.allowClear = false,
  });
  final DateTime? value;
  final bool allowClear;
  final ValueChanged<DateTime?> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(7),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
        );
        if (picked != null) onChanged(picked);
      },
      child: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: colors.outline.withValues(alpha: .35)),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value == null
                    ? (allowClear ? 'Select end date' : 'Select date')
                    : '${value!.day}/${value!.month}/${value!.year}',
                style: TextStyle(
                  color: value == null ? colors.onSurfaceVariant : null,
                ),
              ),
            ),
            if (allowClear && value != null)
              InkWell(
                onTap: () => onChanged(null),
                child: Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: colors.onSurfaceVariant,
                ),
              )
            else
              const Icon(Icons.calendar_today_outlined, size: 18),
          ],
        ),
      ),
    );
  }
}
