import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/core/usecases/usecase.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/admin/presentation/widgets/admin_app_bar.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/domain/usecases/get_staff_members.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/structure/domain/entities/structure_entities.dart';
import 'package:school_pulse/injection_container.dart' as di;
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
  static const _sections = ['Departments', 'Staff Roles & Designations'];
  late int _selectedIndex;
  List<UserEntity> _staff = const [];
  bool _staffLoaded = false;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTab.clamp(0, _sections.length - 1);
    _loadStaff();
  }

  @override
  void didUpdateWidget(covariant PeopleStructureScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTab != widget.initialTab) {
      _selectedIndex = widget.initialTab.clamp(0, _sections.length - 1);
    }
  }

  Future<void> _loadStaff() async {
    final result = await di.sl<GetStaffMembers>()(NoParams());
    if (!mounted) return;
    setState(() {
      _staff = result.getOrElse(() => const []);
      _staffLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const AdminAppBar(title: 'People'),
    body: BlocBuilder<StructureBloc, StructureState>(
      builder: (_, state) => _selectedIndex == 0
          ? _DepartmentsList(
              departments: state.departments,
              staff: _staff,
              staffLoaded: _staffLoaded,
            )
          : _DesignationsList(
              designations: state.designations,
              staff: _staff,
              staffLoaded: _staffLoaded,
            ),
    ),
  );
}

class _DepartmentsList extends StatefulWidget {
  const _DepartmentsList({
    required this.departments,
    required this.staff,
    required this.staffLoaded,
  });
  final List<Department> departments;
  final List<UserEntity> staff;
  final bool staffLoaded;
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
          ..sort(
            (a, b) => a.displayOrder != b.displayOrder
                ? a.displayOrder.compareTo(b.displayOrder)
                : a.name.compareTo(b.name),
          );
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
                    itemBuilder: (_, i) {
                      final department = items[i];
                      final staffCount = widget.staff
                          .where((s) => s.departmentId == department.id)
                          .length;
                      return StructureRecordCard(
                        icon: Icons.account_balance_outlined,
                        color: Colors.blue,
                        title: department.name,
                        subtitle: [
                          if (department.code.isNotEmpty) department.code,
                          if (widget.staffLoaded)
                            '$staffCount ${staffCount == 1 ? 'Staff' : 'Staff'}',
                        ].join(' - '),
                        isActive: department.isActive,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: context.read<StructureBloc>(),
                              child: DepartmentDetailsScreen(
                                schoolId: schoolId,
                                department: department,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
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
  const _DesignationsList({
    required this.designations,
    required this.staff,
    required this.staffLoaded,
  });
  final List<StaffDesignation> designations;
  final List<UserEntity> staff;
  final bool staffLoaded;
  @override
  State<_DesignationsList> createState() => _DesignationsListState();
}

class _DesignationsListState extends State<_DesignationsList> {
  String _query = '';
  String _filter = 'All';
  @override
  Widget build(BuildContext context) {
    final schoolId =
        (context.read<AuthBloc>().state as AuthAuthenticated).user.schoolId;
    final items =
        widget.designations
            .where((r) => r.name.toLowerCase().contains(_query.toLowerCase()))
            .where(
              (role) => switch (_filter) {
                'Active' => role.isActive && !role.isArchived,
                'Inactive' => !role.isActive && !role.isArchived,
                'System' => role.isSystemPreset,
                'Custom' => !role.isSystemPreset,
                _ => true,
              },
            )
            .toList()
          ..sort(
            (a, b) => a.displayOrder != b.displayOrder
                ? a.displayOrder.compareTo(b.displayOrder)
                : a.name.compareTo(b.name),
          );
    return Scaffold(
      body: Column(
        children: [
          _RoleSummary(designations: widget.designations, staff: widget.staff),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: StructureSearchBar(
              hint: 'Search roles...',
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: ['All', 'Active', 'Inactive', 'System', 'Custom']
                  .map(
                    (filter) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(filter),
                        selected: _filter == filter,
                        onSelected: (_) => setState(() => _filter = filter),
                      ),
                    ),
                  )
                  .toList(),
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
                    itemBuilder: (_, i) {
                      final designation = items[i];
                      final staffCount = widget.staff
                          .where((s) => s.designationId == designation.id)
                          .length;
                      return StructureRecordCard(
                        icon: staffDesignationIcon(designation.iconName),
                        color: staffDesignationColor(designation.colorHex),
                        title: designation.name,
                        subtitle: [
                          if (designation.code.isNotEmpty) designation.code,
                          if (designation.category.isNotEmpty)
                            designation.category,
                          _scopeName(designation.scopeType),
                          if (widget.staffLoaded) '$staffCount Staff',
                        ].join(' - '),
                        isActive: designation.isActive,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: context.read<StructureBloc>(),
                              child: DesignationDetailsScreen(
                                schoolId: schoolId,
                                designation: designation,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
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

class _RoleSummary extends StatelessWidget {
  const _RoleSummary({required this.designations, required this.staff});
  final List<StaffDesignation> designations;
  final List<UserEntity> staff;

  @override
  Widget build(BuildContext context) {
    final active = designations.where((role) => role.isActive).length;
    final custom = designations.where((role) => !role.isSystemPreset).length;
    final metrics = [
      ('Total roles', designations.length),
      ('Active', active),
      (
        'Assigned staff',
        staff.where((s) => s.designationId?.isNotEmpty ?? false).length,
      ),
      ('Custom', custom),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: metrics
            .map(
              (metric) => Expanded(
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 8,
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${metric.$2}',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          metric.$1,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

String _scopeName(String value) => value
    .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(1)}')
    .replaceFirstMapped(
      RegExp(r'^.'),
      (match) => match.group(0)!.toUpperCase(),
    );

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
