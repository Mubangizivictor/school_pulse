import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/admin/presentation/widgets/admin_app_bar.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/structure/domain/entities/structure_entities.dart';
import '../bloc/structure_bloc.dart';
import '../bloc/structure_state.dart';
import '../widgets/structure_empty_hint.dart';
import '../widgets/structure_ui_kit.dart';
import 'people_forms_screen.dart';

/// Tenant-owned organisation metadata.  This deliberately manages
/// designations only: app access roles remain in the authorization module.
class PeopleStructureScreen extends StatefulWidget {
  const PeopleStructureScreen({super.key, this.initialTab = 0});
  final int initialTab;

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
  Widget build(BuildContext context) => Scaffold(
    appBar: const AdminAppBar(title: 'People'),
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
            builder: (_, state) => _selectedIndex == 0
                ? _DepartmentsList(departments: state.departments)
                : _DesignationsList(designations: state.designations),
          ),
        ),
      ],
    ),
  );
}

class _DepartmentsList extends StatefulWidget {
  const _DepartmentsList({required this.departments});
  final List<Department> departments;
  @override
  State<_DepartmentsList> createState() => _DepartmentsListState();
}

class _DepartmentsListState extends State<_DepartmentsList> {
  String _query = '';
  @override
  Widget build(BuildContext context) {
    final schoolId =
        (context.read<AuthBloc>().state as AuthAuthenticated).user.schoolId;
    final items =
        widget.departments
            .where(
              (d) =>
                  d.name.toLowerCase().contains(_query.toLowerCase()) ||
                  d.code.toLowerCase().contains(_query.toLowerCase()),
            )
            .toList()
          ..sort((a, b) => a.name.compareTo(b.name));
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: StructureSearchBar(
              hint: 'Search departments...',
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? const StructureEmptyHint('No departments defined yet.')
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                    itemCount: items.length,
                    itemBuilder: (_, i) => _OrganisationCard(
                      icon: Icons.account_balance_outlined,
                      color: Colors.blue,
                      title: items[i].name,
                      code: items[i].code,
                      active: items[i].isActive,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: context.read<StructureBloc>(),
                            child: DepartmentFormScreen(
                              schoolId: schoolId,
                              existing: items[i],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: _AddButton(
        label: 'Add Department',
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: context.read<StructureBloc>(),
              child: DepartmentFormScreen(schoolId: schoolId),
            ),
          ),
        ),
      ),
    );
  }
}

class _DesignationsList extends StatefulWidget {
  const _DesignationsList({required this.designations});
  final List<StaffDesignation> designations;
  @override
  State<_DesignationsList> createState() => _DesignationsListState();
}

class _DesignationsListState extends State<_DesignationsList> {
  String _query = '';
  @override
  Widget build(BuildContext context) {
    final schoolId =
        (context.read<AuthBloc>().state as AuthAuthenticated).user.schoolId;
    final items =
        widget.designations
            .where((r) => r.name.toLowerCase().contains(_query.toLowerCase()))
            .toList()
          ..sort((a, b) => a.name.compareTo(b.name));
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: StructureSearchBar(
              hint: 'Search roles...',
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? const StructureEmptyHint(
                    'No staff roles or designations defined yet.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                    itemCount: items.length,
                    itemBuilder: (_, i) => _OrganisationCard(
                      icon: Icons.person_outline_rounded,
                      color: Colors.deepPurple,
                      title: items[i].name,
                      code: 'Designation',
                      active: items[i].isActive,
                      subtitle: items[i].description,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: context.read<StructureBloc>(),
                            child: DesignationFormScreen(
                              schoolId: schoolId,
                              existing: items[i],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: _AddButton(
        label: 'Add Role',
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: context.read<StructureBloc>(),
              child: DesignationFormScreen(schoolId: schoolId),
            ),
          ),
        ),
      ),
    );
  }
}

class _OrganisationCard extends StatelessWidget {
  const _OrganisationCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.code,
    required this.active,
    required this.onTap,
    this.subtitle,
  });
  final IconData icon;
  final Color color;
  final String title;
  final String code;
  final bool active;
  final String? subtitle;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Material(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.outline.withValues(alpha: .18)),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: .10),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(icon, color: color, size: 19),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          decoration: active
                              ? null
                              : TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle?.isNotEmpty == true
                            ? subtitle!
                            : (code.isEmpty ? 'No code' : code),
                        style: TextStyle(
                          fontSize: 11,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!active)
                  const StructureStatusBadge(
                    label: 'Inactive',
                    isActive: false,
                  ),
                const SizedBox(width: 6),
                Icon(Icons.chevron_right_rounded, color: colors.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.label, required this.onPressed});
  final String label;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => FloatingActionButton.extended(
    onPressed: onPressed,
    icon: const Icon(Icons.add),
    label: Text(label),
    backgroundColor: AppColors.primary(context),
    foregroundColor: Colors.white,
  );
}
