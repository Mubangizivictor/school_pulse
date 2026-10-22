import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import '../../domain/services/structure_integrity_validator.dart';
import '../bloc/structure_bloc.dart';
import '../bloc/structure_event.dart';
import '../bloc/structure_state.dart';
import '../widgets/structure_dialogs.dart';

const _validator = StructureIntegrityValidator();

/// Definition-first People Structure: define departments and responsibilities
/// without forcing a person assignment during institutional setup. A single
/// staff account can hold multiple [StaffDesignation]s at once (e.g. Teacher
/// + Class Teacher, Teacher + Head of Department) - designations are the one
/// and only role-definition concept; there is no separate "staff role"
/// layer to keep in sync with it.
class PeopleStructureScreen extends StatelessWidget {
  final String section;
  final bool showAppBar;

  const PeopleStructureScreen({
    super.key,
    this.section = 'departments',
    this.showAppBar = true,
  });

  @override
  Widget build(BuildContext context) {
    final requested =
        GoRouterState.of(context).uri.queryParameters['section'] ?? section;
    final normalized = requested == 'roles' ? 'roles' : 'departments';
    return Scaffold(
      appBar: showAppBar
          ? AppBar(
              title: Text(
                normalized == 'roles'
                    ? 'Staff Roles & Responsibilities'
                    : 'Departments',
              ),
            )
          : null,
      backgroundColor: showAppBar ? null : Colors.transparent,
      body: BlocBuilder<StructureBloc, StructureState>(
        builder: (context, state) => normalized == 'roles'
            ? _roles(context, state)
            : _departments(context, state),
      ),
    );
  }

  String _schoolId(BuildContext context) =>
      (context.read<AuthBloc>().state as AuthAuthenticated).user.schoolId;

  Widget _departments(BuildContext context, StructureState state) {
    final bloc = context.read<StructureBloc>();
    final schoolId = _schoolId(context);
    final scheme = Theme.of(context).colorScheme;

    void onAdd() => showDepartmentFormDialog(
      context,
      schoolId: schoolId,
      onSave: (value) => _dispatchIfValid(
        context,
        _validator.validateDepartment(value, state.departments),
        () => bloc.add(SaveDepartmentRequested(value)),
      ),
    );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    'Organize staff and subjects by department.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add department'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (state.departments.isEmpty)
              _DepartmentsEmptyState(onAdd: onAdd)
            else
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: state.departments.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (_, index) {
                    final department = state.departments[index];
                    final subjectCount = state.subjects
                        .where(
                          (subject) =>
                              subject.departmentId == department.id &&
                              subject.isActive,
                        )
                        .length;
                    return AppCard(
                      child: ListTile(
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: scheme.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.account_balance_outlined,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        title: Text(
                          department.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            decoration: department.isActive
                                ? null
                                : TextDecoration.lineThrough,
                          ),
                        ),
                        subtitle: Text(
                          '$subjectCount subject${subjectCount == 1 ? '' : 's'} • '
                          '${department.headOfDepartmentStaffId.isEmpty ? 'HOD not assigned' : 'HOD assigned'}',
                        ),
                        trailing: PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert),
                          onSelected: (_) => showDepartmentFormDialog(
                            context,
                            schoolId: schoolId,
                            existing: department,
                            onSave: (value) => _dispatchIfValid(
                              context,
                              _validator.validateDepartment(
                                value,
                                state.departments,
                              ),
                              () => bloc.add(SaveDepartmentRequested(value)),
                            ),
                          ),
                          itemBuilder: (_) => const [
                            PopupMenuItem(value: 'edit', child: Text('Edit')),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _roles(BuildContext context, StructureState state) {
    final bloc = context.read<StructureBloc>();
    final schoolId = _schoolId(context);
    return _SectionPage(
      intro:
          'Define reusable responsibilities/designations here. One staff account may hold several designations at the same time (e.g. Teacher + Class Teacher, Teacher + Head of Department) - assigning a designation never creates a separate login.',
      primaryLabel: 'Add Staff Role',
      onPrimary: () => showDesignationFormDialog(
        context,
        schoolId: schoolId,
        onSave: (value) => _dispatchIfValid(
          context,
          _validator.validateDesignation(value, state.designations),
          () => bloc.add(SaveDesignationRequested(value)),
        ),
      ),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          if (state.designations.isEmpty)
            const EmptyState(
              icon: Icons.badge_outlined,
              title: 'No staff roles yet',
              message:
                  'Add only the responsibilities this school actually uses - e.g. Teacher, Class Teacher, Head of Department, Bursar.',
            )
          else
            ...state.designations.map(
              (designation) => AppCard(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(
                    designation.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      decoration: designation.isActive
                          ? null
                          : TextDecoration.lineThrough,
                    ),
                  ),
                  subtitle: Text(
                    [
                      if (designation.category.trim().isNotEmpty)
                        designation.category.trim(),
                      designation.allowMultipleStaff
                          ? 'Multiple staff'
                          : 'Single staff',
                      designation.allowConcurrentAssignments
                          ? 'Concurrent with other roles'
                          : '',
                    ].where((item) => item.isNotEmpty).join(' • '),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => showDesignationFormDialog(
                      context,
                      schoolId: schoolId,
                      existing: designation,
                      onSave: (value) => _dispatchIfValid(
                        context,
                        _validator.validateDesignation(
                          value,
                          state.designations,
                        ),
                        () => bloc.add(SaveDesignationRequested(value)),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DepartmentsEmptyState extends StatelessWidget {
  final VoidCallback onAdd;

  const _DepartmentsEmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.account_balance_outlined,
      title: 'No departments added',
      message: 'Add your first department to continue.',
      ctaLabel: 'Add department',
      onCtaPressed: onAdd,
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
