import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/injection_container.dart' as di;
import '../../domain/services/structure_dependency_service.dart';
import '../bloc/structure_bloc.dart';
import '../bloc/structure_event.dart';
import '../bloc/structure_state.dart';
import '../widgets/structure_dialogs.dart';
import '../widgets/structure_empty_hint.dart';
import '../widgets/structure_ui_kit.dart';

/// Departments and staff Designations/Roles - the org-structure metadata
/// other modules (Admin's user management) read from.
class PeopleStructureScreen extends StatefulWidget {
  final int initialTab;
  const PeopleStructureScreen({super.key, this.initialTab = 0});

  @override
  State<PeopleStructureScreen> createState() => _PeopleStructureScreenState();
}

class _PeopleStructureScreenState extends State<PeopleStructureScreen> {
  static const _sections = ['Departments', 'Staff roles & designations'];
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTab.clamp(0, _sections.length - 1);
  }

  @override
  void didUpdateWidget(covariant PeopleStructureScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTab != widget.initialTab) {
      _selectedIndex = widget.initialTab.clamp(0, _sections.length - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('People')),
      body: Column(
        children: [
          StructureSectionPicker(
            sections: _sections,
            selectedIndex: _selectedIndex,
            onSelected: (index) =>
                context.go('/staff/admin/structure/people?tab=$index'),
          ),
          Expanded(
            child: BlocBuilder<StructureBloc, StructureState>(
              builder: (context, state) => IndexedStack(
                index: _selectedIndex,
                children: [
                  _DepartmentsTab(state: state),
                  _StaffRolesTab(state: state),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DepartmentsTab extends StatelessWidget {
  final StructureState state;
  const _DepartmentsTab({required this.state});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<StructureBloc>();
    final schoolId =
        (context.read<AuthBloc>().state as AuthAuthenticated).user.schoolId;
    return Scaffold(
      body: state.departments.isEmpty
          ? const StructureEmptyHint('No departments defined yet.')
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: state.departments.length,
              itemBuilder: (context, index) {
                final department = state.departments[index];
                return AppCard(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(
                      department.name,
                      style: TextStyle(
                        decoration: department.isActive
                            ? null
                            : TextDecoration.lineThrough,
                      ),
                    ),
                    subtitle: department.description.isNotEmpty
                        ? Text(department.description)
                        : null,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () => showDepartmentFormDialog(
                            context,
                            existing: department,
                            schoolId: schoolId,
                            onSave: (updated) =>
                                bloc.add(SaveDepartmentRequested(updated)),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          onPressed: () async {
                            final staffCount = await di
                                .sl<StructureDependencyService>()
                                .countStaffInDepartment(
                                  schoolId,
                                  department.id,
                                );
                            if (!context.mounted) return;
                            final confirmed = await showDeleteConfirmDialog(
                              context,
                              title: 'Delete Department',
                              message: 'Delete "${department.name}"?',
                              impactMessage:
                                  '$staffCount staff member(s) currently reference this department.',
                            );
                            if (confirmed == true) {
                              bloc.add(
                                DeleteDepartmentRequested(department.id),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDepartmentFormDialog(
          context,
          schoolId: schoolId,
          onSave: (d) => bloc.add(SaveDepartmentRequested(d)),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Add Department'),
      ),
    );
  }
}

class _StaffRolesTab extends StatelessWidget {
  final StructureState state;
  const _StaffRolesTab({required this.state});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<StructureBloc>();
    final schoolId =
        (context.read<AuthBloc>().state as AuthAuthenticated).user.schoolId;
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Staff Designations',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            TextButton.icon(
              onPressed: () => showDesignationFormDialog(
                context,
                schoolId: schoolId,
                onSave: (d) => bloc.add(SaveDesignationRequested(d)),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Add'),
            ),
          ],
        ),
        if (state.designations.isEmpty)
          const StructureEmptyHint(
            'No designations defined yet.\ne.g. Principal, Bursar, Librarian, Driver.',
          ),
        ...state.designations.map(
          (designation) => AppCard(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text(
                designation.name,
                style: TextStyle(
                  decoration: designation.isActive
                      ? null
                      : TextDecoration.lineThrough,
                ),
              ),
              subtitle: designation.description.isNotEmpty
                  ? Text(designation.description)
                  : null,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => showDesignationFormDialog(
                      context,
                      existing: designation,
                      schoolId: schoolId,
                      onSave: (updated) =>
                          bloc.add(SaveDesignationRequested(updated)),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () async {
                      final confirmed = await showDeleteConfirmDialog(
                        context,
                        title: 'Delete Designation',
                        message: 'Delete "${designation.name}"?',
                      );
                      if (confirmed == true) {
                        bloc.add(DeleteDesignationRequested(designation.id));
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Staff Roles',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            TextButton.icon(
              onPressed: () => showStaffRoleFormDialog(
                context,
                designations: state.designations,
                schoolId: schoolId,
                onSave: (r) => bloc.add(SaveStaffRoleRequested(r)),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Add'),
            ),
          ],
        ),
        if (state.staffRoles.isEmpty)
          const StructureEmptyHint(
            'No roles defined yet.\ne.g. Class Teacher, Exam Officer, Discipline Teacher - separate from designation.',
          ),
        ...state.staffRoles.map((role) {
          final designation = state.designations
              .where((d) => d.id == role.designationId)
              .firstOrNull;
          return AppCard(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text(
                role.name,
                style: TextStyle(
                  decoration: role.isActive ? null : TextDecoration.lineThrough,
                ),
              ),
              subtitle: Text(designation?.name ?? 'No designation'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => showStaffRoleFormDialog(
                      context,
                      existing: role,
                      designations: state.designations,
                      schoolId: schoolId,
                      onSave: (updated) =>
                          bloc.add(SaveStaffRoleRequested(updated)),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () async {
                      final confirmed = await showDeleteConfirmDialog(
                        context,
                        title: 'Delete Role',
                        message: 'Delete "${role.name}"?',
                      );
                      if (confirmed == true) {
                        bloc.add(DeleteStaffRoleRequested(role.id));
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
