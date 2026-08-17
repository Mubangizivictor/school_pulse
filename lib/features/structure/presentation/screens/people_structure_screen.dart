import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import '../../domain/services/structure_integrity_validator.dart';
import '../bloc/structure_bloc.dart';
import '../bloc/structure_event.dart';
import '../bloc/structure_state.dart';
import '../widgets/structure_dialogs.dart';
import '../widgets/structure_empty_hint.dart';

const _validator = StructureIntegrityValidator();

/// Definition-first People Structure: define departments and responsibilities
/// without forcing a person assignment during institutional setup.
class PeopleStructureScreen extends StatelessWidget {
  final String section;

  const PeopleStructureScreen({super.key, this.section = 'departments'});

  @override
  Widget build(BuildContext context) {
    final requested = GoRouterState.of(context).uri.queryParameters['section'] ?? section;
    final normalized = requested == 'roles' ? 'roles' : 'departments';
    return Scaffold(
      appBar: AppBar(
        title: Text(normalized == 'roles' ? 'Staff Roles & Responsibilities' : 'Departments'),
      ),
      body: BlocBuilder<StructureBloc, StructureState>(
        builder: (context, state) => normalized == 'roles'
            ? _roles(context, state)
            : _departments(context, state),
      ),
    );
  }

  Widget _departments(BuildContext context, StructureState state) {
    final bloc = context.read<StructureBloc>();
    return _SectionPage(
      intro: 'Define departments now. A Head of Department is assigned later, so Department creation never depends on a teacher or staff record.',
      primaryLabel: 'Add Department',
      onPrimary: () => showDepartmentFormDialog(
        context,
        onSave: (value) => _dispatchIfValid(
          context,
          _validator.validateDepartment(value, state.departments),
          () => bloc.add(SaveDepartmentRequested(value)),
        ),
      ),
      child: state.departments.isEmpty
          ? const StructureEmptyHint('No departments configured yet.')
          : ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: state.departments.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, index) {
                final department = state.departments[index];
                final subjectCount = state.subjects
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
                      '$subjectCount active subject${subjectCount == 1 ? '' : 's'}',
                      if (department.headOfDepartmentStaffId.isEmpty) 'HOD assigned later',
                    ].join(' • ')),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => showDepartmentFormDialog(
                        context,
                        existing: department,
                        onSave: (value) => _dispatchIfValid(
                          context,
                          _validator.validateDepartment(value, state.departments),
                          () => bloc.add(SaveDepartmentRequested(value)),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _roles(BuildContext context, StructureState state) {
    final bloc = context.read<StructureBloc>();
    final activeDesignations = state.designations.where((item) => item.isActive).toList();
    return _SectionPage(
      intro: 'Define reusable responsibilities. One staff account may later hold several roles at the same time; creating a role never creates a separate login.',
      primaryLabel: 'Add Staff Role',
      onPrimary: () => showStaffRoleFormDialog(
        context,
        designations: activeDesignations,
        onSave: (value) => _dispatchIfValid(
          context,
          _validator.validateRole(
            value,
            roles: state.staffRoles,
            designations: state.designations,
          ),
          () => bloc.add(SaveStaffRoleRequested(value)),
        ),
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
                  onSave: (value) => _dispatchIfValid(
                    context,
                    _validator.validateDesignation(value, state.designations),
                    () => bloc.add(SaveDesignationRequested(value)),
                  ),
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
                    style: TextStyle(decoration: designation.isActive ? null : TextDecoration.lineThrough),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => showDesignationFormDialog(
                      context,
                      existing: designation,
                      onSave: (value) => _dispatchIfValid(
                        context,
                        _validator.validateDesignation(value, state.designations),
                        () => bloc.add(SaveDesignationRequested(value)),
                      ),
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
            const StructureEmptyHint('No staff roles yet. Add only responsibilities the school actually uses.')
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
                      designations: activeDesignations,
                      onSave: (value) => _dispatchIfValid(
                        context,
                        _validator.validateRole(
                          value,
                          roles: state.staffRoles,
                          designations: state.designations,
                        ),
                        () => bloc.add(SaveStaffRoleRequested(value)),
                      ),
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

class _SectionPage extends StatelessWidget {
  final String intro;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final Widget child;

  const _SectionPage({
    required this.intro,
    required this.primaryLabel,
    required this.onPrimary,
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
                onPressed: onPrimary,
                icon: const Icon(Icons.add),
                label: Text(primaryLabel),
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

void _dispatchIfValid(
  BuildContext context,
  String? validationError,
  VoidCallback dispatch,
) {
  if (validationError == null) {
    dispatch();
    return;
  }
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(validationError)));
}

extension _FirstOrNullExtension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
