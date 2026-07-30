import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import '../bloc/structure_bloc.dart';
import '../bloc/structure_event.dart';
import '../bloc/structure_state.dart';
import '../widgets/structure_dialogs.dart';
import '../widgets/structure_empty_hint.dart';

/// Departments and staff Designations/Roles - the org-structure metadata
/// other modules (Admin's user management) read from.
class PeopleStructureScreen extends StatefulWidget {
  const PeopleStructureScreen({super.key});

  @override
  State<PeopleStructureScreen> createState() => _PeopleStructureScreenState();
}

class _PeopleStructureScreenState extends State<PeopleStructureScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const _tabs = [
    Tab(text: 'Departments'),
    Tab(text: 'Staff Roles'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('People'),
        bottom: TabBar(controller: _tabController, isScrollable: true, tabs: _tabs),
      ),
      body: BlocBuilder<StructureBloc, StructureState>(
        builder: (context, state) {
          return TabBarView(
            controller: _tabController,
            children: [
              _DepartmentsTab(state: state),
              _StaffRolesTab(state: state),
            ],
          );
        },
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
                    title: Text(department.name, style: TextStyle(decoration: department.isActive ? null : TextDecoration.lineThrough)),
                    subtitle: department.description.isNotEmpty ? Text(department.description) : null,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () => showDepartmentFormDialog(
                            context,
                            existing: department,
                            onSave: (updated) => bloc.add(SaveDepartmentRequested(updated)),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () async {
                            final confirmed =
                                await showDeleteConfirmDialog(context, title: 'Delete Department', message: 'Delete "${department.name}"?');
                            if (confirmed == true) bloc.add(DeleteDepartmentRequested(department.id));
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDepartmentFormDialog(context, onSave: (d) => bloc.add(SaveDepartmentRequested(d))),
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
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Staff Designations', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            TextButton.icon(
              onPressed: () => showDesignationFormDialog(context, onSave: (d) => bloc.add(SaveDesignationRequested(d))),
              icon: const Icon(Icons.add),
              label: const Text('Add'),
            ),
          ],
        ),
        if (state.designations.isEmpty) const StructureEmptyHint('No designations defined yet.\ne.g. Principal, Bursar, Librarian, Driver.'),
        ...state.designations.map((designation) => AppCard(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(designation.name, style: TextStyle(decoration: designation.isActive ? null : TextDecoration.lineThrough)),
                subtitle: designation.description.isNotEmpty ? Text(designation.description) : null,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => showDesignationFormDialog(
                        context,
                        existing: designation,
                        onSave: (updated) => bloc.add(SaveDesignationRequested(updated)),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () async {
                        final confirmed =
                            await showDeleteConfirmDialog(context, title: 'Delete Designation', message: 'Delete "${designation.name}"?');
                        if (confirmed == true) bloc.add(DeleteDesignationRequested(designation.id));
                      },
                    ),
                  ],
                ),
              ),
            )),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Staff Roles', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            TextButton.icon(
              onPressed: () => showStaffRoleFormDialog(context, designations: state.designations, onSave: (r) => bloc.add(SaveStaffRoleRequested(r))),
              icon: const Icon(Icons.add),
              label: const Text('Add'),
            ),
          ],
        ),
        if (state.staffRoles.isEmpty)
          const StructureEmptyHint('No roles defined yet.\ne.g. Class Teacher, Exam Officer, Discipline Teacher - separate from designation.'),
        ...state.staffRoles.map((role) {
          final designation = state.designations.where((d) => d.id == role.designationId).firstOrNull;
          return AppCard(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text(role.name, style: TextStyle(decoration: role.isActive ? null : TextDecoration.lineThrough)),
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
                      onSave: (updated) => bloc.add(SaveStaffRoleRequested(updated)),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () async {
                      final confirmed = await showDeleteConfirmDialog(context, title: 'Delete Role', message: 'Delete "${role.name}"?');
                      if (confirmed == true) bloc.add(DeleteStaffRoleRequested(role.id));
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
