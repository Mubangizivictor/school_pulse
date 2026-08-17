import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import '../../domain/entities/structure_entities.dart';
import '../bloc/structure_bloc.dart';
import '../bloc/structure_event.dart';
import '../bloc/structure_state.dart';
import '../widgets/structure_dialogs.dart';
import '../widgets/structure_empty_hint.dart';

/// Definition-only People Structure editor.
///
/// Departments and roles are created here without requiring a person to be
/// assigned immediately. That deliberately breaks the old circular setup
/// pattern: define structure first, create staff later, assign responsibility
/// after both sides exist.
class PeopleStructureScreen extends StatelessWidget {
  final String section;

  const PeopleStructureScreen({
    super.key,
    this.section = 'departments',
  });

  @override
  Widget build(BuildContext context) {
    final normalized = section == 'roles' ? 'roles' : 'departments';
    return Scaffold(
      appBar: AppBar(
        title: Text(normalized == 'roles' ? 'Staff Roles & Responsibilities' : 'Departments'),
      ),
      body: BlocBuilder<StructureBloc, StructureState>(
        builder: (context, state) {
          return normalized == 'roles'
              ? _StaffRolesSection(state: state)
              : _DepartmentsSection(state: state);
        },
      ),
    );
  }
}

class _DepartmentsSection extends StatelessWidget {
  final StructureState state;

  const _DepartmentsSection({required this.state});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<StructureBloc>();
    return _PeopleSectionScaffold(
      intro: 'Define academic or operational departments now. A Head of Department is assigned later and is never required to create the department itself.',
      addLabel: 'Add Department',
      onAdd: () => showDepartmentFormDialog(
        context,
        onSave: (department) {
          final error = _validateDepartment(department, state);
          if (error != null) return _showError(context, error);
          bloc.add(SaveDepartmentRequested(department));
        },
      ),
      child: state.departments.isEmpty
          ? const StructureEmptyHint('No departments configured yet.')
          : ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: state.departments.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final department = state.departments[index];
                final subjects = state.subjects
                    .where((subject) => subject.departmentId == department.id && subject.isActive)
                    .length;
                return AppCard(
                  child: ListTile(
                    title: Text(
                      department.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        decoration: department.isActive ? null : TextDecoration.lineThrough,
                      ),
                    ),
                    subtitle: Text([
                      if (department.code.trim().isNotEmpty) department.code.trim(),
                      '$subjects active subject${subjects == 1 ? '' : 's'}',
                      if (department.headOfDepartmentStaffId.isEmpty) 'HOD assigned later',
                    ].join(' • ')),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => showDepartmentFormDialog(
                        context,
                        existing: department,
                        onSave: (updated) {
                          final error = _validateDepartment(updated, state);
                          if (error != null) return _showError(context, error);
                          bloc.add(SaveDepartmentRequested(updated));
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _StaffRolesSection extends StatelessWidget {
  final StructureState state;

  const _StaffRolesSection({required this.state});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<StructureBloc>();
    return _PeopleSectionScaffold(
      intro: 'Define job designations and responsibilities. One staff account may later receive several roles; defining a role never creates or replaces a staff account.',
      addLabel: 'Add Staff Role',
      onAdd: () => showStaffRoleFormDialog(
        context,
        designations: state.designations.where((item) => item.isActive).toList(),
        onSave: (role) {
          final error = _validateRole(role, state);
          if (error != null) return _showError(context, error);
          bloc.add(SaveStaffRoleRequested(role));
        },
      ),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Designations',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              TextButton.icon(
                onPressed: () => showDesignationFormDialog(
                  context,
                  onSave: (designation) {
                    final error = _validateDesignation(designation, state);
                    if (error != null) return _showError(context, error);
                    bloc.add(SaveDesignationRequested(designation));
                  },
                ),
                icon: const Icon(Icons.add),
                label: const Text('Add'),
              ),
            ],
          ),
          if (state.designations.isEmpty)
            const StructureEmptyHint('Designations are optional labels such as Teacher, Principal or Bursar.')
          else
            ...state.designations.map(
              (designation) => AppCard(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(
                    designation.name,
                    style: TextStyle(
                      decoration: designation.isActive ? null : TextDecoration.lineThrough,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => showDesignationFormDialog(
                      context,
                      existing: designation,
                      onSave: (updated) {
                        final error = _validateDesignation(updated, state);
                        if (error != null) return _showError(context, error);
                        bloc.add(SaveDesignationRequested(updated));
                      },
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 20),
          Text(
            'Responsibilities / Roles',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          if (state.staffRoles.isEmpty)
            const StructureEmptyHint(
              'No staff roles yet. Roles such as Class Teacher or Exam Officer are assignments a staff member may hold in addition to other roles.',
            )
          else
            ...state.staffRoles.map((role) {
              final designation = state.designations.where((item) => item.id == role.designationId).firstOrNull;
              return AppCard(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(
                    role.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      decoration: role.isActive ? null : TextDecoration.lineThrough,
                    ),
                  ),
                  subtitle: Text(designation?.name ?? 'No required designation'),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => showStaffRoleFormDialog(
                      context,
                      existing: role,
                      designations: state.designations.where((item) => item.isActive).toList(),
                      onSave: (updated) {
                        final error = _validateRole(updated, state);
                        if (error != null) return _showError(context, error);
                        bloc.add(SaveStaffRoleRequested(updated));
                      },
                    ),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _PeopleSectionScaffold extends StatelessWidget {
  final String intro;
  final String addLabel;
  final VoidCallback onAdd;
  final Widget child;

  const _PeopleSectionScaffold({
    required this.intro,
    required this.addLabel,
    required this.onAdd,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              intro,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add),
                label: Text(addLabel),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

String? _validateDepartment(Department candidate, StructureState state) {
  if (candidate.name.trim().isEmpty) return 'Enter a department name.';
  final duplicateName = state.departments.any(
    (department) => department.id != candidate.id &&
        department.isActive &&
        candidate.isActive &&
        department.name.trim().toLowerCase() == candidate.name.trim().toLowerCase(),
  );
  if (duplicateName) return 'An active department with this name already exists.';
  final code = candidate.code.trim().toLowerCase();
  if (code.isNotEmpty &&
      state.departments.any(
        (department) => department.id != candidate.id &&
            department.isActive &&
            candidate.isActive &&
            department.code.trim().toLowerCase() == code,
      )) {
    return 'This department code is already in use.';
  }
  return null;
}

String? _validateDesignation(StaffDesignation candidate, StructureState state) {
  if (candidate.name.trim().isEmpty) return 'Enter a designation name.';
  if (state.designations.any(
    (designation) => designation.id != candidate.id &&
        designation.isActive &&
        candidate.isActive &&
        designation.name.trim().toLowerCase() == candidate.name.trim().toLowerCase(),
  )) {
    return 'An active designation with this name already exists.';
  }
  return null;
}

String? _validateRole(StaffRole candidate, StructureState state) {
  if (candidate.name.trim().isEmpty) return 'Enter a role name.';
  if (state.staffRoles.any(
    (role) => role.id != candidate.id &&
        role.isActive &&
        candidate.isActive &&
        role.name.trim().toLowerCase() == candidate.name.trim().toLowerCase(),
  )) {
    return 'An active role with this name already exists.';
  }
  if (candidate.designationId.isNotEmpty &&
      !state.designations.any(
        (designation) => designation.id == candidate.designationId && designation.isActive,
      )) {
    return 'Select an active designation or leave the designation unassigned.';
  }
  return null;
}

void _showError(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

extension _FirstOrNullExtension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
